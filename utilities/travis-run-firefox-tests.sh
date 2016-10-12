#!/bin/bash
set -e

#############################################################
# This script updates travis with firefox and
# geckodriver and starts the selion firefox suites locally
#############################################################

if [ -n "${SAUCE_USERNAME}" ]; then
  echo { \"sauceUserName\": \"${SAUCE_USERNAME}\", \"sauceApiKey\": \"${SAUCE_ACCESS_KEY}\", \"tunnel-identifier\": \"__string__${TRAVIS_JOB_NUMBER}\", \"build\": \"${TRAVIS_BUILD_NUMBER}\", \"idle-timeout\": 120, \"tags\": [\"commit ${TRAVIS_COMMIT}\", \"branch ${TRAVIS_BRANCH}\", \"pull request ${TRAVIS_PULL_REQUEST}\"] } > client/src/test/resources/sauceConfig.json
  mvn test -pl client -DsuiteXmlFile=Firefox-Suite.xml -B -V
else

  # Remove any existing firefox
  #sudo rm -fr /usr/local/firefox-*
  export FIREFOX_VERSION=49.0.1
  export FIREFOX_URL=http://download.cdn.mozilla.net/pub/firefox/releases/${FIREFOX_VERSION}/linux-x86_64/en-US/firefox-${FIREFOX_VERSION}.tar.bz2
  wget -O firefox-${FIREFOX_VERSION}.tar.bz2 ${FIREFOX_URL}
  # and install downloaded firefox
  tar -xjf firefox-${FIREFOX_VERSION}.tar.bz2

  export GECKODRIVER_VERSION=v0.10.0
  curl -L -o geckodriver.tar.gz https://github.com/mozilla/geckodriver/releases/download/${GECKODRIVER_VERSION}/geckodriver-${GECKODRIVER_VERSION}-linux64.tar.gz
  gunzip -c geckodriver.tar.gz | tar xopf -
  chmod +x geckodriver

  mvn test -pl client -DsuiteXmlFile=Firefox-Suite.xml -DSELION_SELENIUM_RUN_LOCALLY=true \
    -DSELION_SELENIUM_USE_GECKODRIVER=true -DSELION_SELENIUM_GECKODRIVER_PATH=geckodriver \
    -Dwebdriver.firefox.bin=$PWD/firefox/firefox -B -V
fi
