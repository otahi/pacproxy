require 'spec_helper'
require 'httpclient'

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
      @http_server.mount_proc('/') { |_req, res| res.status = 200 }
      @http_server.mount_proc('/noproxy/') { |_req, res| res.status = 200 }
      @proxy_server = WEBrick::HTTPProxyServer.new(Port: 13_081)
      Thread.new { @http_server.start }
      Thread.new { @proxy_server.start }
      wait_server_status([@http_server, @proxy_server], :Running)
    end

    after(:each) do
      $stdout, $stderr = STDOUT, STDERR
      @http_server.shutdown
      @proxy_server.shutdown
      @pacproxy_server.shutdown
      wait_server_status([@http_server, @proxy_server, @pacproxy_server], :Stop)
    end

    it 'transfer request to server directly' do
      @pacproxy_server =
        Pacproxy::Pacproxy.new(Port: 13_128,
                               Proxypac: 'spec/all_direct.pac')
      Thread.new { @pacproxy_server.start }
      wait_server_status(@pacproxy_server, :Running)

      c = HTTPClient.new('http://127.0.0.1:13128')
      res = c.get('http://127.0.0.1:13080/')
      expect(res.status).to eq(200)

      res = c.get('http://127.0.0.1:13080/noproxy/')
      expect(res.status).to eq(200)
    end

    it 'transfer request to server via parent proxy' do
      @pacproxy_server =
        Pacproxy::Pacproxy.new(Port: 13_128,
                               Proxypac: 'spec/all_proxy.pac')
      Thread.new { @pacproxy_server.start }
      wait_server_status(@pacproxy_server, :Running)

      c = HTTPClient.new('http://127.0.0.1:13128')
      res = c.get('http://127.0.0.1:13080/')
      expect(res.status).to eq(200)

      res = c.get('http://127.0.0.1:13080/noproxy/')
      expect(res.status).to eq(200)
    end

    it 'transfer request to server via parent proxy partially' do
      @pacproxy_server =
        Pacproxy::Pacproxy.new(Port: 13_128,
                               Proxypac: 'spec/partial_proxy.pac')
      Thread.new { @pacproxy_server.start }
      wait_server_status(@pacproxy_server, :Running)

      c = HTTPClient.new('http://127.0.0.1:13128')
      res = c.get('http://127.0.0.1:13080/')
      expect(res.status).to eq(200)

      res = c.get('http://127.0.0.1:13080/noproxy/')
      expect(res.status).to eq(200)
    end
  end
end
