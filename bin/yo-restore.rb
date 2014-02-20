#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/yo-defs'



def restore_link(target_name, link_name)
  if File.symlink?(link_name)
    if symlink_target(link_name) == target_name
      return # OK
    else
      delete_link_if_exists link_name
    end
  end

  if File.exist?(link_name) 
    # kann hier kein Link mehr sein
    File.rename(link_name, link_name + "_sav" + Time.now.strftime("-%Y%m%d-%H%M"))
  end
  File.symlink(target_name, link_name)
  puts "#{target_name} --> #{link_name}"
end

pairs = %w[
  /111/ye-sys/kabc-neu/                  ~/.kde/share/apps/kabc
  
  /111/ye-sys/kmail-neu/                 ~/.kde/share/apps/kmail
  /111/ye-sys/kmail-neu/kmailrc          ~/.kde/share/config/kmailrc
  /111/ye-sys/kmail-neu/kmail2rc         ~/.kde/share/config/kmail2rc
  /111/ye-sys/kmail-neu/emaildefaults    ~/.kde/share/config/emaildefaults
  /111/ye-sys/kmail-neu/emailidentities  ~/.kde/share/config/emailidentities 
  /111/ye-sys/kmail-neu/mailtransports   ~/.kde/share/config/mailtransports
  /111/ye-sys/kmail-neu/ye-signaturen/   ~/.mail-signaturen
  
  /111/ye-sys/mozilla-neu/       ~/.mozilla  

  /yay/211/ye-vbox/dotVirtualBox  ~/.VirtualBox

  
].inject([[]]) do |result, new_val|
  if result.last.size < 2 
    result.last << new_val
  else
    result << [new_val]
  end
  result
end


pairs.each do |target_name, link_name|
  restore_link target_name, link_name.sub("~", ENV["HOME"])
end

