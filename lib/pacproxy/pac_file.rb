require 'pacproxy'
require 'pac'
require 'uri'
require 'thread'

module Pacproxy
  # Pacproxy::PacFile represent proxy.pac file
  class PacFile
    include Loggable

    def initialize(file_location, update_interval = 1800)
      @file_location = file_location
      @update_interval = update_interval
      @runtime = Runtime.new
      begin_update
    end

    def shutdown
      @runtime.shutdown
    end

    def find(uri)
      return 'DIRECT' unless @runtime
      @runtime.find(uri)
    end

    private

    def begin_update
      is_updated = false
      Thread.new do
        loop do
          @runtime.update(@file_location)
          is_updated = true
          sleep(@update_interval)
        end
      end
      sleep 0.01 until is_updated
    end
  end
end
