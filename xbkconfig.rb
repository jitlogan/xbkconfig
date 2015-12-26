#!/usr/bin/env ruby

require 'parslet'


class XBKconfig

    class Parser < Parslet::Parser
        rule(:newline) { str("\n") >> str("\r").maybe }
        rule(:comment) { str("#").repeat(1) >> (newline.absent? >> any).repeat >> newline.repeat }

        rule(:doubleQuote) { str('"') }
        rule(:commandLine) { doubleQuote >> ( (newline.absent? >> doubleQuote.absent? >> any).repeat ).as(:command) >> doubleQuote >> match["\s"].repeat >> newline }

        rule(:bind) { (newline.absent? >> doubleQuote.absent? >> any).repeat.as(:bind) >> newline.repeat }
        rule(:bindEntry) { ( commandLine >> bind ).as(:bindEntry) }
        rule(:main) { ( comment | bindEntry ).repeat }
        root(:main)
    end

    class Transform < Parslet::Transform
        rule(:bindEntry => { :command => simple(:c), :bind => simple(:b) } ) { { command: String(c), bind: String(b) } }
    end

    def self.parse(string = File.read(File.expand_path("#{ENV['HOME']}/.xbindkeysrc")))
        list = XBKconfig::NodeList.new
        self::Transform.new.apply(self::Parser.new.parse(string)).each do |bindEntry|
            list.add(XBKconfig::Node.new(bindEntry[:command], bindEntry[:bind]))    
        end
        return list
    end

    class NodeList < Array
        def add(node)
            self << node
        end
    end

    class Node
        attr_accessor :bind
        attr_reader :command

        def command=(command)
            @command = surroundCommand(command)
        end

        def initialize(command = nil, bind = nil)
            if command.nil?
                @command, @bind = [command, bind]
            else
                @command, @bind = [surroundCommand(command), bind]
            end
        end

    private
        def surroundCommand(command)
            '"' + command + '"'
        end
    end


end
