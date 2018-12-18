#!/bin/bash
# Copyright 2017 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit

scripts_dir="$(dirname "${BASH_SOURCE[0]}")"

# make sure we're running as the owner of the checkout directory
RUN_AS="$(ls -ld "$scripts_dir" | awk 'NR==1 {print $3}')"
if [ "$USER" != "$RUN_AS" ]
then
    echo "This script must run as $RUN_AS, trying to change user..."
    exec sudo -u $RUN_AS $0
fi

sudo apt-get update -y

if ps ax | grep -v grep | grep gassistpi > /dev/null
then
    echo "==========Google Assistant Voice Service is running, stopping it for updating the project=========="
    sudo systemctl stop gassistpi.service
else
    echo "==========Service is not running, proceeding to update the project=========="
fi

sudo mv /home/pi/GassistPi /home/pi/GassistPi.bak-$(date +%F)

git clone https://github.com/shivasiddharth/GassistPi

cd /home/pi/

sed 's/#.*//' /home/pi/GassistPi/Requirements/GassistPi-system-requirements.txt | xargs sudo apt-get install -y

source env/bin/activate

pip install -r /home/pi/GassistPi/Requirements/GassistPi-pip-requirements.txt
echo ""
echo ""
echo "==========Finished updating the project. Please restart the Pi=========="
