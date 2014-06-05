#!/usr/bin/env bash
#
#  place this script in ~/.dynhomeip
#  and generate a cronjob e.g. for every 10 minutes to check your ip-address
#  create also a ~/ftp.login file with your ftp credentials and ftp-server
#  the only thing you need is a webspace to upload the redirect.html file
#  have fun

ftplogin () {
	if [ -f ~/ftp.login ]; then
		# first line of your ftp.login should be LOGINNAME:PASSWORD
		readonly FTPLOGIN=$(awk 'NR==1' ~/ftp.login)
		# second line of your ftp.login should point to your ftpserver incl. path like	
		# ftpserver.example.com/upload_path/
		readonly FTPSERVER=$(awk 'NR==2' ~/ftp.login)
	else 
		echo "please create your ~/ftp.login"
	fi
}

getip () {
	# \o/ duckduckgo - let's get our current ip address
	liveip=$(curl -s https://duckduckgo.com/?q=my+ip+address | egrep -o '([[:digit:]]{1,3}\.){3}[[:digit:]]{1,3}')
	
	if [ ! -f myip ]; then
		echo $liveip >myip
	fi 
	
	myip=$(< myip)
}

main () {
	ftplogin
	getip
	if [ "$liveip" != "$myip" ]; then 
		# ip changed write to myip
	        echo $liveip >myip
		# read new ip and write a html file with a forwarder to your new ip
		newip=$(head -1 myip)
		printf -v HTML %s '<html>\n<head>\n<meta http-equiv="refresh" content="0; URL=http://' ${newip} '">\n</head>\n</html>';
		echo -e $HTML >redirect.html
	
		# upload redirect.html file to your webspace
		# -k means there is no certificate check, this can be insecure
		curl -s -S --ssl-reqd -u $FTPLOGIN ftp://$FTPSERVER -k -T redirect.html
	
		# if your ftp doesn't support tls use this 
		# curl -s -S -u $FTPLOGIN ftp://$FTPSERVER -T redirect.html
	
	fi
}

main

exit
