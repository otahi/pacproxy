require 'pacproxy/general_logger'
require 'pacproxy/access_logger'

module Pacproxy
  # Provide log Function
  module Loggable
    def general_logger
      GeneralLogger.instance.logger
    end

    def access_logger
      AccessLogger.instance
    end

    def debug(message)
      general_logger.debug(message)
    end

    def info(message)
      general_logger.info(message)
    end

    def lwarn(message)
      general_logger.warn(message)
    end

    def error(message)
      general_logger.error(message)
    end

    def fatal(message)
      general_logger.fatal(message)
    end

    def accesslog(req, res)
      access_logger.accesslog(req, res)
    end
  end
end
