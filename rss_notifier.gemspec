# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rss_notifier/version'

Gem::Specification.new do |spec|
  spec.name          = "rss_notifier"
  spec.version       = RssNotifier::VERSION
  spec.authors       = ["Zhomart Mukhamejanov"]
  spec.email         = ["mzhomart@gmail.com"]

  spec.summary       = %q{RSS Notification}
  spec.description   = %q{Notifies RSS updates via Pushbullet and Email}
  spec.homepage      = "https://github.com/Zhomart/rss_notifier"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r[^bin/]).map { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'http', '~> 1.0'
  spec.add_dependency 'thor', '~> 0.19'
  spec.add_dependency 'virtus', '~> 1.0'
  spec.add_dependency 'inflecto'
  spec.add_dependency 'sendgrid-ruby'

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "pry", '~> 0.10'
end
