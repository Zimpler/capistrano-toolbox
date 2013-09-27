require 'securerandom'

Capistrano::Configuration.instance(:must_exist).load do
  def put_nginx_config (user, contents, target, sudo=false)
    tempfile = Tempfile.new(File.basename(target))
    tempfile.write(contents)
    tempfile.close

    remote_tempfile ="#{release_path}/tmp/new-nginx-config"
    restart_nginx_file = "#{release_path}/tmp/nginx_restart.txt"

    suscp(user, tempfile.path, remote_tempfile, sudo)
    surun(user, "diff -q #{remote_tempfile} #{target} && rm #{remote_tempfile} || (mv #{remote_tempfile} #{target} && touch #{restart_nginx_file})", sudo)
    surun(user, "chmod 644 #{target} && chown root:root #{target}", sudo)
    tempfile.unlink
  end

  def suscp (user, from, to, sudo=false)
    servers = find_servers_for_task(current_task)
    servers.each do |server|
      command = "scp #{from} #{user}@#{server}:#{to}"
      puts "  * \033[1;33mexecuting \"#{command}\"\033[0m"
      raise unless system command
    end
  end


  def surun (user, command, sudo=false)
    puts "  * \033[1;33mexecuting sudo \"#{command}\"\033[0m"
    servers = find_servers_for_task(current_task)
    puts "    servers: #{servers.inspect}"
    servers.each do |server|
      puts "    [#{server}] executing command"
      maybe_sudo = sudo ? "sudo -s /bin/bash -c #{command.inspect}" : command
      raise unless system %!ssh #{server} -l #{user} #{maybe_sudo.inspect}!
    end
  end

  def remote_file_exists?(path, options={})
    'true' == capture("test -f #{path} && echo true || echo false", options).strip
  end
end
