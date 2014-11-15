# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pacproxy/version'

Gem::Specification.new do |spec|
  spec.name          = "pacproxy"
  spec.version       = Pacproxy::VERSION
  spec.authors       = ["OTA Hiroshi"]
  spec.email         = ["otahi.pub@gmail.com"]
  spec.summary       = %q{A proxy server works with proxy.pac}
  spec.description   = %q{A proxy server works with proxy.pac}
  spec.homepage      = "https://github.com/otahi/pacproxy"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'pac', '~> 1.0.0'
  spec.add_dependency 'dnode', '~> 0.0.2'
  spec.add_dependency 'os', '~> 0.9.6'
  if  /cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM
    spec.add_dependency 'win32-process', '~> 0.7.4'
  end

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rspec', '~> 3.0.0'
  spec.add_development_dependency 'rake', '~> 10.3.2'
  spec.add_development_dependency 'httpclient', '~> 2.4.0'
  spec.add_development_dependency 'therubyracer', '~> 0.12.1'

  spec.add_development_dependency 'rubocop', '0.24.1'
  spec.add_development_dependency 'coveralls', '~> 0.7'
  spec.add_development_dependency 'byebug', '~> 3.4.0'
end
