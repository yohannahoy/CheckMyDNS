#!/bin/bash

####################################################################################################################
# L'objectif de ce script est de vérifier le bon fonctionnement de votre dyndns notamment en utilisant dnssec      #
####################################################################################################################

#NomDom="XXX.net"
#LstNdM="xx yy zz"
#NomCheck="yyy.net"
#SrvSec="9.9.9.9"

####################################################################################################################
# Obj : Ajout de la couleur pour les résultats                                                                     #
####################################################################################################################

normal=$(tput sgr0)                      # normal text
red="$bold$(tput setaf 1)"                # bright red text
green=$(tput setaf 2)                     # dim green text
white="$bold$gray"                        # bright white text

####################################################################################################################
# Obj : Recherche du champ ad dans la question posée au resolveur                                                  #
####################################################################################################################
#Vérifier que l'adresse obtenue via la consultation d'une page web (https) est identique à celle fournit par le serveur DNS.
# L'objectif est de récupérer l'adresse ip publique à partir d'une page web (autre que wathismyip and co...)
ipfromweb=$(wget -4qO- https://$NomCheck)
ipfromweb=${ipfromweb// /}

# remplacer XX par le sous domaine correspondant au site d'excution de ce script.
ipfromdns=$(dig +short XX.$NomDom @$SrvSec)
echo "Pour le serveur Web (https) : $ipfromdns"

addr=$(wget -4qO- https://$NomCheck)
geoiplookup $addr -f GeoIP.dat

#L'objectif est de soliciter un résolveur DNS qui supporte DNSSEEC et qui est récursif. 
#Le flag ad nous informe de la fiabilité de la réponse.
#La variable ipfromdns contient l'adresse ip déclarée en enregistrement dns.
#A chaque itération, la boucle vérifie les valeurs soumisent dans SdNomDom
for NdSD in $LstNdM; do
	SdNomDom=$NdSD"."$NomDom
	nb=$(dig +dnssec $SdNomDom @$SrvSec |grep flag|grep -c ad)
	if [ $nb -eq 1 ]
		 then
		ipfromdns=$(dig +short $SdNomDom @$SrvSec)
		echo -e "\nPour $NdSD : $ipfromdns"
		geoiplookup $ipfromdns -f GeoIP.dat
	else
		echo -e "\n${red}Votre resolveur n'a pas validé l'authenticité de votre adresse ip dynamique${normal}"
	fi
done

