#!/usr/bin/env ruby


require File::dirname(__FILE__) + '/yo-gemeinsam'

#ziel = "/media/SD_8GB_ext3"
#ziel = "/media/Fusion"
if YAY_SCHEME[:multi]
  update122 ARGV

  do_multi :sync_to, ARGV + ["--backup"]
    
else
opts = ARGV.grep /^-/
normale_args = ARGV - opts
ziel = normale_args[0]

raise "kein Ziel angegeben" unless ziel

puts "transferiere nach #{ziel}"

erg = sync_nach ziel, opts+["--backup"]

p erg

p ende_zeit = Time.now

end