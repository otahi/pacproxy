require 'pacproxy'
require 'pacproxy/runtimes/node/node'
require 'pacproxy/runtimes/pac/pac'

module Pacproxy
  # Pacproxy::Runtime represet runtime
  class Runtime
    include Loggable

    def initialize
      @runtime = autodetect
    end

    def shutdown
      @runtime.shutdown
    end

    def find(url)
      @runtime.find(url)
    end

    def update(file_location)
      @runtime.update(file_location)
    end

    private

    def autodetect
      return Runtimes::Pac.runtime  if Runtimes::Pac.runtime
      return Runtimes::Node.runtime if Runtimes::Node.runtime

      fail(RuntimeUnavailable,
           'No runtime supporting proxy.pac')
    end
  end
end
