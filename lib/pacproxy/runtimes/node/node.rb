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
        @socket = File.join(Dir.tmpdir, "pacproxy-#{rand_string}")

        @server_thread = Thread.new(@socket) do |s|
          begin
            js = File.join(File.dirname(__FILE__), 'find.js')

            if OS.windows?
              server = start_server
            else
              server = fork { exec "node #{js} #{s}" }
            end
          ensure
            if OS.windows?
              stop_server(server)
            else
              Process.kill(server)
            end
            File.delete(@socket)
          end
        end
        sleep 0.01 until File.exist?(@socket)
      end

      def shutdown
        @server_thread.kill
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

      def call_find(uri)
        proxy = nil
        DNode.new.connect(@socket) do |remote|
          remote.find(@source, uri, uri.host,
                      proc do |p|
                        proxy = p
                        EM.stop
                      end)
        end
        proxy
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
