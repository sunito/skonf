#!/usr/bin/env ruby

require 'fileutils'

patch_quelle = ARGV.first

unless patch_quelle
  puts "Usage #{File.basename($0)} <Pfad-zur-Patch-Quelle>"
end

class String
  def / rest
    File.join( self, rest)
  end
end

def puts_and_execute command
  puts   "##> " + command
  system command
end  


puts_and_execute "find #{patch_quelle} -name '*Zone.Identifier'"

puts_and_execute "rm #{patch_quelle / '*/*/*/*/*Zone.Identifier'}"
puts_and_execute "rm #{patch_quelle / '*/*/*Zone.Identifier'}"
puts_and_execute "rm #{patch_quelle / '*Zone.Identifier'}"

puts_and_execute "find #{patch_quelle} -name '*Zone.Identifier'"

puts_and_execute "cp -va #{patch_quelle / 'Mathstar'} /111/subversion"

puts "Fertig."





__END__
rm /111/subversion/subversion-Patch_140415d/*/*/*/*/*Zone.Identifier             # 2014-04-16 08:28:24
 1996  rm /111/subversion/subversion-Patch_140415d/*/*/*Zone.Identifier                 # 2014-04-16 08:28:34
 1997  rm /111/subversion/subversion-Patch_140415d/*Zone.Identifier             # 2014-04-16 08:28:39
 1998  find /111/subversion/subversion-Patch_140415d/ -name "*Zone.Identifier"          # 2014-04-16 08:28:42
 1999  cp -va /111/subversion/subversion-Patch_140415d/Mathstar/ /111/subversion/               # 2014-04-16 08:30:54
