require 'rss_notifier/adapter'
require 'rss_notifier/config'
require 'rss_notifier/db'
require 'rss_notifier/models'

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
          @notify << Adapter::Email.new(d[:email], @config)
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

    # @return [Array] of tuples (url, name)
    def rss_urls_from_config
      @rss_urls_from_config ||= @config.rss_urls.map do |o|
        [ o[:url].to_s.strip, o[:name].to_s.strip ]
      end.to_h
    end

    def check_rss!
      changed_items = []

      rss_urls_from_config.each do |url, name|
        RssNotifier.logger.info "Checking #{name} | #{url}"

        feed = @db.get_feed(url: url, name: name)

        rss_raw = nil
        response = nil
        begin
          response = HTTP.get(url)
          # require 'pry'; binding.pry
          raw_encoded = response.to_s.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
          rss_raw = RSS::Parser.parse(raw_encoded)
        rescue => e
          RssNotifier.logger.warn "Cannot parse RSS: #{e}"
          puts e.backtrace
          next
        end
        rss_raw.items.each do |raw_item|
          item = feed.find_or_create_item(link: raw_item.link)
          item.update({
            title: raw_item.title,
            description: raw_item.description,
            date: raw_item.date
          })
          changed_items << item if item.changed?
        end

        feed.save
      end

      if changed_items.empty?
        RssNotifier.logger.info 'No changes'
        return
      end

      if options[:notify]
        RssNotifier.logger.info "#{changed_items.size} items changed, notifing..."

        changed_items.each do |item|
          notify!(item)
        end
      else
        RssNotifier.logger.info "#{changed_items.size} items changed"
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
