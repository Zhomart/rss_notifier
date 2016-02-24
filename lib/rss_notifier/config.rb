require 'ostruct'
require 'yaml'

module RssNotifier
  class Config < OpenStruct

    DEFAULTS = {
      adapters: {
        email: {
          mailgun_api: 'something',
          from: 'Excited User <mailgun@YOUR_DOMAIN_NAME>'
        }
      },
      notify: [
        { email: 'me@example.com', adapter: 'email', enabled: false },
        { name: 'mini me', access_token: '<get from pushbullet.com/#settings>', adapter: 'pushbullet', enabled: false },
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
