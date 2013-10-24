#!/usr/bin/env ruby
# encoding: UTF-8
 
require 'Qt4'
require 'fileutils'

require 'iconv'

=begin
begin
File.open("/home/hans/fototrans_out.log", "w") do |f|
   f.puts ARGV.inspect
   f.puts ENV.inspect
end
rescue
  p $!
end
=end

def trc kind, what=:_nonXistent
  if what==:_nonXistent
    puts kind
  else
    puts "#{kind}: #{what.inspect}"
  end
end

class Transfer
  attr_reader :fehlermeldung
  def initialize
#    unless @sd_card_path 
      sd_card_paths = Dir["/media/*"].map do |pfad|
	trc :pfad, pfad
	ziel = File.join( pfad, "DCIM")
	ziel if File.directory?(pfad) and pfad !~ /cdrom/i and File.directory?(ziel)
      end.compact
      trc :sd_card_path, @sd_card_path
      if sd_card_paths.size > 1
	@fehlermeldung = Iconv.conv("LATIN1", "UTF8", "Es sind mehrere Foto-Karten angeschlossen.\nBitte alle zur Zeit nicht benötigten entfernen!")
      elsif sd_card_paths.empty?
        @fehlermeldung = "Keine Digitalkamera-Karte gefunden"
      else
	@fehlermeldung = nil
	@sd_card_path = sd_card_paths.first
      end

 #   end
    #raise "Absturz-Test"    
  end
  
  def target_base_dir
    [
      "/dat/Sabine/Bilder/", # Sabine
      "/yay/422/Fotos/",  # Sven
      "/dat/Static/sPana/",  # Sven old
      "/fest/Static/sPana/", # Sven very-old
      "/daten/Eigene/Fotos",  # Mapa
      "#{ENV['HOME']}/Bilder/"
    ].find do |dir|
      File.exist?(dir)
    end
  end
  
  def sd_card_path 
    @sd_card_path
  end
  
  def start(content_desc)
    { 'ä' => 'ae',
      'ö' => 'oe',
      'ü' => 'ue',
      'Ä' => 'Ae',
      'Ö' => 'Oe',
      'Ü' => 'Ue',
      'ß' => 'sz'
    }.each do |umlaut, ersatz|
      content_desc = content_desc.gsub(Iconv.conv("LATIN1", "UTF8", umlaut), ersatz)
    end
    @content_desc = content_desc.gsub(/[^\w\d.+-_]/i, "-")    
    
    erg = "nix"
    begin
      return "Keine Fotokarte gefunden" unless File.exist?(sd_card_path)      
    
      vorhandene_fotoordner = Dir.entries(sd_card_path).grep(/^\d\d\d[_\w\d]+/)
      trc :vorhandene_fotoordner, vorhandene_fotoordner
      return "Fotokarte hat keine Bilder von einer Digitalkamera" if vorhandene_fotoordner.empty?
      
      all_fotos = vorhandene_fotoordner.map do |foto_folder|
        trc :source_path, foto_folder
        Dir[File.join(sd_card_path, foto_folder, "*")].to_a
      end.flatten
      
      foto_count = all_fotos.size
      return "Keie Fotos gefunden" if foto_count == 0
      
      # best_time = Time.now
      # best_time = File.mtime(all_fotos.last)
      mod_times = all_fotos.map{|f|File.mtime(f)}.sort
      best_time = mod_times.last
      
      dat_format = "%Y-%m-%d"
      "Fotos von #{mod_times.first.strftime(dat_format)} bis #{mod_times.last.strftime(dat_format)}"
      # 2013-06-29: Todo: diesen String anzeigen!
      
      target_path = File.join( target_base_dir, "#{best_time.strftime('%Y')}/#{best_time.strftime('%Y-%m-%d')}_#{@content_desc}")
      trc :target_path, target_path 
      
      FileUtils.mkpath target_path

      all_fotos.each_with_index do |foto_file_name, idx| 
        trc :src_item, foto_file_name
        erg = FileUtils.mv foto_file_name, File.join(target_path, File.basename(foto_file_name))
        sleep 0.01	
        yield [foto_file_name,    (idx+1) * 300 / foto_count]   
      end
      erg = "#{foto_count} Dateien übertragen"
    rescue
      trc :error, $!
      trc $!.backtrace.join("\n"), ""
      return $!
    end
    "Erfolg: #{erg}" 
  end
end # Transfer

notfall_label = notfall_fenster = nil

app = Qt::Application.new(ARGV) do
  notfall_fenster = Qt::Widget.new do
    self.window_title = 'Fehler'
    resize(600, 80)

    notfall_label = Qt::Label.new("Fehler aufgetreten")
    empty_space = Qt::Label.new
    contact_info_label = Qt::Label.new("Bitte Sven informieren: 039881-49194 oder fototrans2013@suska.org")
    quit_button = Qt::PushButton.new('Beenden') do
      connect(SIGNAL :clicked) { Qt::Application.instance.quit }
    end
    self.layout = Qt::VBoxLayout.new do
      add_widget(notfall_label, 0, Qt::AlignCenter)
      add_widget(empty_space, 0, Qt::AlignCenter)
      add_widget(contact_info_label, 0, Qt::AlignRight)
      add_widget(quit_button, 0, Qt::AlignRight)
    end    
  end
end

begin
  haupt_fenster = Qt::Widget.new do

    self.window_title = 'Fototransfer v1.0.1'
    resize(400, 100)

    quit_button = Qt::PushButton.new('Beenden') do
      connect(SIGNAL :clicked) { Qt::Application.instance.quit }
    end

    source_label = Qt::Label.new('')
    target_label = Qt::Label.new('')
    empty_space = Qt::Label.new
    

    transfer = nil
    
    init_folders = proc do
      transfer = Transfer.new
      if transfer.sd_card_path
        source_label.text = "<font color=grey>Quelle: #{transfer.sd_card_path}</color>"
        target_label.text = "<font color=grey>Ziel: #{transfer.target_base_dir.to_s}</color>"
        true
      else
        source_label.text = transfer.fehlermeldung 
        false
      end
    end  
    
    if init_folders.call
      main_label = Qt::Label.new('<big>Was ist auf den Fotos?   (kurz, wenige Worte)</big>')
      beschr_edit = Qt::LineEdit.new(self)
      beschr_edit.size = 300
      fortschritt_pbar =  Qt::ProgressBar.new(self)
      fortschritt_pbar.width = 300
      fortschritt_pbar.minimum = 0
      fortschritt_pbar.maximum = 300
 
      transf_button = Qt::PushButton.new('Hier klicken um Fotos zu verschieben') do
        self.width = 300
        connect(SIGNAL :clicked) do 
          main_label.text = "Beginne :" + beschr_edit.text
	  
          result = transfer.start(beschr_edit.text) do |foto_file_name, fortschritt_prozent|
            fortschritt_pbar.value = fortschritt_prozent
            main_label.text = foto_file_name.sub(/^.+...(.{30})/, '...\1')
          end
          main_label.text = result
          #Qt::Application.instance.quit 
        end
      end
    end
    

    self.layout = Qt::VBoxLayout.new do
      add_widget(source_label, 0, Qt::AlignLeft)
      add_widget(target_label, 0, Qt::AlignLeft)
      add_widget(empty_space, 0, Qt::AlignCenter)
      add_widget(main_label, 0, Qt::AlignCenter)
      add_widget(beschr_edit, 0, Qt::AlignCenter)
      add_widget(transf_button, 0, Qt::AlignLeft)
      add_widget(fortschritt_pbar, 0, Qt::AlignRight)
      add_widget(quit_button, 0, Qt::AlignRight)
    end    
  end
  
  
  haupt_fenster.show
  
rescue
  trc :globalerror, $!
  trc $!.backtrace
  notfall_label.text = "#{$!}"
  notfall_fenster.show
end


if __FILE__ == $0
    #p transfer("Versuch2")
    app.exec
end  
