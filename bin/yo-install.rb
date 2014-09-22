#!/usr/bin/env ruby
# encoding: utf-8

require 'fileutils'

require File.dirname(__FILE__) + '/yo-defs'

if ARGV.size > 1 or ARGV[0] =~ /-h/
  puts <<-EOT
  
  Usage: yo-install.rb <Hauptordner>
  
  Der Ordner <Hauptordner> wird erstellt, falls nicht vorhanden.
  Darin wird der Unterordner 122 angelegt (falls nicht vorhanden) und darin
  werden dann einige Dot-Files (bzw. Ordner) gespeichert.
  Außerdem werden sämtliche yay-Segmente auf diesen Ordner gerichtet, falls
  sie noch nicht erstellt wurden.
  EOT
  exit
end
  
install_ziel_dir = ARGV[0] || "/dat/aaa"


class RelevantDataInTwoPlacesError < RuntimeError; end


def puts_and_execute command
  puts   "##!!## " + command
  system command
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

def create_link(target_name, link_name)
  if File.symlink?(link_name) 
    puts "#{link_name} exists, checking if <-- #{target_name}"
    old_target = `ls -l #{link_name}`.split(" ").last 
    if old_target != target_name
      puts "wrong link: #{old_target}"
      delete_link_if_exists link_name
    end
  end
  unless File.symlink?(link_name)
    puts "#{target_name} --> #{link_name}"
    begin
      File.symlink(target_name, link_name)
    rescue Errno::EACCES
      puts $!
      puts "sudo(#{link_name}):"
      puts_and_execute "sudo ln -s #{target_name} #{link_name}"
    end
  end
end

def create_link_unless_exists(target_name, link_name)
  if File.symlink?(link_name) or File.exist?(link_name)
    puts "#{link_name} exists"
  else
    create_link(target_name, link_name)
  end
end

def move_and_symlink_or_ensure_correctness(store_name, orig_name)
  unless File.symlink?(store_name) or File.exist?(store_name) # Wenn es schon existiert, fassen wir es nicht an
    if File.exist?(orig_name)
      begin
	FileUtils.move(orig_name, store_name)  
      rescue
	puts $!
	puts "##!!## sudo(#{store_name}):"
	puts_and_execute "sudo mv #{orig_name} #{store_name}"
      end
      puts "##!!## #{orig_name} ##> #{store_name}"
    else
      if store_name =~ /\/$/
	Dir.mkdir store_name
        puts "##!!## Directory #{store_name.inspect} created"
      else
	# gefährlich, wegen Auto-sync, neue leere Datei würde die alte gute Datei überschreiben
	# File.open(store_name, "w"){}
        puts "#{store_name.inspect} missing, no empty file created"
      end
    end
  else
    if File.exist?(orig_name) and not File.symlink?(orig_name)
      if File.directory?(orig_name) and Dir.entries(orig_name).size == 2 # nur "." und ".."
	Dir.rmdir(orig_name)
      else	
        raise RelevantDataInTwoPlacesError, "!!!!!\n!!!!! Please manually merge #{orig_name} into #{store_name} !!!!!!\n!!!!!"
      end
    end
  end
  create_link( store_name, orig_name)
end

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




if YAY_SWITCH_DIR != BEST_YAY_SWITCH_DIR 
  possible_122_link_locations = [
    "#{BEST_YAY_SWITCH_DIR}/ya122", 
    
    "#{YAY_SWITCH_DIR}/ya122", 
    "#{YAY_SWITCH_DIR}/122", 
    "/122"
  ]

  if File.exist?(YAH111_LINK)
    puts "\n  Moving from #{YAY_SWITCH_DIR} to #{BEST_YAY_SWITCH_DIR}!!\n\n"
    create_dir_unless_exists BEST_YAY_SWITCH_DIR
    Dir[File.join YAY_SWITCH_DIR, "ya*"].each do |orig|
      FileUtils.mv orig, File.join(BEST_YAY_SWITCH_DIR, File.basename(orig))
    end

    if File.exist?( old_yah111_link= File.join(BEST_YAY_SWITCH_DIR, "yah") )
      FileUtils.mv old_yah111_link, File.join(BEST_YAY_SWITCH_DIR, "ya111")
    end
    delete_link_if_exists "/111"
    delete_link_if_exists "#{HOME}/111"
    
    Object.send :remove_const, "YAY_SWITCH_DIR"
    Object.send :remove_const, "YAY_SCHEME"
    Object.send :remove_const, "YAH111_LINK"
    def_YAY_consts        
  end
  
  
  ya122_link = possible_122_link_locations.find {|dir| File.exist? dir}
  if ya122_link
    folder122 = symlink_target(ya122_link)
    # Hier wird zwischen direkten Links und Switch-Links unterschieden
    # bei ersteren müssen wir den 122-Ordner noch wegnehmen
    ya122_dir = File.dirname(folder122) if ( folder122 and ya122_link =~ /\/122$/ )
    possible_122_link_locations.each do |link|
      delete_link_if_exists link
    end    
  end
end


create_dir_unless_exists YAY_ENTRY_DIR
create_dir_unless_exists YAY_SWITCH_DIR

create_link "#{YAH111_LINK}/111", "#{HOME}/111"
create_link "#{YAH111_LINK}/111", "/111"

create_link YAY_ENTRY_DIR, "#{HOME}/aa"
create_link YAY_ENTRY_DIR, "/aa"


ya122_dir = ARGV[0] || ya122_dir  # robuster machen
ya122_link = "#{YAY_SWITCH_DIR}/ya122"

if ya122_dir
  create_dir_unless_exists ya122_dir 
  #create_link_unless_exists ya122_dir, "/122"  
  # Hier Orts-Änderung einbauen, falls Link schon existiert!
  create_link_unless_exists ya122_dir, ya122_link
  create_dir_unless_exists "#{ya122_link}/122"
end

ya322_dir = ya122_dir
ya322_link = "#{YAY_SWITCH_DIR}/ya322"
if ya322_dir
  create_link_unless_exists ya322_dir, ya322_link
  create_dir_unless_exists "#{ya322_link}/322"
end

ya177_link = "#{YAY_SWITCH_DIR}/ya177"
if File.symlink?(ya177_link)
  puts "Performing ya177 actions"
  move_and_symlink_or_ensure_correctness "#{ya177_link}/177/Downloads", "#{HOME}/Downloads"
else
  puts "no symlink creation for 177, because #{ya177_link} does not exist." 
end

if File.symlink?(ya122_link)
  puts "Performing ya122 actions"
  # this is now maintained solely through git:
  # move_and_symlink_or_ensure_correctness "#{ya122_link}/122/bin/",                "#{HOME}/bin"
  
  create_dir_unless_exists       "#{ya122_link}/122/yc-dot/"
  move_and_symlink_or_ensure_correctness "#{ya122_link}/122/yc-dot/twinkle/",     "#{HOME}/.twinkle"
  move_and_symlink_or_ensure_correctness "#{ya122_link}/122/yc-dot/sflphone/",    "#{HOME}/.config/sflphone"
  move_and_symlink_or_ensure_correctness "#{ya122_link}/122/yc-dot/bash_aliases", "#{HOME}/.bash_aliases"
  move_and_symlink_or_ensure_correctness "#{ya122_link}/122/yc-dot/linphonerc",   "#{HOME}/.linphonerc"
else
  puts "no symlink creation for 122, because #{ya122_link} does not exist."  
end

if File.symlink?(ya322_link)
  puts "Performing ya322 actions"
  move_and_symlink_or_ensure_correctness "#{ya322_link}/322/conf-akonadi/",       "#{HOME}/.config/akonadi"
  # Die folgende Verlinkung würde den Akonadi-Server lahmlegen
  # move_and_symlink_or_ensure_correctness "#{ya322_link}/322/loc-sh-akonadi/",     "#{HOME}/.local/share/akonadi"

  move_and_symlink_or_ensure_correctness "#{ya322_link}/322/kde-config/",         "#{HOME}/.kde/share/config"
  
  create_dir_unless_exists       "#{HOME}/.kde/share/config-local"  
  Dir["#{HOME}/.kde/share/config/plasm*"].each do |komplett_name|
    puts "plasma: " + komplett_name
    basename = File.basename(komplett_name)
    move_and_symlink_or_ensure_correctness "#{HOME}/.kde/share/config-local/#{basename}",     komplett_name
  end	
else
  puts "no 322-symlink creation, #{ya322_link} does not exist."  
end


SEGMENTS.each do |segment|
  # Weniger hart "/dat/aaa" verdrahten:
  create_link_unless_exists install_ziel_dir, "#{YAY_SWITCH_DIR}/ya#{segment}"
  create_dir_unless_exists "#{YAY_SWITCH_DIR}/ya#{segment}/#{segment}"
  
  create_link "#{YAY_SWITCH_DIR}/ya#{segment}/#{segment}", "#{YAY_ENTRY_DIR}/#{segment}"
end

  move_and_symlink_or_ensure_correctness "/111/ye-sys/kmail-neu/local-mail/",     "#{HOME}/.local/share/local-mail"
