## Deluge Web UI Library

This library interacts with the JSON based web ui calls to automate interaction with the `deluged` daemon.

### Usage

```ruby
gem install deluge

deluge = Deluge.new
deluge.login 'password'
```

### Credits

Heavily based upon the [deluge-ruby](https://github.com/mikaelwikman/deluge-ruby) project by [Mikael Wikman](https://github.com/mikaelwikman). His project is an alternative that makes RPC calls on the daemon directly.
