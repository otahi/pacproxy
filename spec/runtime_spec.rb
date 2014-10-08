require 'spec_helper'

describe Pacproxy::Runtime do

  after(:each) do
    @runtime.shutdown
  end

  describe 'Runtime#new' do
    it 'returns Pacproxy::Runtime' do
      @runtime = Pacproxy::Runtime.new
      expect(@runtime).to be_kind_of(Pacproxy::Runtime)
    end
  end
end
