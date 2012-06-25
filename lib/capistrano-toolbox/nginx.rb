require 'capistrano-toolbox/helpers'

Capistrano::Configuration.instance(:must_exist).load do
  namespace :deploy do
    namespace :nginx do

      desc "Updates nginx config"
      task :update_config do
        config_dir = fetch(:nginx_remote_config_dir)

        config = fetch(:nginx_config, nil)
        if config
          available_path = File.join(config_dir, "#{application}.conf")
          put_as_root(config, available_path)
          surun "nxensite #{application}.conf"
        end

        ssl_config = fetch(:nginx_ssl_config, nil)
        if ssl_config
          available_ssl_path = File.join(config_dir, "#{application}-ssl.conf")
          put_as_root(ssl_config, available_ssl_path)
          surun "nxensite #{application}-ssl.conf"
        end
      end

      desc "Reload nginx config"
      task :reload, :roles => :app, :except => { :no_release => true } do
        surun "service nginx reload"
      end
    end
  end

  after "deploy:nginx:update_config", "deploy:nginx:reload"
end