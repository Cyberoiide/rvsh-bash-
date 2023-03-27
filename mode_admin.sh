#! /bin/bash

function admin_help {
	if [ $1 == "all" ]; then # mode all on affiche toutes les commande disponible 
		echo "help : donne la liste des fonction ou comment utiliser une fonction si la fonction est entré en argument."
		echo "host : permet d'ajouter ou d'enlever une machine virtuel."
		echo "user : permet de creer, d'enlever et de modifier un utilisateur"
		echo "exit : quitte le programme."
	else # mode deux on affiche en fonction de la commande demandé, comment utilisé la commande. 
		case "$2" in
			"help" )
				echo " Utilisation : help cmd?"
				echo " Option : Aucune"
				;;
			"host" )
				echo " Utilisation : host mode nom"
				echo " Option :"
				echo "-c/-create : indique que l'on est en mode ajout de VM"
				echo "-d/-delete : indique que l'on est en mode enlever une VM"
				;;
			"user" )
				echo " Utilisation : user mode utilisateir machine"
				echo " Option :"
				echo "-c/-create : indique que l'on est en mode creation d'utilisateur"
				echo "-d/-delete : indique que l'on est en mode suppression d'utilisateur."
				echo "-p/-password : permet de changer le mot de passe d'un tuilisateur."
				echo "-gavm/-give_acces_VM : permet de donner l'accès à une machine à un utilisateur donné."
				echo "-ravm/-remove_acces_VM : permet de retirer l'accès à une machine à un utilisateur donné."
				;;
			"exit" )
				echo " Utilisation : exit"
				echo " Option : Aucune"
				;;
			* )
				echo "La commande demandé n'existe pas" 
				;;
		esac
	fi 
	
}

function admin_host {
	if [[ $1 == "-c" || $1 == "-create" ]]; then # vérifie si on est en mode create 
		if [ ! -e ~/VM/$2 ]; then # vérifie si la VM n'existe pas
			echo "" > ~/VM/$2;
		else
			echo " La VM $2 existe déja" 
		fi
	elif [[ $1 == "-d" || $1 == "-delete" ]]; then # vérifie si on est en mode delete 
		if [ -e ~/VM/$2 ]; then # vérifie si la VM existe  
			rm ~/VM/$2;
		else
			echo " La VM $2 n'existe pas" 
		fi
	fi
}



function admin_user {
	if [[ $1 == "-c" || $1 == "-create" ]]; then # vérifie si on est en mode create
		if [ ! -e ~/User/$2 ]; then # vérifie si l'utilisateur n'existe pas
			mkdir ~/User/$2;
			read -p "Password for $2 :" pswd 
			echo $pswd > ~/User/$2/info.txt
		else
			echo " L'utilisateur $2 existe déja" 
		fi
	elif [[ $1 == "-d" || $1 == "-delete" ]]; then # vérifie si on est en mode delete 
		if [ -e ~/User/$2 ]; then # vérifie si l'utilisateur existe
			rm -r ~/User/$2
		else
			echo " L'utilisateur $2 n'existe pas" 
		fi
	elif [[ $1 == "-p" || $1 == "-password" ]]; then # vérifie si on est en mode delete
		if [ -e ~/User/$2 ]; then
			read -p " Nouveau mot de passe pour $2 : " pswd
			sed -i "1s/.*/$pswd/" ~/User/$2/info.txt
		else
			echo " L'utilisateur $2 n'existe pas" 
		fi
	elif [[ $1 == "-gavm" || $1 == "-give_acces_VM" ]]; then # vérifie si on est en mode donner des permissions d'accès
		if [ $(ls ~/VM | grep -c "^$3$") -eq 1 ]; then # vérifie si la VM existe 
			if [ $(grep -c "^$2$" ~/VM/$3) -eq 0 ]; then #vérifie si l'utilisatuer a déja accès à la vm
				echo $2 >> ~/VM/$3 # enregistre l'utilisateur dans le fichier de la VM
			else
				echo " L'utilisateur $2 a déja accès à la machine $3"
			fi
		else
			echo " La VM $3 n'existe pas"
		fi
	elif [[ $1 == "-ravm" || $1 == "-remove_acces_VM" ]]; then # vérifie si on est en mode retirer des permissions d'accès
		if [ $(ls ~/VM | grep -c "^$3$") -eq 1 ]; then # vérifie si la VM existe
			if [ $(grep -c "^$2$" ~/VM/$3) -eq 1 ]; then #vérifie si l'utilisatuer n'a pas accès à la vm
				sed -i "/$2/d" ~/VM/$3
			else
				echo " L'utilisateur $2 n'a pas accès à la machine $3"
			fi
		else
			echo " La VM $3 n'existe pas"
		fi
	fi
}
		


function admin_afinger {
	if [[ $1 == "-a" || $1 == "-add" ]]; then
		if [ -e ~/User/$2 ]; then
			echo $3 >> ~/User/$2/info.txt
		else
			echo " L'utilisateur $2 n'existe pas" 
		fi 
	elif [[ $1 == "-c" || $1 == "-clear" ]]; then
		echo "done"
		head -n1 ~/User/$2/info.txt > temp.txt;
		mv temp.txt ~/User/$2/info.txt
	fi
}



function loop_admin {
	while [ true ] #reste en mode admin jusqu'à que la commande exit soit actionné 
	do 
		read -p "root@hostroot> " cmd arg1 arg2 arg3 # récupère les commandes avec argument donnés par l'admin
		case "$cmd" in 
			
			"help" )
				if [ -z $arg1  ]; then
					admin_help "all"; # appel la fonction help en mode all pour quel présente toutes les commandes
				else
					admin_help "cmd" $arg1;
				fi
				;;
			"host" )
				if [ ! -z $arg2  ]; then # vérifie si l'argument 2 n'est pas vide 
					admin_host $arg1 $arg2;
				fi
				;;
			"user" )
				if [ ! -z $arg2  ]; then # vérifie si l'argument 2 n'est pas vide 
					admin_user $arg1 $arg2 $arg3;
				fi
				;;
			"afinger" )
				if [ ! -z $arg2  ]; then # vérifie si l'argument 2 n'est pas vide 
					admin_afinger $arg1 $arg2 $arg3;
				fi
				;;
			"exit" )
				exit ;
				;;
		esac 
				
	done
}


function connect_mode_admin {
	nbrtry=3;
	while [ $nbrtry -gt 0  ] # le programme donne 3 tentative à la personne pour rentrer le mot de passe
	do
		read -p "Password : " pswd #récupère le mot de passe
		if [ $pswd == "1234" ]; then # vérifie si le mot de passe est correct
			break # Fin du while si le mot de passe est trouvé
		else
			((nbrtry--))
			echo "Mot de passe incorrect. Il vous reste $nbrtry tentative" #Envois un message de vérif
		fi
	done
	if [ $pswd != "1234" ]; then
		echo "Trop d'erreur" #
		exit ; # On termine le programme 
	else
		loop_admin ;
	fi
}
