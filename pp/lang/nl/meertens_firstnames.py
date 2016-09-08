#!/usr/bin/env python2.7
# -*- coding: utf-8 -*-
"""
    narralyzer_languagemodel.pp.lang.nl.meertens_firstnames
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    Simple harvester for Dutch first names, and their freq.

    Data-source:
        http://www.meertens.knaw.nl/nvb/

    :copyright: (c) 2016 Koninklijke Bibliotheek, by Willem-Jan Faber.
    :license: GPLv3
    https://github.com/KBNLresearch/Narralyzer/blob/master/licence.txt
"""

import logging
import pickle
import sys
import urllib

from lxml import etree
from StringIO import StringIO

sys.reload(sys)
sys.setdefaultencoding('utf-8')

class MeertensFirstnameHarvester:
    BASEURL = 'http://www.meertens.knaw.nl/nvb/naam/bevat/%s'
    BASEURL1 = 'http://www.meertens.knaw.nl/nvb/naam/pagina%i/bevat/%s'

    CACHE_F = 'first_names_f.pickle'
    CACHE_M = 'first_names_m.pickle'

    female = {}
    male = {}

    # http://www.phonetics.ucla.edu/course/chapter1/vowels.html
    vowels = ['a',
              'e',
              'i',
              'o',
              'u']

    def __init__(self):
        for k in self.vowels:
            url = self.BASEURL % k
            self._fetch_page(url)

            log.debug('Writing %i first names to cache %s' % (
                len(self.female.keys()) + len(self.male.keys()),
                self.CACHE_M)
            )

            with open(self.CACHE_M, 'wb') as fh:
                pickle.dump(self.female, fh)

            with open(self.CACHE_F, 'wb') as fh:
                pickle.dump(self.male, fh)

            for i in range(26665):
                url = self.BASEURL1 % (i, k)

                if not self._fetch_page(url):
                    break

                log.debug('Writing %i first names to cache %s' % (
                    len(self.female.keys()) + len(self.male.keys()),
                    self.CACHE_M)
                )

                print('F', k, sorted(self.female.keys())[-10:])
                print('M', k, sorted(self.male.keys())[-10:])

                with open(self.CACHE_F, 'wb') as fh:
                    pickle.dump(self.female, fh)

                with open(self.CACHE_M, 'wb') as fh:
                    pickle.dump(self.male, fh)

    def _fetch_page(self, url):
        try:
            html = urllib.urlopen(url).read()
            log.debug('Reading %s' % url)
            parser = etree.HTMLParser()
            tree = etree.parse(StringIO(html), parser)
            self._parse_tds(tree.xpath('//td'))
            return True
        except:
            return False

    def _parse_tds(self, tds):
        for i in range(1, 16):
            nr = i * 3

            name = tds[nr].xpath('a')[0]
            name = name.text.encode('utf-8')
            name = name.replace('(', '').replace(')', '')

            female = tds[nr + 2].text.split(' ')[-1]
            male = tds[nr + 1].text.split(' ')[-1]

            if name not in [self.female.keys() + self.male.keys()]:
                if female == '-':
                    female = 0
                if male == '-':
                    male = 0

                if int(female) > int(male) and int(female) > 4:
                    self.female[name] = female
                elif int(female) > 1:
                    self.female[name] = female
                else:
                    if int(male) > int(female) and int(male) > 4:
                        self.male[name] = male
                    elif int(male) > 1:
                        self.male[name] = male

logging.basicConfig()
log = logging.getLogger("dutchnames")
log.setLevel(logging.DEBUG)
meertens = MeertensFirstnameHarvester()
