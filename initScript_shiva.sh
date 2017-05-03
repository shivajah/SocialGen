#!/bin/bash
export SOCIAL_GEN_HOME=$HOME/SocialGen;
cd $SOCIAL_GEN_HOME;
mvn clean package;
export SOCIAL_GEN_LOCAL_HOME=/Users/shiva/SocialGen_Local/;
$SOCIAL_GEN_HOME/scripts/install.sh;
$SOCIAL_GEN_HOME/scripts/init.sh
