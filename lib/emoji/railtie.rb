require 'emoji'
require 'rails'

begin
  require 'sprockets'
  sprockets_available = true
rescue LoadError
  sprockets_available = false
end

module Emoji
  class Railtie < Rails::Railtie
    initializer "emoji.defaults" do
      Emoji.asset_host = ActionController::Base.asset_host
      if sprockets_available
        asset_prefix = Rails.application.config.assets.prefix rescue '/assets'
        Emoji.asset_path = File.join(asset_prefix, '/emoji')
      end
      Emoji.use_plaintext_alt_tags = false
    end

    rake_tasks do
      load File.absolute_path(File.dirname(__FILE__) + '/tasks/install.rake')
    end
  end
end
