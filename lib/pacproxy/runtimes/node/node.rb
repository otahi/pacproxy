require 'pacproxy'
require 'pacproxy/runtimes/base'

require 'open-uri'
require 'dnode'
require 'thread'
require 'os'

module Pacproxy
  module Runtimes
    # Pacproxy::Runtimes::Node represet node js runtime
    class Node < Base
      include Loggable

      TIMEOUT_JS_CALL = 0.5
      TIMEOUT_JS_SERVER = 5
      attr_reader :source

      def self.runtime
        if Util.which('node').nil?
          error('No PAC supported runtime')
          fail(RuntimeUnavailable,
               'No PAC supported runtime')
        end
        new
      end

      def initialize
        js = File.join(File.dirname(__FILE__), 'find.js')

        retries = 3
        begin
          Timeout.timeout(TIMEOUT_JS_SERVER) do
            server = TCPServer.new('127.0.0.1', 0)
            @port = server.addr[1]
            server.close
            if OS.windows?
              @server_pid = start_server
            else
              @server_pid = fork { exec('node', js, @port.to_s) }
              Process.detach(@server_pid)
            end
            sleep 0.01 until port_open?
          end
        rescue Timeout::Error
          shutdown
          if retries > 0
            retries -= 1
            lwarn('Timeout. Initialize Node.js server.')
            retry
          else
            error('Gave up to retry Initialize Node.js server.')
            raise 'Gave up to retry Initialize Node.js server.'
          end
        end
      end

      def shutdown
        if OS.windows?
          stop_server(@server_pid)
        else
          Process.kill(:INT, @server_pid)
        end
      end

      def update(file_location)
        @source = open(file_location, proxy: false).read
      rescue
        @source = nil
      end

      def find(url)
        return 'DIRECT' unless @source
        uri = URI.parse(url)
        call_find(uri)
      end

      private

      def port_open?
        Timeout.timeout(TIMEOUT_JS_CALL) do
          begin
            TCPSocket.new('127.0.0.1', @port).close
            return true
          rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
            return false
          end
        end
      rescue Timeout::Error
        false
      end

      def call_find(uri, retries = 3)
        proxy = nil
        begin
          thread = Thread.new do
            DNode.new.connect('127.0.0.1', @port) do |remote|
              remote.find(@source, uri, uri.host,
                          proc do |p|
                            proxy = p
                            EM.stop
                          end)
            end
          end
          thread.join(TIMEOUT_JS_CALL)
          proxy
        rescue Timeout::Error
          if retries > 0
            retries -= 1
            lwarn('Timeout. Retring call_find.')
            retry
          else
            error('Gave up Retry call_find.')
            nil
          end
        end
      end

      def rand_string
        (0...16).map { ('a'..'z').to_a[rand(26)] }.join
      end

      def start_server
        require 'win32/process'
        Process.create(
                       app_name:          Util.which('node'),
                       creation_flags:    Process::DETACHED_PROCESS
                       )
      end

      def stop_server(server_info)
        require 'win32/process'
        return unless server_info || server_info.respond_to?(:process_id)
        Process.kill('ExitProcess', [server_info.process_id])
      end
    end
  end
end
