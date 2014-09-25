require 'pacproxy'
require 'pac'
require 'uri'
require 'thread'

module Pacproxy
  # Pacproxy::PacFile represent proxy.pac file
  class PacFile
    include Loggable

    @js_lock = Mutex.new
    class << self
      attr_reader :js_lock
    end

    def initialize(file_location, update_interval = 1800)
      @pac = nil
      @file_location = file_location
      @update_interval = update_interval
      @runtime = autodetect
      begin_update
    end

    def find(uri)
      return 'DIRECT' unless @pac
      PacFile.js_lock.synchronize do
        @pac.find(uri)
      end
    end

    private

    def autodetect
      PAC if PAC.runtime
    rescue
      Runtime::Node.runtime
    end

    def begin_update
      is_updated = false
      Thread.new do
        loop do
          update
          is_updated = true
          sleep(@update_interval)
        end
      end
      sleep 0.01 until is_updated
    end

    def update
      tmp = autodetect.load(@file_location)
      @pac = tmp if @pac.nil? || @pac.source != tmp.source
    rescue => e
      error("#{@file_location} update error: #{e}")
    end
  end
end
