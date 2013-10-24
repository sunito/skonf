#!/usr/bin/env ruby

pfad = "/dat/Jobs/je/redmine"

$stdout.sync = true

system "#{pfad}/script/server -p3142"  #-eproduction

