#!/bin/bash

####################################################################################################################
# L'objectif de ce script est de vérifier le bon fonctionnement de votre dyndns notamment en utilisant dnssec      #
####################################################################################################################

NomDom="bn.xxxx.xx"
NomCheck="xxxx.xx"

####################################################################################################################
# Obj : Ajout de la couleur pour les résultats                                                                     #
####################################################################################################################

normal=$(tput sgr0)                      # normal text
red="$bold$(tput setaf 1)"                # bright red text
green=$(tput setaf 2)                     # dim green text
white="$bold$gray"                        # bright white text

fonc_verif_dns () {
####################################################################################################################
# Obj : Recherche du champ ad dans la question posée au resolveur                                                  #
####################################################################################################################

#L'objectif est de soliciter un résolveur DNS qui supporte DNSSEEC et qui est récursif. 
#Le flag ad nous informe de la fiabilité de la réponse.
# la variable ipfromdns contient l'adresse ip déclarée en enregistrement dns.
nb=$(dig +dnssec $NomDom @9.9.9.9 |grep flag|grep -c ad)
if [ $nb -eq 1 ]
 then
	ipfromdns=$(dig +short $NomDom @9.9.9.9)
#        echo -e "\n${green}Adresse renvoyée par votre resolveur : $ipfromdns ${normal}"
else

        echo -e "\n${red}Votre resolveur n'a pas validé l'authenticité de votre adresse ip dynamique${normal}"
fi


#L'objectif est de récupérer l'adresse ip publique à partir d'une page web (autre que wathismyip and co...)
# L'adresse ip du site à consulter est récupériée via le DNS resolveur du serveur 
ipfromweb=$(wget -4qO- https://$NomCheck)

#Ajout d'un espace à la fin de la variable chargée du DNS pour la comparaison de chaine.
ipfromdns=$ipfromdns" "

#Comparaison des 2 adresses IP 
if [ "$ipfromdns" != "$ipfromweb" ] ; then 
	echo "L'adresse IP enregistrée par votre résolveur est ${red} $ipfromdns ${normal}" 
	echo "L'adresse IP enregistrée constatée sur le web  est ${red} $ipfromweb ${normal}" 
	echo "${red}Alerte, une mise à jour ou un détournement est en cours...${normal}"
else
    echo "${green}Ras au niveau DNS${normal}"
fi


}

fonc_maj_dns () {
/etc/init.d/ddclient restart
grep SUCCESS /var/log/syslog 
}

fonc_lst_con () {
echo -e "\n####################################################################################################################"
echo "# Obj : Historique des connexions                                                                                  #"
echo "####################################################################################################################"
last -f /var/log/wtmp
}


fonc_disq () {
echo -e "\n####################################################################################################################"
echo "# Obj : Utilisation de l'espace disque                                                                             #"
echo "####################################################################################################################"
df -h


}
echo -e "\n###################################################################################################################"
echo "#                               Menu                                                                              #"
echo "###################################################################################################################"
PS3="${blue} Que souhaitez vous faire ( Enter pour afficher les opérations possibles ) ? ${normal}"
select choix in \
   "Vérifier l'enregistrement DNSSEC" \
   "Forcer la mise à jour du DNS dynamique"  \
   "Afficher les dernières connexions"  \
   "Afficher les informations sur les disques"  \
   "Abandon"
do
   clear
   echo "Vous avez choisi l'item $REPLY : $item"
   case $REPLY in


      1) fonc_verif_dns exit ;;
      2) fonc_maj_dns exit ;;
      3) fonc_lst_con exit ;;
      4) fonc_disq exit ;;
      5) echo "Fin"
         exit 0 ;;
      *) echo "Fonction non implémentée"  ;;
   esac
done

