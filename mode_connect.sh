#! /bin/bash

vm="" #enregistre la vm actuelle
user="" #enregistre le user actuel


function verif_pswd {
	nbrtry=3;
	pswd=$(head -n 1 ~/User/$1/info.txt);
	while [ $nbrtry -gt 0  ] # le programme donne 3 tentative à la personne pour rentrer le mot de passe
	do
		read -p "Password : " pswdtest #récupère le mot de passe
		if [ $pswdtest == $pswd ]; then # vérifie si le mot de passe est correct
			break # Fin du while si le mot de passe est trouvé
			echo "good job"
		else
			((nbrtry--))
			echo "Mot de passe incorrect. Il vous reste $nbrtry tentative" #Envois un message de vérif
			
		fi
	done
	if [ $pswdtest != $pswd ]; then # si le mot de passe est correct on lance la boucle du fonctionnement admin sinon on termine le programme.
		echo "Trop d'erreur" #
		exit ; # On termine le programme 
	else
		return 1;
	fi 
}

function add_log {
	echo "$1|$2|$(date)|$(tty)" >> log.txt
}




function connect_who {
	while read line 
	do
		if [ $(echo $line | grep -c "^$1") -eq 1 ]; then
			echo $line | awk 'BEGIN{FS="|"}{print $1,$2,$3}'
		fi
	done < log.txt
}



function connect_rusers {
	while read line 
	do
		echo $line | awk 'BEGIN{FS="|"}{print $1,$2,$3}'
	done < log.txt
}

function connect_rhost { 
	ls ~/VM #imprime le nom des fichiers dans le dossier VM
	
}

function connect_rconnect {
	connect_mode_connect $1 $2 #rappelle la fonction mode_connect mais avec les nouveaux paramètres donnés
}

function connect_su {
	connect_mode_connect $1 $2
}

function connect_passwd {
	sed -i "1s/.*/$2/" ~/User/$1/info.txt
	echo "Mot de passe pour $1 changé en $2"
}


function loop_connect {
	while [ true ] #boucle infinie 
	do
		read -p "$2@$1>" cmd arg1 arg2
		case "$cmd" in 
		
			"who" ) 
				if [ -z $arg1 ]; then
					connect_who $1 $2;						
				fi				
				;;
				
			"rusers" )
				connect_rusers;
				;;
			
			"rhost" )
				connect_rhost;
				;;
			
			"rconnect" )
				
				connect_rconnect $arg1 $arg2;
				;;
			
			"su" )
				connect_rconnect $1 $arg1; #ici arg1 = nom du nouveau user
				;;
			
			"passwd" )
				connect_passwd $2 $arg1; # 2=user, arg1=nv passwd
				;;
				
			"exit" )
				exit;
				;;
			
			*) 
				echo "Erreur cette fonction n'existe pas"
				;;
		esac	
	done
}


function connect_mode_connect {
	if [ -e ~/User/$2 ]; then # vérifie si le user existe
		if [ -e ~/VM/$1  ]; then # vérifie si la machine existe
			if [ $(grep -c ^$2$ ~/VM/$1) -eq 1 ]; then # vérifie si l'utilisateur a le droit de se connecter sur la machine
				verif_pswd $2;
				add_log $1 $2;
				loop_connect $1 $2;
			else
				echo "L'utilisateur $2 n'a pas le droit de se connecter à la machine $1"
			fi
		else
			echo "La machine $1 n'existe pas"
		fi
	else
		echo "L'utilisateur $2 n'existe pas"
	fi
	
}
