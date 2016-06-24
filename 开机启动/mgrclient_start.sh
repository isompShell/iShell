#!/bin/bash

if ! grep -i "mgrclient.sh" /usr/local/bin/start.sh;then
	echo -e "/usr/local/client/mgrclient.sh" >>/usr/local/bin/start.sh
fi
java -jar /usr/local/client/mgr_client.jar >/dev/dull &