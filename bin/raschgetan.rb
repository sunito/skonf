#!/usr/bin/env ruby
# encoding: utf-8

require 'fileutils'
require 'time'

class String
  define_method "/" do |rest|
    if empty?
      rest
    else
      File.join( self, rest)
    end
  end
end



class TanMails
  def initialize dir
    @dir = dir
  end
  
  def neueste
    alle_dateinamen = Dir[@dir/"cur/*"] + Dir[@dir/"new/*"]
    neueste_datei = alle_dateinamen.sort_by{|dn| File.mtime(dn)}.last
  end
  
  def extrahiere_tan text
    [
      / lautet: ([\w\d]{6})/, # Postb
      / lautet ([\d]{6}),/    # GLS
    ].find do |re|
      if re =~ text
        return $1
      end
    end
    nil
  end
  
  def info
    neu_text = File.read neueste
    tan = extrahiere_tan neu_text
    if tan
      zeit_str = neu_text.scan(/^Date: (.+)$/).first.first
      zeit = Time.parse(zeit_str) if zeit_str
      if zeit.nil?
        "keine Zeit in der Mail gefunden!! (Tan: #{tan}"
      else
        (Time.now - zeit < 600 ? '' : "Keine neue Tan-Mail \n  Alte ") +
          "Tan: #{tan}      Zeit: #{zeit.strftime('%b-%d. %T')}"
      end
    else
      "Keine aktuelle Tan-Mail gefunden"
    end
  end
  
end

`kmail-check`
sleep 1


tm = TanMails.new "/111/ye-sys/kmail-neu/local-mail/.e-EingangPrio.directory/e-Anrufe/"

puts tm.info
