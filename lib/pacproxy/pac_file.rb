require 'pacproxy'
require 'pac'
require 'uri'

module Pacproxy
  # Pacproxy::PacFile represent proxy.pac file
  class PacFile
    include Loggable
    def initialize(file_location, update_interval = 1800)
      @pac = nil
      begin_update(file_location, update_interval)
    end

    def find(uri)
      return 'DIRECT' unless @pac
      @pac.find(uri)
    end

    private

    def begin_update(file_location, update_interval)
      is_updated = false
      Thread.new do
        loop do
          update(file_location)
          is_updated = true
          sleep(update_interval)
        end
      end
      sleep 0.01 until is_updated
    end

    def update(file_location)
      tmp = PAC.load(file_location)
      @pac = tmp if @pac.nil? || @pac.source != tmp.source
    rescue => e
      error("#{file_location} update error: #{e}")
    end
  end
end
