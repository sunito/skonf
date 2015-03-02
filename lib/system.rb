#!/usr/bin/env ruby
#encoding: UTF-8


has_apt=system %Q(which apt-get)


$kde_dir = ENV['HOME'] + "/.kde4"
if File.exist?( $kde_dir + "/share/config/kwinrc" )  
  puts $kde_dir
else
  kde_dir = ENV['HOME'] + "/.kde"
end
