require 'spec_helper'

describe Pacproxy::PacFile do
  describe 'PacFile#find' do
    it 'returns proxyurl in pac file' do
      pac_file = Pacproxy::PacFile.new('spec/all_proxy.pac')
      expect(pac_file.find('http://sample.org/')).to eq('PROXY localhost:13081')
    end
    it 'returns DIRECT when no pac file' do
      pac_file = Pacproxy::PacFile.new('')
      expect(pac_file.find('http://sample.org/')).to eq('DIRECT')
    end
  end
  describe 'PacFile#update' do
    it 'has same pac file if no change' do
      pac_file = Pacproxy::PacFile.new('spec/all_proxy.pac', 0.01)
      expect(pac_file).to receive(:update).at_least(2).times

      first_pac  = pac_file.instance_variable_get(:@pac)
      sleep 0.2
      second_pac = pac_file.instance_variable_get(:@pac)
      expect(second_pac).to eq(first_pac)
    end
  end
end
