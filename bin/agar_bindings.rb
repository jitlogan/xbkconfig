#!/usr/bin/env ruby

require 'scriptster'
require_relative '../xbkconfig'


bind_list = XBKconfig.parse


def add_bindings(bind_list)
    fire_command = "xte"
    7.times do
        fire_command << %Q| 'key w' 'usleep 70000'|
    end

    [[fire_command, "b:2"], ["", "b:8"], ["", "b:9"]].each do |pair|
        bind_list.add(XBKconfig::Node.new(pair.first, pair.last))
    end

    return bind_list
end

["adding", "removing"].each do |method_prefix|
    define_method("xbind_#{method_prefix}") do
        Scriptster.log :info, "#{method_prefix} agar.io bindings"
        Scriptster.cmd "pkill xbindkeys", raise: false
        Scriptster.cmd "xbindkeys"
    end
end

def write(bind_list)
    File.open(File.expand_path("~/.xbindkeysrc"), "w") do |file|
        writeString = ""
        bind_list.each_with_index do |bind, index|
            writeString += "#{bind.command}\n"
            writeString += "  #{bind.bind}"
            writeString += "\n\n" if !index.eql?(bind_list.size - 1)
        end
        file.write(writeString)
    end
end


if !bind_list.empty?
    if %w(b:2 b:8 b:9).any?{|bind| bind_list.any?{|node| node.bind.eql?(bind)}}
        bind_list.delete_if{|node| %w(b:2 b:8 b:9).any?{|bind| node.bind.eql?(bind)}}
        write(bind_list)
        xbind_removing
    else
        add_bindings(bind_list)
        write(bind_list)
        xbind_adding
    end
else
    add_bindings(bind_list)
    write(bind_list)
    Scriptster.log :info, "adding agar.io bindings"
    Scriptster.cmd "pkill xbindkeys", raise: false
    Scriptster.cmd "xbindkeys", raise: false
end
