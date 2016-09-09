#!/bin/bash

# Goal of this install procedure is to get && and freeze the stanford-language models
# This enables the framework to keep track of data and software versions used during classification.

# This file is part of the Narralyzer project.

# Narralyzer config util,
# all (global) variables should be defined in the conf/conf.ini file.
CONFIG=$(../../narralyzer/config.py self)

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
    (
    dest_path="$($CONFIG root)"/"$($CONFIG stanford_models)"
    src_url=$($CONFIG lang_"$lang"_stanford_ner_source)
    if [ -f "$dest_path"/"$(basename $src_url)" ]
    then
        msg="Allready stored ""$dest_path"/"$(basename $src_url)"
        airbag $msg
    fi
    msg="Storing $src_url into $dest_path"
    inform_user "$msg"

    msg="Failed to get""$dest_path"/"$(basename $src_url)"
    curl -s $src_url > "$dest_path"/"$(basename $src_url)" || airbag "$msg"

    sum=$(md5sum -b "$dest_path"/"$(basename $src_url)" | cut -d ' ' -f 1)
    if [ -f "$dest_path"/"$sum" ]
    then
        msg="md5sum hash space to small to handle all language modules. (Bable-fish alert!)"
        airbag "$msg"
    fi
    mv "$dest_path"/"$(basename $src_url)" "$dest_path"/"$sum"
    ln -s "$dest_path"/"$sum" "$dest_path"/"$(basename $src_url)"
    ) &
done
