#! /bin/bash
echo -n "Please enter directory path of the repository(leave empty if in repo dir): "
read directory
if [ -n "$directory" ]; then 
	cd $directory
else 
	printf "Working Directory: $(pwd)\n"
fi
echo -n "Please enter current branch: "
read current
echo -n "Please enter the branch to compare: "
read compare
{ 
	git diff $current..$compare >/dev/null 2>&1
} || {
	printf "Please make sure that the branches you want to compare are checked out locally.\n"
	set -e
}
totalfilesmodified=($(git diff $current..$compare --diff-filter=r --numstat | grep -Ev '^1\s+1[^1]' | awk '{print $3}'))
if [ "${#totalfilesmodified[@]}" -gt 0 ]; then 
	printf "Date ran: $(date +%m-%d-%y)\n" >> diffsraw.diff
	printf "Found changes in ${#totalfilesmodified[@]} files\n"
	if [ "$(git branch | grep -E '^[*]' | cut -d* -f2 | tr -d '[:space:]')" != "master" ]; then 
		git checkout master
	fi
	for i in "${totalfilesmodified[@]}"; do
		printf "Evaluating changes in $i\n"
		printf "Diffs in $i" >> diffsraw.diff
		diff=$(git diff $current $compare -- $i)
		echo -En "$diff" >> diffsraw.diff
		printf "\nend of diffs in $i\n" >> diffsraw.diff
		#TODO: add logic to make sure that the tables are excluded
		if [ $(git diff $current $compare -- $i | wc -l) -ge 2 ]; then 
			if [ -e "$i" ]; then
				printf "File found in master\n"
				printf "\nComplete DDL from DataGuard(Prod)\n\n" >> diffsraw.diff
				cat "./$i" >> diffsraw.diff
				printf "\nDDL END FOR $i\n">> diffsraw.diff
			else 
				printf "$i not found in master\n"
		 		printf "\n$i not found in master\n" >> diffsraw.diff
	 		fi
		fi
		# echo -En "$diffcleaned">> diffadditions.diff
	done
else 
	printf "No changes found. Both branches are upto date.\n"
fi
read -p "Press any key to exit..."