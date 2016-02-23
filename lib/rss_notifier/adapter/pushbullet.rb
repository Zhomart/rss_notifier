require 'http'
require 'oj'

module RssNotifier
  module Adapter
    class Pushbullet

      attr_reader :name
      attr_reader :access_token

      def initialize(name, access_token)
        @name = name
        @access_token = access_token
      end

      def notify(item)
        body = Oj.dump({
          'type' => 'link',
          'title' => "#{item.rss_title}",
          'body' => item.title,
          'url' => item.link
        })

        RssNotifier.logger.debug("Adapter::Pushbullet #{name}, #{body}")

        response = HTTP.timeout(:per_operation, write: 5, connect: 7, read: 5)
          .headers(
            'Access-Token' => access_token,
            'Content-Type' => 'application/json'
          )
          .post('https://api.pushbullet.com/v2/pushes', body: body)

        if response.code != 200
          RssNotifier.logger.warn("Could not notify #{self}. Code=#{response.code}")
          false
        else
          RssNotifier.logger.debug("#{self} notified")
          true
        end
      end

      def to_s
        "<Adapter::Pushbullet #{name}>"
      end

    end
  end
end
