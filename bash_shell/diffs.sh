#! /bin/bash
set -e
if [ -e "diffsraw.diff" ]; then
	echo "" > diffsraw.diff #clear out the diffsraw file if it exists
fi
RED='\033[0;31m'
GREEN='\033[1;32m' 
NC='\033[0m'
echo -ne "Please enter directory path of the repository(${RED}leave empty if already in repo dir${NC}): "
read directory
if [ -n "$directory" ]; then 
	cd $directory
else 
	printf "Working Directory: $(pwd)\n"
fi
echo -n "Please enter branch a: "
read brancha
echo -n "Please enter the branch b: "
read branchb
echo -ne "${GREEN}Sacred DDL${NC} source(default: master): "
read ddlsource
if [ -z "$ddlsource" ]; then
	ddlsource="master" #default to DataGuard if ddl source is isn't specified
	git checkout "$ddlsource" >/dev/null 2>&1
else
	localbranch=$(git branch | grep -w "$ddlsource" | tr -d '[:space:]')
	if [ -n $localbranch ]; then 
		git checkout "$ddlsource" >/dev/null 2>&1
	elif [ -z $localbranch ]; then
		remotebranch=$(git ls-remote --heads origin "$ddlsource" | grep "$ddlsource" | tr -d '[:space:]')
		ddlsourcefromremote="origin/$ddlsource"
		if [ -n $remotebranch ]; then 
			git checkout --track "$ddlsourcefromremote" >/dev/null 2>&1
		else
			printf "${RED}The sacred ddl source branch doesn't exist.${NC}/n"
		fi
	fi
fi
{ 
	git diff $brancha..$branchb >/dev/null 2>&1
} || {
	printf "${RED}Please make sure that the branches you want to compare are checked out locally.${NC}\n"
}
totalfilesmodified=($(git diff "$brancha".."$branchb" --diff-filter=r --numstat | grep -Ev '^1\s+1[^1]' | awk '{print $3}'))
if [ "${#totalfilesmodified[@]}" -gt 0 ]; then 
	printf "Date ran: $(date +%m-%d-%y)\n" >> diffsraw.diff
	printf "Found changes in ${#totalfilesmodified[@]} files\n"
	for i in "${totalfilesmodified[@]}"; do
		object=$(echo "$i" | cut -d/ -f1)
		printf "Evaluating changes in $i\n"
		printf "Diffs in $i" >> diffsraw.diff
		diff=$(git diff "$brancha" "$branchb" -- "$i")
		echo -En "$diff" >> diffsraw.diff
		printf "\nend of diffs in $i\n" >> diffsraw.diff
		if [ $(git diff "$brancha" "$branchb" -- "$i" | wc -l) -ge 2 ] && [ "$object" != "TABLE" ]; then
			if [ -e "$i" ]; then
				printf "\nComplete DDL from DataGuard(Prod):\n\n" >> diffsraw.diff
				cat "./$i" >> diffsraw.diff
				printf "\nDDL END FOR $i\n\n">> diffsraw.diff
			else
				printf "${RED}$i not found in $ddlsource${NC}\n"
		 		printf "$i not found in $ddlsource\n\n" >> diffsraw.diff
	 		fi
 		# handle table ddl parsing logic here
	 	# else 
		fi
	done
else 
	printf "${GREEN}No changes found. Both branches are upto date.${NC}\n"
fi
read -p "Press any key to exit..."
