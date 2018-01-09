#!/usr/bin/env ruby
#encoding: UTF-8


has_apt=system %Q(which apt-get)

# todo: verwende: kde4-config --localprefix
$kde_dir = ENV['HOME'] + "/.kde4"
if File.exist?( $kde_dir + "/share/config/kwinrc" )  
  puts $kde_dir
else
  puts ".kde"
  $kde_dir = ENV['HOME'] + "/.kde"
end
