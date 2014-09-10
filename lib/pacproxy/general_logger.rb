require 'singleton'
require 'logger'

module Pacproxy
  # Provide log Function
  class GeneralLogger
    include Singleton

    attr_accessor :logger

    def initialize
      c = Config.instance.config['general_log']
      return @logger = nil unless c

      location = c['location'] ? c['location'] : STDOUT
      shift_age = c['shift_age'] ? c['shift_age'] : 0
      shift_size = c['shift_size'] ? c['shift_size'] : 1_048_576
      @logger = Logger.new(location, shift_age, shift_size)
      @logger.level = c['log_level'] ? Logger.const_get(c['log_level']) : Logger::ERROR
      @logger.progname = 'pacproxy'
    end
  end
end
