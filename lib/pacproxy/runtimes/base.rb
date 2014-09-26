require 'pacproxy'

module Pacproxy
  module Runtimes
    # Pacproxy::Runtimes::Basee represet basic runtime
    class Base
      include Loggable

      attr_reader :source

      def self.runtime
      end

      def initialize
      end

      def shutdown
      end

      def update(_file_location)
      end

      def find(_url)
      end
    end
  end
end
