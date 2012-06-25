Capistrano::Configuration.instance(:must_exist).load do
  namespace :deploy do
    namespace :config do
      desc "Copy config files"
      task :copy_files do
        run "cp #{shared_path}/config/* #{release_path}/config/"
      end
    end
  end
end