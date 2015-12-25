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

    def self.parse(string = File.read(File.expand_path("#{ENV['HOME']}/.xbindkeysrc")))
        self::Parser.new.parse(string)
    end

    class NodeList
        def initialize
            @list = []
        end

        def add(node)
            @list << node
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
