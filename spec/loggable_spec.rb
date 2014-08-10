require 'spec_helper'

describe Pacproxy::GeneralLogger do

  # Loggable class example
  class LoggableExample
    include Pacproxy::Loggable
  end

  before(:each) do
    log = StringIO.new
    @logger = Logger.new(log)
    @logger.level = Logger::DEBUG
    Pacproxy::GeneralLogger.instance.logger = @logger
    @loggable =  LoggableExample.new
  end

  describe '#debug' do
    it 'write debug log' do
      message = 'DEBUG LOG'
      expect(@logger).to receive(:debug).with(message)
      @loggable.debug(message)
    end
  end
  describe '#info' do
    it 'write info log' do
      message = 'INFO LOG'
      expect(@logger).to receive(:info).with(message)
      @loggable.info(message)
    end
  end
  describe '#lwarn' do
    it 'write warn log' do
      message = 'WARN LOG'
      expect(@logger).to receive(:warn).with(message)
      @loggable.lwarn(message)
    end
  end
  describe '#error' do
    it 'write error log' do
      message = 'ERROR LOG'
      expect(@logger).to receive(:error).with(message)
      @loggable.error(message)
    end
  end
  describe '#fatal' do
    it 'write fatal log' do
      message = 'FATAL LOG'
      expect(@logger).to receive(:fatal).with(message)
      @loggable.fatal(message)
    end
  end
end
