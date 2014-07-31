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

    def debug?
      general_logger.debug?
    end

    def info(message)
      general_logger.info(message)
    end

    def info?
      general_logger.info?
    end

    def lwarn(message)
      general_logger.warn(message)
    end

    def warn?
      general_logger.warn?
    end

    def error(message)
      general_logger.error(message)
    end

    def error?
      general_logger.error?
    end

    def fatal(message)
      general_logger.fatal(message)
    end

    def fatal?
      general_logger.fatal?
    end

    def accesslog(req, res)
      access_logger.accesslog(req, res)
    end
  end
end
