 #!/bin/bash
folder='/pathto/watchfolder/'
# -m monitor
# -q quiet
# -e quiet
 
inotifywait -m -q -e create $folder | while read file
        do
                echo "changes detected"
                myfile=`echo $file | cut -d ' ' -f3`
                path=`echo $folder$myfile`
                grep 'this is it' $path
        done

