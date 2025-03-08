for i in *.sqfs; do dir=`sh -c "echo ${i} | sed 's/.sqfs//g'"`; sudo mkdir -p /srv/datasets/${dir}; sudo umount /srv/datasets/${dir}; done
