#!/usr/bin/env ruby

require 'scriptster'
require_relative 'xbkconfig'


bind_list = XBKconfig.parse


def add_bindings(bind_list)
    # Constructing agar.io fire command
    fireCommand = "xte"
    7.times do
        fireCommand << %Q| 'key w' 'usleep 70000'|
    end

    # Constructing list
    [[fireCommand, "b:2"], ["", "b:8"], ["", "b:9"]].each do |pair|
        bind_list.add(XBKconfig::Node.new(pair.first, pair.last))
    end
end


def xbindkeys(command)
    raise ArgumentError unless command[:action].eql?(:kill) || command[:action].eql?(:restart)

    def xb_kill()
        Scriptster.cmd "pkill xbindkeys", raise: false
        Scriptster.log :info, "no entries in config | killing xbindkeys"
    end

    def xb_restart(message)
        Scriptster.cmd "pkill xbindkeys", raise: false
        Scriptster.cmd "xbindkeys"
        Scriptster.log :info, "#{message} | xbindkeys restarted"
    end

    xb_kill if command[:action].eql?(:kill)
    xb_restart(command[:message]) if command[:action].eql?(:restart)
end


def write(bind_list)
    File.open(File.expand_path("~/.xbindkeysrc")) do |file|
        writeString = ""
        bind_list.each_with_index do |bind, index|
            writeString += "#{bind.command}\n"
            writeString += "#{bind.bind}"
            writeString += "\n\n" if !index.eql?(bind_list - 1)
        end
        file.write(writeString)
    end
end


if !bind_list.empty?
    # Proceed
    # if "agar.io binds are present => remove them; else => add them"
    if %w(b:2 b:8 b:9).any?{|bind| bind_list.any?{|node| node.bind.eql?(bind)}}
        bind_list.delete_if{|node| %w(b:2 b:8 b:9).any?{|bind| node.bind.eql?(bind)}}
        # write(bind_list)
        p bind_list
    else
        add_bindings(bind_list)
        p bind_list
        # write(bind_list)
    end
else
    # Add binds to config
    add_bindings(bind_list)
    # write(bind_list)
    p bind_list
end
