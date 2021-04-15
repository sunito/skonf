#!/usr/bin/env ruby
# encoding: utf-8

require 'fileutils'
require 'time'

MIN_SEKUNDEN_MAIL_ALS_VOLL_VERALTET = 900 # 15 Minuten
MAX_SEKUNDEN_MAIL_NOCH_ALS_NEU_GEWERTET = 70 # 1:10 (1:24 Abstand ist real schon passiert) vielleicht ginge auch noch 70 =^= 1:20 <2020Ag> 
# 1:45 min <2020Jul> Jetzt niedriger OK, mit dem voll_alt-Status
# 135 2:15 Minuten <2020,Mar> für Ma erhöht, ist vielleicht gerade noch machbar
# 120 2 Minuten <2019,Mai30>
# 1.5 Minuten -- schneller schafft man die nächste nicht. 90 Sek sind eher kurz, 2018Apr von 150 Sek runtergegangen, das war in manchen Fällen zu lang

TIMEOUT_SEKUNDEN = 10 # 12sek waren unangenehm lange <2020Jul> 
# 12 # Jetzt mal auf Nr sicher gehen, das ist für Anfänger leichter <2020Mar> 
# 9sek ist auch zuwenig für Gls  <2020Mar> 
# <2019> War mal 10, das reicht immer, 8sek hat nicht gereicht f Gls
#TIMEOUT_SEKUNDEN = 8 # 6 wäre für Gls zu wenig #<2018>

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
  #yield
end


class TSMSMails
  def initialize dir
    @dir = dir
  end

  def neueste
    alle_dateinamen = Dir[@dir/"*/*"]  # Dir[@dir/"cur/*"] +
    sortierte_dateinamen = alle_dateinamen.sort_by{|dn| dont { print File.mtime(dn); puts " <-- "+dn};   File.mtime(dn)}
    neueste_dateien = sortierte_dateinamen.last(3)
    #neueste_dateien.each do |nd| p File.mtime(nd) end
    #p neueste_datei
    neueste_dateien.reverse
  end

  def extrahiere text
    #p text
    #p text.encoding
    d_wd = ['\d', '\w\d']
    dig, an = d_wd.map { |zeichen|  "([#{zeichen}]{6})" }
    ab='AN'; ap='\+P'; f="T#{ab}"
    [
      # ToDo: weitere Erkenner (z.B. generisch), da aktuell alle Nicht-Standard-SMS als "Leer" klassifiziert werden
      / lautet: #{an}/, # Pb Standard
      /#{ap}[aoe]s[ty]b()/,           # Pb leer
      / lautet ([\d]{6}),/,   # GLS Standard, funktioniert auch f Dauauftr
      /\+GLS #{f}()/,            # gls leer
      /#{f} #{an}/,     # sk und 3ds (mc seco)
      /Hier ist die #{f}.+hr: #{dig}/ # Standarding
    ].find do |re|
      if re =~ text
        return $1
      end
    end
    nil
  end

  def status
    erstmalig = true
    fehler_nachricht = neueste.map { |aktueller_dateiname|
      neu_text = File.read aktueller_dateiname, encoding: 'utf-8'
      w, c = " T", extrahiere(neu_text)
      zeit_str = neu_text.scan(/^Date: (.+)$/).first.first
      zeit = Time.parse(zeit_str) if zeit_str
      w += 'a'; m = "#{w}n-Mail "
      erg = if c
        if c.empty? # erster Ansatz zur Erkennung leerer SMS-Mails
          if erstmalig                     
            return [false, "FEHLER!! \n Die SMS kam leer an.\n Bitte NEUE#{w}n senden lassen!"]
            nil
          end
        else
          wc = "#{w}n: #{c}"
          if zeit.nil?
              [0, "Ungewöhnliche#{m}erhalten:\n keine Zeit in der Mail gefunden!! (#{wc})"]
          else
            erg = "#{wc}      Zeit: #{zeit.strftime('%b-%d. %T')}"
            zeit_diff = Time.now - zeit
            erfolg =  ( zeit_diff < MAX_SEKUNDEN_MAIL_NOCH_ALS_NEU_GEWERTET)
            return [true, erg] if erfolg                
            zualt =  (zeit_diff > MIN_SEKUNDEN_MAIL_ALS_VOLL_VERALTET)
            [zeit_diff, (zualt ?"NUR GANZ VERALTETE":"KEINE FRISCHE") + m + "\n\n  " + (zualt ?"Mit Sicherheit":"Eventuell")+" veraltete" + erg ]
          end
        end
      else
        [999999, "Keine aktuelle#{m}gefunden"]
      end
      erstmalig = false
      erg
    }.sort.first.last
    [false, fehler_nachricht]
  end

  SCRIPT_DIR = File.dirname(__FILE__)
  def warte wartedauer=TIMEOUT_SEKUNDEN
    anf_zeit = Time.now
    text = nil
    while Time.now - anf_zeit <= wartedauer do
      #`#{SCRIPT_DIR}/kmail-check`
      File.popen "#{SCRIPT_DIR}/kmail-check"  # Neuen Prozess starten, nicht auf Abschluss warten
      erfolg, text = status
      break text if erfolg
      sleep 1.4
    end
    text
  end
end



[
  "/111/ye-sys/kmail-neu/local-mail/.e--e--Entwicklung.directory/Anrufe--e--/",
  "#{ENV['HOME']}/.local/share/local-mail/inbox/"
].find do |dirname|
  if File.exist? dirname
    tm = TSMSMails.new dirname
    erg = tm.warte
    puts erg
    if erg =~ /(n:) ([\w\d]{6})/
      f=$2
      system("qdbus org.kde.klipper /klipper setClipboardContents  #{f}")
    end
    true
  end
end

