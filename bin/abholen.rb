#!/usr/bin/env ruby
# encoding: utf-8

erg=`/wartung/skonf/bin/raschgetan.rb`

antwort = case erg
 when /KEINE NEUE/
  "eventuell veraltet"  
when /n: /     
  "OK"
else
  "Fehler"
end

system %Q(kdialog --msgbox "#{antwort}")
