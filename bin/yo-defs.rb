#!/usr/bin/env ruby

require_relative "../lib/system.rb"

HOME    = ENV['HOME'] unless defined? HOME
BEST_YAY_SWITCH_DIR = "/yay/switch" unless defined? BEST_YAY_SWITCH_DIR
POSSIBLE_YAY_SWITCH_DIRS = [BEST_YAY_SWITCH_DIR, "/yay", "/etc/yay", HOME]

YAY_ENTRY_DIR = (BEST_YAY_SWITCH_DIR=="/yay/switch") ? "/yay" : BEST_YAY_SWITCH_DIR

# SEGMENTS = %w[111 133 311 322 122 411 422 455 811 822]
SEGMENTS = %w[111 122 133 144         177   
              211 222             266   
              311             355               
                                      477      499
              511     533     555 566  
                          644                  699 
                                  766 777  
              811                              888  
                                                   999
           ]

=begin
11 - arbeit
22 - sysconf
33 - statisch groß
44 - writeonly
55 - von bekannten
66 - von fremd
77 - von public
88 - backup
99 - archiv
=end

def symlink_target link_path
  `ls -l #{link_path}`.split(" ").last
end

def delete_link_if_exists file_name
  if File.symlink? file_name
    begin
      puts "Deleting #{file_name}"
      File.delete file_name 
    rescue
      puts $!
      puts_and_execute "sudo rm #{file_name}"
    end     
  else 
    puts "#{file_name} does not exist"
  end
end

def yay_dir_to_config(dir)
  scheme = {:multi => !!(dir=~/^\/yay/)}
  yah111_link = File.join( dir, scheme[:multi] ? "ya111" : "yah")
  [dir, scheme, yah111_link]
end  

def def_YAY_consts_old
  
  yay_config_found = POSSIBLE_YAY_SWITCH_DIRS.find do |dir| 
    if File.exist?(dir) 
      yay_config = yay_dir_to_config(dir)
      break yay_config if File.exist?(yay_config.last)
    end
  end  
  yay_config_found ||= yay_dir_to_config(BEST_YAY_SWITCH_DIR)
  
  dir, scheme, yah111_link = yay_config_found
  
  Object.const_set :YAY_SWITCH_DIR,     dir
  Object.const_set :YAY_SCHEME,  scheme
  Object.const_set :YAH111_LINK, yah111_link
end


class YayConfig
  def initialize yay_dir
    @SWITCH_DIR = yay_dir
  end
  
  attr_reader :SWITCH_DIR
  
  def SCHEME
    {:multi => !!(@SWITCH_DIR=~/^\/yay/)}
  end
  
  def YAH111_LINK
    File.join( @SWITCH_DIR, self.SCHEME[:multi] ? "ya111" : "yah")
  end
end

def def_YAY_consts
  
  yay_config_found = POSSIBLE_YAY_SWITCH_DIRS.find do |dir| 
    if File.exist?(dir) 
      yay_config = YayConfig.new(dir)
      break yay_config if File.exist?(yay_config.YAH111_LINK)
    end
  end  
  yay_config_found ||= YayConfig.new(BEST_YAY_SWITCH_DIR)
  
  Object.send :remove_const, :YAY if defined? YAY
  Object.const_set :YAY, yay_config_found
  
  Object.const_set :YAY_SWITCH_DIR,     YAY.SWITCH_DIR
  Object.const_set :YAY_SCHEME,  YAY.SCHEME
  Object.const_set :YAH111_LINK, YAY.YAH111_LINK
end

def_YAY_consts


class String
  define_method "/" do |teil_pfad|
    return self if teil_pfad.empty?
    return teil_pfad if self.empty?  
    File.join(self, teil_pfad)
  end
end

puts "YAY_SWITCH_DIR=#{YAY_SWITCH_DIR}, YAY_SCHEME=#{YAY_SCHEME.inspect}"

def create_dir_unless_exists dir_name
  unless File.exist? dir_name
    begin
      Dir.mkdir dir_name 
    rescue
      puts $!
      puts_and_execute "sudo mkdir #{dir_name}"
      puts_and_execute "sudo chown #{ENV['USER']}.users #{dir_name}"
    end     
  else
    puts "#{dir_name} exists"
  end
end

