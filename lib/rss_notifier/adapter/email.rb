require 'http'
require 'erb'

module RssNotifier
  module Adapter
    class Email

      attr_reader :email

      HTML_TEMPLATE = File.expand_path('../email.html.erb', __FILE__)

      # curl -s --user 'api:YOUR_API_KEY' \
      #     https://api.mailgun.net/v3/YOUR_DOMAIN_NAME/messages \
      #     -F from='Excited User <mailgun@YOUR_DOMAIN_NAME>' \
      #     -F to=YOU@YOUR_DOMAIN_NAME \
      #     -F to=bar@example.com \
      #     -F subject='Hello' \
      #     -F text='Testing some Mailgun awesomness!'

      def initialize(email)
        @email = email
        @template = ERB.new(File.read(HTML_TEMPLATE))
      end

      def notify(item)
        b = binding
        b.local_variable_set(:item, item)
        html = @template.result(b)
        puts "-------"
      end

      def to_s
        "<Adapter::Email email=#{email}>"
      end

    end
  end
end
