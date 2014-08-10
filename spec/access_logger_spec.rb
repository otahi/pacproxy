require 'spec_helper'

describe Pacproxy::AccessLogger do
  describe 'accesslog' do
    it 'write Apache common log format' do
      log = Pacproxy::AccessLogger.instance
      log.logger = ''
      now = Time.now
      now_string = now.strftime('[%d/%b/%Y:%H:%M:%S %Z]')

      req = double('req')
      allow(req).to receive(:attributes).and_return([])
      allow(req).to receive(:peeraddr).and_return(%w(host-a host-b host-c))
      allow(req).to receive(:port).and_return(80)
      allow(req).to receive(:query_string).and_return('query_string_test')
      allow(req).to receive(:request_line)
        .and_return(req_line = 'GET http://remotehost/abc HTTP/1.1')
      allow(req).to receive(:request_method).and_return('GET')
      allow(req).to receive(:request_time).and_return(now)
      allow(req).to receive(:unparsed_uri).and_return('http://remotehost/abc')
      allow(req).to receive(:user).and_return('user-a')

      res = double('req')
      allow(res).to receive(:filename).and_return('')
      allow(res).to receive(:sent_size).and_return(128)
      allow(res).to receive(:status).and_return(200)

      log.accesslog(req, res)
      expect(log.logger)
        .to eq("host-c - user-a #{now_string} \"#{req_line}\" 200 128\n")
    end
  end
end
