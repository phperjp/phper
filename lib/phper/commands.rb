#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'phper'

class Phper::Commands < CommandLineUtils::Commands
  include Phper
  def initialize
    super
    @commands += ["login","logout","list","create","destroy","info"]
    @commands += ["keys","keys:add","keys:remove","keys:clear"]
    @commands += ["servers","servers:add","servers:remove"]
    @commands += ["open","db:init","deploy"]

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
      cmd = "git remote add phper #{git}"
      %x{#{cmd}}
      puts "--> #{cmd}"
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
          cmd = "git remote rm #{name}"
          %x{#{cmd}}
          puts "--> #{cmd}"
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
    puts "Initialize Database #{project}"
  end



  private

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
end
