#!/bin/bash

user=`whoami`
(cd .xmind_installer;sudo /tmp/xmind-installer.sh $user)
