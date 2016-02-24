require 'virtus'
require 'inflecto'
require 'json'

# {
#   rss_url => {
#     'Last-Modified' => 'blah',
#     'items' => { item_url => Item, ... },
#   }
# }
module RssNotifier
  module Models
    class Feed
      include Virtus.model(:finalize => false)

      attribute :url, String
      attribute :name, String
      attribute :items, Array['RssNotifier::Models::Item']

      # updated_at in DB
      attribute :updated_at, Time


      # @return [RssNotifier::Models::Item]
      def find_or_create_item(link:)
        item = items.detect { |i| i.link.to_s.strip == link.to_s.strip }
        unless item
          item = RssNotifier::Models::Item.new(feed_url: self.url, link: link)
          self.items << item
        end
        item
      end

      def store
        @store ||= RssNotifier::Db.default.store
      end

      def changed?
        !updated_at || items.any?(&:changed?)
      end

      def save
        items.each do |item|
          item.updated_at = Time.now
        end
        self.updated_at = Time.now

        store.transaction do
          store["feeds"] ||= {}
          store["feeds"][url] = self.to_db_object
        end
      end

      def to_db_object
        {
          'url' => url,
          'name' => name,
          'updated_at' => updated_at,
          'items' => items.map(&:to_db_object),
        }
      end

    end
  end
end
