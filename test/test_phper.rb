require 'helper'

class TestPhper < Test::Unit::TestCase
  should "version reterns version" do
    require "stringio"
    out = StringIO.new
    Phper::CLI.new { |cli|
      cli.version(out)
      assert out.string =~ /\d+\.\d+.\d+/
    }
  end
end
