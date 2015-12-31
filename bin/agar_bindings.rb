#!/usr/bin/env ruby

require_relative '../xbkconfig.rb'
require 'scriptster'


bindList = XBKconfig.parse()

def writeXbindkeysrc(string)
    File.open("#{ENV['HOME']}/.xbindkeysrc", "w") do |file|
        file.write(string)
    end
end

def restartXbindkeys(command)
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

agarBindings = %w(b:2 b:8 b:9)
if bindList.kind_of?(Array) && agarBindings.any?{ |bind| bindList.any?{|node| node.bind.eql?(bind)} }
    writeString = ""
    
    bindList.delete_if do |node|
        agarBindings.any? do |bind|
            node.bind.eql?(bind)
        end
    end

    unless bindList.empty?
        bindList.each_with_index do |node, index|
            writeString += "#{node.command}\n"
            writeString += "  #{node.bind}"
            writeString += "\n\n" unless index.eql?(bindList.size - 1)
        end

        restartXbindkeys({action: :restart, message: "removing entries"})
    else
        restartXbindkeys({action: :kill})
    end

    writeXbindkeysrc(writeString)

else
    list = XBKconfig::NodeList.new

    fireCommand = "xte"
    7.times do
        fireCommand << %Q| 'key w' 'usleep 70000'|
    end

    list << XBKconfig::Node.new(fireCommand, "  b:2")

    [8, 9].each do |n|
        list << XBKconfig::Node.new("", "b:" + String(n))
    end

    writeString = ""

    bindList.each{|node| writeString += "#{node.command}\n"; writeString += "  #{node.bind}\n\n"} unless bindList.empty?

    list.each_with_index do |node, index|
        writeString += "#{node.command}\n"
        writeString += "  #{node.bind}"
        writeString += "\n\n" unless index.eql?(list.size - 1)
    end

    writeXbindkeysrc(writeString)
    restartXbindkeys({action: :restart, message: "added bindings"})
end
