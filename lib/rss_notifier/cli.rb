require 'thor'

module RssNotifier
  class Cli < Thor

    package_name 'RssNotifier'

    desc "init", "Initializes the app"
    method_options :force => :boolean, :notify => :boolean
    def init
      RssNotifier::App.init(force: options.force?)
    end

    desc "start", "starts the app"
    method_options :notify => :boolean
    def start
      unless options.notify?
        RssNotifier.logger.warn "Notifcation is disabled. To enable, run $ rss_notifier start --notify"
      end

      app = RssNotifier::App.new(notify: options.notify?)
      app.run
    end
  end
end
