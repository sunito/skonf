#!/usr/bin/env ruby
# encoding: utf-8

require 'fileutils'
require 'time'

MAX_SEKUNDEN_MAIL_NOCH_ALS_NEU_GEWERTET = 90 # 1.5 Minuten -- schneller schafft man die nächste nicht
# 90 Sek sind eher kurz, 2018-Apr-29 von 150 Sek runtergegangen, das war in manchen Fällen zu lang
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


class TSMSMails
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

  def extrahiere text
    #p text.encoding
    d_wd = ['\d', '\w\d']
    dig, an = d_wd.map { |zeichen|  "([#{zeichen}]{6})" }
    ab='AN'; ap='+P'; f="T#{ab}"
    [
      # ToDo: weitere Erkenner (z.B. generisch), da aktuell alle Nicht-Standard-SMS als "Leer" klassifiziert werden
      / lautet: #{dig}/, # Pb Standard
      /\#{ap}[aoe]s[ty]b()/,           # Pb leer
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
    neu_text = File.read neueste, encoding: 'utf-8'
    w, c = " T", extrahiere(neu_text)
    zeit_str = neu_text.scan(/^Date: (.+)$/).first.first
    zeit = Time.parse(zeit_str) if zeit_str
    w += 'a'; m = "#{w}n-Mail "
    if c
      if c.empty? # erster Ansatz zur Erkennung leerer SMS-Mails
         [false, "FEHLER!! \n Die SMS kam leer an.\n Bitte NEUE#{w}n senden lassen!"]
      else
        wc = "#{w}n: #{c}"
        if zeit.nil?
          [true, "Ungewöhnliche#{m}erhalten:\n keine Zeit in der Mail gefunden!! (#{wc})"]
        else
          erfolg =  (Time.now - zeit < MAX_SEKUNDEN_MAIL_NOCH_ALS_NEU_GEWERTET)
          [ erfolg, (erfolg ? '' : "KEINE NEUE#{m}\n\n  Alte ") +
            "#{wc}      Zeit: #{zeit.strftime('%b-%d. %T')}"
          ]
        end
      end
    else
      [false, "Keine aktuelle#{m}gefunden"]
    end
  end

  SCRIPT_DIR = File.dirname(__FILE__)
  def warte wartedauer=TIMEOUT_SEKUNDEN
    anf_zeit = Time.now
    text = nil
    while Time.now - anf_zeit <= wartedauer do
      `#{SCRIPT_DIR}/kmail-check`
      erfolg, text = status
      break text if erfolg
      sleep 1.4
    end
    text
  end
end




#tm = TSMSMails.new "/111/ye-sys/kmail-neu/local-mail/.e-EingangPrio.directory/e-Anrufe/"
tm = TSMSMails.new "#{ENV['HOME']}/.local/share/local-mail/inbox/"


puts tm.warte
