require 'minitest/autorun'
require '../xbkconfig.rb'

class TestXBKconfig < Minitest::Test
    def setup
        @result = XBKconfig.parse
        @nodeList = XBKconfig::NodeList.new
        @emptyNode = XBKconfig::Node.new()
        @node = XBKconfig::Node.new("command", "bind")
    end

    def test_default_parse
        assert_instance_of(XBKconfig::NodeList, @result)
    end

    def test_nodeList_instance
        assert_instance_of(XBKconfig::NodeList, @nodeList)
    end

    def test_nodeList_add_empty
        assert_raises(RuntimeError) { @nodeList.add(@emptyNode) }
    end

    def test_nodeList_type_error
        assert_raises(TypeError) { @nodeList.add(String.new) }
    end

    def test_nodeList_add
        assert_instance_of(XBKconfig::NodeList, @nodeList.add(@node))
    end

    def test_nodeList_size
        assert_equal(1, @nodeList.add(@node).size)
    end

end
