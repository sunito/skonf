#!/usr/bin/env ruby

number, text, rest = ARGV

if text.nil? or rest then
  puts "Usage "#{File.basename($0)} <mobile-number> <text-of-sms>"
  exit 1
end

if text.size > 160 
  puts "Text too long (#{text.size})"
  puts "text: " + text
  exit 2
end

number.gsub(/[^+0-9]/, "")
number = "+49" + number[1..-1] if number =~ /^0[^0]/

class String
  def / rest
    File.join( self, rest)
  end
end

uname_files = Dir[ ENV["HOME"] / ".ssh"/"passwords"/"nonoh" / "he*"] 
raise "username entry not found" if uname_files.empty?
raise "several username entries found" if uname_files.size > 1
uname_file = uname_files.first

password = File.read(uname_file).chomp
username = File.basename(uname_file)


puts "Text size = #{text.size} characters"

#cmd = "wget -O - 'https://www.nonoh.net/myaccount/sendsms.php?username=#{username}&password=#{password}&from=+4939877052998&to=#{number}&text=#{text}'"
cmd = "wget -O - 'https://www.nonoh.net/myaccount/sendsms.php?username=#{username}&password=#{password}&from=+4915792311751&to=#{number}&text=#{text}'"
puts cmd
system cmd