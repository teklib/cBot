echo Quelle stratégie voulez vous installer ?
read strategy_name
echo Quelle le symbol de l asset en future a trader ex pour EGLD-PERP ?
read symbol1
echo Entrez votre clé api publique
read public_key
echo Entrez votre clé api privée
read private_key
echo Entrez le nom de votre sous compte, ne pas mettre despaces dans votre nom de sous compte!
read subaccount_name
echo Entrez le TOKEN de votre bot discord
read token_bot_discord

sudo apt-get update
sudo apt install pip -y
sudo apt install jq -y

#permet d avoir plusieurs bot dans des folders differents
folder_name=${PWD}

pip install -r $folder_name/requirements.txt

secret_file=secret.json
if test -f "$secret_file"; then
    echo Conitu
else
    echo '{}' > secret.json
fi

cron_file=cronlog.log
if test -f "$secret_file"; then
    echo Conitu
else
    touch cronlog.log
fi

secret_content=`cat secret.json`
$secret_content | jq '. + { "'"$strategy_name"'_'"$symbol1"':{"public_key" : "'"$public_key"'","private_key" : "'"$private_key"'","subaccount_name" : "'"$subaccount_name"'","symbol1" : "'"$symbol1"'","token_bot_discord" : "'"$token_bot_discord"'"} }' secret.json > tmp.$$.json && mv tmp.$$.json secret.json

croncmd="cd "$folder_name";python3 "$strategy_name".py "$symbol1" "$symbol2" > cronlog.log"
cronjob="0 * * * * $croncmd"
( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -
croncmd="cd "$folder_name";python3 bot_discord.py"
cronjob="0 20 * * * $croncmd"
( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -

echo L erreur command not found n est pas un probleme

python3 "$folder_name"/"$strategy_name".py "$symbol1" "$symbol2"

echo Si votre programme vous a afficher un message qui ne ressemble pas a une erreur c est que tout est bien installe 
echo vous pouvez verifier que votre bot tourne en tapant \" crontab -l \" , vous aurez une ligne de type $croncmd
echo vous pouvez maintenant quitter par exemple en faisant par exemple la commande \"exit\"
