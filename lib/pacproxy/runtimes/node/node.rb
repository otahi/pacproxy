require 'pacproxy'
require 'tempfile'
require 'open-uri'
require 'dnode'
require 'thread'

module Pacproxy
  module Runtime
    # Pacproxy::Runtime::Node represet node js runtime
    class Node
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

        Thread.new(@socket) do |s|
          begin
            js = File.join(File.dirname(__FILE__), 'find.js')
            server = fork { exec "node #{js} #{s}" }
          ensure
            Process.kill(server)
            File.delete(@socket)
          end
        end
        loop until File.exist?(@socket)
      end

      def load(file_location)
        @source = open(file_location, proxy: false).read
        self
      rescue
        @source = nil
        self
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
    end
  end
end
