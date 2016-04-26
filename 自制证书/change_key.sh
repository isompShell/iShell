#!/bin/bash
USER=$2
COMMAND=$1
CLIENT_FILE1=/etc/simp_fort/cacenter/client/client-cert.${USER}.pem
CLIENT_FILE2=/etc/simp_fort/cacenter/client/client-key.${USER}.pem
CLIENT_FILE3=/etc/simp_fort/cacenter/client/client-req.${USER}.csr
CLIENT_FILE4=/etc/simp_fort/cacenter/client/client.${USER}.p12

returns_the_result (){
case $? in 
    2)
      echo "2,,Already revoked.";exit 2
    ;;



esac
}



client_add(){
expect -c "
spawn openssl genrsa -out /etc/simp_fort/cacenter/client/client-key.${USER}.pem 2048
expect \#
">/dev/null
expect -c "
spawn openssl req -new -out /etc/simp_fort/cacenter/client/client-req.${USER}.csr -key /etc/simp_fort/cacenter/client/client-key.${USER}.pem

expect \"Country\ Name\" { send \"cn\n\"}

expect \"State\ or\ Province\ Name\" { send \"beijing\n\"}

expect \"Locality\ Name\" {send \"beijing\n\"}

expect \"Organization\ Name\" {send \"isomp\n\"}

expect \"Organizational\ Unit\ Name\" {send \"isomp\n\"}

expect \"Common\ Name\" {send \"${USER}\n\"}

expect \"Email\ Address\" {send \"isomp@isomp\n\"}

expect \"A\ challenge\ password\" {send \"123456\n\"}

expect \"An\ optional\ company\ name\" {send \"isomp\n\"}

expect \#
">/dev/null
expect -c "
spawn openssl x509 -req -in /etc/simp_fort/cacenter/client/client-req.${USER}.csr -out /etc/simp_fort/cacenter/client/client-cert.${USER}.pem -signkey /etc/simp_fort/cacenter/client/client-key.${USER}.pem -CA /etc/simp_fort/cacenter/server/ca/ca-cert.pem -CAkey /etc/simp_fort/cacenter/server/ca/ca-key.pem -CAcreateserial -days 3650


expect \#

">/dev/null
expect -c "
spawn openssl pkcs12 -export -clcerts -in /etc/simp_fort/cacenter/client/client-cert.${USER}.pem -inkey /etc/simp_fort/cacenter/client/client-key.${USER}.pem -out /etc/simp_fort/cacenter/client/client.${USER}.p12
expect \"*assword:\" {send \"123456\n\"}
expect  \"*assword:\" {send \"123456\n\"}
expect \#

">/dev/null
}

client_del(){
expect -c "
spawn openssl ca -keyfile /etc/simp_fort/cacenter/server/ca/ca-key.pem -cert /etc/simp_fort/cacenter/server/ca/ca-cert.pem -revoke /etc/simp_fort/cacenter/client/client-cert.${USER}.pem
expect \"unable\ to\ load\ certificate\" {exit 2} 
">/dev/null
returns_the_result
rm -rf  ${CLIENT_FILE1}
rm -rf  ${CLIENT_FILE2}
rm -rf  ${CLIENT_FILE3}
rm -rf  ${CLIENT_FILE4}

}
client_cat(){
expect -c "
spawn openssl x509 -noout -text -in /etc/simp_fort/cacenter/client/client-cert.${USER}.pem

expect \"unable\ to\ load\ certificate\" {exit 2} 

"
returns_the_result




}
case $COMMAND in
     add)
         client_add   
      ;;
     del)
         client_del
     ;;
     cat)
         client_cat 
     ;;
     *)
        echo "3,,Parameter error";exit 3
esac      



