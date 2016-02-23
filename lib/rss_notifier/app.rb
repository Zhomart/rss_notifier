require 'rss_notifier/adapter'
require 'rss_notifier/config'
require 'rss_notifier/db'
require 'rss_notifier/item'

require 'pathname'
require 'rss'
require 'http'

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
      @notify = []
      @options = {
        notify: notify
      }

      setup_notify(@config.notify)
    end

    def setup_notify(notify)
      notify.each do |d|
        next unless d[:enabled]
        if d[:adapter] == 'email'
          @notify << Adapter::Email.new(d[:email])
        elsif d[:adapter] == 'pushbullet'
          @notify << Adapter::Pushbullet.new(d[:name], d[:access_token])
        else
          raise "Unknown adapter #{d[:adapter]}"
        end
      end
    end

    def run
      loop do
        check_rss!
        RssNotifier.logger.info "Waiting for #{@config.period_in_minutes} minutes"
        sleep @config.period_in_minutes * 60
      end
    end

    def check_rss!
      @config.rss_urls.each do |url_object|
        title, url = url_object[:title], url_object[:url]

        RssNotifier.logger.info "Checking #{title} | #{url}"

        raw = HTTP.get(url).to_s
        feed = nil
        begin
          raw = raw.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
          feed = RSS::Parser.parse(raw)
        rescue => e
          RssNotifier.logger.warn "Cannot parse RSS: #{e}"
          puts e.backtrace
          next
        end
        items = []
        feed.items.each do |item|
          items << Item.new({
            rss_url: url,
            rss_title: title,
            link: item.link,
            title: item.title,
            description: item.description,
            date: item.date
          })
        end
        @db.update(items)
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
          notify!(item)
        end
      end
    end

    def notify!(item)
      @notify.each do |notify|
        begin
          notify.notify(item)
        rescue => e
          puts "#{e}: #{item.link} | #{notify}"
          puts e.backtrace
        end
      end
    end

  end
end
