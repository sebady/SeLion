#!/bin/bash
set -e

#############################################################
# This script updates travis CI with latest google chromium
# and chromedriver and starts the selion chrome suite locally
#############################################################
if [ -n "${SAUCE_USERNAME}" ]; then
  echo { \"sauceUserName\": \"${SAUCE_USERNAME}\", \"sauceApiKey\": \"${SAUCE_ACCESS_KEY}\", \"tunnel-identifier\": \"__string__${TRAVIS_JOB_NUMBER}\", \"build\": \"${TRAVIS_BUILD_NUMBER}\", \"idle-timeout\": 120, \"tags\": [\"commit ${TRAVIS_COMMIT}\", \"branch ${TRAVIS_BRANCH}\", \"pull request ${TRAVIS_PULL_REQUEST}\"] } > client/src/test/resources/sauceConfig.json
  mvn test -pl client -DsuiteXmlFile=Chrome-Suite.xml -B -V
else

  export CHROMEDRIVER_VERSION=`curl -s http://chromedriver.storage.googleapis.com/LATEST_RELEASE`
  curl -L -O "http://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip"
  unzip chromedriver_linux64.zip && chmod +x chromedriver

	# Use travis installed chromium version
  #export CHROME_REVISION=`curl -s http://commondatastorage.googleapis.com/chromium-browser-snapshots/Linux_x64/LAST_CHANGE`
  #curl -L -O "http://commondatastorage.googleapis.com/chromium-browser-snapshots/Linux_x64/${CHROME_REVISION}/chrome-linux.zip"
  #unzip chrome-linux.zip
  #ln -sf $PWD/chrome-linux/chrome-wrapper google-chrome

  mvn test -pl client -DsuiteXmlFile=Chrome-Suite.xml -DSELION_SELENIUM_RUN_LOCALLY=true \
    -DSELION_SELENIUM_CHROMEDRIVER_PATH=$PWD/chromedriver \
    -DSELION_SELENIUM_CHROME_OPTIONS="--no-sandbox" -B -V
fi
