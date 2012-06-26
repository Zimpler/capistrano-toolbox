require 'capistrano-toolbox/helpers'

Capistrano::Configuration.instance(:must_exist).load do
  namespace :deploy do
    namespace :unicorn do
      task :restart, :roles => :app, :except => { :no_release => true } do
        old_pid = nil
        if remote_file_exists?(unicorn_pid)
          old_pid = capture("cat #{unicorn_pid}")
          cmd = "kill -s USR2 #{old_pid}"
        else
          cmd = "RAILS_ENV=production /etc/init.d/unicorn start"
        end

        run cmd, :shell => '/bin/bash'

        sleep(1)
        cmd = <<-SHELL
echo -n "    Waiting for unicorn" ; while [ ! -s #{unicorn_pid} -o -s #{unicorn_pid}.oldbin ] ; do echo -n "." ; sleep 1 ; done
SHELL
        run(cmd, shell: '/bin/bash') do |channel, stream, data|
          print(data)
        end

        new_pid = capture("cat #{unicorn_pid}")

        if new_pid == old_pid
          raise "Unicorn failed to restart!"
        end
      end
    end
  end
end