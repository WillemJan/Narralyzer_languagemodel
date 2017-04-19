#!/bin/bash

# Goal of this install procedure is to get && and freeze fetch stanford core, unpack, throw away unused files.
# This enables the framework to keep track of data and software versions used during classification.

# This file is part of the Narralyzer project.

# Narralyzer config util,
# all (global) variables should be defined in the conf/conf.ini file.

#------------------------------------------------
# Functions
#------------------------------------------------

# Little wrapper to datestamp outgoing messages.
function inform_user() {
    msg="$1"
    timestamp=$(date "+%Y-%m-%d %H:%M")
    echo "$timestamp: Narralyzer start_stanford.sh $msg"
}

function airbag() {
    echo "Exit with -1, from $0:$@"
    exit -1
}


if [ -f "../../narralyzer/config.py" ]
then
    CONFIG=$(../../narralyzer/config.py self)
else
    airbag "Could not find ../../narralyzer/config.py, aborting."
fi

# Fetch the given URL, and save to disk
# use the 'basename' for storing,
# retry a couple of times before failing.
function get_if_not_there () {
    URL=$1
    retries=4
    not_done="true"
    if [ ! -f $(basename $URL) ]; then
        while [ $not_done == "true" ]; do
           inform_user "Fetching $URL..."
           wget_output=$(wget -q "$URL")
           if [ $? -ne 0 ]; then
               # If downloading fails, try again.
               retries=$(($retries - 1))
               if [ $retries == 0 ]; then
                   $(wget -q "$URL")
                   airbag "Error while fetching $URL, no retries left." $LINENO
               else
                   inform_user "Error while fetching $URL, $retries left." $LINENO
                   sleep 1
               fi
           else
               # Else leave the loop.
               not_done="false"
           fi
        done
    else
        inform_user "Not fetching $URL, file allready there."
    fi
}

get_if_not_there $($CONFIG stanford_core_source)
unzip $(basename $($CONFIG stanford_core_source))
find $(basename $($CONFIG stanford_core_source) | cut -d '.' -f 1) -name stanford-corenlp*\.jar -exec cp '{}' ./java/ ';'
find $(basename $($CONFIG stanford_core_source) | cut -d '.' -f 1) -name slf4j* -exec cp '{}' ./java/ ';'
