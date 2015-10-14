#!/bin/sh
# © Copyright IBM Corporation 2015.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

CANDLE_HOME=/opt/ibm/apm/agent
PRODUCTCODE=qi
INSTANCENAME=${NODENAME}
SILENTCONFIG=${CANDLE_HOME}/config/${INSTANCENAME}_mqsilent.txt
IIB_DOCKER_USER=iibuser
IIB_DOCKER_GROUP=mqbrkrs

chown_home()
{
    sudo chown -R $IIB_DOCKER_USER:$IIB_DOCKER_GROUP $CANDLE_HOME >/dev/null 2>&1
}

start_instance ()
{
  #echo "basename:$(basename $0)"
  if [ ! -f ${CANDLEHOME}/config/${PRODUCTCODE}\_${INSTANCENAME}.environment -a -z "`ls ${CANDLEHOME}/config/*_${PRODUCTCODE}\_${INSTANCENAME}.cfg 2>/dev/null`" ] ; then
    echo "The instance \"${INSTANCENAME}\" is not configured for this agent, will generate a slient config..."
    echo "agentId=${AGENTID}\n">${SILENTCONFIG}
    echo "defaultWMBInstallDirectory=/opt/ibm/iib-10.0.0.0\n">>${SILENTCONFIG}
    echo "WMQLIBPATH=\n">>${SILENTCONFIG}
    #cat ${SILENTCONFIG}

    #`dirname $0`/mq-agent.sh config ${INSTANCENAME} ${SILENTCONFIG}
    ${CANDLE_HOME}/bin/iib-agent.sh config ${INSTANCENAME} ${SILENTCONFIG}
  fi

  ${CANDLE_HOME}/bin/iib-agent.sh start ${INSTANCENAME} 
}

stop_instance()
{
  ${CANDLE_HOME}/bin/iib-agent.sh stop ${INSTANCENAME} 
}

if [ "$1" = "start" ]; then
  chown_home
  start_instance
elif [ "$1" = "stop" ]; then
  stop_instance
else
  echo "Invalid parameter,only start|stop allowed";
fi
