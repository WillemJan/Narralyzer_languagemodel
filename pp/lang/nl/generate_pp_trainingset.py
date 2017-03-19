#!/usr/bin/env python2.7


import os
import codecs
from lxml import etree


import pickle


root = etree.Element("NameCollection")

for line in codecs.open('last_names.txt', 'r', encoding='UTF-8'):
    if line.strip():
        etree.SubElement(root, "Name")
        etree.SubElement(root, "Surname").text = line.strip()
print etree.tostring(root, encoding="UTF-8", pretty_print=True)
