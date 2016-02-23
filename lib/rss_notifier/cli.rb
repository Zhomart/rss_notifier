module RssNotifier
  class Cli

    def self.start
      app = RssNotifier::App.new
      app.run
    end
  end
end
