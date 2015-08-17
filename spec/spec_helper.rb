require 'coveralls'
Coveralls.wear!

require 'simplecov'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start do
  add_filter '.bundle/'
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'pacproxy'
require 'webrick'
require 'webrick/httpproxy'
