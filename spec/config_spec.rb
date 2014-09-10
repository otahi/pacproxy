require 'spec_helper'

describe Pacproxy::Config do
  it 'store values from specified yaml file' do
    c = Pacproxy::Config.instance.update('pacproxy.yml')

    expect(c.config['daemonize']).to eq(true)
    expect(c.config['port']).to eq(3128)
    expect(c.config['pac_file']['location']).to eq('proxy.pac')
    expect(c.config['general_log']['location']).to eq('pacproxy.log')
    expect(c.config['access_log']['log_rotate']['shift_age']).to eq(7)
  end
end
