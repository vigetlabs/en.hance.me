require 'viget/deployment'

set :application, 'enhance'
set :repository, 'git@github.com:vigetlabs/en.hance.me.git'

after "deploy:update_code", "resque:workers:restart"

namespace :resque do
  namespace :workers do
    desc "Start Resque"
    task :start, :roles => [:resque] do
      rake_task = "env RAILS_ENV=#{rails_env} QUEUE=* BACKGROUND=yes PIDFILE=tmp/pids/resque_worker.pid rake resque:work > /dev/null 2>&1"
      run "cd #{current_path}; bundle exec #{rake_task}"
    end

    desc "Stop Resque"
    task :stop, :roles => [:resque] do
      run "cd #{current_path}; bundle exec rake resque:stop_worker"
    end

    desc "Restart Resque"
    task :restart, :roles => [:resque] do
      servers = find_servers_for_task(current_task) & roles[:resque].servers
      puts "found resque servers: #{servers.inspect}"

      if servers.any?
        resque.workers.stop
        resque.workers.start
      end
    end
  end
end
