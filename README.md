# conkyScripts
A collection of scripts I use to gather useful metrics to display via Conky

mediacomUsage.pl is a script to log into your Mediacom account and pull your current usage from the Usage Meter.  It returns two text files, one with your total usage for the month (in GB) and one with the dates of the current billing period. I like to display this in Conky via the following:

${voffset 10}${font ConkySymbols:size=13}N${font}${voffset -10}${goto 40}Mediacom: ${exec cat /home/user/Scripts/mediacomUsage.txt} GB${alignr } ${execbar echo "scale=2; $(cat /home/user/Scripts/mediacomUsage.txt) / 9.99" | bc -q} 
${goto 40}Cycle: ${execi 60 cat /home/user/Scripts/mediacomDates.txt}
