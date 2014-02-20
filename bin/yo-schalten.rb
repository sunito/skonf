#!/usr/bin/env ruby

require File::dirname(__FILE__) + '/yo-gemeinsam'

#opts = ARGV.grep /^-/

if ARGV.empty? 
  puts "Aktuelle yah-Orte: " 
  puts `ls -l #{YAY_SWITCH_DIR}`.scan(/ ya... .+$/).join("\n")  #.split(" ").last
else
  if YAY_SCHEME[:multi]
    update122 ARGV
    do_multi :switch_to, ARGV
  else
    schalte_auf expandiere_basis_pfad ARGV[0]
  end
end

