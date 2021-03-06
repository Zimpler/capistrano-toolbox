require 'capistrano-toolbox/helpers'

Capistrano::Configuration.instance(:must_exist).load do
  namespace :deploy do
    namespace :unicorn do
      task :restart, :roles => :app, :except => { :no_release => true } do
        rails_env = fetch(:rails_env, "production")
        servers = find_servers roles: :app
        servers.each do |server|
          old_pid = nil
          if remote_file_exists?(unicorn_pid, hosts: [server])
            old_pid = capture("cat #{unicorn_pid}", hosts: [server])
            cmd = "kill -s USR2 #{old_pid}"
          else
            cmd = "RAILS_ENV=#{rails_env} /etc/init.d/unicorn start"
          end

          run(cmd, shell: '/bin/bash', hosts: [server])

          sleep(1)

          cmd = "echo -n '    Waiting for unicorn' ; while [ ! -s #{
            unicorn_pid
          } -o -s #{
            unicorn_pid
          }.oldbin ] ; do echo -n '.' ; sleep 1 ; done"

          run(cmd, shell: '/bin/bash', hosts: [server]) do |channel, stream, data|
            print(data)
          end

          new_pid = capture("cat #{unicorn_pid}", hosts: [server])

          if new_pid == old_pid
            raise "Unicorn failed to restart!"
          end
        end
      end
    end
  end
end
