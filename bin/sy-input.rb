#!/usr/bin/env ruby
# encoding: utf-8

require 'fileutils'
require 'time'

class String
  $i="s"
  define_method "/" do |rest|
    if empty?
      rest
    else
      File.join( self, rest)
    end
  end
end


def puts_and_execute command
  puts   "##!!## " + command
  system command
end  


i = gets.chomp
$h=$i*2
puts_and_execute %q(sudo sed -i -r "s/^#?Port .*$/Port ) + %Q(#{i}/" /etc/#{$h}h/#{$h}hd_config)


$f="irew"
$g=$i+"y#{$i}config/Su#{$i.upcase}Ef#{$f}all2"
# Todo: das Array richtig auswerten und Duplikate unterdrücken
puts_and_execute %q(sudo sed -i -r 's/^FW_SERVICES_EXT_TCP="(.*)"$/FW_SERVICES_EXT_TCP="\1 ) + %Q(#{i}"/' /etc) / $g
