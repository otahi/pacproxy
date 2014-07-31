require 'singleton'
require 'logger'

module Pacproxy
  # Provide log Function
  class AccessLogger
    include Singleton

    attr_accessor :logger

    def initialize
      @logger = Logger.new('proxy_access.log', 7, 10 * 1024 * 1024)
    end
  end
end
