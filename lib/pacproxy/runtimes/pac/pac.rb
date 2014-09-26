require 'pacproxy'
require 'pacproxy/runtimes/base'

require 'open-uri'
require 'thread'

module Pacproxy
  module Runtimes
    # Pacproxy::Runtimes::Pac represent Pac
    class Pac < Base
      include Loggable

      attr_reader :source

      @js_lock = Mutex.new
      class << self
        attr_reader :js_lock
      end

      def self.runtime
        PAC.runtime
        new
      end

      def find(url)
        return 'DIRECT' unless @pac
        Pac.js_lock.synchronize do
          @pac.find(url)
        end
      end

      def update(file_location)
        tmp = PAC.load(file_location)
        @pac = tmp if @pac.nil? || @pac.source != tmp.source
      rescue => e
        error("#{file_location} update error: #{e}")
      end
    end
  end
end
