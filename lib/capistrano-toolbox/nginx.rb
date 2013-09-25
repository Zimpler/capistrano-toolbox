require 'capistrano-toolbox/helpers'

Capistrano::Configuration.instance(:must_exist).load do
  namespace :deploy do
    namespace :nginx do

      desc "Updates nginx config"
      task :update_config do
        nginx_user     = fetch(:nginx_user, "root")
        nginx_use_sudo = fetch(:nginx_use_sudo, false)

        config_dir = fetch(:nginx_remote_config_dir)
        config     = fetch(:nginx_config, nil)
        if config
          available_path = File.join(config_dir, "#{application}.conf")
          put_as_root(nginx_user, config, available_path, nginx_use_sudo)
          surun(nginx_user, "nxensite #{application}.conf", nginx_use_sudo)
        end

        ssl_config = fetch(:nginx_ssl_config, nil)
        if ssl_config
          available_ssl_path = File.join(config_dir, "#{application}-ssl.conf")
          put_as_root(nginx_user, ssl_config, available_ssl_path, nginx_use_sudo)
          surun(nginx_user, "nxensite #{application}-ssl.conf", nginx_use_sudo)
        end
      end

      desc "Reload nginx config"
      task :reload, :roles => :app, :except => { :no_release => true } do
        nginx_user     = fetch(:nginx_user, "root")
        nginx_use_sudo = fetch(:nginx_use_sudo, false)

        surun(nginx_user, "service nginx reload", nginx_use_sudo)
      end
    end
  end

  after "deploy:nginx:update_config", "deploy:nginx:reload"
end
