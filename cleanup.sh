###!/bin/bash
##
##
##
###VERSION -v2 - ASP-167697 - sFTP cleanup job
###VERSION -v3 - ASP-199644 - Add 4 more directories DIR_[27] to DIR_[30]


###################################################################Variables###################################################################
CURRENT_DATE=$(date +"%Y-%m")
#LOG_TIME=$(date +%F"  "%H:%M:%S)
#LOGFILE=/tmp/sftp-cleanup-job_$(date +"%Y-%m-%d_%H-%M-%S").log
LOGFILE=/data04/wssuite/$FK_IDENT/wss/bin/CLEANUP-LOGS/sftp-cleanup-job_$(date +"%Y-%m-%d_%H-%M-%S").log
BASE_DIR=/data04/wssuite/$FK_IDENT/varsoft/inter$FK_IDENT
DIR_[1]="$BASE_DIR/../echange/datalog/out/MT101D/ARCHIVE"
DIR_[2]="$BASE_DIR/../echange/datalog/out/MT210D/ARCHIVE"
DIR_[3]="$BASE_DIR/EXPORT/report/Dashboard/ARCHIVE"
DIR_[4]="$BASE_DIR/EXPORT/accounts/ARCHIVE"
DIR_[5]="$BASE_DIR/EXPORT/banks_cashpooler/ARCHIVE"
DIR_[6]="$BASE_DIR/EXPORT/entities/ARCHIVE"
DIR_[7]="$BASE_DIR/EXPORT/agora/afb120/ARCHIVE"
DIR_[8]="$BASE_DIR/EXPORT/SEB/afb120/ARCHIVE"
DIR_[9]="$BASE_DIR/EXPORT/proprete_sage/afb120/ARCHIVE"
DIR_[10]="$BASE_DIR/EXPORT/proprete/afb120/ARCHIVE"
DIR_[11]="$BASE_DIR/EXPORT/eau/afb120/ARCHIVE"
DIR_[12]="$BASE_DIR/EXPORT/agora/compta/ARCHIVE"
DIR_[13]="$BASE_DIR/EXPORT/proprete_sage/compta/ARCHIVE"
DIR_[14]="$BASE_DIR/EXPORT/proprete/compta/ARCHIVE"
DIR_[15]="$BASE_DIR/EXPORT/vws/compta/ARCHIVE"
DIR_[16]="$BASE_DIR/EXPORT/taux/NATIXIS/ARCHIVE"
DIR_[17]="$BASE_DIR/EXPORT/taux/agora/ARCHIVE"
DIR_[18]="$BASE_DIR/IMPORT/paiement/ARCHIVE"
DIR_[19]="$BASE_DIR/IMPORT/prelevement/ARCHIVE"
DIR_[20]="$BASE_DIR/IMPORT/mt940/ARCHIVE"
DIR_[21]="$BASE_DIR/IMPORT/mt940_rbc/ARCHIVE"
DIR_[22]="$BASE_DIR/IMPORT/afb120/ARCHIVE"
DIR_[23]="$BASE_DIR/EXPORT/taiga/previ/ARCHIVE"
DIR_[24]="$BASE_DIR/EXPORT/taiga/taigataux/ARCHIVE"
DIR_[25]="$BASE_DIR/EXPORT/taiga/positions/ARCHIVE"
####DIR_[26]="$BASE_DIR/EXPORT/eau/compta/ARCHIVE"
DIR_[27]="$BASE_DIR/IMPORT/mt940/ARCHIVED"
DIR_[28]="$BASE_DIR/IMPORT/mt940/archive"
DIR_[29]="$BASE_DIR/IMPORT/mt940_rbc/ARCHIVED"
DIR_[30]="$BASE_DIR/IMPORT/afb120/ARCHIVED"
#DIR_[31]="$BASE_DIR/IMPORT/mt940_rbc/archive"
#DIR_[32]="$BASE_DIR/IMPORT/afb120/archive"

###################################################################Functions###################################################################
###Validate the last execution
succ_or_fail ()
{
if [[ $? -eq 0 ]]
then
echo "$(date +%F"  "%H:%M:%S)                         $1 SUCCESSFUL" >> $LOGFILE
else
echo "$(date +%F"  "%H:%M:%S)                         $1 FAILED ------------------------------------ CHECK AGAIN!!!" >> $LOGFILE
exit 1
fi
}

###Remove the null files inside the directory
rem_null_files ()
{
if [[ $(find . -type f -empty | wc -l) -gt 0 ]]
then
echo "$(date +%F"  "%H:%M:%S)                         Below null files have been found" >> $LOGFILE
echo "#########################################################################################################################################################" >> $LOGFILE
find . -type f -empty | cut -d / -f2 >> $LOGFILE
echo "#########################################################################################################################################################" >> $LOGFILE
echo "  " >> $LOGFILE
echo "  " >> $LOGFILE
echo "$(date +%F"  "%H:%M:%S)                         Removing the above mentioned files now.." >> $LOGFILE
find . -type f -empty -delete
succ_or_fail "Files removed -"
echo "" >> $LOGFILE
echo "$(date +%F"  "%H:%M:%S)                         Validating if there are any more null files available" >> $LOGFILE
echo "$(date +%F"  "%H:%M:%S)                         $(find . -type f -empty | wc -l) null files found now..." >> $LOGFILE

elif [[ $(find . -type f -empty | wc -l) = 0 ]]
then
echo "#########################################################################################################################################################" >> $LOGFILE
echo "$(date +%F"  "%H:%M:%S)                         No null files have been found" >> $LOGFILE
echo "#########################################################################################################################################################" >> $LOGFILE
else
echo "$(date +%F"  "%H:%M:%S)                         ERROR (rem_null): Check again" >> $LOGFILE
exit 1

fi
}

###Create directories monthly in format YEAR_MM and move the files based on creation date to that respective directories.
move_files ()
{
ls -p | grep -v / | grep -v backup.zip | while read file_name
do
CURRENT_FILE_DATE=$(ls -lrth --time-style=+"%Y-%m" "$file_name" | awk {'print $6'})

if [[ $CURRENT_DATE != $CURRENT_FILE_DATE ]]
then

        if [ ! -d $CURRENT_FILE_DATE ]
        then
        echo "$(date +%F"  "%H:%M:%S)                         Creating directory named $CURRENT_FILE_DATE" >> $LOGFILE
        mkdir -p $CURRENT_FILE_DATE
        fi

echo "$(date +%F"  "%H:%M:%S)                         Moving file "$file_name" to $CURRENT_FILE_DATE/" >> $LOGFILE
mv "$file_name" $CURRENT_FILE_DATE/
succ_or_fail "File moved -"
fi
done
}



###Zip the folders and then remove it
zip_dir ()
{
if [[ $(find . -type d | wc -l) -gt 1 ]]
then
echo "$(date +%F"  "%H:%M:%S)                         Below directories have been found in ARCHIVE" >> $LOGFILE
echo "#########################################################################################################################################################" >> $LOGFILE
find . -type d  >> $LOGFILE
echo "#########################################################################################################################################################" >> $LOGFILE
echo "  " >> $LOGFILE
echo "  " >> $LOGFILE

ls -p | grep / | cut -d / -f1 | while read dir
do
echo "$(date +%F"  "%H:%M:%S)                         Creating the ZIP of $dir" >> $LOGFILE
zip -9r ${dir}_backup $dir >> $LOGFILE
succ_or_fail "Zip created with the name ${dir}_backup.zip -"
done


###Romove the directories after the zip completion
echo "$(date +%F"  "%H:%M:%S)                         Removing the directories now" >> $LOGFILE
ls -p | grep / | cut -d / -f1 | while read dir
do
if [[ -f ${dir}_backup.zip ]]
then
rm -rf $dir
succ_or_fail "Directory $dir removed -"
fi
done


elif [[ $(find . -type d | wc -l) = 1 ]]
then
echo "#########################################################################################################################################################" >> $LOGFILE
echo "$(date +%F"  "%H:%M:%S)                         No directories have been found" >> $LOGFILE
echo "#########################################################################################################################################################" >> $LOGFILE
else
echo "$(date +%F"  "%H:%M:%S)                         ERROR (zip-dir): Check again" >> $LOGFILE
exit 1
fi
}


#################################################################################################################################



###Actual implementation
for i in {1..25}
do
echo "############ Entering directory ${DIR_[$"i"]}/../ - ############" >> $LOGFILE
cd ${DIR_[$"i"]}/..
rem_null_files

echo "############ Entering directory ${DIR_[$"i"]} - ############" >> $LOGFILE
cd ${DIR_[$"i"]}
succ_or_fail " Entering directory - "
rem_null_files
move_files
zip_dir
echo " " >> $LOGFILE
echo " " >> $LOGFILE

done

for i in {27..30}
do
echo "############ Entering directory ${DIR_[$"i"]} - ############" >> $LOGFILE
cd ${DIR_[$"i"]} 
succ_or_fail " Entering directory - "
rem_null_files
move_files
zip_dir
echo " " >> $LOGFILE
echo " " >> $LOGFILE

done
