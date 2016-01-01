#!/usr/bin/env ruby

require_relative 'parser'


class XBKconfig

    def self.parse(string = File.read(File.expand_path("#{ENV['HOME']}/.xbindkeysrc")))
        bind_list = XBKconfig::NodeList.new

        # Cleaning comments if present
        parsed_string = XBKconfig::Parser::Transform.new.apply(XBKconfig::Parser::Parser.new.parse(string))
        parsed_string.delete_if{|hash| hash.keys.eql?([:comment])} unless string.empty?

        # Create nodes if string is not empty
        unless parsed_string.empty?
             parsed_string.each do |hash|
                 bind_list.add(XBKconfig::Node.new(hash[:command], hash[:bind]))
             end
        end
        return bind_list
    end

    class NodeList < Array
        def add(node)
            if !node.kind_of?(XBKconfig::Node)
                raise TypeError, "no implicit conversion of #{node.class} into XBKconfig::Node"
            else
               self << node
            end
        end

        def binds
            self.collect {|node| node.bind}
        end
    end

    class Node
        attr_accessor :bind
        attr_reader :command

        def command=(command)
            @command = surroundCommand(command)
        end

        def initialize(command = "", bind)
            @command, @bind = [surroundCommand(command), sanitizeBind(bind)]

        end

    private
        def surroundCommand(command)
            return (command[0] && command[-1]).eql?('"') ? command : command.inspect
        end

        def sanitizeBind(bind)
            bind.strip
        end
    end


end
