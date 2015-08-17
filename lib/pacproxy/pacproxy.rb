require 'pacproxy'
require 'socket'
require 'uri'

module Pacproxy
  # Pacproxy::Pacproxy represent http/https proxy server
  class Pacproxy
    include Loggable

    attr_reader :status

    REQUEST_LINE_REGEXP =
      /^(?<method>\w+)\s+(?<unparsed_uri>\S+)\s+HTTP\/(?<version>\d\.\d)\s*$/
    BUFFER_SIZE = 1024 * 16

    def initialize(config = {})
      # TODO: Logger
      @status = :Stop
      @host = config['host']
      @port = config['port']
      @auth = config['auth']
      return unless config['pac_file'] && config['pac_file']['location']

      @pac = PacFile.new(config['pac_file']['location'],
                         config['pac_file']['update_interval'])
    end

    def start
      @socket = TCPServer.new(@host, @port)
      @status = :Running
      loop do
        s = @socket.accept
        Thread.new(s, &method(:handle_request))
      end
    ensure
      shutdown
    end

    def shutdown
      @socket.close if @socket
      @pac.shutdown if @pac
      @status = :Stop
    end

    private

    def handle_request(client_s)
      request_line = client_s.readline
      match_result = request_line.match(REQUEST_LINE_REGEXP)
      method       = match_result[:method]
      unparsed_uri = match_result[:unparsed_uri]
      version      = match_result[:version]

      proxy = if method == 'CONNECT'
                @pac.find("https://#{unparsed_uri}")
              else
                @pac.find(unparsed_uri)
              end
      # TODO: recover
      if method == 'CONNECT' && proxy == 'DIRECT'
        do_connect(client_s, method, unparsed_uri, version)
      else
        unparsed_uri = "https://#{unparsed_uri}" if method == 'CONNECT'
        do_request(client_s, method, unparsed_uri, version, proxy)
      end
    end

    def do_request(client_s, method, unparsed_uri, version, proxy)
      if proxy =~ /^proxy/i
        host, port = find_proxy_uri(proxy).split(':')
        port ||= 80
        server_s = TCPSocket.new(host, port)
        server_s.write("#{method} #{unparsed_uri} HTTP/#{version}\r\n")
        write_proxy_credential(server_s)
      else
        uri = URI.parse(unparsed_uri)
        # TODO: recover
        server_s = TCPSocket.new(uri.host, uri.port)
        server_s.write("#{method} #{uri.path}?#{uri.query} HTTP/#{version}\r\n")
      end

      # TODO: write log
      loop do
        line = client_s.readline
        if line =~ /^proxy/i && proxy == 'DIRECT'
          # Strip proxy headers
          next
        elsif line.strip.empty?
          server_s.write("Connection: close\r\n\r\n")
          break
        else
          server_s.write(line)
        end
      end

      transfer_data(client_s, server_s)
    ensure
      client_s.close
      server_s.close
    end

    def do_connect(client_s, _method, unparsed_uri, _version)
      uri = URI.parse("https://#{unparsed_uri}")
      # TODO: recover
      server_s = TCPSocket.new(uri.host, uri.port)
      client_s.read_nonblock(BUFFER_SIZE)
      client_s.write("HTTP/1.0 200 Connection Established\r\n\r\n")

      # TODO: write log
      transfer_data(client_s, server_s)
    ensure
      client_s.close
      server_s.close
    end

    def transfer_data(client_s, server_s)
      while (fds = IO.select([client_s, server_s]))
        if fds[0].member?(client_s)
          server_s.write(client_s.read_nonblock(BUFFER_SIZE))
        elsif fds[0].member?(server_s)
          client_s.write(server_s.read_nonblock(BUFFER_SIZE))
        end
      end
    end

    def write_proxy_credential(server_s)
      return unless @auth
      credentials = 'Basic ' +
        ["#{@auth['user']}:#{@auth['password']}"].pack('m').delete("\n")
      server_s.write('Proxy-authorization: ' + credentials + "\r\n")
    end

    def find_proxy_uri(proxy_line)
      case proxy_line
      when /^DIRECT/
        nil
      when /PROXY/
        primary_proxy = proxy_line.split(';')[0]
        /PROXY (.*)/.match(primary_proxy)[1]
      end
    end
  end
end
