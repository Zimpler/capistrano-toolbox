Capistrano::Configuration.instance(:must_exist).load do
  def put_as_root(contents, target)
    tempfile = Tempfile.new(File.basename(target))
    tempfile.write(contents)
    tempfile.close
    rootscp(tempfile.path, target)
    surun "chmod 644 #{target}"
    tempfile.unlink
  end

  def rootscp(from, to)
    servers = find_servers_for_task(current_task)
    servers.each do |server|
      command = "scp #{from} root@#{server}:#{to}"
      puts "  * \033[1;33mexecuting \"#{command}\"\033[0m"
      system command
    end
  end

  def surun (command)
    puts "  * \033[1;33mexecuting sudo \"#{command}\"\033[0m"
    servers = find_servers_for_task(current_task)
    puts "    servers: #{servers.inspect}"
    servers.each do |server|
      puts "    [#{server}] executing command"
      `ssh #{server} -l root "#{command.gsub('"','\\"')}"`
    end
  end
end
