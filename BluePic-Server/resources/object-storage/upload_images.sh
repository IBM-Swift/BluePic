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

imagesFolder=`dirname $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )`/images
authHeader="Bearer eyJhbGciOiJSUzI1NiIsImpwayI6eyJhbGciOiJSU0EiLCJleHAiOiJBUUFCIiwibW9kIjoiQUkzT2YyZFd5VnVwY183OHY3WVl6WXRpZ05mZ083ZHdxYmtscHZQaE5MYWpOR1ROdWRfc1Nqb2x0QWJCVnFCZFRpYmMybDNXUmlWUzJSWUxkbnhidG9jRkNka0cyLWJLdC0xNWNVM1VFTW5QeGw5TW9Rc2U1cXlJMEVzcFVkelh4RjY1dVNEeUR2VnhvekFXZkdocXNMSUE0THlOV1phU1dOUERWUzhxelc4Zi1HUjlfb3ZIaGhXVEZWRzlCQ3JwV0VqTGZDaTFSWEREWWY3MXkzQ0tQUXY4RzYxSGZBQVMwRC1zMndEbC1mUGZJTDlHQUdnS29LSnQ5T0V6VlRwakt0cW5YNHNxeWUyVXZhWm5FYkRtUDdVTGtpSGtCdlUwSEhwNmM1cnF6QlFxUGxyNGhiYVhPM3JDZW5DNl80Ml9lZDEyNEYxWjVCS21WVmo3NUYzckpROCJ9fQ.eyJleHAiOjE5NjAzMTE2ODgsImF1ZCI6IjJmZTM1NDc3LTUxYjAtNGM4Ny04MDNkLWFjYTU5NTExNDMzYiIsImlzcyI6Imh0dHA6XC9cL2FibXMubXlibHVlbWl4Lm5ldDo4MFwvaW1mLWF1dGhzZXJ2ZXJcL2F1dGhvcml6YXRpb25cLyIsInBybiI6IjYzODA4MDJkZjZkZjlhNzAzODA2MzVjMDA4MmJmOTEzMjA1MTc2ZTAifQ.UDLdkoCDcM9i3k1QR4NGVbJr2O7vic2v1PRKxetNF-ToOink-zQFfMLtHOIgfxxrI65hbo4b_jYYr4LHaryZNis3bb5YUbtfmH3EFkrp_UHQZVZ_X9OTQnA3zAu_VjDyB0ta8zMPHS3nXZfjqHg_WlPy2WpkfUh94Jwpj5l39mVKFOA3FyD6KPOv_DJQ3STiMBP62kJ9jYGyrURZJPFlAJ48ktiPPWQ9zms0x_lQLjGVkoIt8-SDy1n1pT3mfKhvie7unQbZUDdSSgoJnLEaFTO4LzBwn6b4TtQhSmEV_OjFqinOuTeqwYOZIpaqjGRD8h_0PeChcWCnXXwwuXyC5g eyJhbGciOiJSUzI1NiIsImpwayI6eyJhbGciOiJSU0EiLCJleHAiOiJBUUFCIiwibW9kIjoiQUkzT2YyZFd5VnVwY183OHY3WVl6WXRpZ05mZ083ZHdxYmtscHZQaE5MYWpOR1ROdWRfc1Nqb2x0QWJCVnFCZFRpYmMybDNXUmlWUzJSWUxkbnhidG9jRkNka0cyLWJLdC0xNWNVM1VFTW5QeGw5TW9Rc2U1cXlJMEVzcFVkelh4RjY1dVNEeUR2VnhvekFXZkdocXNMSUE0THlOV1phU1dOUERWUzhxelc4Zi1HUjlfb3ZIaGhXVEZWRzlCQ3JwV0VqTGZDaTFSWEREWWY3MXkzQ0tQUXY4RzYxSGZBQVMwRC1zMndEbC1mUGZJTDlHQUdnS29LSnQ5T0V6VlRwakt0cW5YNHNxeWUyVXZhWm5FYkRtUDdVTGtpSGtCdlUwSEhwNmM1cnF6QlFxUGxyNGhiYVhPM3JDZW5DNl80Ml9lZDEyNEYxWjVCS21WVmo3NUYzckpROCJ9fQ.eyJleHAiOjE0NjAzMTE2ODgsInN1YiI6Ijo6NjM4MDgwMmRmNmRmOWE3MDM4MDYzNWMwMDgyYmY5MTMyMDUxNzZlMCIsImltZi5hcHBsaWNhdGlvbiI6eyJpZCI6ImNvbS5teS5hcHAiLCJ2ZXJzaW9uIjoiMS4wIn0sImltZi51c2VyIjp7ImlkIjoiMTAwMyIsImF1dGhCeSI6ImltZi1hdXRoc2VydmVyIiwiZGlzcGxheU5hbWUiOiJ0ZXN0VXNlciBkaXNwbGF5IiwiYXR0cmlidXRlcyI6eyJmb28iOiJiYXIifX0sImF1ZCI6IjJmZTM1NDc3LTUxYjAtNGM4Ny04MDNkLWFjYTU5NTExNDMzYiIsImlzcyI6Imh0dHA6XC9cL2FibXMubXlibHVlbWl4Lm5ldDo4MFwvaW1mLWF1dGhzZXJ2ZXJcL2F1dGhvcml6YXRpb25cLyIsImlhdCI6MTQ2MDMwODA4OCwiaW1mLmRldmljZSI6eyJpZCI6IjMwMDMiLCJwbGF0Zm9ybSI6IkFuZHJvaWQiLCJtb2RlbCI6IkFuZHJvaWQgU0RLIGJ1aWx0IGZvciB4ODZfNjQiLCJvc1ZlcnNpb24iOiI2LjAifX0.aNSzQB16G9WPv8z1Q5nFyyQAvX5P-llkqmfOJiyO51krzFTiBZCx3WeqqnRA4Hd_ltQAReAq5JYp0ZHo0bN0qtdEeJBGXsR9PGj4uWWCFV1AQrZBBdZfn_Y_6MqkQng4k3VJh3896y3FBAB5qiubAuNt2-7WP-NOAAq-k_3myvyqOwkIcgqnlyCZ_TnayigSwBuiGnfMQ8AUl6vO05UuqGWhuaZNzduW826wI6P8_sjGZLv8f_ZTf5v2WHiK1RhEN-VnbQMV6nMDRtMS9n4M7KiFcGXkQn3KRsfYCTxtia0yXpaReACHm3mJt5xTNmunQ0tr62d49Quqhd0aoTqvHA"

# Upload images via Kitura-based server (localhost)
curl -v --data-binary @$imagesFolder/bridge.png -X POST http://localhost:8090/users/1003/images/bridge.png/Bridge/100/100/34.2/80.5/Austin,%20Texas -H "Authorization: $authHeader"
curl -v --data-binary @$imagesFolder/car.png -X POST http://localhost:8090/users/1003/images/car.png/Car/90/90/50.2/90.5/Tuscon,%20Arizona -H "Authorization: $authHeader"

# Upload images via Kitura-based server (running on Bluemix)
#curl -v --data-binary @$imagesFolder/bridge.png -X POST http://bluepic-superconductive-ebonite.mybluemix.net/users/1003/images/bridge.png/Bridge/100/100/34.2/80.5/Austin,%20Texas -H "Authorization: $authHeader"
#curl -v --data-binary @$imagesFolder/car.png -X POST http://bluepic-superconductive-ebonite.mybluemix.net/users/1003/images/car.png/Car/90/90/50.2/90.5/Tuscon,%20Arizona -H "Authorization: $authHeader"