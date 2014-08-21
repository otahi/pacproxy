require 'spec_helper'

describe Pacproxy::Config do
  it 'store values from specified yaml file' do
    config = Pacproxy::Config.new('pacproxy.yml')

    expect(config.daemonize).to eq(true)
    expect(config.port).to eq(3128)
    expect(config.pac_file['location']).to eq('proxy.pac')
    expect(config.general_log['location']).to eq('pacproxy.log')
    expect(config.access_log['log_rotate']['shift_age']).to eq(7)
  end
end
