# docker-ezgo-vdi

run *[ezgo](http://ezgo.westart.tw/)* in docker to provide virtual desktop.

**Quick Start**

Run the docker image and open port 80

docker run -it --rm -p 80:80 leejoneshane/ezgo-vdi

Browse http://localhost

**Connect with VNC Viewer**

Forward VNC service port 5900 to host by

docker run -it --rm -p 80:80 -p 5900:5900 leejoneshane/ezgo-vdi

Now, open the vnc viewer and connect to port 5900.

**Connect with Microsoft Remote Desktop**

Forward RDP service port 3389 to host by

docker run -it --rm -p 80:80 -p 3389:3389 leejoneshane/ezgo-vdi

Now, open the Microsoft Remote Desktop Client and connect to host.

**Connect with Google Chrome Remote Desktop**

You don't need forward any port, lunch chrome remote desktop extension and add the host ip.
