require 'helper'

class TestPhper < Test::Unit::TestCase
  should "version reterns version" do
    require "stringio"
    out = StringIO.new
    Phper::CLI.new(out) { |cli|
      cli.version
      assert out.string =~ /\d+\.\d+.\d+/
    }
  end
end
