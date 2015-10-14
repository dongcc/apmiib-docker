# apmiib-docker
Monitoring IBM Integration Bus in a Docker container

# Overview

By using the Dockerfile and scripts that are provided in this repository, you can use IBM Performance Management (http://www-03.ibm.com/software/products/en/application-performance-management) to monitor the IBM Integration Bus (http://www-03.ibm.com/software/products/en/ibm-integration-bus) that is running inside a Docker container. 
Any feedback regarding the function that is described in this article will be very much appreciated. 



# Installing Monitoring Agent for IBM Integration Bus

Install the Monitoring Agent for IBM Integration Bus on your Docker host. The default installation directory on Linux systems is /opt/ibm/apm/agent. For more information on installing the agent, see the “Installing your agents” section in the IBM Performance Management Knowledge Center (http://www-01.ibm.com/support/knowledgecenter/SSHLNR_8.1.2/com.ibm.pm.doc/install/onprem_install_intro.htm). 

Note: if you do not want to use the IIB Agent on Docker host directly, you must set SKIP_PRECHECK to YES before installation. For example:

~~~
export SKIP_PRECHECK=YES
~~~

If you already configured an IBM Integration Bus for Developers Edition Docker Container image, you want to use the IBM Performance Management to monitor that, please flow the session of "Changing existing image".

If you do not have any existing IBM Integration Bus for Developers Edition Docker Container image, please follow the session of "Building the image".

# Changing existing image

There is a shell script(patch.sh) in this repository that can help you copying the scripts into your existing container like below:

~~~
./patch.sh ${CONTAINER_ID}
~~~

You can get your container id via the Docker command "docker ps".

After applying the changes to your Docker container, you can update and commit your image.

~~~
docker commit -m "enable APM monitoring" -a "DCC"  ${CONTAINER_ID} iibv10image:v2
~~~
Where the "iibv10image" is your docker image of IBM Integration Bus that existied in your repository.

You will have a new image in your repository named iibv10image:v2.

When you run the image, accept the terms of the IBM Integration Bus for Developers Edition license by specifying the environment variable “LICENSE” equal to “accept”. You can also view the license terms by setting this variable to “view”. If you don’t set the variable, the container is ended with a usage statement. You can view the license in a different language by setting the “LANG” environment variable.

In addition to accepting the license, you must specify a Integration node by using the “NODENAME” environment variable. For more information, see the iib GitHub (https://github.com/ot4i/iib-docker).

If you run multiple containers, you are sharing the same Performance Management installation on the Docker host. Note that if you are using the same NODENAME across different Docker containers in the same Docker host, you need to use different AGENTID.

~~~
docker run \
  --env LICENSE=accept \
  --env NODENAME=IIBNODE1 \
  --env AGENTID=docker01 \
  --volume /opt/ibm/apm/agent:/opt/ibm/apm/agent \
  --publish-all\
  --detach \
  --entrypoint=iibwithapm \
  iibv10image:v2
~~~

Here are the parameters descrption:
--env LICENSE=accept                           You accept the terms of the IBM IIB for Developers license
--env NODENAME=IIBNODE1                        The Integration node that runs in this container
--env AGENTID=docker01                         The agent id of the IIB agent, max 8 characters
--volume /opt/ibm/apm/agent:/opt/ibm/apm/agent The first /opt/ibm/apm/agent directory stands for where are you installed IBM Performance Management on your Docker host;
                                               the second /opt/ibm/apm/agent is the home APM directory of your Docker container, do not change this value.                       
--entrypoint=iibwithapm                        Override the existing the ENTRYPOINT of the IIB docker container, note this script also includes the steps to call the ENTRYPOINT of the IIB container.
iibv10image:v2                                 The image you just commited.

# Building the image

The image can be built by using standard Docker commands (https://docs.docker.com/userguide/dockerimages/) against the provided Dockerfile. For example, run the following commands: 

~~~
docker build -t ibmcom/apm4iib .
~~~

An image called ibmcom/apm4iib is created in your local Docker registry.


When you run the image, accept the terms of the IBM Integration Bus for Developers Edition license by specifying the environment variable “LICENSE” equal to “accept”. You can also view the license terms by setting this variable to “view”. If you don’t set the variable, the container is ended with a usage statement. You can view the license in a different language by setting the “LANG” environment variable.

In addition to accepting the license, you must specify a Integration node by using the “NODENAME” environment variable. For more information, see the iib GitHub (https://github.com/ot4i/iib-docker).

For example:

~~~
docker run \
  --env LICENSE=accept \
  --env NODENAME=IIBNODE1 \
  --env AGENTID=docker01 \
  --volume /opt/ibm/apm/agent:/opt/ibm/apm/agent \
  --publish-all\
  --detach \
  ibmcom/apm4iib
~~~

Here are the parameters descrption:
--env LICENSE=accept                           You accept the terms of the IBM IIB for Developers license
--env NODENAME=IIBNODE1                        The Integration node that runs in this container
--env AGENTID=docker01                         The agent id of the IIB agent, max 8 characters
--volume /opt/ibm/apm/agent:/opt/ibm/apm/agent The first /opt/ibm/apm/agent directory stands for where are you installed IBM Performance Management on your Docker host;
                                               the second /opt/ibm/apm/agent is the home APM directory of your Docker container, do not change this value.                       
ibmcom/apm4iib                                  The image you just built.

If you run multiple containers, you are sharing the same Performance Management installation on the Docker host. Note that if you are using the same NODENAME across different Docker containers in the same Docker host, you need to use different AGENTID.

# Running administrative commands

It is recommended that you configure IIB in your own custom image. However, you might need to run IIB commands directly inside the process space of the container. To run a command against a running queue manager, you can use “docker exec”. If you run commands non-interactively under Bash, then the IIB environment will be configured correctly. For example: 

~~~
docker exec \
  --tty \
  --interactive \
  ${CONTAINER_ID} \
  bash -c mqsilist
~~~

By using this method, you have full control over all aspects of the Performance Management installation and IIB installation.
Note: if you use this method to make changes to the filesystem, the changes will be lost if you re-created your container unless you make those changes in volumes.

# Accessing logs

You can find the Performance Management logs in the agent installation directory (e.g. /opt/ibm/apm/agent/logs/) on your docker host.

# Verifying your container is running correctly

Follow the steps to verify if the image is used as provided or has been customized: 

1. Run a container, making sure to expose port 4414 to the host - the container should start without error
2. Run mqsilist to show the status of your node as described above - your node should be listed as running
3. Access syslog as descried above - there should be no errors
4. Connect a browser to your host on the port you exposed in step 1 - the Integration Bus web user interface should be displayed.
5. Run command “iib-agent.sh” as described in section “Running Administrative Commands” to show the status of your node. For example: 

~~~
docker exec \
  ${CONTAINER_ID} \
  bash -c "/opt/ibm/apm/agent/bin/iib-agent.sh status"
~~~
The node should be listed as running.

At this point, your container is running and you can access Performance Management console (http://www-01.ibm.com/support/knowledgecenter/SSHLNR_8.1.2/com.ibm.pm.doc/install/admin_console_start.htm) to view the performance dashboards.

# Issues and contributions

For issues that are specifically related to this Dockerfile, please use the GitHub issue tracker (https://github.com/dongcc/apmiib-docker/issues). If you submit a Pull Request related to this Dockerfile, please indicate in the Pull Request that you accept and agree to be bound by the terms of the [IBM Contributor License Agreement](CLA.md).

# License

The Dockerfile and associated scripts are licensed under the [Apache License 2.0](LICENSE). IBM Integration Bus for Developers is licensed under the IBM International License Agreement for Non-Warranted Programs. You can check the license from the image using the “LICENSE=view” environment variable as previously described. Note that this license does not permit further distribution.