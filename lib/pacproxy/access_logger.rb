require 'singleton'
require 'logger'
require 'webrick/accesslog'

module Pacproxy
  # Provide log Function
  class AccessLogger
    include Singleton

    attr_accessor :logger

    def initialize
      @logger = Logger.new('proxy_access.log', 7, 10 * 1024 * 1024)
      @format = WEBrick::AccessLog::COMMON_LOG_FORMAT
    end

    def accesslog(req, res)
      params = setup_params(req, res)
      logger << WEBrick::AccessLog.format(@format, params)
      logger << "\n"
    end

    private

    # This format specification is a subset of mod_log_config of Apache:
    # See: https://github.com/ruby/ruby/blob/trunk/lib/webrick/accesslog.rb

    def setup_params(req, res)
      WEBrick::AccessLog.setup_params({ ServerName: '-' }, req, res)
    end
  end
end
