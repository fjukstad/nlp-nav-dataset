#!/bin/bash
wget https://data.nav.no/api/nav-opendata/2f6ce2a2c65dd50709d389486da3947a/resources/ledige_stillinger_meldt_til_nav_2018.csv.gz
gzip -d ledige_stillinger_meldt_til_nav_2018.csv.gz

wget https://data.nav.no/api/nav-opendata/stillingstekster/stillinger_2019_tekst.csv.gz
gzip -d stillinger_2019_tekst.csv.gz
