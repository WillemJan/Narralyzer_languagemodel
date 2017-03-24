#!/usr/bin/env python2.7
# -*- coding: utf-8 -*-
"""
    Narralyzer_languagemodel.pp.lang.nl.generate_pp_trainingset_firstnames
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    Simple traing material generator for parserator

    Data-source:
        See *namen.txt

    :copyright: (c) 2016 Koninklijke Bibliotheek, by Willem-Jan Faber.
    :license: GPLv3
    https://github.com/KBNLresearch/Narralyzer/blob/master/licence.txt
"""

import os
import sys
reload(sys) 
sys.setdefaultencoding('utf8')

import codecs
import pickle
import glob

from lxml import etree

root = etree.Element("NameCollection")
names = set()

f = pickle.load(open("first_names_f.pickle", 'rb'))
m = pickle.load(open("first_names_m.pickle", 'rb'))

for fname in glob.glob('*namen.txt'):
    for line in codecs.open(fname, 'rb', encoding='UTF-8'):
        if not line.startswith('#'):
                names.add(line.strip())

for name in f.keys():
    names.add(unicode(name, 'utf-8'))

for name in m.keys():
    names.add(unicode(name, 'utf-8'))

for name in names:
    e_name = etree.SubElement(root, "Name")
    etree.SubElement(
        e_name, "GivenName").text = name

print(etree.tostring(
        root, encoding="UTF-8", pretty_print=True))
