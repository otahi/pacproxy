require 'pacproxy'
require 'webrick/httpproxy'
require 'uri'

module Pacproxy
  # Pacproxy::Pacproxy represent http/https proxy server
  class Pacproxy < WEBrick::HTTPProxyServer # rubocop:disable ClassLength
    include Loggable

    def initialize(config = {}, default = WEBrick::Config::HTTP)
      super({ Port: config['port'], Logger: general_logger }, default)
      return unless config['pac_file'] && config['pac_file']['location']

      @pac = PacFile.new(config['pac_file']['location'],
                         config['pac_file']['update_interval'])
    end

    def shutdown
      @pac.shutdown
      super
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

    # This method is mainly from WEBrick::HTTPProxyServer.
    # To allow upstream proxy authentication,
    # it operate 407 response from an upstream proxy.
    # see: https://github.com/ruby/ruby/blob/trunk/lib/webrick/httpproxy.rb
    # rubocop:disable all
    def do_CONNECT(req, res)
      # Proxy Authentication
      proxy_auth(req, res)

      ua = Thread.current[:WEBrickSocket]  # User-Agent
      raise WEBrick::HTTPStatus::InternalServerError,
        "[BUG] cannot get socket" unless ua

      host, port = req.unparsed_uri.split(":", 2)
      # Proxy authentication for upstream proxy server
      if proxy = proxy_uri(req, res)
        proxy_request_line = "CONNECT #{host}:#{port} HTTP/1.0"
        if proxy.userinfo
          credentials = "Basic " + [proxy.userinfo].pack("m").delete("\n")
        end
        host, port = proxy.host, proxy.port
      end

      begin
        @logger.debug("CONNECT: upstream proxy is `#{host}:#{port}'.")
        os = TCPSocket.new(host, port)     # origin server

        if proxy
          @logger.debug("CONNECT: sending a Request-Line")
          os << proxy_request_line << WEBrick::CRLF
          @logger.debug("CONNECT: > #{proxy_request_line}")
          if credentials
            @logger.debug("CONNECT: sending a credentials")
            os << "Proxy-Authorization: " << credentials << WEBrick::CRLF
          end
          os << WEBrick::CRLF
          proxy_status_line = os.gets(WEBrick::LF)
          @logger.debug("CONNECT: read a Status-Line form the upstream server")
          @logger.debug("CONNECT: < #{proxy_status_line}")
          if /^HTTP\/\d+\.\d+\s+(?<st>200|407)\s*/ =~ proxy_status_line
            res.status = st.to_i
            while line = os.gets(WEBrick::LF)
              res.header['Proxy-Authenticate'] =
                line.split(':')[1] if /Proxy-Authenticate/i =~ line
              break if /\A(#{WEBrick::CRLF}|#{WEBrick::LF})\z/om =~ line
            end
          else
            raise WEBrick::HTTPStatus::BadGateway
          end
        end
        @logger.debug("CONNECT #{host}:#{port}: succeeded")
      rescue => ex
        @logger.debug("CONNECT #{host}:#{port}: failed `#{ex.message}'")
        res.set_error(ex)
        raise WEBrick::HTTPStatus::EOFError
      ensure
        if handler = @config[:ProxyContentHandler]
          handler.call(req, res)
        end
        res.send_response(ua)
        access_log(@config, req, res)

        # Should clear request-line not to send the response twice.
        # see: HTTPServer#run
        req.parse(WEBrick::NullReader) rescue nil
      end

      begin
        while fds = IO::select([ua, os])
          if fds[0].member?(ua)
            buf = ua.sysread(1024);
            @logger.debug("CONNECT: #{buf.bytesize} byte from User-Agent")
            os.syswrite(buf)
          elsif fds[0].member?(os)
            buf = os.sysread(1024);
            @logger.debug("CONNECT: #{buf.bytesize} byte from #{host}:#{port}")
            ua.syswrite(buf)
          end
        end
      rescue
        os.close
        @logger.debug("CONNECT #{host}:#{port}: closed")
      end

      raise WEBrick::HTTPStatus::EOFError
    end
    # rubocop:enable all

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

    # This method is mainly from WEBrick::HTTPProxyServer.
    # proxy-authenticate can be transferred from a upstream proxy server
    # to a client
    # see: https://github.com/ruby/ruby/blob/trunk/lib/webrick/httpproxy.rb
    HOP_BY_HOP = %w( connection keep-alive upgrade
                     proxy-authorization te trailers transfer-encoding )
    SHOULD_NOT_TRANSFER = %w( set-cookie proxy-connection )
    def choose_header(src, dst)
      connections = split_field(src['connection'])
      src.each do |key, value|
        key = key.downcase
        next if HOP_BY_HOP.member?(key)        || # RFC2616: 13.5.1
          connections.member?(key)             || # RFC2616: 14.10
          SHOULD_NOT_TRANSFER.member?(key)        # pragmatics

        dst[key] = value
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
