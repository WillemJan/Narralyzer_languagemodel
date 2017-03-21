#!/usr/bin/env python2.7

import os
import codecs
from lxml import etree
import pickle

root = etree.Element("NameCollection")
achtervoegsels = set()

for line in codecs.open('achtervoegsels.txt', 'r', encoding='UTF-8'):
    if not line.strip().startswith('#'):
        achtervoegsels.add(line.strip())

for line in codecs.open('last_names.txt', 'r', encoding='UTF-8'):
    if line.strip():
        e_name = etree.SubElement(root, "Name")
        etree.SubElement(e_name, "Surname").text = line.strip()

        achtervoegsel_check = set()
        [achtervoegsel_check.add(item) for item in line.strip().split(', ')]
        if achtervoegsel_check.intersection(achtervoegsels):
            if len(line.strip().split(', ')) >= 2:
                name = line.strip().split(', ')[1]
                name += u" " + line.strip().split(', ')[0]
                e_name = etree.SubElement(root, "Name")
                etree.SubElement(e_name, "Surname").text = name

print (etree.tostring(root, encoding="UTF-8", pretty_print=True))
