# docker-ezgo-vdi

run *[ezgo](http://ezgo.westart.tw/)* in docker to provide virtual desktop.

**Quick Start**

Run the docker image and open port 80

docker run -p 80:80 -d leejoneshane/ezgo-vdi

Browse http://localhost

**Connect with VNC Viewer**

Forward VNC service port 5900 to host by

docker run -p 5900:5900 -d leejoneshane/ezgo-vdi

Now, open the vnc viewer and connect to port 5900.

**Connect with Microsoft Remote Desktop**

Forward RDP service port 3389 to host by

docker run -p 3389:3389 -d leejoneshane/ezgo-vdi

Now, open the Microsoft Remote Desktop Client and connect to host.

**Connect with Google Chrome Remote Desktop**

You don't need forward any port, like below:

docker run -d leejoneshane/ezgo-vdi

Then, lunch chrome remote desktop extension and add the host ip.
