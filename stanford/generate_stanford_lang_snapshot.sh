#!/bin/bash

# Goal of this install procedure is to get && and freeze the stanford-language models
# This enables the framework to keep track of data and software versions used during classification.

# This file is part of the Narralyzer project.

# Narralyzer config util,
# all (global) variables should be defined in the conf/conf.ini file.
CONFIG=$(../../narralyzer/config.py self)

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

# Moves the retrieved classifiers into there respective lang dir, 
# and generate md5sum usefull for reference later.
function move_classifiers_inplace {
    for lang in $($CONFIG supported_languages | xargs); do
        target_path=$($CONFIG root)
        target_path="$target_path"/"$($CONFIG stanford_ner_path)"/"$lang"
        echo "target_path: $target_path"
        if [ ! -d $target_path ]; then
            mkdir -p $target_path || airbag "Could not create directory: $target_path" $LINENO
            inform_user "Created directory: $target_path"
        fi
        src="$($CONFIG root)"/"$(find stanford/models -name $($CONFIG "lang_"$lang"_stanford_ner") -type f || airbag "Could not find model for $lang." $LINENO)"
        checksum=$(md5sum -b "$src" | cut -d ' ' -f 1 || airbag "Failed to md5sum $src" $LINENO)
        target="$target_path"/"$checksum"".crf.ser.gz"
        inform_user "Moving classifier $src to $target."
        # SHOWER-THOUGHT: I could also link them, and delete unused files..
        # For now, this feels right.
        mv "$src" "$target" || airbag "Failed to move $src to $target" $LINENO
    done
}

# Fetch and unpack the language models.
function fetch_stanford_lang_models {
    for lang in $($CONFIG supported_languages | xargs);do
        get_if_not_there $($CONFIG "lang_"$lang"_stanford_ner_source")
    done
    find . -name \*.jar -exec unzip -q -o '{}' ';'
}


for lang in $($CONFIG supported_languages | xargs)
do
    mdkir -p

done

