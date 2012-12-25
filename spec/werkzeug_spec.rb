# encoding: utf-8

require 'werkzeug'

class String
  unless method_defined?(:grep)
    def grep(regexp)
      split("\n").grep(regexp)
    end
  end
end

describe Werkzeug do
  before(:each) do
    @random = rand(222)
    @dateiname = "test_konfig_datei_#{@random}.ini"
    File.open(@dateiname, "w") do |datei|
      datei.puts "nase=w22tralala"
      datei.puts "name=wert1"
      datei.puts "na.e=w99"      
      datei.puts "name_B=wert#{@random}"
    end
    @werkzeug = Werkzeug.new(@dateiname)
  end
  after(:each) do
    File.delete(@dateiname)
  end

  it "sollt eexistierendeEinträge ändern" do
    vorher = File.read(@dateiname)
    vorher.grep(/name=wert1/).should_not be_empty
    vorher.grep(/name_B=wert#{@random}/).should_not be_empty
    @werkzeug.setze("name", "wert2")
    nachher = File.read(@dateiname)
    nachher.grep(/name=wert2/).should_not be_empty
    nachher.grep(/name=wert1/).should be_empty
    nachher.grep(/name_B=wert#{@random}/).should_not be_empty
  end

  it "sollte auch Namen mit speziellen Zeichen korrekt behandeln" do
    vorher = File.read(@dateiname)
    vorher.grep(/na\.e=w99/).should_not be_empty
    vorher.grep(/name=wert1/).should_not be_empty
    vorher.grep(/name_B=wert#{@random}/).should_not be_empty
    @werkzeug.setze("na.e", "w_punkt_neu")
    nachher = File.read(@dateiname)
    puts File.read(@dateiname)
    
    nachher.grep(/na\.e=w_punkt_neu/).should_not be_empty
    nachher.grep(/na\.e=w99/).should be_empty
    
    nachher.grep(/name=wert1/).should_not be_empty
    nachher.grep(/name_B=wert#{@random}/).should_not be_empty
  end

  it "sollte in echt funktionieren" do
    vorher = File.read(@dateiname)
    vorher.grep(/name=wert1/).should_not be_empty
    puts system "ini_setzen.rb #{@dateiname} name wert2"
    nachher = File.read(@dateiname)
    nachher.grep(/name=wert2/).should_not be_empty


  end

end

