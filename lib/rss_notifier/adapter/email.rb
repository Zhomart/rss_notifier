require 'http'
require 'erb'
require 'sendgrid-ruby'

module RssNotifier
  module Adapter
    class Email

      attr_reader :email

      HTML_TEMPLATE = File.expand_path('../email.html.erb', __FILE__)

      # @param email [String]
      # @param config [RssNotifier::Config]
      def initialize(email, config)
        @config = config
        @email = email
        @template = ERB.new(File.read(HTML_TEMPLATE))

        @config[:adapters][:email][:from] or
          raise 'config[:adapters][:email][:from] is not configured.'

        @config[:adapters][:email][:sendgrid_api_key] or
          raise 'config[:adapters][:email][:sendgrid_api_key] is not configured.'
      end

      def notify(item)
        b = binding
        b.local_variable_set(:item, item)
        html = @template.result(b)

        RssNotifier.logger.debug("Adapter::Email #{email}, #{html}")

        mail = SendGrid::Mail.new do |m|
          m.to = email
          m.from = @config[:adapters][:email][:from]
          m.subject = "#{item.feed.name} | #{item.title}"
          m.html = html
        end

        client = RssNotifier::Adapter::Email.client(@config[:adapters][:email][:sendgrid_api_key])

        begin
          res = client.send(mail)
          if res.code == 200
            RssNotifier.logger.debug("#{self} notified")
          else
            RssNotifier.logger.warn("Could not notify #{self}. Code=#{res.code}")
            p res.body
            return false
          end
        rescue => e
          puts e.to_s
          puts e.backtrace
          return false
        end

        true
      end

      def to_s
        "<Adapter::Email email=#{email}>"
      end

      def self.client(api_key)
        @clients ||= {}
        @clients[api_key] ||= SendGrid::Client.new(api_key: api_key)
      end

    end
  end
end
