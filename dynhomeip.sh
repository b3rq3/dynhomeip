#!/usr/bin/env bash
#
#  place this script in ~/.dynhomeip
#  and generate a cronjob e.g. for every 10 minutes to check your ip-address
#  create also a ftp.login file with your ftp credentials and ftp-server in ~/.dynhomeip 
#  the only thing you need is a webspace to upload the redirect.html file
#  have fun

FTPLOGIN=`awk 'NR==1' ftp.login`
FTPSERVER=`awk 'NR==2' ftp.login`

# \o/ duckduckgo - let's get our current ip address
LIVEIP=`curl -s https://duckduckgo.com/?q=my+ip | egrep -o '([[:digit:]]{1,3}\.){3}[[:digit:]]{1,3}'`

if [ ! -f myip ]; then
	echo $LIVEIP >myip
fi 

MYIP=`head -1 myip`

if [ "$LIVEIP" != "$MYIP" ]; then 
	# ip changed write to myip
        echo $LIVEIP >myip
	# read new ip and upload a html file with a forwarder to your new ip
	NEWIP=`head -1 myip`
	printf -v HTML %s '<html>\n<head>\n<meta http-equiv="refresh" content="0; URL=http://' ${NEWIP} '">\n</head>\n</html>';
	echo -e $HTML >redirect.html

	# upload redirect.html file to your webspace
	# -k means there is no certificate check, this can be insecure
	curl -s -S --ssl-reqd -u $FTPLOGIN ftp://$FTPSERVER -k -T redirect.html

	# if your ftp doesn't support tls use this 
	# curl -s -S -u $FTPLOGIN ftp://$FTPSERVER -T redirect.html

	#rm -f redirect.html
fi

exit

