#for i in `ls */gamelist.xml`
#do
#    echo processing $i ...
#    node gamelist.js $i
#done

for i in `ls */gamelist_en.xml`
do
    echo processing $i ...
    node gamelist.js $i 1
done
