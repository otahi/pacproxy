require 'pacproxy'
require 'pac'

module Pacproxy
  class Pac_file
    def initialize(file_location)
      if file_location
        @pac_file = PAC.load(file_location)
      else
        #log
        @pac_file = nil
      end
    end

    def find(uri)
      return 'DIRECT' unless @pac_file
      @pac_file.find(uri)
    end
  end
end
