# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

# use rack deflator to gzip assets when serving from heroku.... this is not needed when serving from s3
# use Rack::Deflater

run MTGBazaar::Application
