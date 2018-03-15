#!/bin/sh
[ $#  -lt 1 ] && echo " НЕ указан ключ запуска | DB - резервирование базы | S - резервирование исходников " && exit 1 #выводим в терминал инфо
#переменные окружения
DB_USER="login" #login резервируемой базы
DB_PASS="pass" #pass резервируемой базы
PATH_TO_DB="/home/backup/db" #путь куда сохраняем базу
PATH_TO_SOURCE="/home/backup/source" #путь куда сохраняем исходники
DB_ALD=7 #удаление бекапа старше 7 дней
SOURCE_ALD=60 #удаление бекапа старше 60 дней

if [ $1 = "DB" ]
then
#резервируем CRM DB и архивируем в gzip
echo "резервируем базу CRM"
mysqldump -u$DB_USER -p$DB_PASS crm | gzip > `date +$PATH_TO_DB/crm/crm.sql.%Y-%m-%d.%H%M%S.gz` 
#резервируем asterisk и архивируем в gzip
echo "резервируем базу ASTERISK"
mysqldump -u$DB_USER -p$DB_PASS asterisk | gzip > `date +$PATH_TO_DB/asterisk/asterisk.sql.%Y-%m-%d.%H%M%S.gz` 
echo "резервируем базу ASTERISK_CDR"
mysqldump -u$DB_USER -p$DB_PASS asteriskcdrdb | gzip > `date +$PATH_TO_DB/asterisk/asteriskcdrdb.sql.%Y-%m-%d.%H%M%S.gz` 
echo "удаление мусора"
#=== Удаляем старый мусор нахуй! ==================
find $PATH_TO_DB/crm/ -atime +$DB_ALD -delete

find $PATH_TO_DB/asterisk/ -atime +$DB_ALD -delete
#===========================================
fi
if [ $1 = "S" ]
then
#исходники резервируем и архивируем в tar
echo "Архивирование исходников CRM"
tar -cJf `date +$PATH_TO_SOURCE/crm.%Y-%m-%d.%H%M%S.tar` /home/crm
echo "Архивирование исходников FREEPBX"
tar -cJf `date +$PATH_TO_SOURCE/freePBX.%Y-%m-%d.%H%M%S.tar` /home/freePBX
echo "Архивирование настроек ASTERISK"
tar -cJf `date +$PATH_TO_SOURCE/asterisk_etc.%Y-%m-%d.%H%M%S.tar` /etc/asterisk
#=== Удаляем старый мусор нахуй!==================
echo "Удаляем старый мусор"
find $PATH_TO_SOURCE/ -atime +$SOURCE_ALD -delete

fi
#==========================================
