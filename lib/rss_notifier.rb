require "rss_notifier/version"
require 'rss_notifier/cli'
require 'rss_notifier/app'

require 'logger'


module RssNotifier

  def self.logger
    @logger ||= ::Logger.new(STDOUT)
  end

end
