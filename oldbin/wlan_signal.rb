#!/usr/bin/env ruby

wartezeit = ARGV.first.to_f || 0.8

loop do
  print Time.now.strftime("%H:%M:%S ")
  %w(wlan eth).each do |geraeteart|
    (0..3).each do |i|
      schnittstelle = "#{geraeteart}#{i}"
      erg = `iwconfig #{schnittstelle} 2>&1| grep ality`
      next if erg.empty?
      match = erg.match(/ity=(\d+)\/(\d+)/)
      if match
	wert = match[1].to_i
	max = match[2].to_f
	prozent = '%02d%%' % (100 * wert.to_f / max)
	sterne = ('*'*([wert-20, 0].max)).gsub(/(\*{10})/, '\1 ')
    #    sterne = ('*'*([wert-20, 0].max)).gsub("*"*10, "*"*10+" ")
	puts "#{schnittstelle}: #{wert}  #{prozent} #{sterne}" 
      else
	puts "#{schnittstelle}: #{erg}"
      end
    end
  end
  sleep wartezeit
end
