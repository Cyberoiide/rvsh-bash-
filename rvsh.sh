#! /bin/bash
i=0


source mode_admin.sh #
source mode_connect.sh #


if [ $# -eq 1 ]; then #On vérifie si le nombre d'argument est égal à 1 pour voir si on est bien en mod admin
	if [ $1 ==  "-admin" ]; then #on vérifie si le mode admin a bien été écrit
		connect_mode_admin;
	else
		echo "Mauvait format : rvsh -admin" #on indique en cas d'erreur le format
	fi
elif [ $# -eq 3 ]; then #On vérifie si le nombre d'argument est bien égal à 3 pour le mode connect
	if [ $1 == "-connect" ]; then
		connect_mode_connect $2 $3;
	else
		echo "Mauvais format : rvsh -connect nom_machine nom_utilisateur" #On renvoit le format en cas d'erreur 
	fi
else
	echo "Mauvais format : rvsh -mode argument1 argument2?" #On renvois le format en cas d'erreur
fi

