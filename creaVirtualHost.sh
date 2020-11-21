#!/bin/bash
clear
echo "######################################################"
echo "#                                                    #"
echo "#         Generatore di virtualHost v 1.0            #"
echo "#                Mauro Spezzaferro                   #"
echo "#                                                    #"
echo "######################################################"


#verifico se l'utente è root 
if [[ $EUID -ne 0 ]]; then
   echo "Attenzione, devi avviare lo script come root" 
   exit 1
fi

echo "Visualizzo la lista dei progetti presenti nella cartella /var/www/html"
echo 
listaProgetti=$(ls -l /var/www/html/ | grep "^d" | awk '{print $9}')
echo $listaProgetti
echo 

echo "Inserisci il nome del progetto (E.g. website.lan)"
read nomeProgetto
if [[ -z "$nomeProgetto" ]]; then
	echo "Attenzione, il campo non può essere vuoto"
exit 1
fi
echo "Inserisci l'utente che dovrà esserne il proprietario"
read user
if [[ -z "$nomeProgetto" ]]; then
	echo "Attenzione, il campo non può essere vuoto"
exit 1
fi
echo "Gruppo a cui farà riferimento (E.g. www-data)"
read gruppo
if [[ -z "$nomeProgetto" ]]; then
	echo "Attenzione, il campo non può essere vuoto"
exit 1
fi
echo "Procedo con la creazione della cartella del progetto"
#creo la cartella del progetto
mkdir -p /var/www/html/$nomeProgetto/public
#creo il file index 
echo "Procedo con la creazione del file index.php all'interno della cartella"
echo "<?php echo '<h1>Ciao: $nomeProgetto</h1>'; ?>" > /var/www/html/$nomeProgetto/public/index.php
#cambio i permessi alla cartella precedentemente creata
echo "Procedo al cambio dei permessi"
chmod 775 -R /var/www/html/$nomeProgetto
#cambio il gruppo e il proprietario 
echo "Procedo al cambio del gruppo e del proprietario"
chown $user:$gruppo -R /var/www/html/$nomeProgetto
#genero il file di confing.
echo "Genero il file .conf"
touch /etc/apache2/sites-available/$nomeProgetto.conf
echo "<VirtualHost *:80>
	ServerAdmin webmaster@localhost
	DocumentRoot /var/www/html/$nomeProgetto/public
	ServerName $nomeProgetto
	ServerAlias www.$nomeProgetto
	ErrorLog ${APACHE_LOG_DIR}/error.log
	CustomLog ${APACHE_LOG_DIR}/access.log combined

<Directory /var/www/html/$nomeProgetto>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
</Directory>


</VirtualHost>" > /etc/apache2/sites-available/$nomeProgetto.conf
#aggiungo le informazioni al file /etc/hosts 
echo "Aggiorno il file hosts"
echo "127.0.0.1    $nomeProgetto" >> /etc/hosts
echo "Abilito il file .conf" 
a2ensite $nomeProgetto.conf
echo "Riavvio apache per effettuato le modifiche"
service apache2 restart
echo "Operazione conclusa...per verificare il funzionamento digita: http://$nomeProgetto"
