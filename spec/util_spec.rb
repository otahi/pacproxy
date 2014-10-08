require 'spec_helper'

describe Pacproxy::Util do
  describe 'Util#which' do
    it 'return "/bin/sh" when "sh" is given' do
      l = Pacproxy::Util.which('sh')
      expect(l).to eq('/bin/sh')
    end
    it 'return nil when "unknown command" is given' do
      l = Pacproxy::Util.which('unknown command')
      expect(l).to be_nil
    end
  end
end
