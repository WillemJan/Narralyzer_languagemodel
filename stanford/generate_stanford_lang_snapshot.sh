#!/bin/bash

# Goal of this install procedure is to get && and freeze the stanford-language models
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
    #exit -1
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


# Fetch and unpack the language models.
function fetch_stanford_lang_models {
    for lang in $($CONFIG supported_languages | xargs);do
        get_if_not_there $($CONFIG "lang_"$lang"_stanford_ner_source")
    done
    find . -name \*.jar -exec unzip -q -o '{}' ';'
}

#------------------------------------------------
# / Functions
#------------------------------------------------

for lang in $($CONFIG supported_languages | xargs)
do
    dest_path="$($CONFIG root)"/"$($CONFIG stanford_models)"
    src_url=$($CONFIG lang_"$lang"_stanford_ner_source)
    if [ -f "$dest_path"/"$(basename $src_url)" ]
    then
        msg="Allready stored ""$dest_path"/"$(basename $src_url)"
        #airbag $msg
    fi
    msg="Storing $src_url into $dest_path"
    inform_user "$msg"

    msg="Failed to get""$dest_path"/"$(basename $src_url)"
    #curl -s $src_url > "$dest_path"/"$(basename $src_url)" || airbag "$msg"

    sum=$(md5sum -b "$dest_path"/"$(basename $src_url)" | cut -d ' ' -f 1)
    if [ -f "$dest_path"/"$sum" ]
    then
        msg="md5sum hash space to small to handle all language modules. (Bable-fish alert!)"
        airbag "$msg"
    fi

    if [ "$lang" != "nl" ]; then
        cd "$dest_path"
        # unzip -o "$dest_path"/"$(basename $src_url)"
        echo "-"
        echo $($CONFIG lang_"$lang"_stanford_ner)
        unzip -p "$dest_path"/"$(basename $src_url)" edu/stanford/nlp/models/ner/$($CONFIG lang_"$lang"_stanford_ner) > $($CONFIG lang_"$lang"_stanford_ner)
        echo "--"

        #stanford/nlp/models/ner/english.all.3class.distsim.crf.ser.gz
        cd -
    else
        mv "$dest_path"/"$(basename $src_url)" "$dest_path"/"$sum"
        ln -s "$dest_path"/"$sum" "$dest_path"/"$(basename $src_url)"
    fi
done
