## Deluge Web UI Library

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
