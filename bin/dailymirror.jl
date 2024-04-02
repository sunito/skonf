
#const LOCS = Dict(:ynil=>:WANGELAD, :yeta=>:N330WD1B, :ykes=>:N330WD1C, :ygra=>:Seagate5, :yrin=>:N330WD1A)
#const  LOCS = Dict(:ynil=>:WANGELAD, :ykia=>:N330WD1B, :ykes=>:N330WD1C, :ygra=>:Seagate5, :yrin=>:N330WD1A)
const  LOCS = Dict(:y2tt=>:"2T_DAT", :ynil=>:WANGELAD, :ykia=>:N330WD1B, :ykes=>:N330WD1C, :ygra=>:Seagate5, :yrin=>:N330WD1A)

if length(ARGS) < 2
  println(LOCS)
  exit(2)
end
const LABEL   = LOCS[Symbol(ARGS[1])]
const SUFFIX  = ARGS[2]

@show (LABEL, SUFFIX)

if run(ignorestatus(`grep /gup /proc/mounts`)).exitcode == 0 
  println("/gup war schon eingehängt, unmount erstmal")
  run(`umount /gup/`)
  sleep(0.5)
end

#run(`akonadictl stop`)
#run(`killall kmail`)

run(`mount -L $(LABEL) /gup/`)

sleep(0.5)

if false
#if run(`grep /gup /proc/mounts`).exitcode != 0 
  run(`mount /gup/`)
end
@show run(`grep /gup /proc/mounts`)

println()
if run(`grep /gup /proc/mounts`).exitcode == 0 
  println("/gup ist eingehängt --  los geht's")
else
  println("/gup ist nicht eingehängt")
  exit(2)
end

rufen() = run(`play /111/Produktion/maja1-8.wav`, wait=false)

println("run(`kilkm`)")
run(`df`)

run(`date`)
println("--------------- root ---------------")
run(ignorestatus(`time sudo rsync -avx --delete  --exclude baloo/index --exclude .cache/mozilla --exclude CacheStorage / /gup/tuxaura2-root$(SUFFIX)`))
rufen()
run(`df`)
run(`date`)

run(`date`)
println("--------------- /dat ---------------")
run(ignorestatus(`time sudo rsync -avx --delete  /dat/ /gup/vivosus-dat$SUFFIX`))
rufen()
if run(ignorestatus(`grep /fdat /proc/mounts`)).exitcode != 0 
  run(`mount /fdat/`)
end
run(`df`)

run(`date`)
println("--------------- /fdat/b,c ---------------")
run(ignorestatus(`time sudo rsync  -avx --delete  --exclude baloo/index --exclude aaa  /fdat/ /gup/vivosus-fdat`))
rufen()
run(`df`)



run(`umount /gup/`)


#gupkomplett1
#
