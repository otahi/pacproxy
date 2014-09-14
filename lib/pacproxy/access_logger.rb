require 'singleton'
require 'logger'
require 'webrick/accesslog'

module Pacproxy
  # Provide log Function
  class AccessLogger
    include Singleton

    attr_accessor :logger

    def initialize
      c = Config.instance.config['access_log']
      @format = WEBrick::AccessLog::COMMON_LOG_FORMAT
      return @logger = nil unless c

      @format = c['format'] if c['format']

      location = c['location'] ? c['location'] : STDOUT
      shift_age = c['shift_age'] ? c['shift_age'] : 0
      shift_size = c['shift_size'] ? c['shift_size'] : 1_048_576
      @logger = Logger.new(location, shift_age, shift_size)
    end

    def accesslog(req, res)
      params = setup_params(req, res)
      return unless @logger
      @logger << WEBrick::AccessLog.format(@format, params)
      @logger << "\n"
    end

    private

    # This format specification is a subset of mod_log_config of Apache:
    # See: https://github.com/ruby/ruby/blob/trunk/lib/webrick/accesslog.rb

    def setup_params(req, res)
      WEBrick::AccessLog.setup_params({ ServerName: '-' }, req, res)
    end
  end
end
