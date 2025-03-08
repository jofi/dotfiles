for i in *.sqfs; do dir=`sh -c "echo ${i} | sed 's/.sqfs//g'"`; sudo mkdir -p /srv/datasets/${dir}; sudo mount -t squashfs -o loop ${i} /srv/datasets/${dir}; done
