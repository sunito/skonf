
require "fileutils"

require File::dirname(__FILE__) + '/yo-defs'

def rsync quelle, ziel, optionen
  rsync_zusatz_opts = if optionen[:update] 
    '--update --exclude=".*.swp"'
  else
    '--delete --exclude "*/Cache/*"'
  end
  anf_zeit = Time.now

  # ensure that rsync syncs _with_ ant not _into_ the target
  quelle = quelle + "/" unless quelle =~ /\/$/
  
  befehlszeile = "rsync -av #{rsync_zusatz_opts} #{quelle} #{ziel}"
  puts "#{anf_zeit} >>> #{befehlszeile}"
  
  erg = system befehlszeile
  
  end_zeit = Time.now
  puts "#{end_zeit} <<< rsync -av #{rsync_zusatz_opts} #{quelle} #{ziel}"
  puts (Time.local(2000,1,1,0,0) + (end_zeit - anf_zeit)).strftime("%H:%M:%S")
  puts
  erg
end

def tokenpfad(pfad, aktiv_art=:aktiv) 
  File.join(pfad, "yo_#{aktiv_art}")
end

def aktiviere pfad="/111/", ziel_aktiv_art=:aktiv
  aktuelle_aktiv_art = "in#{ziel_aktiv_art}".sub("inin","").to_sym
  FileUtils.move tokenpfad(pfad, aktuelle_aktiv_art), tokenpfad(pfad, ziel_aktiv_art)
  puts "#{pfad} (-->#{symlink_target(YAH111_LINK)}) ist jetzt #{ziel_aktiv_art}"
  puts
end

def expandiere_basis_pfad pfad_angabe
  erg = case pfad_angabe
  when "+loc"
    "/dat/aaa"
  when "+lbu"
    local_backup_main_paths = %w[/cur /dat]
    local_backup_dirs = %w[ye-mirror ye-backup]
    target_pfad = 
	local_backup_main_paths.find do |main_path|
	  e = local_backup_dirs.find do |dir|
	    pfad = File.join( main_path, dir ) 
	    break pfad if File.exist?( pfad )
	  end
	  break e if e
	end
    target_pfad or raise "none of the predifined lbu locations #{local_backup_dirs.inspect} exist in #{local_backup_main_paths.inspect}."
  when "+ext"
    Dir["/media/*"].find do |pfad|
      ziel = File.join( pfad, "aaa")
      break ziel if File.directory?(pfad) and
        pfad !~ /cdrom/i and
        File.exist?(ziel)
    end 
  else
    pfad_angabe
  end
  
  if File.basename(erg) =~ /aaa/
    erg
  else
    File.join( erg, "aaa")
  end
end

def update288 argv
# ToDo: Besser formulieren
  main_part = argv.grep(/(111\+?=)?[^=\s]+/).first
  main_path = main_part.split("=").last
  do_multi :update_both, ["288=#{main_path}"]
end

# ToDo: Konsolidieren der Optionenübergabe!!
#       Bei jedem segment oder einmal für alle??
def argv_to_hash argv
  opts = argv.grep /^-/
  places = (argv - opts)
  erg = {}
  places.each do |place_spec|
    wo, was = place_spec.split(/=/).reverse
    was ||= "111"
    erg[was] = wo, opts
  end
  [erg, opts]
end

def do_multi meth_sym, argv
  places_hash, opts = argv_to_hash(argv)  
  places_hash.each do |was, (wohin, opts)  |
    sy = Syncronizer.new(was, wohin, opts)
    sy.send meth_sym
  end
  
  
end

def sync_multi argv
  do_multi :sync_to, argv
end

class Syncronizer
  def initialize(segment, wohin, default_opts=[])
    @segment = segment
    @ziel_basis_pfad = expandiere_basis_pfad(wohin)
    @default_opts = default_opts
    
    @link_basis_pfad = File.join YAY.SWITCH_DIR, "ya#{segment}"

  end
  attr_reader :segment, :ziel_basis_pfad

  def link_segment_pfad
    File.join( @link_basis_pfad, segment)
  end
  
  def ziel_segment_pfad
    File.join( ziel_basis_pfad, segment)
  end
               
  def switch_to 
    puts "Schalte ya#{segment} auf: #{ziel_basis_pfad.inspect}"
    FileUtils.rm @link_basis_pfad rescue puts "Fehler beim Entfernen des alten Symlinks: #{$!}"
    FileUtils.symlink ziel_basis_pfad, @link_basis_pfad
    #File.symlink ziel_basis_pfad, basis_link_pfad
    #`ln -s #{ziel_basis_pfad} #{basis_link_pfad}`
  end

  def sync_to 
    raise "auf #{ENV["HOSTNAME"]} ist aktueller Store nicht verf?gbar" unless File.exist?(link_segment_pfad)
    raise "aktueller Store ist nicht aktiv" unless File.exist?(tokenpfad(link_segment_pfad))
    raise "Ziel #{ziel_segment_pfad} existiert nicht" unless File.exist?(ziel_segment_pfad)
    
    verlaufdatei_pfad = File.join(ziel_basis_pfad, "yo_verlauf.log")
    #system("touch " + verlaufdatei_pfad) unless File.exist? verlaufdatei_pfad

    backup_only = @default_opts.include?("--backup") 

    sync_error_code = nil
    File.open(verlaufdatei_pfad, "a") do |f|
      f.puts
      f.print Time.now
      f.print " von: #{`hostname`.strip}, nach: #{ziel_segment_pfad}"      

      aktiviere( link_segment_pfad, :inaktiv) unless backup_only

      sync_error_code = rsync link_segment_pfad, ziel_segment_pfad, {}      
      puts sync_error_code 
      
      if !sync_error_code
        puts "\n!!Synchronisierung fehlgeschlagen!!"
        puts "Abbruch."
        raise "Fehler beim rsync-Kommando"
      end
      
      f.print " OK "
      f.print Time.now
    end

    unless backup_only
      aktiv_pfad = ziel_segment_pfad
      FileUtils.move tokenpfad(aktiv_pfad, :inaktiv), tokenpfad(aktiv_pfad) 

      switch_to
    end
    
  end # sync_to
  
  def update_both
    bei111_segment_pfad = File.join( YAY.SWITCH_DIR, "ya111", segment)
    rsync bei111_segment_pfad, ziel_segment_pfad, {:update=>true}
    rsync ziel_segment_pfad, bei111_segment_pfad, {:update=>true}
  end    

end # class Syncronizer

# legacy:
def sync_nach ziel_basis_pfad, opts
  ziel_basis_pfad = expandiere_basis_pfad ziel_basis_pfad
  quell_111_pfad = "/111/"
  ziel_111_pfad = File.join(ziel_basis_pfad, "111/")
  raise "auf #{ENV["HOSTNAME"]} ist aktueller Store nicht verf?gbar" unless File.exist?(quell_111_pfad)
  raise "aktueller Store ist nicht aktiv" unless File.exist?(tokenpfad(quell_111_pfad))
  raise "Ziel #{ziel_111_pfad} existiert nicht" unless File.exist?(ziel_111_pfad)
  verlaufdatei_pfad = File.join(ziel_basis_pfad, "yo_verlauf.log")
  #system("touch " + verlaufdatei_pfad) unless File.exist? verlaufdatei_pfad

  backup_only = opts.include?("--backup") 

  sync_111_ok = nil
  File.open(verlaufdatei_pfad, "a") do |f|
    f.puts
    f.print Time.now
    f.print " von: #{`hostname`.strip}, nach: #{ziel_basis_pfad}"
    

    aktiviere quell_111_pfad, :inaktiv

    sync_111_ok = rsync quell_111_pfad, ziel_111_pfad, {}
    
    puts sync_111_ok 
    if !sync_111_ok
      puts 
      puts "Synchronisierung fehlgeschlagen!!"
      puts "Abbruch."
      raise "Fehler beim rsync-Kommando"
    end
    
    f.print " OK "
    f.print Time.now
      

    aktiv_pfad = backup_only ? quell_111_pfad : ziel_111_pfad
    FileUtils.move tokenpfad(aktiv_pfad, :inaktiv), tokenpfad(aktiv_pfad)
    
  end

  quell_288_pfad = "/288/"
  ziel_288_pfad = File.join(ziel_basis_pfad, "288/")
  rsync quell_288_pfad, ziel_288_pfad, {:update=>true}

  if sync_111_ok and not backup_only then
    schalte_auf ziel_basis_pfad
  end
  
end

# legacy:
def schalte_auf ziel_pfad
    puts "Schalte yah auf: #{ziel_pfad}"
    yah_pfad = "#{YAY.SWITCH_DIR}/yah"
    FileUtils.rm yah_pfad rescue puts "Fehler beim Entfernen des alten Symlinks: #{$!}"
    FileUtils.symlink ziel_pfad, yah_pfad
end

