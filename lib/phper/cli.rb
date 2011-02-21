#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'phper'
class Phper::CLI < CommandLineUtils::CLI
  include Phper
  def initialize
    super
    @commands = Commands.new
    yield self if block_given?
  end
  def dispatch(cmd,cmd_argv)
    @commands.send(cmd.sub(/:/,"_"))
  end
  def version
    File.open(File.join(File.dirname(__FILE__) ,
                        "..","..","VERSION"),"r") { |file|
      puts file.gets
    }
  end
end
