require "rss_notifier/version"
require 'rss_notifier/cli'
require 'rss_notifier/app'

require 'logger'


module RssNotifier

  def self.logger
    @logger ||= begin
      l = ::Logger.new(STDOUT)
      l.level = ::Logger::INFO
      l
    end
  end

end
