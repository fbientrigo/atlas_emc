#!/usr/bin/env python3

##
## Usage: sudo ./mkrootfs.py --root=$ROOTFS_PATH --extra=extra_rpms.txt
##
## To install extra packages run ::
## sudo dnf -y --skip-broken -c dnf.conf --releasever=9 --forcearch=aarch64 
##              --verbose --installroot=$ROOTFS_PATH install
#################################################################
## Script based on original script written by Matthias Wittgen ##
#################################################################

import os
import sys
import subprocess
import logging
import shutil
import argparse
import crypt
import augeas
import urllib.request
from shutil import copyfile
from pathlib import Path

#Get directory (absolute path)  and filename of mkrootfs.py
dirname, filename = os.path.split(os.path.abspath(__file__))

dnf_conf=dirname+'/dnf.conf'	#Define dnf.conf path
print("DNF config path: " + dnf_conf)
qemu_bins=dirname
etc=dirname

############################################################################################################################

#Function for running a DNF installation
def run_dnf(rootfs,inst,what):
    cmd=[ "dnf", "-y", "--skip-broken" , "-c",dnf_conf, "--releasever=9", "--forcearch=aarch64", "--repo=baseos,appstream,cern,extras,ha,rt,resilientstorage,locmap-qa,locmap,openafs,epel","--verbose", "--installroot="+rootfs, inst ] + what
    print(cmd)
    try:
        process=subprocess.Popen(cmd,stdout=subprocess.PIPE,shell=False)
        while process.poll() is None:
            output = process.stdout.readline()
            if output:
                print(output.strip().decode('utf-8'))
    except:
        return

############################################################################################################################

#Parsing options
parser = argparse.ArgumentParser(description='Tool to cross-install a root filesystem for Centos Linux ARM')
FORMAT = '%(levelname)s : %(message)s'
parser.add_argument('-v','--verbose',action='store_true', help='verbose output')
parser.add_argument('-r','--root',  nargs=1, help='directory of new rootfs')
parser.add_argument('-e','--extra', nargs=1, help='file with a list of extra packages to be installed')
args = vars(parser.parse_args())
if args['verbose']:
    logging.basicConfig(format=FORMAT,stream=sys.stdout, level=logging.DEBUG)

#Check which arguments were parsed to the script, store information and inform the user
if args['root'] is not None:
    rootdir=args['root'][0]
    print ("Root directory path: " + rootdir)
else:
    print("Use --root=<dir> to set new rootfs directory")
    exit(-1)

if args['extra'] is not None:
	text_file = open(args['extra'][0],"r")
	lines=[]
	for x in text_file:
		x=x.replace("\n", "")
		lines.append(x)

	text_file.close()	

############################################################################################################################

#Check if script is being ran with sudo (superuser priveleges)
if(os.getuid()!=0):
    print ("Program must to run as superuser")
    print ("Relaunching as: sudo "," ".join(sys.argv))
    os.execvp("sudo",["sudo","PATH="+os.getenv("PATH"),"LD_LIBRARY_PATH="+os.getenv("LD_LIBRARY_PATH"),"PYTHONPATH="+os.getenv("PYTHONPATH"),]+sys.argv)
    exit(0)

# Prepare qemu
url = 'https://github.com/multiarch/qemu-user-static/releases/download/v7.1.0-2/qemu-aarch64-static'
urllib.request.urlretrieve(url, 'qemu-aarch64-static')
os.chmod("qemu-aarch64-static", 493)
path=rootdir+"/usr/local/bin/"
os.makedirs(path)
copyfile("qemu-aarch64-static", path+"qemu-aarch64-static")
copyfile("qemu-aarch64-static", "/usr/local/bin/qemu-aarch64-static")

#For this to work, it is required that the virtual machine was already setup
print ("Using qemu-aarch64-static")
shutil.copy(qemu_bins+"/qemu-aarch64-static",rootdir+"/usr/local/bin/qemu-aarch64-static")

run_dnf(rootdir,"clean",["all"])	#Clean all cache files generated from repository metadata
run_dnf(rootdir,"update",[" "])		#Update all the installed packages

#Run the dnf installer and install additional packages if stated in the "extra" argument
print ("Running dnf: group install")
run_dnf(rootdir,"groupinstall",['Minimal Install'])
if args['extra'] is not None:
	print("Installing user defined packages...")
	run_dnf(rootdir,"install",lines)

# The resolv.conf file should exist in order for the Network Manager to apply its settings
print("Creating required files for the Network Manager")
Path(rootdir+"/etc/resolv.conf").touch()

# Update time zone to CERN
zone = "Europe/Zurich"
print("Updating time zone to " + zone)
zoneinfo_path = rootdir + "/usr/share/zoneinfo/" + zone
destination_link = rootdir + "/etc/localtime"

try:
    # Remove the existing localtime link or file if it exists
    if os.path.exists(destination_link):
        os.remove(destination_link)
    
    # Create a symlink in the target filesystem
    os.symlink(zoneinfo_path, destination_link)
except Exception as e:
    print("An error occurred while updating the time zone: ", e)
    print("The process will continue without setting the time zone.")

#Configuration using Augeas
rootpwd=crypt.crypt("EMPaina", crypt.mksalt(crypt.METHOD_SHA512))	#Create a root password
aug=augeas.Augeas(root=rootdir)										#Create augeas tree
aug.set("/files/etc/shadow/root/password",rootpwd)					#Set password
aug.set("/files/etc/sysconfig/selinux/SELINUX","disabled")			#Disable SELINUX
aug.save()
aug.close()

# Instructions for first time running
print("When running for the first time, initialize your network connection by running:")
print("$ nmcli con mod eth0 ipv4.method auto")
print("$ nmcli con mod eth0 ipv6.method auto")