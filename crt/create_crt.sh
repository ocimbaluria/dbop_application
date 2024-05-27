#!/bin/zsh

openssl genrsa -out ca.key 2048
openssl req -new -x509 -days 365 -key ca.key -subj "/C=CN/ST=GD/L=SZ/O=oracle, Inc./CN=oracle Root CA" -out ca.crt
openssl req -newkey rsa:2048 -nodes -keyout tls.key -subj "/C=CN/ST=GD/L=SZ/O=oracle, Inc./CN=cdb19c-ords" -out server.csr
echo "subjectAltName=DNS:cdb19c-ords,DNS:www.example.com" > extfile.txt
openssl x509 -req -extfile extfile.txt -days 365 -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out tls.crt

kubectl create secret tls db-tls --key="tls.key" --cert="tls.crt"  -n oracle-database-operator-system
kubectl create secret generic db-ca --from-file=ca.crt -n oracle-database-operator-system