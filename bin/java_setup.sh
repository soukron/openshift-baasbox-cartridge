#!/bin/sh

# JRE 8 Update 25
URL=http://download.oracle.com/otn-pub/java/jdk/8u25-b17/jre-8u25-linux-x64.tar.gz

cd $OPENSHIFT_DATA_DIR
if [ -d "java" ] && [ "`cat java/URL`" == ${URL} ]; then
  echo "Java already installed"
else
  echo "Installing Java from ${URL}"

  if [ -d "java" ]; then
    rm -rf java
  fi

  wget --progress=bar -O java.tar.gz --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" ${URL}

  mkdir java
  tar -xf java.tar.gz -C java --strip-components=1
  rm java.tar.gz

  echo ${URL} > java/URL
fi

