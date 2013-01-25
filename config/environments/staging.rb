MTGBazaar::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # CUSTOM OPTIONS -------------------------------------------------------------------------------------------------- #
  
  # this is needed for devise to work on heroku
  config.action_mailer.default_url_options = { :host => 'mtgbazaar-staging.herokuapp.com' }
  
  # STANDARD OPTIONS -------------------------------------------------------------------------------------------------- #

  # Serving static assets and setting cache headers 
  # which will be used by cloudfront as well
  config.static_cache_control = "public, max-age=11536000"

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Setting compressor currently doesn't work (thx to @carhartl for the tip) https://github.com/rails/sass-rails/issues/104
  # config.assets.css_compressor = :yui
  # config.assets.js_compressor = :uglifier

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false
  
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
  config.action_controller.perform_caching = true

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # Serve Assets from S3
  # config.action_controller.asset_host = "https://mtgbazaar-staging.s3.amazonaws.com"
  
  # This will allow your app to serve up the URLs using SSL if the request is coming via SSL. 
  # Doing this can avoid warnings in the browser that your app contains secure and unsecure content.
  # config.action_controller.asset_host = Proc.new do |source, request|
  #  scheme = request.ssl? ? "https" : "http"
  #  "#{scheme}://#{ENV['FOG_DIRECTORY']}.s3.amazonaws.com"
  #end

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )
  # add these files to be pre-compiled... for some reason they are missed?  This is needed to get CKEditor to work for Heroku
  config.assets.precompile += [ /ckeditor\/\w+.(css|js|png|gif)$/, 'ckeditor/config.js', 'ckeditor/skins/kama/editor.css', 'ckeditor/lang/en.js']

  # Disable delivery errors, bad email addresses will be ignored
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.asset_host = "http://mtgbazaar-staging.herokuapp.com"
  
  # Enable threaded mode
  config.threadsafe!
  # this is required to access model dependencies while running rake tasks From: http://stackoverflow.com/questions/2204936/dbseed-not-loading-models
  config.dependency_loading = true if $rails_rake_task

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify
  
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
