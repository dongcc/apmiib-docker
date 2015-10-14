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

FROM iibv10image

ENV CANDLE_HOME /opt/ibm/apm/agent

MAINTAINER DCC <dongcc@cn.ibm.com>

USER root

COPY iib-agent4docker.sh /usr/local/bin/
COPY iibwithapm          /usr/local/bin/

RUN chmod +x /usr/local/bin/iib-agent4docker.sh
RUN chmod +x /usr/local/bin/iibwithapm

VOLUME ${CANDLE_HOME}

USER iibuser
# start apm agents
ENTRYPOINT ["iibwithapm"]
