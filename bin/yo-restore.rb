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

yesys_dir = "/111/ye-sys"
create_dir_unless_exists yesys_dir
kmail_dir = yesys_dir / "kmail-neu"
create_dir_unless_exists kmail_dir
ako_config = yesys_dir / "akonadi-konfig"
create_dir_unless_exists ako_config

pairs = [
  # ["/111/ye-sys/kabc-neu/",                "~/.kde/share/apps/kabc"], veraltet
  
  # ["/111/ye-sys/kmail-neu/",               "~/.kde/share/apps/kmail"], veraltet
  #["/111/ye-sys/kmail-neu/kmailrc,          "~/.kde/share/config/kmailrc"], veraltet

  [kmail_dir / "local-mail",                  "~/.local/share/local-mail"],

  [ako_config / "config_akonadi",            "~/.config/akonadi"], # das ist ein Ordner
    
  [ako_config / "kmail2rc",                  "~/.config/kmail2rc"],
  [ako_config / "emaildefaults",             "~/.config/emaildefaults"],
  [ako_config / "emailidentities",           "~/.config/emailidentities"],
  [ako_config / "mailtransports",            "~/.config/mailtransports"],
  [ako_config / "ye-signaturen",             "~/.mail-signaturen"],
  
  [yesys_dir / "mozilla-neu",                "~/.mozilla"],

  ["/yay/211/ye-vbox/dotVirtualBox",         "~/.VirtualBox"]

  
]
=begin
.inject([[]]) do |result, new_val|
  new_val = new_val.sub('~/.kde', $kde_dir)
  if result.last.size < 2 
    result.last << new_val
  else
    result << [new_val]
  end
  result
=end


pairs.each do |target_name, link_name|
  restore_link target_name, link_name.sub("~", ENV["HOME"])
end

