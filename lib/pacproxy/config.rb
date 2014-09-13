require 'pacproxy'
require 'yaml'

module Pacproxy
  # Pacproxy::Config represent configuration for Pacproxy
  class Config
    include Singleton
    DEFAULT_CONFIG = {
      'daemonize' => false,
      'port' => 3128,
      'pac_file' => { 'location' => nil },
      'general_log' => { 'location' => 'pacproxy.log' }
    }

    attr_reader :config

    def initialize
      @config = DEFAULT_CONFIG
      self
    end

    def update(yaml_file = 'pacproxy.yml')
      @config.merge!(read_config(yaml_file))
      self
    end

    def read_config(yaml_file)
      return {} unless yaml_file
      return {} unless File.exist?(yaml_file)
      YAML.load(File.read(yaml_file))
    end
  end
end
