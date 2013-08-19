#!/usr/bin/env bash
#
#  place this script in ~/.dynhomeip
#  and generate a cronjob e.g. for every 5 minutes to check your ip-address
#  well dyndns changed it's service, but we don't need it
#  this script uses curl, egrep to point to your dynamic ip address
#  the only thing you need is a webspace to upload your redirect.html
#  have fun

FTPUSER=""
FTPPWD=""
FTPSERVER=""

# \o/ duckduckgo - let's get our current ip address
LIVEIP=`curl -s https://duckduckgo.com/?q=my+ip | egrep -o '([[:digit:]]{1,3}\.){3}[[:digit:]]{1,3}'`

if [ ! -f myip ]; then
	echo $LIVEIP >myip
fi 

CURRENTIP=`head -1 myip`

if [ $LIVEIP!=$CURRENTIP ]; then 
        echo $LIVEIP >myip
fi

# read myip and upload a html script with a forwarder
MYIP=`head -1 myip`

printf -v HTML %s '<html>\n<head>\n<meta http-equiv="refresh" content="0; URL=http://' ${MYIP} '">\n</head>\n</html>';

echo -e $HTML >redirect.html

# upload redirect.html file to your webspace
#curl --ssl-reqd --ftp-ssl-ccc -u $FTPUSER:$FTPWD ftp://$FTPSERVER/ -v -k -T redirect.html

# delete redirect.html
#rm -f redirect.html
