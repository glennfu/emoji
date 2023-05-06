require 'emoji'
require 'rails'

module Emoji
  class Railtie < Rails::Railtie
    def sprockets_available?
      defined?(Rails.application.config.assets) && Rails.application.config.assets.is_a?(Sprockets::Railtie::Configuration)
    end

    initializer "emoji.defaults" do
      Emoji.asset_host = ActionController::Base.asset_host
      asset_prefix = sprockets_available? ? Rails.application.config.assets.prefix : '/assets'
      Emoji.asset_path = File.join(asset_prefix, '/emoji')
      Emoji.use_plaintext_alt_tags = false
    end

    rake_tasks do
      load File.absolute_path(File.dirname(__FILE__) + '/tasks/install.rake')
    end
  end
end
