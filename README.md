## Deluge Web UI Library

[![Build Status](https://travis-ci.org/jSherz/deluge-json-ruby.svg)](https://travis-ci.org/jSherz/deluge-json-ruby) [![Coverage Status](https://coveralls.io/repos/jSherz/deluge-json-ruby/badge.svg)](https://coveralls.io/r/jSherz/deluge-json-ruby) [![Code Climate](https://codeclimate.com/github/jSherz/deluge-json-ruby/badges/gpa.svg)](https://codeclimate.com/github/jSherz/deluge-json-ruby)

This library interacts with the JSON based web ui calls to automate interaction with the `deluged` daemon.

### Usage

```ruby
gem install deluge

deluge = Deluge.new('http://my-deluge-host:1234/json')
deluge.login('password')
```

*NB:* Ensure you remember to add the '/json' to your hostname!

### Credits

Heavily based upon the [deluge-ruby](https://github.com/mikaelwikman/deluge-ruby) project by [Mikael Wikman](https://github.com/mikaelwikman). His project is an alternative that makes RPC calls on the daemon directly.
