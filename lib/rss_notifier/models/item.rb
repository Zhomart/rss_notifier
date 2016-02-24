require 'virtus'

module RssNotifier
  module Models
    class Item
      include Virtus.model

      attribute :link, String
      attribute :title, String
      attribute :description, String
      attribute :date, Time

      # updated_at in DB
      attribute :updated_at, Time

      attribute :feed_url, String


      def feed
        @feed ||= RssNotifier::Db.default.find_feed(url: feed_url)
      end

      def update(attributes)
        __title = self.title
        self.attributes = attributes
        @__changed = __title != self.title
      end

      def changed?
        new_record? || @__changed
      end

      def new_record?
        !self.updated_at
      end

      def to_h
        {
          feed_url: feed.url,
          feed_name: feed.name,
          link: link,
          title: title,
          description: description,
          date: date,
        }
      end

      def to_db_object
        {
          'link' => link,
          'title' => title,
          'description' => description,
          'date' => date,
          'updated_at' => updated_at,
          'feed_url' => feed_url,
        }
      end

    end
  end
end
