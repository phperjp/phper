require 'helper'

class TestPhper < Test::Unit::TestCase
  def command commands
    Phper::CLI::run(commands)
  end
  context "commands" do
    setup do
      require "stringio"
      @cli = Phper::CLI.new
      @cli.out = StringIO.new
    end

    should "version shows version" do
      @cli.version
      assert @cli.out.string =~ /\d+\.\d+.\d+/
    end

    should "help shows help" do
      command ["help"]
      # assert_equal(@cli.out.string.length,481)
    end

  end
end
