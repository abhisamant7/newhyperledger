#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
# Exit on first error, print all commands.
set -ev

# don't rewrite paths for Windows Git Bash users
export MSYS_NO_PATHCONV=1
FABRIC_START_TIMEOUT=90 
docker-compose -f docker-compose.yml down

docker-compose -f docker-compose.yml up -d  ca.dfarmadmin.com  orderer.dfarmadmin.com  peer0.dfarmadmin.com  peer0.dfarmretail.com  couchdb

# wait for Hyperledger Fabric to start
# incase of errors when running later commands, issue export FABRIC_START_TIMEOUT=<larger number>
export FABRIC_START_TIMEOUT=10
#echo ${FABRIC_START_TIMEOUT}
sleep ${FABRIC_START_TIMEOUT}

# Create the channel
docker exec -e "CORE_PEER_LOCALMSPID=DfarmadminMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@dfarmadmin.com/msp" peer0.dfarmadmin.com peer channel create -o orderer.dfarmadmin.com:7050 -c dfarmchannel -f /etc/hyperledger/configtx/channel.tx
# Join peer0.dfarmadmin.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=DfarmadminMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@dfarmadmin.com/msp" peer0.dfarmadmin.com peer channel join -b dfarmchannel.block

# Join peer0.dfarmretail.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=DfarmretailMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@dfarmretail.com/msp" peer0.dfarmretail.com peer channel join -b dfarmchannel.block
