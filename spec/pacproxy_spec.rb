require 'spec_helper'
require 'httpclient'
require 'webrick/https'

def wait_server_status(servers, status)
  return unless servers || status
  servers = [servers] unless servers.respond_to?(:all?)
  return unless servers.all? { |s| s.respond_to?(:status) }
  sleep(0.01) until servers.all? { |s| s.status == status }
end

describe Pacproxy do
  describe 'Pacproxy::VERSION' do
    it 'have a version number' do
      expect(Pacproxy::VERSION).not_to be_nil
    end
  end

  describe 'Pacproxy#proxy_uri' do
    before(:each) do
      $stdout, $stderr = StringIO.new, StringIO.new
      @http_server = WEBrick::HTTPServer.new(Port: 13_080)
      @http_server.define_singleton_method(:service) do |_req, res|
        res.status = 200
      end

      @https_server = WEBrick::HTTPServer.new(Port: 13_443,
                                              SSLEnable: true,
                                              SSLCertName: [%w(CN 127.0.0.1)])
      @https_server.define_singleton_method(:service) do |_req, res|
        res.status = 200
      end

      @proxy_server = WEBrick::HTTPProxyServer.new(Port: 13_081)
      Thread.new { @http_server.start }
      Thread.new { @https_server.start }
      Thread.new { @proxy_server.start }
      wait_server_status([@http_server, @https_server, @proxy_server], :Running)
    end

    after(:each) do
      $stdout, $stderr = STDOUT, STDERR
      @http_server.shutdown
      @https_server.shutdown
      @proxy_server.shutdown
      @pacproxy_server.shutdown
      wait_server_status([@http_server,
                          @https_server,
                          @proxy_server,
                          @pacproxy_server],
                         :Stop)
    end

    it 'transfer request to server directly' do
      c = Pacproxy::Config.instance.config
      c['port'] = 13_128
      c['pac_file']['location'] = 'spec/all_direct.pac'
      @pacproxy_server = Pacproxy::Pacproxy.new(c)
      Thread.new { @pacproxy_server.start }
      wait_server_status(@pacproxy_server, :Running)

      c = HTTPClient.new('http://127.0.0.1:13128')
      res = c.get('http://127.0.0.1:13080/')
      expect(res.status).to eq(200)

      res = c.get('http://127.0.0.1:13080/noproxy/')
      expect(res.status).to eq(200)
    end

    it 'transfer request to server directly via HTTPS' do
      c = Pacproxy::Config.instance.config
      c['port'] = 13_128
      c['pac_file']['location'] = 'spec/all_direct.pac'
      @pacproxy_server = Pacproxy::Pacproxy.new(c)
      Thread.new { @pacproxy_server.start }
      wait_server_status(@pacproxy_server, :Running)

      c = HTTPClient.new('http://127.0.0.1:13128')
      c.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE
      res = c.get('https://127.0.0.1:13443/')
      expect(res.status).to eq(200)

      res = c.get('https://127.0.0.1:13443/noproxy/')
      expect(res.status).to eq(200)
    end

    it 'transfer request to server directly with PUT method' do
      c = Pacproxy::Config.instance.config
      c['port'] = 13_128
      c['pac_file']['location'] = 'spec/all_direct.pac'
      @pacproxy_server = Pacproxy::Pacproxy.new(c)
      Thread.new { @pacproxy_server.start }
      wait_server_status(@pacproxy_server, :Running)

      c = HTTPClient.new('http://127.0.0.1:13128')
      res = c.put('http://127.0.0.1:13080/')
      expect(res.status).to eq(200)

      res = c.put('http://127.0.0.1:13080/noproxy/')
      expect(res.status).to eq(200)
    end

    it 'transfer request to server via parent proxy' do
      c = Pacproxy::Config.instance.config
      c['port'] = 13_128
      c['pac_file']['location'] = 'spec/all_direct.pac'
      @pacproxy_server = Pacproxy::Pacproxy.new(c)
      Thread.new { @pacproxy_server.start }
      wait_server_status(@pacproxy_server, :Running)

      c = HTTPClient.new('http://127.0.0.1:13128')
      res = c.get('http://127.0.0.1:13080/')
      expect(res.status).to eq(200)

      res = c.get('http://127.0.0.1:13080/noproxy/')
      expect(res.status).to eq(200)
    end

    it 'transfer request to server via parent proxy partially' do
      c = Pacproxy::Config.instance.config
      c['port'] = 13_128
      c['pac_file']['location'] = 'spec/partial_proxy.pac'
      @pacproxy_server = Pacproxy::Pacproxy.new(c)
      Thread.new { @pacproxy_server.start }
      wait_server_status(@pacproxy_server, :Running)

      c = HTTPClient.new('http://127.0.0.1:13128')
      res = c.get('http://127.0.0.1:13080/')
      expect(res.status).to eq(200)

      res = c.get('http://127.0.0.1:13080/noproxy/')
      expect(res.status).to eq(200)
    end

    it 'transfer request with auth to server via parent proxy' do
      c = Pacproxy::Config.instance.config
      c['port'] = 13_128
      c['pac_file']['location'] = 'spec/all_proxy.pac'
      @pacproxy_server = Pacproxy::Pacproxy.new(c)

      Thread.new { @pacproxy_server.start }
      wait_server_status(@pacproxy_server, :Running)

      c = HTTPClient.new('http://127.0.0.1:13128')
      header = { header: { 'proxy-authorization' =>
          %Q(Basic #{['user01:pass01'].pack('m').delete("\n")})
        }
      }
      res = c.get('http://127.0.0.1:13080/', header)
      expect(res.status).to eq(200)
      res = c.get('http://127.0.0.1:13080/noproxy/', header)
      expect(res.status).to eq(200)
    end

    it 'respond 407 when upstrem proxy respond 407' do
      proxy_proc = proc do |_req, resp|
        resp.header.merge!('Proxy-Authenticate' => "Basic realm=\"proxy\"")
        fail WEBrick::HTTPStatus::ProxyAuthenticationRequired
      end

      pc = @proxy_server.instance_variable_get('@config')
      @proxy_server.instance_variable_set('@config',
                                          pc.merge(ProxyAuthProc: proxy_proc))
      c = Pacproxy::Config.instance.config
      c['port'] = 13_128
      c['pac_file']['location'] = 'spec/all_proxy.pac'
      @pacproxy_server = Pacproxy::Pacproxy.new(c)

      Thread.new { @pacproxy_server.start }
      wait_server_status(@pacproxy_server, :Running)

      c = HTTPClient.new('http://127.0.0.1:13128')
      res = c.get('http://127.0.0.1:13080/')
      expect(res.status).to eq(407)
      expect(res.header['Proxy-Authenticate']).to eq(["Basic realm=\"proxy\""])
    end
  end
end
