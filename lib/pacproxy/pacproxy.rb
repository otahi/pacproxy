require 'pacproxy'
require 'webrick/httpproxy'
require 'uri'

module Pacproxy
  class Pacproxy < WEBrick::HTTPProxyServer
    def initialize(config={}, default=WEBrick::Config::HTTP)
      super(config, default)
      @pac = PacFile.new(config[:Proxypac])
    end

    def proxy_uri(req, res)
      uri = super(req,res)
      return unless @pac

      request_uri = if 'CONNECT' == req.request_method
                      "https://#{req.header["host"][0]}/"
                    else
                      req.unparsed_uri
                    end

      proxy_line = @pac.find(request_uri)
      case proxy_line
      when /^DIRECT/
        uri = nil
      when /PROXY/
        primary_proxy = proxy_line.split(';')[0]
        proxy = /PROXY (.*)/.match(primary_proxy)[1]
        uri = URI.parse("http://#{proxy}")
      end
    end
  end
end
