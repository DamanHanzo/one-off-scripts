midevserverpath='*****' #get from fellow tpl devs
miqaserverpath='*****' #get from fellow tpl devs
ilqaserverpath='****' #get from fellow tpl devs

midevserveraddr='******' #get from fellow tpl devs
miqaserveraddr='*******' #get from fellow tpl devs
ilqaserveraddr='*******' #get from fellow tpl devs

IFS= read -r -p "Job directory name: " jobname
echo "$jobname"
IFS= read -r -p "Path to the dir to deploy: " directory
echo "$directory"
IFS= read -r -p "Deploy to all environments i.e MI-DEV, MI-QA, and IL-QA(Y/N): " allenvs
echo "$allenvs"

if [ -e "$directory" ]; then
	shellfiles=$(ls "$directory" | grep .sh)
	printf "Converting executable files to unix fileformat\n"
	for i in "${shellfiles[@]}"; do
		#convert file format to unix before deploying
		dos2unix "$directory$i"
	done
fi

if [ "$allenvs" == "Y" ]; then 
	echo "deploying to MI-DEV"
	rsync -artuv --chmod=755 "$directory" "$midevserveraddr:$midevserverpath$jobname" #TODO: add password flag

	echo "deploying to MI-QA"
	rsync -artuv --chmod=755 "$directory" "$miqaserveraddr:$miqaserverpath$jobname" #TODO: add password flag

	echo "deploying to IL-QA"
	rsync -artuv --chmod=755 "$directory" "$ilqaserveraddr:$ilqaserverpath$jobname" #TODO: add password flag

elif [ "$allenvs" == "N" ]; then
	echo -ne "Deploy to MI-DEV(Y/N): "
	read midev
	if [ $midev == "Y" ]; then
		echo "Deploying to MI-DEV"
		rsync -artuv --chmod=755 "$directory" "$midevserveraddr:$midevserverpath$jobname" #TODO: add password flag
	fi
	echo -ne "Deply to MI-QA(Y/N): "
	read miqa
	if [ $miqa == "Y" ]; then
		echo "Deploying to MI-QA"
		rsync -artuv --chmod=755 "$directory" "$miqaserveraddr:$miqaserverpath$jobname" #TODO: add password flag
	fi
	echo -ne "Deploy to IL-QA(Y/N): "
	read ilqa
	if [ $ilqa == 'Y' ]; then
		echo "Deploying to IL-QA"
		rsync -artuv --chmod=755 "$directory" "$ilqaserveraddr:$ilqaserverpath$jobname" #TODO: add password flag
	fi
fi