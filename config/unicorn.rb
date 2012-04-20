## SETUP file for unicorn webserver

# unicorn_rails -c /config/unicorn.rb

# amount of unicorn workers to spin up in addition to one master
worker_processes 4

# Load rails+github.git into the master before forking workers
# for super-fast worker spawn times
preload_app true

# Restart any workers that haven't responded in 30 seconds
timeout 30