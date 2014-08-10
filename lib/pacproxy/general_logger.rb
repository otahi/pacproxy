require 'singleton'
require 'logger'

module Pacproxy
  # Provide log Function
  class GeneralLogger
    include Singleton

    attr_accessor :logger

    def initialize
      @logger = Logger.new('pacproxy.log', 7, 10 * 1024 * 1024)
      @logger.progname = 'pacproxy'
    end
  end
end
