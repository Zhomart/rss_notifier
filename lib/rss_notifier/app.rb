require 'rss_notifier/adapter'

module RssNotifier
  class App

    PERIOD = 10 # seconds


    def initialize
    end

    def run
      loop do
        check_rss!
        sleep PERIOD
      end
    end

    def check_rss!
      puts "checking rss"
    end

  end
end
