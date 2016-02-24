require 'yaml/store'

require 'rss_notifier/models'

module RssNotifier
  class Db

    attr_reader :store
    attr_accessor :feeds


    def initialize(store)
      @feeds = {}
      @store = store
    end

    # @param url [String]
    # @param items [Array] of Item
    # @return [Boolean] changed?
    def update(new_items)
      new_items.each do |item|
        if !item.link || item.link.empty?
          RssNotifier.logger.warn "Empty item_url for url #{item.link}"
          next
        end

        old_item = self.items[item.link] ||= Item.new
        old_item.update(item.to_h)
      end
      changed?
    end

    def changed?
      0 < changed_items.size
    end

    # @return [Array] of Item
    def changed_items
      ch_items = []
      @items.each do |url, item|
        if item.new_record? || item.changed?
          ch_items << item
        end
      end
      ch_items
    end

    def save
      return true unless changed?

      @items.each do |url, item|
        item.saved_at = Time.now
      end
      store.transaction do
        store['items'] = @items
      end
      true
    end

    # @return [RssNotifier::Models::Feed] creates new Feed if not found
    def get_feed(url:, name:)
      @feeds[url] ||= RssNotifier::Models::Feed.new(url: url.to_s.strip, name: name)
    end

    # @return [RssNotifier::Models::Feed]
    def find_feed(url:)
      @feeds[url.to_s.strip]
    end

    def load
      @feeds = {}
      store.transaction do
        feeds_raw = store['feeds'] || {}
        feeds_raw.each do |url, feed_raw|
          feed = RssNotifier::Models::Feed.new(feed_raw)
          @feeds[feed.url] = feed
        end
      end
      self
    end

    # @return [RssNotifier::Db]
    def self.default
      @default or raise "Not initialized"
    end

    def self.default=(default)
      @default = default
    end

    def self.load(filename)
      store = YAML::Store.new(filename)
      RssNotifier::Db.default = RssNotifier::Db.new(store)
      RssNotifier::Db.default.load
      RssNotifier::Db.default
    end

  end
end
