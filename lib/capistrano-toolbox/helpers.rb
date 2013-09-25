require 'securerandom'

Capistrano::Configuration.instance(:must_exist).load do
  def put_as_root (user, contents, target, sudo=false)
    tempfile = Tempfile.new(File.basename(target))
    tempfile.write(contents)
    tempfile.close
    suscp(user, tempfile.path, target, sudo)
    surun(user, "chmod 644 #{target}", sudo)
    surun(user, "chown root:root #{target}", sudo)
    tempfile.unlink
  end

  def suscp (user, from, to, sudo=false)
    servers = find_servers_for_task(current_task)
    servers.each do |server|
      tempfile = "~/suscp-upload-#{SecureRandom.hex(6)}"
      command = "scp #{from} #{user}@#{server}:#{tempfile}"
      puts "  * \033[1;33mexecuting \"#{command}\"\033[0m"
      raise unless system command
      surun(user, "mv #{tempfile} #{to}", sudo)
    end
  end

  def surun (user, command, sudo=false)
    puts "  * \033[1;33mexecuting sudo \"#{command}\"\033[0m"
    servers = find_servers_for_task(current_task)
    puts "    servers: #{servers.inspect}"
    servers.each do |server|
      puts "    [#{server}] executing command"
      raise unless system %!ssh #{server} -l #{user} "#{"sudo" if sudo} #{command.gsub('"','\\"')}"!
    end
  end

  def remote_file_exists?(path, options={})
    'true' == capture("test -f #{path} && echo true || echo false", options).strip
  end
end
