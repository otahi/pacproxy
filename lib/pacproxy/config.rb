require 'pacproxy'
require 'yaml'

module Pacproxy
  # Pacproxy::Config represent configuration for Pacproxy
  class Config
    attr_reader :daemonize
    attr_reader :port
    attr_reader :pac_file
    attr_reader :general_log
    attr_reader :access_log

    def initialize(yaml_file)
      config = read_config(yaml_file)
      config.each do |k, v|
        instance_variable_set("@#{k}", v)
      end if config
    end

    def read_config(yaml_file)
      return nil unless yaml_file
      return nil unless File.exist?(yaml_file)
      YAML.load(File.read(yaml_file))
    end
  end
end
