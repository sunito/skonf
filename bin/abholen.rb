#!/usr/bin/env ruby
# encoding: utf-8

erg=`/wartung/skonf/bin/raschgetan.rb`

antwort = case erg
 when /KEINE FRISCHE/
  "eventuell veraltet"  
 when /GANZ VERALTET/
  "Nein!! \nKomplett veraltet!"  
when /n: /     
  "OK"
else
  "Fehler"
end

system %Q(kdialog --msgbox "#{antwort}")
