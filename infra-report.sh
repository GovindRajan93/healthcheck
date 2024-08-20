cd /home/ansibleuser/automation/infra-reports/
echo "Checking systems are up and running"
Today=$(date +"%d/%m/%Y")
ansible -m ping all -i hosts.ini > ping-test.txt
grep -i "success" ping-test.txt | cut -d"|" -f1 > online-host
grep -i "UNREACHABLE" ping-test.txt | cut -d"|" -f1 > offline-host
echo "Testing ansible via shell script"
echo "Start Time: `date +"%F_%H:%M:%S"`"
ansible-playbook fs.yml -i hosts.ini > infra-report_raw.txt
echo "Preparing the output"
cat infra-report_raw.txt | sed -e '/PLAY/d;/TASK/d;/^ok:/d;/^changed:/d;/^}/d;/^\s*]/d;/^\s*"report/d;/changed=/d;/^$/d;s/"//g;s/report.stdout_lines://g' > infra-report-raw.html
cat infra-report_raw.txt | sed -e '/PLAY/d;/TASK/d;/^ok:/d;/^changed:/d;/^}/d;/^\s*]/d;/^\s*"report/d;/changed=/d;/^$/d;s/"//g;s/report.stdout_lines://g;s/ - //g' | tr -d "'" > infra-report-raw.html
awk 'BEGIN{print "<table>"} {print "<tr>";for(i=1;i<=NF;i++)print "<td>" $i"</td>";print "</tr>"} END{print "</table>"}' infra-report-raw.html > infra-report.html
cat head_raw.html > head.html
rep="<h2 style=color:blue;font-size:35px; align="\"center"\"> <img src="\"https://www.redhat.com/rhdc/managed-files/Asset-Red_Hat-Logo_page-Logo-RGB.svg"\" alt="\"RedHat"\" width="\"160"\" height="\"160"\">  SSG RHV VM's Health Check Report - Date  <img src="\"https://www.redhat.com/rhdc/managed-files/Asset-Red_Hat-Logo_page-Logo-RGB.svg"\" alt="\"Redhat"\" width="\"160"\" height="\"160"\"> </h2>"
echo ${rep/Date/$Today} >> head.html
cat head_1.html >> head.html
cat head.html > Infra-Report_`date +"%d-%m-%Y"`.html
cat infra-report.html | grep -v "table" >> Infra-Report_`date +"%d-%m-%Y"`.html
echo "</table> </body> </html>" >> Infra-Report_`date +"%d-%m-%Y"`.html
echo "Script completed: `date +"%F_%H:%M:%S"`"
# #Uploading File
file="Infra-Report_`date +"%d-%m-%Y"`.html"
if [ -f "$file" ]; 
then
scp /home/ansibleuser/automation/infra-reports/$file fileshare-ip:/infra_reports/
echo "Report for `date +%F` has been uploaded"
else
echo "Infra Report doesnot exists and didn't upload. Please check the log"
fi