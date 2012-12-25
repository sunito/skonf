#!/usr/bin/env ruby


class Werkzeug
  def initialize dateiname
    @dateiname = dateiname
  end

  def setze(name, wert)
 #  system %Q(sed -ri "s/^(#{name}=).*$/#{name}=7#{wert}/" #{@dateiname})
 
    vorher = File.read(@dateiname)
    nachher = vorher.gsub(/^(#{Regexp.escape(name)}=).*$/, "#{name}=#{wert}" )
    File.open(@dateiname, "w") do |datei|
     datei.puts nachher
    end
  end

end
