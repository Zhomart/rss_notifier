# RssNotifier

It checks given rss urls every given period and notifies you using [Pushbullet](https://www.pushbullet.com).


## Usage

Install the gem

```
    $ gem install rss_notifier
```

Then initialize it somewhere

```
  $ mkdir ~/craigslist
  $ cd ~/craigslist
  $ rss_notifier init --force
  $ vim config.yml
  $ rss_notifier start
    <CTRL-C> load initial rss content without notification.
  $ rss_notifier start --notify
```

If you want it to run in the background, use `tmux`.


## Development

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rss_notifier. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
