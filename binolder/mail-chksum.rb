#!/usr/bin/env ruby

require 'jcode'

str = ARGV[0]

asc = proc do |z|
  z.unpack("c").first
end

sum = 0
str.each_char do |z|
  e = case z
    when /\d/ then z.to_i
    when /[a-z]/i then asc[z.upcase] - asc["@"]
    else raise "weder zahl noch Buchstabe: #{z}"
  end 
  print "#{z}->#{"%2d"%e}  "
  sum += e
end
puts
puts  "#{str} ==> #{9 - (sum % 10)}"
