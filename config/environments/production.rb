MTGBazaar::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # CUSTOM OPTIONS -------------------------------------------------------------------------------------------------- #
  
  # this is needed for devise to work on heroku
  config.action_mailer.default_url_options = { :host => 'mtgbazaar.herokuapp.com' }
  
  # STANDARD OPTIONS -------------------------------------------------------------------------------------------------- #

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = true

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Setting compressor currently doesn't work (thx to @carhartl for the tip) https://github.com/rails/sass-rails/issues/104
  config.assets.css_compressor = :yui
  config.assets.js_compressor = :uglifier

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = true
  
  # add these files to be pre-compiled... for some reason they are missed?  This is needed to get CKEditor to work for Heroku
  config.assets.precompile += ['ckeditor/config.js', 'ckeditor/skins/kama/editor.css', 'ckeditor/lang/en.js']
  
  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store
  config.cache_store = :dalli_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )

  # Disable delivery errors, bad email addresses will be ignored
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.asset_host = "http://mtgbazaar.herokuapp.com"
  
  # Enable threaded mode
  config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify
  
  # Logging configuration for more verbose logs in heroku as per http://stackoverflow.com/questions/8031007/how-to-increase-heroku-log-drain-verbosity-to-include-all-rails-app-details
      STDOUT.sync = true
      logger = Logger.new(STDOUT)
      logger.level = 0 # Must be numeric here - 0 :debug, 1 :info, 2 :warn, 3 :error, and 4 :fatal
      # NOTE:   with 0 you're going to get all DB calls, etc.

      Rails.logger = Rails.application.config.logger = logger

      ### NOTE: Be sure to comment out these:
      #   See everything in the log (default is :info)
      #   config.log_level = :debug  # Commented out as per Chris' instructions from Heroku

      #   Use a different logger for distributed setups
      #   config.logger = SyslogLogger.new
  
end
