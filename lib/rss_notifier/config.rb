require 'ostruct'
require 'yaml'

module RssNotifier
  class Config < OpenStruct

    DEFAULTS = {
      adapters: {
        email: {
          sendgrid_api_key: '<Get it from sendgrid.com>',
          from: 'RSS Notifier <rss-notifier@joma.pw>',
        }
      },
      notify: [
        { email: 'me@example.com', adapter: 'email', enabled: false },
        { name: 'mini me', access_token: '<Get it from pushbullet.com>', adapter: 'pushbullet', enabled: false },
      ],
      rss_urls: [
        { name: 'Some News', url: 'http://some-site.com/rss' }
      ],
      period_in_minutes: 20
    }

    def self.load(filename)
      c = YAML.load(File.read(filename))
      RssNotifier::Config.new(DEFAULTS.dup.merge(c['rss_notifier'] || c[:rss_notifier]))
    end

    def self.default
      RssNotifier::Config.new(DEFAULTS)
    end

    def save_to(filename)
      File.open(filename, 'w') do |f|
        f.write(YAML.dump({ rss_notifier: self.to_h }))
      end
    end

  end
end
