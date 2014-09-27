# Pacproxy [![Build Status](https://travis-ci.org/otahi/pacproxy.png?branch=master)](https://travis-ci.org/otahi/pacproxy)[![Coverage Status](https://coveralls.io/repos/otahi/pacproxy/badge.png?branch=master)](https://coveralls.io/r/otahi/pacproxy?branch=master)[![Code Climate](https://codeclimate.com/github/otahi/pacproxy.png)](https://codeclimate.com/github/otahi/pacproxy)[![Gem Version](https://badge.fury.io/rb/pacproxy.png)](http://badge.fury.io/rb/pacproxy)

Pacproxy provides an http/https proxy server which does proxy access according with a local/remote proxy.pac.
If your user agent is behind of the corporate proxy server and it does not recognize proxy.pac,
Proxypac transfers both your Internet and Intranet access correctly.

## Usage

You can run pacproxy with specified proxy.pac location, running port and so on.

    $ bundle exec pacproxy -P http://sample.org/proxy.pac -p 3128

or

    $ bundle exec pacproxy -P /opt/pacproxy/sample-proxy.pac -p 3128

or

    $ bundle exec pacproxy -c pacproxy.yml


## Configuration

You can configure pacproxy by a file which you specified with `-c` option.
The default configuration file is `pacproxy.yml`([sample](./pacproxy.yml))
in the current working directory.

Configurable items:
- daemonize
- port
- pac file
- general log
- access log 

## Installation
You can select Ruby javascript runtimes or Node.js

### With a Ruby javascript runtime
Puts these lines on Gemfile, for example:

    source 'https://rubygems.org'
    
    gem 'pacproxy'
    gem 'therubyracer'

And then execute:

    $ bundle

### With Node.js
Install node.js runtime before this installation.
Puts these lines on Gemfile, for example:

    source 'https://rubygems.org'
    
    gem 'pacproxy'

And then execute:

    $ bundle
    $ bundle exec pacproxy --npminstall

## Requirements

Before or After installing the `pacproxy` gem,
you need to install a JavaScript runtime.:

* [therubyracer](https://rubygems.org/gems/therubyracer) Google V8 embedded within Ruby
* [therubyrhino](https://rubygems.org/gems/therubyrhino/) Mozilla Rhino embedded within JRuby
* [johnson](https://rubygems.org/gems/johnson/) Mozilla SpiderMonkey embedded within Ruby 1.8
* [mustang](https://rubygems.org/gems/mustang/) Mustang V8 embedded within Ruby
* [Node.js](http://nodejs.org/) Node.js runtime

## Contributing

1. Fork it ( https://github.com/otahi/pacproxy/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
