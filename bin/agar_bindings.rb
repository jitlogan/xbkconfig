#!/usr/bin/env ruby

require '../xbkconfig.rb'


# If there is predifined bindigns in file remove them, else, add them.

bindList = XBKconfig.parse

def writeXbindkeysrc(string)
    # File.open("#{ENV['HOME']}/.xbindkeysrc", "w") do |file|
    #     file.write(string)
    # end
    puts string
end

if %w(b:2 b:8 b:9).all?{ |bind| bindList.any?{|node| node.bind.eql?(bind)} }

# if bindList.include? {|node| ["b:2", "b:8", "b:9"].any? {|binding| node.bind.eql?(binding)} }
#     # Remove bindings; aka make default xbindkeysrc
#     writeXbindkeysrc(`xbindkeys -d`)
# else
#     # Add binding to xbindkeysrc
#     list = XBKconfig::NodeList.new
# 
#     fireCommand = "xte"
#     7.times do
#         fireCommand << %Q| 'key w' 'usleep 70000'|
#     end
# 
# 
#     list << XBKconfig::Node.new(fireCommand, "  b:2")
# 
#     [8, 9].each do |n| 
#         list << XBKconfig::Node.new("", "b:" + String(n))
#     end
# 
# 
#     writeString = ""
# 
#     bindList.each_with_index do |node, index|
#         writeString += "#{node.command}\n"
#         writeString += "  #{node.bind}"
#         writeString ++ "\n\n" unless index.eql?(bindList.size - 1) 
#     end
# 
#     writeXbindkeysrc(writeString)
# end
