#!/usr/bin/env ruby

home_ordner = ENV["HOME"]
ziel_ordner = '/111/Folks/kmail-adr'

ziel_ordner = home_ordner unless File.writable?(ziel_ordner)

dateiname = "#{home_ordner}/.kde/share/config/kmailrc"
zeilen = File.read(dateiname)
recent_zeile = zeilen.grep /Recent Addresses/

zeile = recent_zeile.first
zeile.slice!("Recent Addresses=")
adressen = zeile.split(',') 
puts adressen.join("\n")

zeitstempel = Time.now.strftime('%Y-%m-%d')
File.open("#{ziel_ordner}/recent_mailaddr_#{zeitstempel}.txt", "w") do |ausgabe|
  adressen.each do |adr|
    ausgabe.puts adr
  end
end

