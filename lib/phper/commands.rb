#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'phper'
require "parsedate"
require "time"
require 'base64'

class Phper::Commands < CommandLineUtils::Commands
  include Phper
  attr_reader :commands
  def initialize
    super
    @commands += ["login","logout","list","create","destroy","info"]
    @commands += ["keys","keys:add","keys:remove","keys:clear"]
    @commands += ["servers","servers:add","servers:remove"]
    @commands += ["open","db:init","deploy"]
    @commands += ["hosts"]
    @commands += ["files","files:dump","files:get"]
    @commands += ["files:modified","files:modified:get"]
    @commands += ["logs","logs:tail"]

    @agent = Agent.new
    # @cache_file =  homedir + "/.phper.cache"
    # @cache = Cache.new(@cache_file)
    yield self if block_given?
  end

  def homedir
    ENV['HOME']
  end

  def login
    opt = OptionParser.new
    opt.parse!(@command_options)
    @summery = "Login to phper.jp."
    @banner = ""
    return opt if @help

    user = ask('Enter user: ') do |q|
      q.validate = /\w+/
    end

    ok = false
    while(!ok) 
      password = ask("Enter your password: ") do |q|
        q.validate = /\w+/
        q.echo = false
      end

      @agent.login(user,password)
      if @agent.login? # => OK
        ok = true
        Keystorage.set("phper.jp",user,password)
        puts "login OK"
      else
        puts "password mismatch"
      end
    end
  end

  def logout
    opt = OptionParser.new
    opt.parse!(@command_options)
    @summery = "Logout from phper.jp ."
    @banner = ""
    return opt if @help
    Keystorage.delete("phper.jp")
  end


  def list
    opt = OptionParser.new
    opt.parse!(@command_options)
    @summery = "get project list"
    @banner = ""
    return opt if @help

    start
    @agent.projects.each { |pj|
      puts pj["project"]["id"]
    }
  end

  def info
    project = nil
    OptionParser.new { |opt|
      project = extract_project(opt)
      @summery = "show project info"
      return opt if @help
    }
    raise "project is not specified." unless project
    start
    project = @agent.projects(project)
    puts "%s" % project["project"]["id"]
    puts "--> %s" % project["project"]["git"]
    puts "--> mysql://%s:%s@%s/%s" % [project["project"]["dbuser"],
                                      project["project"]["dbpassword"],
                                      "db.phper.jp",
                                      project["project"]["dbname"]]
    @agent.servers(project["project"]["id"]).each { |server|
      puts "%s\thttp://%s" % [server["server"]["name"],server["server"]["fqdn"]]
    }
  end

  def create
    OptionParser.new { |opt|
      opt.parse!(@command_options)
      @summery = "craete project"
      @banner = "[<name>]"
      return opt if @help
    }
    name = @command_options.shift

    start
    project = @agent.projects_create name
    
    puts "Created %s" % project["project"]["id"]
    puts "--> %s" % project["project"]["git"]
    puts "--> mysql://%s:%s@%s/%s" % [project["project"]["dbuser"],
                                      project["project"]["dbpassword"],
                                      "db.phper.jp",
                                      project["project"]["dbname"]]
    # if here
    if in_git? and project["project"]["id"] != git_remote(Dir.pwd) 
      git = project["project"]["git"]
      exec_report("git remote add phper #{git}")
      init_phper_dir
    end
  end

  def destroy
    project = nil
    yes = false
    OptionParser.new { |opt|
      opt.on('-y','--yes', 'answer yes for all questions') { |v|
        yes = true
      }
      project = extract_project(opt)
      @summery = "destroy project"
      return opt if @help
    }
    raise "project is not specified." unless project
    start
    pj = @agent.projects(project)
    git = pj["project"]["git"]
    raise "project is not exist." unless pj

    yes = true if yes or ask("Destroy #{project}? ",["yes","no"]) == "yes"
    if yes
      @agent.projects_delete project
      puts "Destroyed #{project}"
      # if here
      if in_git? and project == git_remote(Dir.pwd)
        git_remotes(git).each{ |name|
          exec_report("git remote rm #{name}")
        }
      end
    end
  end

  def keys
    OptionParser.new { |opt|
      opt.parse!(@command_options)
      @summery = "list keys"
      @banner = ""
      return opt if @help
    }
    start
    @agent.keys.each { |key|
      name = name_of_key(key["key"]["public_key"])
      puts name if name
    }
  end


  def keys_add
    OptionParser.new { |opt|
      opt.parse!(@command_options)
      @summery = "add keys"
      @banner = "<public key file>"
      return opt if @help
    }
    file = @command_options.shift
    raise "file is not specified." unless file
    key = ""
    File.open(file) { |f|
      key = f.read
    }
    name = name_of_key(key)
    raise "invalid key" unless name
    start
    @agent.keys_create(key)
    puts "key of %s added" % name
  end

  def keys_remove
    OptionParser.new { |opt|
      opt.parse!(@command_options)
      @summery = "remove key"
      @banner = "<user@host>"
      return opt if @help
    }
    name = @command_options.shift
    raise "key name is not specified." unless name
    start
    count = @agent.keys_delete(name)
    puts "%i key(s) named %s removed" % [count,name]
  end

  def keys_clear
    OptionParser.new { |opt|
      opt.parse!(@command_options)
      @summery = "remove all keys"
      @banner = ""
      return opt if @help
    }
    start
    count = @agent.keys_delete_all
    puts "%i key(s) removed" % [count]
  end

  def servers
    project = nil
    OptionParser.new { |opt|
      project = extract_project(opt)
      @summery = "list servers"
      return opt if @help
    }
    raise "project is not specified." unless project
    start
    @agent.servers(project).each { |server|
      puts "%s\thttp://%s" % [server["server"]["name"],server["server"]["fqdn"]]
    }
  end

  def servers_add
    param = {}
    project = nil
    name = nil
    OptionParser.new { |opt|
      opt.on('--name=NAME', 'Name of this server') { |v|
        param[:name] = v
      }
      opt.on('--root=ROOT', 'Document Root') { |v|
        param[:root] = v
      }
      project = extract_project(opt)
      @banner = "[<host>]"
      @summery = "add server"
      return opt if @help
    }
    raise "project is not specified." unless project
    host = @command_options.shift
    if host
      param[:fqdn] = host
      param[:name] = host unless param.has_key?(:name)
    end

    start
    server = @agent.servers_create(project,param)["server"]
    puts "Created %s" % server["name"]
    puts "--> http://%s" % server["fqdn"]
  end

  def servers_remove
    param = {}
    project = nil
    name = nil
    OptionParser.new { |opt|
      project = extract_project(opt)
      @banner = "[<host or name>]"
      @summery = "remove server"
      return opt if @help
    }
    raise "project is not specified." unless project
    name = @command_options.shift

    start
    count =  @agent.servers_delete(project,name)
    puts "%i server(s) named %s removed" % [count,name]
  end

  def servers_clear
    OptionParser.new { |opt|
      project = extract_project(opt)
      @summery = "remove all servers"
      return opt if @help
    }
    raise "project is not specified." unless project

  end

  def open
    project = nil
    OptionParser.new { |opt|
      project = extract_project(opt)
      @banner = "[<host or name pattern>]"
      @summery = "Open URL"
      return opt if @help
    }
    raise "project is not specified." unless project
    start
    servers = @agent.servers(project)
    raise "project #{project} has no servers." if servers.length == 0
    name = @command_options.shift

    server = nil
    if name
      server = servers.find { |s|
        s["server"]["name"] =~ /^#{name}/ or s["server"]["fqdn"] =~ /^#{name}/
      }
    end
    server = servers.shift unless server
    url = "http://#{server["server"]["fqdn"]}"
    puts "Opening #{url}"
    Launchy.open url
  end

  def deploy
    project = nil
    OptionParser.new { |opt|
      project = extract_project(opt)
      @banner = ""
      @summery = "Deploy project"
      return opt if @help
    }
    raise "project is not specified." unless project
    start
    @agent.projects_deploy(project)
    puts "Deploy #{project}"
  end

  def db_init
    project = nil
    OptionParser.new { |opt|
      project = extract_project(opt)
      @banner = ""
      @summery = "Initialize project database."
      return opt if @help
    }
    raise "project is not specified." unless project
    start
    @agent.projects_init_db(project)
    project = @agent.projects(project)
    puts "Initialize Database %s" % project["project"]["id"]
    puts "--> mysql://%s:%s@%s/%s" % [project["project"]["dbuser"],
                                      project["project"]["dbpassword"],
                                      "db.phper.jp",
                                      project["project"]["dbname"]]
  end

  def hosts
    project = nil
    OptionParser.new { |opt|
      project = extract_project(opt)
      @summery = "list project hosts"
      return opt if @help
    }
    raise "project is not specified." unless project
    start
    @agent.hosts(project).each { |host|
      puts "%s" % [host["host"]["id"]]
    }

  end

  def files
    project = nil
    params = {}
    OptionParser.new { |opt|
      opt.on('-h HOST','--host=HOST', 'host') { |v|
        params[:host] = v
      }
      project = extract_project(opt)
      @summery = "list project files"
      return opt if @help
    }
    raise "project is not specified." unless project
    start
    unless params[:host]
      host = @agent.hosts(project).first
      params[:host] = host["host"]["id"]
    end
    raise "project has no hosts" unless params[:host]

    @agent.files(project,params[:host]).each { |file|
      puts "%s" % [file["file"]["name"]]
    }
  end

  def files_get
    @summery =  "get and put file."
    return  files_get_one if @help 
    file = files_get_one
    file_put(file)
  end

  def files_dump
    @summery =  "dump file."
    return  files_get_one if @help 
    file = files_get_one
    puts Base64.decode64(file["file"]["contents"])
  end

  def files_modified 
    @summery = "list modified files since last deploy."
    return file_get_modified if @help
    file_get_modified.each { |file|
      puts "%s" % [file["file"]["name"]]
    }
  end

  def files_modified_get
    @summery = "get modified files since last deploy."
    return file_get_modified if @help
    file_get_modified.each { |file|
      file = @agent.files(@project,@params[:host],file["file"]["name"])
      file_put(file)
    }
  end
  

  private

  def file_get_modified
    @params ||= {}
    OptionParser.new { |opt|
      opt.on('-h HOST','--host=HOST', 'host') { |v|
        @params[:host] = v
      }
      @project = extract_project(opt)
      return opt if @help
    }
    raise "project is not specified." unless @project
    start
    unless @params[:host]
      host = @agent.hosts(@project).first
      @params[:host] = host["host"]["id"]
    end
    raise "project has no hosts" unless @params[:host]
    files = @agent.files(@project,@params[:host])
    modified(files)
  end

  def file_put file
    name = file["file"]["name"]
    raise "Not in under git." unless in_git?

    name = File.join(git_root,name)
    FileUtils.mkdir_p(File.dirname(name))
    File.open(name,"w"){ |f|
      f.write Base64.decode64(file["file"]["contents"])
    }
    puts "--> " + file["file"]["name"]
  end


  def files_get_one
    project = nil
    params = {}
    OptionParser.new { |opt|
      opt.on('-h HOST','--host=HOST', 'host') { |v|
        params[:host] = v
      }
      @banner = "<filename>"
      project = extract_project(opt)
      return opt if @help
    }
    raise "project is not specified." unless project
    file = @command_options.shift
    raise "file is not specified." unless project

    start
    unless params[:host]
      host = @agent.hosts(project).first
      params[:host] = host["host"]["id"]
    end
    raise "project has no hosts" unless params[:host]
    @agent.files(project,params[:host],file)
  end

  def modified files
    marker = files.find { |file|
      file["file"]["name"] == ".phper.deployed"
    }
    "missing marker .phper.deployed file in this host"  unless marker
    marker_mtime = Time.parse(marker["file"]["mtime"])
    files.collect { |file|
      file if Time.parse(file["file"]["mtime"]) > marker_mtime
    }.compact
  end

  def extract_project opt
    @banner = [@banner,"[--project=<project>]"].join(" ")
    project = nil
    opt.on('--project=PROJECT', 'project') { |v|
      project = full_project_name(v)
    }
    opt.parse!(@command_options)
    return project if project
    git_remote(Dir.pwd)
  end

  def user
    Keystorage.list("phper.jp").shift
  end

  def password
    Keystorage.get("phper.jp",user)
  end

  def full_project_name(v)
    return v if v =~ /\-/
    [user,v].join("-") 
  end

  def start
    @agent.log(STDERR) if @options[:debug]
    return true if @agent.login?
    login unless user
    if user
      @agent.login(user,password)
      login unless @agent.login?
    end
  end

  def exec_report cmd
    %x{#{cmd}}
    puts "--> #{cmd}"
  end

=begin
* [CLI] .phper/deploy
* [CLI] .phper/initdb
* [CLI] .phper/httpd.conf
* [CLI] .phper/rsync_exclude.txt
=end
  def init_phper_dir
    files = {}
    files[:deploy] = File.join(git_root,".phper","deploy")
    files[:initdb] = File.join(git_root,".phper","initdb")
    files[:httpd] = File.join(git_root,".phper","httpd.conf")
    files[:rsync] = File.join(git_root,".phper","rsync_exclude.txt")
    FileUtils.mkdir_p(File.join(git_root,".phper"))
    puts File.join(git_root,".phper")
    # deploy
    unless File.file?(files[:deploy])
      File.open(files[:deploy],"w"){ |f|
        f.puts <<EOF
# deploy script here
if [ ! -f .phper.deployed ] ; then
  # when 1st deployed.
  true
fi

EOF
      }
      File::chmod(0100755,files[:deploy])
      exec_report("git add -f #{files[:deploy]}")
    end
    # initdb
    unless File.file?(files[:initdb])
      File.open(files[:initdb],"w"){ |f|
        f.puts <<EOF
# run after inititalize database
EOF
        f.puts ""
      }
      File::chmod(0100755,files[:initdb])
      exec_report("git add -f #{files[:initdb]}")
    end
    # httpd.conf
    unless File.file?(files[:httpd])
      File.open(files[:httpd],"w"){ |f|
        f.puts <<EOF
# httpd.conf
EOF
      }
      exec_report("git add -f #{files[:httpd]}")
    end
    # rsync
    unless File.file?(files[:rsync])
      File.open(files[:rsync],"w"){ |f|
        f.puts <<EOF
# rsync exclude
.git
CVS
.svn
EOF
      }
      exec_report("git add -f #{files[:rsync]}")
    end
  end

  def logs
    project = nil
    # server = nil
    OptionParser.new { |opt|
      @summery = "list logs"
      @banner = ""
      project = extract_project(opt)
      return opt if @help
    }

    raise "project is not specified." unless project
    start
    servers = @agent.servers(project)
    raise "project #{project} has no servers." if servers.length == 0

    servers.each { |server|
      puts "-----> #{server['server']['name']}"
      @agent.logs(project,server).each { |log|
        puts log
      }
    }
  end

  def logs_tail
    project = nil
    server = nil
    name = nil
    OptionParser.new { |opt|
      opt.on('-s SERVER','--server=SERVER', 'server') { |v|
        server = v
      }
      opt.on('-n NAME','--name=NAME', 'log name') { |v|
        name = v
      }
      @summery = "list logs"
      project = extract_project(opt)
      return opt if @help
    }

    raise "project is not specified." unless project
    start
    servers = @agent.servers(project)
    raise "project #{project} has no servers." if servers.length == 0

    if server
      server = servers.find { |s| s["server"]["name"] =~ /^#{server}/ }
      raise "server is not specified." unless server
    end

    servers = [server] if server
    servers.each { |server|
      names = @agent.logs(project,server)
      if name
        raise "#{server["server"]["name"]} has no log:#{name}." unless names.include?(name)
        names = [name]
      end
      names.each { |name|
        puts "-----> log:#{name} #{server["server"]["name"]}"
        puts @agent.logs_tail(project,server,name)["log"]
      }
    }
  end

end
