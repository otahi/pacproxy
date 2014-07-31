require 'singleton'
require 'logger'

module Pacproxy
  # Provide log Function
  class AccessLogger
    include Singleton

    attr_accessor :logger

    def initialize
      @logger = Logger.new('proxy_access.log', 7, 10 * 1024 * 1024)
      @format = ''
    end

    def accesslog(req, res)
      # TODO: impl
      params = setup_params(req, res)
      logger << format(@format, params)
    end

    private

    def setup_params(req, res)
      params = Hash.new('')
      params[:a] = req
      params[:b] = res
      params
    end
  end
end
