require 'pacproxy'
require 'open-uri'

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

      def load(file_location)
        # TODO: delete file_location to replace
        @file_location = file_location
        @source = open(file_location, proxy: false).read
        self
      rescue
        @source = nil
        self
      end

      def find(url)
        return 'DIRECT' unless @source
        uri = URI.parse(url)
        js = File.join(File.dirname(__FILE__), 'FindProxyUrl.js')
        `node #{js} "#{@file_location}" #{uri} #{uri.host}`.chomp
      end
    end
  end
end
