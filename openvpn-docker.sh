#!/usr/bin/env bash


set -e
set -x
docker ps

OVPN_DATA=openvpn

IMAGE=navilg0409/openvpn
TAG=21.03.07

docker volume create --name $OVPN_DATA

read -p "Enter DNS (example: openvpn.example.com): " dns

docker run -v $OVPN_DATA:/etc/openvpn --rm $IMAGE:$TAG ovpn_genconfig -u udp://$dns

docker run -v $OVPN_DATA:/etc/openvpn --rm -it $IMAGE:$TAG ovpn_initpki

docker run -v $OVPN_DATA:/etc/openvpn -d -p 1194:1194/udp --cap-add=NET_ADMIN --restart=always $IMAGE:$TAG

read -p "Enter client name: " CLIENTNAME

docker run -v $OVPN_DATA:/etc/openvpn --rm -it $IMAGE:$TAG easyrsa build-client-full $CLIENTNAME nopass

docker run -v $OVPN_DATA:/etc/openvpn --rm $IMAGE:$TAG ovpn_getclient $CLIENTNAME > $CLIENTNAME.ovpn
