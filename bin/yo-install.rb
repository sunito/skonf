#!/usr/bin/env ruby
# encoding: utf-8

require 'fileutils'

require File.dirname(__FILE__) + '/yo-defs'

if ARGV.size > 1 or ARGV[0] =~ /-h/
  puts <<-EOT
  
  Usage: yo-install.rb <Hauptordner>
  
  Der Ordner <Hauptordner> wird erstellt, falls nicht vorhanden.
  Darin wird der Unterordner 288 angelegt (falls nicht vorhanden) und darin
  werden dann einige Dot-Files (bzw. Ordner) gespeichert.
  Außerdem werden sämtliche yay-Segmente auf diesen Ordner gerichtet, falls
  sie noch nicht erstellt wurden.
  EOT
  exit
end
  
install_ziel_dir = ARGV[0] || "/dat/aaa"


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
      raise "!!!!!\n!!!!! Please manually merge #{orig_name} into #{store_name} !!!!!!\n!!!!!"
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
  possible_288_link_locations = [
    "#{BEST_YAY_SWITCH_DIR}/ya288", 
    
    "#{YAY_SWITCH_DIR}/ya288", 
    "#{YAY_SWITCH_DIR}/288", 
    "/288"
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
  
  
  ya288_link = possible_288_link_locations.find {|dir| File.exist? dir}
  if ya288_link
    folder288 = symlink_target(ya288_link)
    # Hier wird zwischen direkten Links und Switch-Links unterschieden
    # bei ersteren müssen wir den 288-Ordner noch wegnehmen
    ya288_dir = File.dirname(folder288) if ( folder288 and ya288_link =~ /\/288$/ )
    possible_288_link_locations.each do |link|
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

# deprecated:
create_link YAY_ENTRY_DIR, "#{HOME}/222"
create_link YAY_ENTRY_DIR, "/222"

ya288_dir = ARGV[0] || ya288_dir  # robuster machen
ya288_link = "#{YAY_SWITCH_DIR}/ya288"

if ya288_dir
  create_dir_unless_exists ya288_dir 
  #create_link_unless_exists ya288_dir, "/288"  
  # Hier Orts-Änderung einbauen, falls Link schon existiert!
  create_link_unless_exists ya288_dir, ya288_link
  create_dir_unless_exists "#{ya288_link}/288"
end

ya233_dir = ya288_dir
ya233_link = "#{YAY_SWITCH_DIR}/ya233"
if ya233_dir
  create_link_unless_exists ya233_dir, ya233_link
  create_dir_unless_exists "#{ya233_link}/233"
end

move_and_symlink_or_ensure_correctness "#{install_ziel_dir}/Downloads", "#{HOME}/Downloads"

if File.symlink?(ya288_link)
  puts "Performing ya288 actions"
  # this is now maintained solely through git:
  # move_and_symlink_or_ensure_correctness "#{ya288_link}/288/bin/",                "#{HOME}/bin"
  
  create_dir_unless_exists       "#{ya288_link}/288/yc-dot/"
  move_and_symlink_or_ensure_correctness "#{ya288_link}/288/yc-dot/twinkle/",     "#{HOME}/.twinkle"
  move_and_symlink_or_ensure_correctness "#{ya288_link}/288/yc-dot/sflphone/",    "#{HOME}/.config/sflphone"
  move_and_symlink_or_ensure_correctness "#{ya288_link}/288/yc-dot/bash_aliases", "#{HOME}/.bash_aliases"
else
  puts "no symlink creation for 288, because #{ya288_link} does not exist."  
end

if File.symlink?(ya233_link)
  puts "Performing ya233 actions"
  move_and_symlink_or_ensure_correctness "#{ya233_link}/233/conf-akonadi/",       "#{HOME}/.config/akonadi"
  # Die folgende Verlinkung würde den Akonadi-Server lahmlegen
  # move_and_symlink_or_ensure_correctness "#{ya233_link}/233/loc-sh-akonadi/",     "#{HOME}/.local/share/akonadi"

  move_and_symlink_or_ensure_correctness "#{ya233_link}/233/kde-config/",         "#{HOME}/.kde/share/config"
  
  create_dir_unless_exists       "#{HOME}/.kde/share/config-local"  
  Dir["#{HOME}/.kde/share/config/plasm*"].each do |komplett_name|
    puts "plasma: " + komplett_name
    basename = File.basename(komplett_name)
    move_and_symlink_or_ensure_correctness "#{HOME}/.kde/share/config-local/#{basename}",     komplett_name
  end	
else
  puts "no 233-symlink creation, #{ya233_link} does not exist."  
end


SEGMENTS.each do |segment|
  # Weniger hart "/dat/aaa" verdrahten:
  create_link_unless_exists install_ziel_dir, "#{YAY_SWITCH_DIR}/ya#{segment}"
  create_dir_unless_exists "#{YAY_SWITCH_DIR}/ya#{segment}/#{segment}"
  
  create_link "#{YAY_SWITCH_DIR}/ya#{segment}/#{segment}", "#{YAY_ENTRY_DIR}/#{segment}"
end

  move_and_symlink_or_ensure_correctness "/111/ye-sys/kmail-neu/local-mail/",     "#{HOME}/.local/share/local-mail"
