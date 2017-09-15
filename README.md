# docker-ezgo-vdi

run ezgo in docker to provide virtual desktop.

**Quick Start**

Run the docker image and open port 80

docker run -it --rm -p 80:80 leejoneshane/ezgo-vdi

Browse http://localhost

**Connect with VNC Viewer and protect by VNC Password**

Forward VNC service port 5900 to host by

docker run -it --rm -p 80:80 -p 5900:5900 leejoneshane/ezgo-vdi

Now, open the vnc viewer and connect to port 5900. If you would like to protect vnc service by password, set environment variable VNC_PASSWORD, for example:

docker run -it --rm -p 6080:80 -p 5900:5900 -e VNC_PASSWORD=mypassword leejoneshane/ezgo-vdi

A prompt will ask password either in the browser or vnc viewer.
