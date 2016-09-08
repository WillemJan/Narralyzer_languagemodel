#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
    narralyzer_languagemodel.pp.lang.nl.meertens_lastnames
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    Simple harvester for Dutch last names.

    Data-source:
        http://www.meertens.knaw.nl/nfb/

    :copyright: (c) 2016 Koninklijke Bibliotheek, by Willem-Jan Faber.
    :license: GPLv3
    https://github.com/KBNLresearch/Narralyzer/blob/master/licence.txt
"""

import lxml.html
import sys
import urllib.request

sys.reload(sys)
sys.setdefaultencoding('utf-8')


BASEURL = "http://www.meertens.knaw.nl/nfb/lijst_namen.php?operator=cn&naam=%s"
DEBUG = False

vowels = ['a',
          'e',
          'i',
          'o',
          'u']

forbidden = ['Naam',
             'Centraal Bureau voor Genealogie',
             'KNAW/Meertens Instituut']

familynames = set()


def scrape_page(data):
    data = lxml.html.fromstring(data)

    for item in data.xpath("//tr/td/*"):
        if item.text and item.text.strip() and item.text not in forbidden:
            familynames.add(item.text.strip())

    for item in data.xpath("//tr/*"):
        if item.text and len(item.text.split('\t')) == 22:
            familynames.add(item.text.split('\t')[11].strip())

    maxpage = int(data.xpath('//a')[-6].
                  values()[0].split('&')[2].split('=')[-1])
    return maxpage


def fetch_meertens_familynames(offset, vowel):
    url = BASEURL % vowel + "&offset=%i" % offset
    response = urllib.request.urlopen(url)

    if response.status == 200:
        data = response.read()
        return data.decode(response.headers.get_content_charset()), url
    else:
        sys.stderr.write("Error while opening %s\n" % url)
        return False, False


def main():
    for vowel in vowels:
        url = BASEURL % vowel
        data, url = fetch_meertens_familynames(0, vowel)
        maxpage = scrape_page(data)

        if DEBUG:
            print(url)
            for family in familynames:
                print(len(familynames), family)

        for offset in range(50, maxpage, 50):
            data, url = fetch_meertens_familynames(offset, vowel)
            if not data:
                continue

            scrape_page(data)

            if DEBUG:
                print(url)
                for family in familynames:
                    print(len(familynames), family)

    for family in familynames:
        print(family)

if __name__ == "__main__":
        main()
