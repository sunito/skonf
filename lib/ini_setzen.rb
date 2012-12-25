#!/usr/bin/env ruby


require '/yay/288/lib/rubylin/lib/werkzeug'
#require File.join( File.dirname(__FILE__), 'werkzeug')

dateiname, name, wert = ARGV

if ARGV.size < 3 
  puts "Benötigt 3 Parameter!!"
  puts "Usage: "
  puts "ini_setzen.rb <name> <wert> <dateiname>"
  exit 1
end


werkzeug_eingabe = Werkzeug.new(dateiname)
werkzeug_eingabe.setze(name, wert)




