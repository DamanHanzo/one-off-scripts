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
totalfilesmodified=($(git diff $compare --diff-filter=r --numstat | grep -Ev '^1\s+1[^1]' | awk '{print $3}'))
if [ "${#totalfilesmodified[@]}" -gt 0 ]; then 
	printf "Date ran: $(date +%m-%d-%y)\n" >> diffs.diff
	printf "Found changes in ${#totalfilesmodified[@]} files\n"
	for i in "${totalfilesmodified[@]}"; do 
		printf "Evaluating changes in $i\n"
		printf "Diffs in $i" >> diffs.diff
		diff=$(git diff $current $compare -- $i)
		echo -En "$diff" >> diffs.diff
		printf "\nend of diffs in $i\n\n" >> diffs.diff
	done
else 
	printf "No changes found. Both branches are upto date.\n"
fi
read -p "Press any key to exit..."