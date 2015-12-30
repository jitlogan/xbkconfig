#!/usr/bin/env ruby

require '../xbkconfig.rb'
require 'scriptster'


bindList = XBKconfig.parse()

def writeXbindkeysrc(string)
    File.open("#{ENV['HOME']}/.xbindkeysrc", "w") do |file|
    # File.open("/tmp/test01.txt", "w") do |file|
        file.write(string)
    end
end

def restartXbindkeys(action)
    Scriptster.cmd("killall xbindkeys")
    Scriptster.cmd("xbindkeys")
    Scriptster.log(:info, "xbindkeys restarted | #{action} agar.io bindings")
end

agarBindings = %w(b:2 b:8 b:9)
# if agarBindings.all?{ |bind| bindList.any?{|node| node.bind.eql?(bind)} }
if bindList.kind_of?(Array) && agarBindings.any?{ |bind| bindList.any?{|node| node.bind.eql?(bind)} }
    # Remove bindings
    writeString = ""
    
    # bindList.each do |node|
    #     bindList.delete(node) if %(b:2 b:8 b:9).any?{|bind| node.bind.eql?(bind)}
    # end
    bindList.delete_if do |node|
        agarBindings.any? do |bind|
            node.bind.eql?(bind)
        end
    end

    # writeString += "\n" if writeString[-1].eql?("\n")

    bindList.each_with_index do |node, index|
        writeString += "#{node.command}\n"
        writeString += "  #{node.bind}"
        writeString += "\n\n" unless index.eql?(bindList.size - 1)
    end

    writeXbindkeysrc(writeString)
    restartXbindkeys("removing")

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
    restartXbindkeys("adding")
end
