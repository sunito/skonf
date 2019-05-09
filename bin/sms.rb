#!/usr/bin/env ruby

require 'rubygems'
require 'slop'

class String
  define_method '/' do |rest|
    File.join( self, rest)
  end
end


opts = Slop.parse! do 
  banner "Usage: #{$0} [options] <mobile-number> <text-of-sms> "

  #on 'name=', 'Your name'
  #on 'p', 'password', 'An optional password', argument: :optional'
  on 'd', 'dryrun', 'Nichts senden, nur so tun, als ob'
  on 'v', 'verbose', 'Enable verbose mode'
end



number, text, rest = ARGV

if text.nil? or rest then
  puts "Usage #{File.basename($0)} <mobile-number> <text-of-sms>"
  exit 1
end

if text.size > 160 
  puts "Text too long (#{text.size})"
  puts "text: " + text
  exit 2
end

number.gsub(/[^+0-9]/, "")
number = "+49" + number[1..-1] if number =~ /^0[^0]/


provdata = if $0 =~ /inter/
    %w[intervoip.com er*]
  else
    %w[nonoh.net he*]
  end

domain, nam = provdata
dir=domain.split(".").first

uname_files = Dir[ ENV["HOME"] / ".ssh"/"passwords"/dir/nam ] 
raise "username entry not found" if uname_files.empty?
raise "several username entries found" if uname_files.size > 1
uname_file = uname_files.first

password = File.read(uname_file).chomp
username = File.basename(uname_file)


puts "Text size = #{text.size} characters"

#cmd = "wget -O - 'https://www.nonoh.net/myaccount/sendsms.php?username=#{username}&password=#{password}&from=+4939877052998&to=#{number}&text=#{text}'"
cmd = "wget -O - 'https://www.#{domain}/myaccount/sendsms.php?username=#{username}&password=#{password}&from=+4915792311751&to=#{number}&text=#{text}'"
puts cmd
if false   # opts.dryrun?
  puts "Trockenlauf."
else
  erwartete_antwort = "."
  puts
  puts "Wirlich senden?  (Bestätigen mit '#{erwartete_antwort}' (und Enter))"
  antwort=STDIN.gets
  if antwort.chomp == erwartete_antwort
    system cmd  
  else
    puts   "nicht gesendet."
  end
end
