#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/yo-gemeinsam'

rechner, zielname = ARGV

zielpfad = File.expand_path(zielname).chomp("/")

zielordner, basename = File.split(zielpfad)

def puts_and_execute command
  puts   command
  system command
end

puts_and_execute "sudo umount /mnt"
puts_and_execute "sudo mount #{rechner}:#{zielordner} /mnt"
rsync_zusatz_opts = ""
puts_and_execute "rsync -av #{rsync_zusatz_opts} /mnt/#{basename} #{zielordner}"
