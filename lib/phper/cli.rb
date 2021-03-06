#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'phper'
class Phper::CLI < CommandLineUtils::CLI
  include Phper
  attr_accessor :out
  def initialize
    super
    @out=STDOUT
    @commands = Commands.new
    yield self if block_given?
  end
  def dispatch(cmd,cmd_argv)
    raise "Unknown command. #{cmd}" unless @commands.commands.include?(cmd)
    @commands.send(cmd.gsub(/:/,"_"))
  end
  def version
    File.open(File.join(File.dirname(__FILE__) ,
                        "..","..","VERSION"),"r") { |file|
      @out.puts file.gets
    }
  end
end
