Capistrano::Configuration.instance(:must_exist).load do
  namespace :check do
    desc "Make sure we deploy what we expect"
    task :revision do
      unless @ignore_checks
        here = `git rev-parse #{branch}`.chomp
        there = `git ls-remote #{repository} #{branch}`.split.first
        unless here == there
          puts ""
          puts " \033[1;33m**************************************************\033[0m"
          puts " \033[1;33m* WARNING: #{branch} is not the same as origin/#{branch}\033[0m"
          puts " \033[1;33m* local:  #{here}\033[0m"
          puts " \033[1;33m* origin: #{there}\033[0m"
          puts " \033[1;33m**************************************************\033[0m"
          puts ""

          exit
        end
      end
    end

    desc "Make sure we don't linger in a deploy branch"
    task :not_in_deploy do
      unless @ignore_checks || branch == 'master'
        head = `git rev-parse HEAD`.chomp
        deploy = `git rev-parse #{branch}`.chomp
        if head == deploy
          puts ""
          puts " \033[1;33m**********************************************************************\033[0m"
          puts " \033[1;33m* Step out of '#{branch}' to avoid shooting yourself in the foot.\033[0m"
          puts " \033[1;33m**********************************************************************\033[0m"
          puts ""

          exit
        end
      end
    end

    task :schema_version, :roles => :db, :only => { :primary => true } do
      unless @ignore_checks
        rails_env = fetch(:rails_env, "production")
        # If there are pending migrations, there will be a message on STDERR which is enough to abort.
        run "cd #{release_path}; bundle exec rake -s RAILS_ENV=#{rails_env} db:abort_if_pending_migrations"
      end
    end
  end
end