import json
import subprocess
from argparse import ArgumentParser

parser = ArgumentParser()
parser.add_argument("-k", "--installationKey", dest="installationKey", help="Installation key for the package that will be installed.")
parser.add_argument("-p", "--package", dest="packageId", help="The Package Id where the latest subscriber package version will be installed.")
parser.add_argument("-u", "--username", dest="username", help="The username or alias for the username where the package will be installed.", default="StagingSandbox")

args = parser.parse_args()

query = "SELECT SubscriberpackageVersionId FROM Package2Version WHERE Package2Id = '" + args.packageId + "' ORDER BY MajorVersion DESC,MinorVersion DESC,PatchVersion DESC,BuildNumber DESC LIMIT 1"
packageVersionList = subprocess.Popen(['sfdx', 'force:data:soql:query', '-q', query , '--json', '-u', 'admin-salesforce@mobilityhouse.com', '-t'], stdout=subprocess.PIPE, shell=False)
json_data = json.loads(packageVersionList.stdout.read())
latestPackageVersionId = json_data['result']['records'][0]['SubscriberPackageVersionId']

packageInstall = subprocess.call(['sfdx', 'force:package:install', '-w','10','-b','10','-u', args.username, '-p', latestPackageVersionId, '-k', args.installationKey, '-r'])