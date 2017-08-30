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
  
  def status
    neu_text = File.read neueste
    tan = extrahiere_tan neu_text
    if tan
      zeit_str = neu_text.scan(/^Date: (.+)$/).first.first
      zeit = Time.parse(zeit_str) if zeit_str
      if zeit.nil?
        [false, "keine Zeit in der Mail gefunden!! (Tan: #{tan}"]
      else
        erfolg =  (Time.now - zeit < 600)
        [ erfolg, (erfolg ? '' : "Keine neue Tan-Mail \n  Alte ") +
          "Tan: #{tan}      Zeit: #{zeit.strftime('%b-%d. %T')}"
        ]
      end
    else
      [false, "Keine aktuelle Tan-Mail gefunden"]
    end
  end
  
  def warte wartedauer=4
    anf_zeit = Time.now
    text = nil
    while Time.now - anf_zeit <= wartedauer do
      `kmail-check`
      erfolg, text = status
      break text if erfolg
      sleep 0.7
    end
    text
  end
end




tm = TanMails.new "/111/ye-sys/kmail-neu/local-mail/.e-EingangPrio.directory/e-Anrufe/"

puts tm.warte
