#!/bin/bash

##
# Copyright IBM Corporation 2016
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
##

# If any commands fail, we want the shell script to exit immediately.
set -e

# Parse input parameters
source ./parse_inputs.sh

curl -X GET "https://$username.cloudant.com/bluepic_db/_design/main_design" -u $username:$password > main_design.json
#curl -X GET "https://455a9bcb-1b79-4da9-a2aa-3babd429db1f-bluemix.cloudant.com/attendee/_design/attendee_main_design" -u 455a9bcb-1b79-4da9-a2aa-3babd429db1f-bluemix:e20b951230d1eb08e414eb373c0ee8ff368b33534440ebd556dde32af88eb40e > attendee_main_design.json
