#!/bin/bash

pathvar=$(readlink -f $(find . -type f -name "autoscope.sh" -print -quit 2>/dev/null | rev | cut -d'/' -f2- | rev))
bsphcoreconvlocvar=$(readlink -f $(find $pathvar -type f -name "bsphcoreconversion.csv" 2>/dev/null))

printf "\r\n\r\n=====================================================================================\r\n\r\n"
printf '\e[1;34m%-6s\e[m' "WP Engine Self Service Scoping Tool"
printf "\r\n\r\n=====================================================================================\r\n\r\n"
printf "Before starting ensure that you are logged into the WP Engine secure VPN so you can access OverDrive to initiate impersonation - here's how: \r\n\r\nhttps://wpengine.atlassian.net/wiki/spaces/ASKITS/pages/1297449301/How+to+VPN\r\n\r\n"
printf "If you don't have OverDrive access please refer to this document: https://wpengine.atlassian.net/wiki/spaces/SECACT/pages/791019720/Overdrive+Access+Control+Process"
printf "\r\n\r\nThis script will create a Scoping Tool folder and project folder within it, on your Mac OS desktop for the account you are currently investigating."
printf "\r\n\r\nIt will then pull usage.csv files into the project folder for every install you enter and aggregate them into a single account.csv file for you to manipulate later. The 4 columns it outputs, in order, are:\r\n\r\n          visitors | gb_served_directly | uncached_dynamic_hits | backend_server_processing_hours"
printf "\r\n\r\nFinally, it will output the recommended scope. Any results above a P3 will require an SE involvement. Please follow standard SE Engagement processes."
printf "\r\n\r\n=====================================================================================\r\n"

printf "\r\nPlease enter the account name:\r\n"

read -r account

printf "\r\nPlease go to:\r\n\rhttps://overdrive.wpengine.io/account/dashboard/$account\r\n\r\nComplete the following steps:\r\n1. Click one LIVE install\r\n2. Click \"Navigation\" > \"User Portal\"\r\n3. Follow standard OKTA Log In, if required\r\n4. Go back to OVERDRIVE and Press \"Show active installs\"\r\n5. Press \"Copy to clipboard\" or if only analysing a selection highlight the relevant installs and press CMD+C\r\n6. PASTE the result BELOW...\r\n\r\n"

touch $pathvar/autoscopeinstalls.sh

stty -icanon

python3 $pathvar/writeinstalls.py

stty icanon

#read inst

installfilevar=$(find . -type f -name "autoscopeinstalls.sh" -print -quit 2>/dev/null)

source $installfilevar

printf "\r\nPlease ensure you are in IMPERSONATION MODE by clicking through \"Navigation\" > \"User Portal\", and sign in if required. You have 10 seconds, otherwise press ENTER to SKIP...\r\n"

read -t 10

tstamp=$(date +%Y%m%d)

printf "\r\nMaking project folder at /Users/$USER/desktop/Scoping Tool/$account-$tstamp...\r\n"

mkdir -p "/Users/$USER/desktop/Scoping Tool/$account-$tstamp/" 

printf "\r\nLooping through retrieval of usage files for installs:\r\n\r\n$inst\r\n"

cd /Users/$USER/desktop/Scoping\ Tool/$account-$tstamp/ || exit

for site in $inst; do /usr/bin/open -a "/Applications/Google Chrome.app" https\:\/\/my\.wpengine\.com\/installs\/$site\/usage_stats && for i in {1..10}; do mv /Users/$USER/downloads/$site\_usage\_stats* "/Users/$USER/desktop/Scoping Tool/$account-$tstamp/" 2> /dev/null && break || sleep 2; done; done 

printf "\r\nDownload COMPLETE!\r\n"

cd "/Users/$USER/desktop/Scoping Tool/$account-$tstamp/" && sleep 1 

printf "\r\nBuilding your account.csv file... Please hold...\r\n"

for i in {2..181}; do for file in $(ls ./*csv); do head -$i $file | tail -1 | cut -d',' -f4,7,10,11; done | awk -F, '{for(i=1;i<=NF;i++)a[i]+=$i} END{for(i=1;i<=NF;i++)printf "%d%s", a[i], (i==NF?"\n":",")}'; done > account.csv

printf "\r\nFinished building account.csv file!\r\n"

accountavg=$(cat /Users/$USER/desktop/Scoping\ Tool/$account-$tstamp/account.csv | awk -F',' '{ total += $4; count++ } END { print total/count}')
accountmax=$(cat /Users/$USER/desktop/Scoping\ Tool/$account-$tstamp/account.csv | awk -F',' '{print $4}' | sort -rn | head -1)
accountmin=$(cat /Users/$USER/desktop/Scoping\ Tool/$account-$tstamp/account.csv | awk -F',' '{print $4}' | sort -rn | tail -1)
account99=$(cat /Users/$USER/desktop/Scoping\ Tool/$account-$tstamp/account.csv | awk -F',' '{print $4}' | sort -rn | head -3 | tail -1)
account95=$(cat /Users/$USER/desktop/Scoping\ Tool/$account-$tstamp/account.csv | awk -F',' '{print $4}' | sort -rn | head -9 | tail -1)
accountmedian=$(cat /Users/$USER/desktop/Scoping\ Tool/$account-$tstamp/account.csv | awk -F',' '{print $4}' | sort -rn | head -90 | tail -1)

accountavg30=$(cat /Users/$USER/desktop/Scoping\ Tool/$account-$tstamp/account.csv | head -30 | awk -F',' '{ total += $4; count++ } END { print total/count}')
accountmax30=$(cat /Users/$USER/desktop/Scoping\ Tool/$account-$tstamp/account.csv | head -30 | awk -F',' '{print $4}' | sort -rn | head -1)
accountmin30=$(cat /Users/$USER/desktop/Scoping\ Tool/$account-$tstamp/account.csv | head -30 | awk -F',' '{print $4}' | sort -rn | tail -1)
account9530=$(cat /Users/$USER/desktop/Scoping\ Tool/$account-$tstamp/account.csv | head -30 | awk -F',' '{print $4}' | sort -rn | head -2 | tail -1)
accountmedian30=$(cat /Users/$USER/desktop/Scoping\ Tool/$account-$tstamp/account.csv | awk -F',' '{print $4}' | sort -rn | head -15 | tail -1)

premin6m=$(expr $account95 + $(echo "($accountavg+0.5)/1" | bc))
premin30d=$(expr $account9530 + $(echo "($accountavg30+0.5)/1" | bc))
minvi6mo=$(echo "$premin6m/2" | bc)
minvi30d=$(echo "$premin30d/2" | bc)

rec6m=$(echo "($account99+$account95)/2" | bc)

printf "\r\nCALCULATED BSPH VALUES:\r\n==========\r\nAverage: $accountavg\r\nMedian: $accountmedian\r\nMaxVal: $accountmax\r\nMinVal: $accountmin\r\n99pc: $account99\r\n95pc: $account95\r\n\r\n30-day Average: $accountavg30\r\n30-day Median: $accountmedian30\r\n30-day MaxVal: $accountmax30\r\n30-day MinVal: $accountmin30\r\n30-day 95pc: $account9530\r\n"

printf "\r\n6 MONTH WORKLOAD SCOPE\r\n==========\r\n"
printf "MINIMALLY REQUIRED:\r\n"
cat $bsphcoreconvlocvar | awk -v mv6m=$minvi6mo -F',' '{if ($1 == mv6m) print $2, "Cores - Plan", $3;}'
printf "RECOMMENDED:\r\n"
cat $bsphcoreconvlocvar | awk -v r6m=$rec6m -F',' '{if ($1 == r6m) print $2, "Cores - Plan", $3;}'
printf "CONSERVATIVE MAXVAL:\r\n"
cat $bsphcoreconvlocvar | awk -v acc99=$account99 -F',' '{if ($1 == acc99) print $2, "Cores - Plan", $3;}'
printf "\r\n30-DAY WORKLOAD SCOPE\r\n==========\r\n"
printf "MINIMALLY REQUIRED:\r\n"
cat $bsphcoreconvlocvar | awk -v mv30d=$minvi30d -F',' '{if ($1 == mv30d) print $2, "Cores - Plan", $3;}'
printf "RECOMMENDED:\r\n"
cat $bsphcoreconvlocvar | awk -v acc9530=$account9530 -F',' '{if ($1 == acc9530) print $2, "Cores - Plan", $3;}'

printf "\r\nScope Complete...\r\n\r\n"

while true; do
    read -p "Would you like to keep the working files? (Y/n) " yn
    case $yn in
        [Yy]* ) printf "Access the working files for the Scoping Tool at: /Users/$USER/desktop/Scoping Tool/$account-$tstamp\r\n\r\n"; exit;;
        [Nn]* ) printf "Cleaning up after myself...\r\n\r\n"; echo "Deleting"; rm -rfv /Users/$USER/desktop/Scoping\ Tool/$account-$tstamp/; printf "\r\nDONE... Bye!\r\n\r\n"; exit;;
        * ) echo "Input not recognized. Please answer y or n.";;
    esac
done