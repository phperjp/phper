require 'helper'

class TestPhper < Test::Unit::TestCase
  def command commands
    Phper::CLI::run(commands,@out)
  end
  context "commands" do
    setup do
      require "stringio"
      @out = StringIO.new
      @cli = Phper::CLI.new(@out)
    end

    should "version shows version" do
      @cli.version
      assert @out.string =~ /\d+\.\d+.\d+/
    end

    should "help shows help" do
      command "help"
      assert @out.string.length > 481
    end

  end
end
