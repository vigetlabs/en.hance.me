require 'viget/deployment'

set :application, 'enhance'
set :repository, 'git@github.com:vigetlabs/en.hance.me.git'

after "deploy:update_code", "resque:workers:restart"

namespace :resque do
  namespace :workers do
    desc "Start Resque"
    task :start, :roles => [:resque] do
      rake_task = "env RAILS_ENV=#{rails_env} QUEUE=* BACKGROUND=yes PIDFILE=tmp/pids/resque_worker.pid rake resque:work > /dev/null 2>&1"
      run "cd #{release_path}; bundle exec #{rake_task}"
    end

    desc "Stop Resque"
    task :stop, :roles => [:resque] do
      pid_path = 'tmp/pids/resque_worker.pid'
      `cd #{release_path}; cat #{pid_path} | xargs kill -s QUIT`
      `cd #{release_path}; rm -f #{pid_path}`
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
