# Pacproxy

Pacproxy provides http/https proxy routed with proxy.pac.

[![Build Status](https://travis-ci.org/otahi/pacproxy.png?branch=master)](https://travis-ci.org/otahi/pacproxy)
[![Coverage Status](https://coveralls.io/repos/otahi/pacproxy/badge.png?branch=master)](https://coveralls.io/r/otahi/pacproxy?branch=master)
[![Code Climate](https://codeclimate.com/github/otahi/pacproxy.png)](https://codeclimate.com/github/otahi/pacproxy)
[![Gem Version](https://badge.fury.io/rb/pacproxy.png)](http://badge.fury.io/rb/pacproxy)

**:warning:Now Pacproxy is very early stage, so it might have big change.**

## Installation

Add this line to your application's Gemfile, for example:

    gem 'pacproxy'
    gem 'therubyracer'

And then execute:

    $ bundle

## Requirements

After installing the `pacproxy` gem you must install a JavaScript runtime. Compatible runtimes include
(see [pac](https://github.com/samuelkadolph/ruby-pac/blob/master/README.md):

* [therubyracer](https://rubygems.org/gems/therubyracer) Google V8 embedded within Ruby
* [therubyrhino](https://rubygems.org/gems/therubyrhino/) Mozilla Rhino embedded within JRuby
* [johnson](https://rubygems.org/gems/johnson/) Mozilla SpiderMonkey embedded within Ruby 1.8
* [mustang](https://rubygems.org/gems/mustang/) Mustang V8 embedded within Ruby

## Usage

    $ bundle exec pacproxy -P proxy.pac -p 3128

or

    $ bundle exec pacproxy -P http://sample.org/proxy.pac -p 3128

## Contributing

1. Fork it ( https://github.com/otahi/pacproxy/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
