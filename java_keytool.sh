#!/bin/bash

CERT=/path/to/cacerts 
ALIAS=name.of.alias 
${JAVA_HOME}/jre/bin/keytool -import -trustcacerts -file $CERT -alias $ALIAS -keystore ${JAVA_HOME}/jrelib/security/cacerts

