## SETUP file for unicorn webserver

# unicorn_rails -c /config/unicorn.rb

rails_env = ENV['RAILS_ENV'] || 'production'

# amount of unicorn workers to spin up in addition to one master
worker_processes 4

# Load rails+github.git into the master before forking workers
# for super-fast worker spawn times
preload_app true

# Restart any workers that haven't responded in 30 seconds
timeout 30

if rails_env == 'development'
  after_fork do |server,worker|
    # per-process listener ports for debugging/admin:
    addr = "127.0.0.1:#{9293 + worker.nr}"

    # the negative :tries parameter indicates we will retry forever
    # waiting on the existing process to exit with a 5 second :delay
    # Existing options for Unicorn::Configurator#listen such as
    # :backlog, :rcvbuf, :sndbuf are available here as well.
    server.listen(addr, :tries => -1, :delay => 5, :backlog => 128)
  end
end