# RssNotifier

It checks given rss urls every given period and notifies you using [Pushbullet](https://www.pushbullet.com).


## Getting notifications

### Email

Create an account on https://sendgrid.com and generate API Key.

### Pushbullet

Create an account on https://www.pushbullet.com and generate Access Token.


## Usage

Install the gem

```
$ sudo apt-get install libgmp3-dev
$ yum install gmp-devel.x86_64

$ gem install rss_notifier
```

Then initialize it somewhere

```
$ mkdir ~/craigslist
$ cd ~/craigslist
$ rss_notifier init --force
```

Configure `config.yml`. Then start `rss_notifier` to load initial rss content
without notification. Only then start `rss_notifier` with notification.
Otherwise your email/pushbullet will be flooded.

```
$ rss_notifier start
  <CTRL-C>
$ rss_notifier start --notify
```

If you want it to run in the background, use `tmux`.


## Craigslist

1. Create a search url on craigslist, e.g. http://sfbay.craigslist.org/search/bik?query=trek+520
2. Make it RSS by clicking `RSS` on the bottom-right of the page, e.g. https://sfbay.craigslist.org/search/bik?format=rss&query=trek%20520
3. Install gem and initialize it.
4. Add RSS link to the `config.yml`.
5. Start `rss_notifier`.


## Development

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rss_notifier. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
