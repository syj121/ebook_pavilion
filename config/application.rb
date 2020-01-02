require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module EbookPavilion
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    
    #国际化
    config.i18n.locale = 'zh-CN'
    config.i18n.default_locale = 'zh-CN'
    config.encoding = "utf-8"

    #时区
    config.time_zone = 'Beijing'
    config.active_record.default_timezone = :local

    #添加路径
    config.autoload_paths += Dir[Rails.root.join('app', 'models', '{**/}')]
  end
end
