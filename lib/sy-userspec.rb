#!/usr/bin/env ruby
#encoding: UTF-8


class String
  define_method "/" do |rest|    
    File.join( self, rest)
  end
end


def puts_and_execute command
  puts   "exec> " + command
  system command
end  

begin 
  require 'nokogiri'
rescue 
  puts_and_execute "sudo gem install nokogiri"
  require 'nokogiri'
end

snippets_doc = Nokogiri::XML(open(ENV['HOME'] / '.kde/share/apps/plasma_applet_paste/snippets.xml'))

p snippets_doc 

snippets = snippets_doc.search("snippets")

p snippets


passw_node = snippets.search('snippet[@name = "Fecha actual"]')
passw_node = snippets.search('snippet[@name = "Contraseña aleatoria"]')

p passw_node
                             
def add_if_not_exists name, value
  
end
  