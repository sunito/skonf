#!/usr/bin/env ruby
    
# "/var/run/media/sunito/Samsara/zzSymBU/2015-08-?4*"
# "/media/sunito/Samsara/zzSymBU/2015-08-?4*"
$patterns=ARGV

if $patterns.empty?
#  puts "Usage: #{__FILE__} <pattern-to-be-deleted>"
  puts "Usage: "
  puts "  #{File.basename($0)} <pattern-to-be-deleted>"
  exit 2
end

$drive="/media/sunito/Samsara"

def used_space
  df_erg = `df #{$drive}`
  return 0 if df_erg.empty?
  df_erg.lines.to_a.last.split("\s")[2]
end


system "df #{$drive}"
puts Time.now

#2015-05-27-18/

$patterns.each do |pattern|
Dir[pattern].each do |dir_to_clear|
  puts
  zeit_anf = Time.now
  print zeit_anf
  puts " --> " + dir_to_clear
  pre_used = used_space.to_i
  puts "vorher:  " + used_space
  system "rm -rf #{dir_to_clear}"
  system "df #{$drive}"
  zeit_end = Time.now
  zeit_diff = zeit_end - zeit_anf
  puts "#{(zeit_diff/60).to_i}:#{"%02d"%(zeit_diff.to_i%60)}"
  #system "rufen"
  #system "shopt -s expand_aliases ;source .bash_aliases ;rufen"
  system "play /111/Produktion/maja1-8.wav 2>/dev/null"
  ref_time = Time.now
  [0, 6, 5, 5, 5, 5, 50].each do |sleep_time|
    sleep sleep_time+0.1
    post_used = used_space.to_i
    print "diff#{"%02d"%(Time.now-ref_time).to_i}: "
    print "#{pre_used-post_used}   \t"
    puts `df #{$drive}`.lines.to_a.last
  end
  puts "nachher: " + used_space
  puts " <-- " + dir_to_clear
end
end

system "df"
puts "Fertig."

__END__


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
