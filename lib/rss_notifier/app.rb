require 'rss_notifier/adapter'
require 'rss_notifier/config'
require 'rss_notifier/db'

require 'pathname'
require 'rss'
require 'http'

require 'pry'

module RssNotifier
  class App

    CONFIG_DIR = Pathname.new('.')
    CONFIG_FILE = CONFIG_DIR.join('config.yml')
    DB_FILE = CONFIG_DIR.join('db.yml')


    attr_reader :options


    def self.init(force: false)
      if !Dir.exists?(CONFIG_DIR.to_s) || force
        RssNotifier.logger.info("Creating #{CONFIG_DIR}")
        FileUtils.mkdir_p(CONFIG_DIR.to_s)
      else
        RssNotifier.logger.info("Directory #{CONFIG_DIR} already exists, skipping")
      end

      if !File.exists?(CONFIG_FILE) || force
        RssNotifier.logger.info("Creating #{CONFIG_FILE}")
        config = RssNotifier::Config.default
        config.save_to(CONFIG_FILE)
      else
        RssNotifier.logger.info("File #{CONFIG_FILE} already exists, skipping")
      end
    end

    def initialize(notify: false)
      @config = RssNotifier::Config.load(CONFIG_FILE)
      @db = RssNotifier::Db.load(DB_FILE)

      @options = {
        notify: notify
      }
    end

    def run
      loop do
        check_rss!
        sleep @config.period_in_minutes * 60
      end
    end

    def check_rss!
      RssNotifier.logger.info "Checking #{@config.rss_urls.size} urls"

      @config.rss_urls.each do |url_object|
        title, url = url_object[:title], url_object[:url]
        raw = HTTP.get(url).to_s
        feed = RSS::Parser.parse(raw)
        items = []
        feed.items.each do |item|
          items << {
            'url' => item.link,
            'title' => item.title,
            'date' => item.date,
          }
        end
        @db.update(url, items)
      end
      changed_items = @db.changed_items
      is_changed = @db.changed?
      @db.save

      unless is_changed
        RssNotifier.logger.info 'No changes'
        return
      end

      if options[:notify]
        RssNotifier.logger.info "#{changed_items.size} items changed, notifing..."

        changed_items.each do |item|
          notify!(item['url'], item['title'], item['date'])
        end
      end
    end

    def notify!(item_url, title, date)
      puts 'asd'
    end

  end
end
