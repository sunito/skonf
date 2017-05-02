#!/usr/bin/env ruby
# encoding: UTF-8
 
#require 'thread' # workaround for NameError: "const_missing': uninitialized constant Qt::RubyThreadFix::Queue"
#require 'Qt4'
require 'fileutils'

VERSION = "1.0.3"

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
SANDBOX = ARGV.delete("--sandbox")

p SANDBOX

def trc kind, what=:_nonXistent
  if what==:_nonXistent
    puts kind
  else
    puts "#{kind}: #{what.inspect}"
  end
end

class String
  define_method "/" do |rest|
    if empty?
      rest
    else
      File.join( self, rest)
    end
  end
end


IS_SUSE = File.exist? "/run/media"

MEDIA_DIR = if IS_SUSE
  "/run/media"
else
  "/media"
end

class Transfer
  attr_reader :fehlermeldung
  def initialize
      sd_card_paths = (Dir[MEDIA_DIR / "*"] + Dir[MEDIA_DIR / ENV['USER'] / "*"]).map do |pfad|
        trc :pfad, pfad
        ziel = pfad / "DCIM"
        ziel if File.directory?(pfad) and pfad !~ /cdrom/i and File.directory?(ziel)
      end.compact
      if sd_card_paths.size > 1
	      @fehlermeldung = Iconv.conv("LATIN1", "UTF8", "Es sind mehrere Foto-Karten angeschlossen.\nBitte alle zur Zeit nicht benötigten entfernen!")
      elsif sd_card_paths.empty?
        @fehlermeldung = "Keine Digitalkamera-Karte gefunden"
      else
	      @fehlermeldung = nil
	      @sd_card_path = sd_card_paths.first
      end
      if SANDBOX 
        @sd_card_path = "/home/sunito/ft_sandbox/DCIM"
      end
      trc :sd_card_path, @sd_card_path
  end
  
  def target_base_dir
    dirsfile_path = ENV['HOME'] / ".config/user-dirs.dirs"  
    xdg_pictures_dir = if File.exist?(dirsfile_path)
      # ToDo: use `xdg-user-dir PICTURES` 
      File.read(dirsfile_path).scan(/(XDG_PICTURES_DIR) *= *(.*) *$/).first[1]
    else 
      ""
    end
    puts "xdg_pictures_dir: #{xdg_pictures_dir}"
    [
      "/dat/Sabine/Bilder/", # Sabine
      "/aa/533/Fotos/",  # Sven
      "/dat/Eigene/Fotos",  # Mapa
      xdg_pictures_dir,
      "#{ENV['HOME']}/Bilder/",
      "#{ENV['HOME']}/Fotos/"
    ].find do |dir|
      File.exist?(dir)
    end
  end
  
  def sd_card_path 
    @sd_card_path
  end
  
  def start(content_desc)
    p content_desc
    p content_desc.encoding rescue nil
    content_desc_utf8 = content_desc.force_encoding("UTF-8")
    p content_desc_utf8.encoding rescue nil
    { 'ä' => 'ae',
      'ö' => 'oe',
      'ü' => 'ue',
      'Ä' => 'Ae',
      'Ö' => 'Oe',
      'Ü' => 'Ue',
      'ß' => 'sz'
    }.each do |umlaut, ersatz|
      content_desc = content_desc_utf8.gsub(umlaut, ersatz)
      #content_desc = content_desc.gsub(Iconv.conv("LATIN1", "UTF8", umlaut), ersatz)
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
      return "Keine Fotos gefunden" if foto_count == 0
      
      # best_time = Time.now
      # best_time = File.mtime(all_fotos.last)
      mod_times = all_fotos.map{|f|File.mtime(f)}.sort
      best_time = mod_times[mod_times.size/2] # Median
      
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
        yield [foto_file_name,    (idx+1) * 100 / foto_count]   
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
# 
# app = Qt::Application.new(ARGV) do
#   notfall_fenster = Qt::Widget.new do
#     self.window_title = 'Fehler'
#     resize(600, 80)
# 
#     notfall_label = Qt::Label.new("Fehler aufgetreten")
#     empty_space = Qt::Label.new
#     contact_info_label = Qt::Label.new("Bitte Sven informieren: 039881-49194 oder fototrans2013@suska.org")
#     quit_button = Qt::PushButton.new('Beenden') do
#       connect(SIGNAL :clicked) { Qt::Application.instance.quit }
#     end
#     self.layout = Qt::VBoxLayout.new do
#       add_widget(notfall_label, 0, Qt::AlignCenter)
#       add_widget(empty_space, 0, Qt::AlignCenter)
#       add_widget(contact_info_label, 0, Qt::AlignRight)
#       add_widget(quit_button, 0, Qt::AlignRight)
#     end    
#   end
# end

def cmd_zeile_kdialog(args)
  "kdialog " + args.map{|key,val| %Q(--#{key} "#{val.to_s}")}.join(" ")
end

def kdialog args
  `#{cmd_zeile_kdialog(args)}`
end

def fork_kdialog args
  Process.spawn cmd_zeile_kdialog(args)
end

begin
  #haupt_fenster = Qt::Widget.new do
  class Fototrialog

    FENSTERTITEL = "Fototransfer v#{VERSION}"
    #resize(400, 100)

#     quit_button = Qt::PushButton.new('Beenden') do
#       connect(SIGNAL :clicked) { Qt::Application.instance.quit }
#     end

#     source_label = Qt::Label.new('')
#     target_label = Qt::Label.new('')
#     empty_space = Qt::Label.new
    

    #transfer = nil
    
    def init_folders 
      @transfer = Transfer.new
      if @transfer.sd_card_path
        @quellort_text = "Quelle: #{@transfer.sd_card_path}"
        if @transfer.target_base_dir 
          @zielort_text = "Ziel: #{@transfer.target_base_dir.to_s}"
        else
          @zielort_text = "Keinen Ziel-Ordner gefunden! 
                               --> Sven anrufen! (039881-49194) "
        end
        true
      else
        @quellort_text = @transfer.fehlermeldung 
        false
      end
    end  
    
    
    def starte_gui
    #haupt_fenster.show
      if init_folders
        frage_text = "Was ist auf den Bildern? \n(in wenigen Worten)"
        beschreibung = kdialog  title: FENSTERTITEL, inputbox: frage_text
        p beschreibung
        return if beschreibung.strip.empty?
      #beschr_edit = Qt::LineEdit.new(self)
      #beschr_edit.size = 300
      #fortschritt_pbar =  Qt::ProgressBar.new(self)
#       fortschritt_pbar.width = 300
#       fortschritt_pbar.minimum = 0
#       fortschritt_pbar.maximum = 300
 
        knopf_text = 'Hier klicken um die Fotos und Videos zu verschieben'
        erg = kdialog title: FENSTERTITEL, yesno: "Jetzt verschieben: " + beschreibung, :"yes-label" => knopf_text
        p erg
#         self.width = 400  # wirkungslos??
#         self.enabled = false
#         connect(SIGNAL :clicked) do 
#           main_label.text = "Beginne :" + beschr_edit.text
        p 3
 	  #puts kdialog( msgbox: "foto_file_name +  {fortschritt_prozent}%", fork: true)
           vorig_zeit = Time.now - 999
           pid = nil
           result = @transfer.start(beschreibung) do |foto_file_name, fortschritt_prozent|
             if Time.now - vorig_zeit > 1.5
               pid_neu = fork_kdialog msgbox: "#{fortschritt_prozent}% kopiert." #    Aktuelle Datei: " + foto_file_name 
               Process.kill "TERM", pid if pid
               pid = pid_neu
               puts "pid: #{pid.inspect}"
               vorig_zeit = Time.now
             end
#             fortschritt_pbar.value = fortschritt_prozent
#             main_label.text = foto_file_name.sub(/^.+...(.{30})/, '...\1')
           end
           Process.kill "TERM", pid if pid
           p result
           kdialog msgbox: result
#           main_label.text = result
#           self.enabled = false
#           #Qt::Application.instance.quit 
#         end
#       end
      
#       beschr_edit.connect(SIGNAL "textChanged(QString)") do |text|
#         transf_button.enabled = not(text.empty?)
#       end
      end
    end

#     self.layout = Qt::VBoxLayout.new do
#       add_widget(source_label, 0, Qt::AlignLeft)
#       add_widget(target_label, 0, Qt::AlignLeft)
#       add_widget(empty_space, 0, Qt::AlignCenter)
#       add_widget(main_label, 0, Qt::AlignCenter)
#       add_widget(beschr_edit, 0, Qt::AlignCenter)
#       add_widget(transf_button, 0, Qt::AlignLeft)
#       add_widget(fortschritt_pbar, 0, Qt::AlignRight)
#       add_widget(quit_button, 0, Qt::AlignRight)
#     end    
  end
  
  if __FILE__ == $0
    Fototrialog.new.starte_gui
  end  

rescue
  trc :globalerror, $!
  trc $!.backtrace
  kdialog title: "Fehler --- " + Fototrialog::FENSTERTITEL, msgbox: <<-eot
    Es ist ein Fehler aufgetreten. 
    Bitte Sven informieren: 039881-49194 oder fototrans2017@suska.org 

    Fehlermeldung:
    #{$!}
  eot
  #notfall_fenster.show
end


