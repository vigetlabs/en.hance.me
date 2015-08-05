require 'resque/tasks'
task "resque:setup" => :environment

namespace :resque do
  task :setup => :environment

  desc "Stop a resque worker"
  task :stop_worker do
    pid_path = Rails.root.join(ENV['PIDFILE'] || 'tmp/pids/resque_worker.pid')
    if pid_path.file?
      `cat #{pid_path} | xargs kill -s QUIT`
      `rm -f #{pid_path}`
    end
  end
end
