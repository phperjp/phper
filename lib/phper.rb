# -*- coding: utf-8 -*-
module Phper
  def name_of_key key
    if key =~ / (\S+)$/
      return $1
    end
    return nil
  end

  # git remoteの結果からプロジェクトを推測する
  def git_remote(base_dir)
    %x{git remote -v 2> /dev/null }.each_line{ |line|
      if line =~ /\sgitosis@git\.phper\.jp:(.+)\/(.+)\.git\s/
        return [$1,$2].join("-")
      end
    }
    nil
  end

  def git_remotes(git)
    # %x{git remote add phper #{project["project"]["git"]}} 
    r = []
    %x{git remote -v 2> /dev/null }.each_line{ |line|
      if line.include?(git)
        r << $1 if line =~ /^(\S+)/
      end
    }
    r.uniq
  end

  def in_git?
    %x{git status 2>/dev/null }
    $?.to_i == 0
  end

  def git_root
    root = nil
    begin
      startdir = FileUtils.pwd
      until File.directory?(".git")
        FileUtils.cd('..')
        raise "can't find git project" if FileUtils.pwd == "/"
      end
      root = FileUtils.pwd
    rescue =>e
      puts e
    ensure
      FileUtils.cd(startdir)
    end
    return root
  end

  def encode(str,salt=".")
    enc = OpenSSL::Cipher::Cipher.new('aes256')
    enc.encrypt.pkcs5_keyivgen(salt)
    ((enc.update(str) + enc.final).unpack("H*")).to_s
  end
  
  def decode(str,salt=".")
    dec = OpenSSL::Cipher::Cipher.new('aes256')
    dec.decrypt.pkcs5_keyivgen(salt)
    (dec.update(Array.new([str]).pack("H*")) + dec.final)
  end
  
end
require "rubygems"
require "json"
require "highline/import"
require "keystorage"
require 'rest-client'
require 'highline'
require 'launchy'
require 'command-line-utils'
require 'phper/commands'
require 'phper/cli'
require 'phper/agent'

