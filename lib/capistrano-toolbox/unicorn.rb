require 'capistrano-toolbox/helpers'

Capistrano::Configuration.instance(:must_exist).load do
  namespace :deploy do
    namespace :unicorn do
      task :restart, :roles => :app, :except => { :no_release => true } do
        cmd = "if [ -f #{unicorn_pid} ]; then kill -s USR2 `cat #{unicorn_pid}` ; else /etc/init.d/unicorn start ; fi"
        # Not specifying a shell would make it run with rvm-shell which would make "unicorn start" loop forever:
        run cmd, :shell => '/bin/bash'
      end
    end
  end

end