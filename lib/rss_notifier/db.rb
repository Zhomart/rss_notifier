require 'yaml/store'

module RssNotifier
  class Db

    attr_reader :store
    attr_accessor :db


    def initialize(store)
      # { 'url' => { 'url' => { 'saved_at', 'date', 'title' } }, ... }
      @db = {}
      @store = store
    end

    # @param url [String]
    # @param items [Array] { 'date', 'url', 'title' }
    # @return [Boolean] changed?
    def update(url, items)
      local_items = (@db[url] ||= {})
      items.each do |it|
        item = it.dup
        item_url = item.delete('url')
        if !item_url || item_url.empty?
          RssNotifier.logger.warn "Empty item_url for url #{url}"
          next
        end
        old_item = local_items[item_url] || {}
        item['saved_at'] = old_item['saved_at']
        local_items[item_url] = item
      end
      changed?
    end

    def changed?
      0 < changed_items.size
    end

    # @return [Array] { 'url', 'title', 'date', 'saved_at' }
    def changed_items
      ch_items = []
      @db.each do |url, items|
        items.each do |item_url, item|
          if !item['saved_at'] || item['saved_at'] < item['date']
            ch_items << {
              'url' => item_url,
              'title' => item['title'],
              'date' => item['date'],
              'saved_at' => item['saved_at'],
            }
          end
        end
      end
      ch_items
    end

    def save
      return true unless changed?

      @db.each do |url, items|
        items.each do |item_url, item|
          item['saved_at'] = Time.now
        end
      end
      store.transaction do
        store['db'] = @db
      end
      true
    end

    def self.load(filename)
      store = YAML::Store.new(filename)
      db = RssNotifier::Db.new(store)
      store.transaction do
        db.db = store['db'] || {}
      end
      db
    end

  end
end
