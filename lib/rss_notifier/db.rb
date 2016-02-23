require 'yaml/store'

module RssNotifier
  class Db

    attr_reader :store
    attr_accessor :items


    def initialize(store)
      # { item_url => Item, ... }
      @items = {}
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

    def self.load(filename)
      store = YAML::Store.new(filename)
      db = RssNotifier::Db.new(store)
      store.transaction do
        db.items = store['items'] || {}
      end
      db
    end

  end
end
