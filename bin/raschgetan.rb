#!/usr/bin/env ruby
# encoding: utf-8

require 'fileutils'
require 'time'

MAX_SEKUNDEN_MAIL_NOCH_ALS_NEU_GEWERTET = 150 # 2.5 Minuten -- schneller überweiset man nicht
TIMEOUT_SEKUNDEN = 10 # auch 8sek hat nicht gereicht f GLS
#TIMEOUT_SEKUNDEN = 8 # 6 wäre für GLS zu wenig

class String
  define_method "/" do |rest|
    if empty?
      rest
    else
      File.join( self, rest)
    end
  end
end

def dont
  # dont do anything
end


class TanMails
  def initialize dir
    @dir = dir
  end

  def neueste
    alle_dateinamen = Dir[@dir/"*/*"]  # Dir[@dir/"cur/*"] +
    neueste_datei = alle_dateinamen.sort_by{|dn| dont { print File.mtime(dn); puts " <-- "+dn};   File.mtime(dn)}.last
    #p File.mtime(neueste_datei)
    #p neueste_datei
    neueste_datei
  end

  def extrahiere_tan text
    [
      # ToDo: weitere Erkenner (z.B. generisch), da aktuell alle nicht-Standard-Tans als "Leer" klassifiziert werden
      / lautet: ([\w\d]{6})/, # Postb Standard
      /\+Postba()/,           # Postb leer
      / lautet ([\d]{6}),/,   # GLS Standard, funktioniert auch f Dauerauftr
      /\+GLS TAN()/,            # GLS leer
      / TAN ([\w\d]{6})\./     # 3ds -cardprocess.de (Masterc Secucode)
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
   if tan.empty? # erster Ansatz zur Erkennung leerer SMS-Mails
      [false, "FEHLER!! \n Die Tan-SMS kam leer an.\n Bitte NEUE Tan anfordern!"]
   else
    if tan
        zeit_str = neu_text.scan(/^Date: (.+)$/).first.first
        zeit = Time.parse(zeit_str) if zeit_str
        if zeit.nil?
          [true, "Ungewöhnliche Tan-Mail erhalten:\n keine Zeit in der Mail gefunden!! (Tan: #{tan}"]
        else
          erfolg =  (Time.now - zeit < MAX_SEKUNDEN_MAIL_NOCH_ALS_NEU_GEWERTET)
          [ erfolg, (erfolg ? '' : "KEINE NEUE Tan-Mail \n\n  Alte ") +
            "Tan: #{tan}      Zeit: #{zeit.strftime('%b-%d. %T')}"
          ]
        end
    else
        [false, "Keine aktuelle Tan-Mail gefunden"]
    end
   end
  end

  def warte wartedauer=TIMEOUT_SEKUNDEN
    anf_zeit = Time.now
    text = nil
    while Time.now - anf_zeit <= wartedauer do
      `kmail-check`
      erfolg, text = status
      break text if erfolg
      sleep 1.4
    end
    text
  end
end




tm = TanMails.new "/111/ye-sys/kmail-neu/local-mail/.e-EingangPrio.directory/e-Anrufe/"

puts tm.warte
