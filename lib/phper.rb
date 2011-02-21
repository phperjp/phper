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

