require 'pacproxy'
require 'webrick/httpproxy'
require 'uri'

module Pacproxy
  # Pacproxy::Pacproxy represent http/https proxy server
  class Pacproxy < WEBrick::HTTPProxyServer
    include Loggable

    def initialize(config = {}, default = WEBrick::Config::HTTP)
      config[:Logger] = general_logger
      super(config, default)
      @pac = PacFile.new(config[:Proxypac])
    end

    def proxy_uri(req, res)
      super(req, res)
      return unless @pac

      proxy_line = @pac.find(request_uri(req))
      proxy = lookup_proxy_uri(proxy_line)
      create_proxy_uri(proxy, req.header)
    end

    def create_proxy_uri(proxy, header)
      return nil unless proxy
      return URI.parse("http://#{proxy}") unless
        header.key?('proxy-authorization')

      auth = header['proxy-authorization'][0]
      pattern = /basic (\S+)/i
      basic_auth = pattern.match(auth)[1]
      header.delete('proxy-authorization')

      return URI.parse("http://#{proxy}") unless basic_auth

      URI.parse("http://#{basic_auth.unpack('m').first}@#{proxy}")
    end

    def proxy_auth(req, res)
      @config[:ProxyAuthProc].call(req, res) if @config[:ProxyAuthProc]
    end

    private

    def request_uri(request)
      if 'CONNECT' == request.request_method
        "https://#{request.unparsed_uri}/"
      else
        request.unparsed_uri
      end
    end

    def lookup_proxy_uri(proxy_line)
      case proxy_line
      when /^DIRECT/
        nil
      when /PROXY/
        primary_proxy = proxy_line.split(';')[0]
        /PROXY (.*)/.match(primary_proxy)[1]
      end
    end

    def perform_proxy_request(req, res)
      super
      accesslog(req, res)
    end

    # allow PUT method on proxy server
    # method names for webrick is indicated by rubocop
    # rubocop:disable all
    def do_PUT(req, res)
      perform_proxy_request(req, res) do |http, path, header|
        http.put(path, req.body || '', header)
      end
    end
    # rubocop:enable all
  end
end
