---
title: "How many Python core devs use tpying?"
date: 2023-11-11
tags:
  - python
---

The optional type annotations in Python is a big and relatively new thing. For the majority of its life, Python didn't have any good solution for static type checking, and people coming to the language fell in love with it for different reasons.

Today's case study: how many old-school Python developers use type annotations? Specifically, we'll be looking at the core developers because these are mostly people the most dedicated to the language.

**TL;DR:** Out of all Python core devs ever, about 52% have recent open-source projects, and **37% of them use type annotations**. Out of people joining the team in the past 3 years, 71% use type annotations.

## The list of core developers

First, we need a list of Python core team members. Not only present but past as well. We don't want to fall for [survivorship bias](https://en.wikipedia.org/wiki/Survivorship_bias) and miss the people who left because they don't like the new language direction.

The sources I've found:

* [devguide.python.org](https://devguide.python.org/core-developers/developer-log/index.html) is the best source. It includes names, dates, and GitHub usernames. 188 people.
* [github.com](https://github.com/python/cpython/graphs/contributors) has a list of CPython contributors, about 2500 people at the moment who ever changed even a single line of Python code.
* [github.com](https://github.com/orgs/python/people) also has a list of the Python org members.
* [discuss.python.org](https://discuss.python.org/groups/committers) list 105 CPython core developers.

## Methodology

I open the GitHub page of the person (or find another website they use for hosting open-source projects), find the latest non-fork project, and check if it has type annotations. I look only at projects updated in the past few years. I prefer checking public libraries created for others to sue but if there are none, I also check scripts they have for their own use (like a script to deploy a personal blog).

Since the process is manual and tedious and the list is long, I might be wrong in some cases. Contributions are welcome.

## The list

Legend:

* ✅: uses type annotations (in any capacity).
* ❌: no projects with type annotations.
* 🤷: no public projects in the past 5 years.
* ?: no GitHub profile. They might have projects somewhere else.

From new to old:

|   | Name | Joined | Left |
|---|------|--------|------|
| ✅ | [Adam Turner](https://github.com/AA-Turner) | 2023-10-10 | |
| ❌ | [C.A.M. Gerlach](https://github.com/CAM-Gerlach) | 2023-04-19 | |
| ✅ | [Barney Gale](https://github.com/barneygale) | 2023-03-21 | |
| ✅ | [Carl Meyer](https://github.com/carljm) | 2023-02-28 | |
| ✅ | [Pradyun Gedam](https://github.com/pradyunsg) | 2023-01-30 | |
| ✅ | [Shantanu Jain](https://github.com/hauntsaninja) | 2022-12-19 | |
| ✅ | [Kumar Aditya](https://github.com/kumaraditya303) | 2022-11-21 | |
| ✅ | [Hugo van Kemenade](https://github.com/hugovk) | 2022-11-21 | |
| ✅ | [Alex Waygood](https://github.com/AlexWaygood) | 2022-10-18 | |
| ✅ | [Filipe Laíns](https://github.com/FFY00) | 2022-10-17 | |
| 🤷 | [Erlend Egeberg Aasland](https://github.com/erlend-aasland) | 2022-05-05 | |
| ✅ | [Jelle Zijlstra](https://github.com/JelleZijlstra) | 2022-02-15 | |
| ❌ | [Dennis Sweeney](https://github.com/sweeneyde) | 2022-02-02 | |
| 🤷 | [Ken Jin](https://github.com/Fidget-Spinner) | 2021-08-26 | |
| ✅ | [Ammar Askar](https://github.com/ammaraskar) | 2021-07-30 | |
| 🤷 | [Irit Katriel](https://github.com/iritkatriel) | 2021-05-10 | |
| ✅ | [Batuhan Taskaya](https://github.com/isidentical) | 2020-11-08 | |
| ✅ | [Brandt Bucher](https://github.com/brandtbucher) | 2020-09-14 | |
| ✅ | [Lysandros Nikolaou](https://github.com/lysnikolaou) | 2020-06-29 | |
| 🤷 | [Kyle Stanley](https://github.com/aeros) | 2020-04-14 | |
| ✅ | [Donghee Na](https://github.com/corona10) | 2020-04-08 | |
| ❌ | [Karthikeyan Singaravelan](https://github.com/tirkarthi) | 2019-12-31 | |
| 🤷 | [Joannah Nanjekye](https://github.com/nanjekyejoannah) | 2019-09-23 | |
| ❌ | [Abhilash Raj](https://github.com/maxking) | 2019-08-06 | |
| ✅ | [Paul Ganssle](https://github.com/pganssle) | 2019-06-15 | |
| ❌ | [Stéphane Wirtel](https://github.com/matrixise) | 2019-04-08 | |
| ❌ | [Stefan Behnel](https://github.com/scoder) | 2019-04-08 | |
| 🤷 | [Cheryl Sabella](https://github.com/csabella) | 2019-02-19 | |
| ❌ | [Lisa Roach](https://github.com/lisroach) | 2018-09-14 | |
| ❌ | [Emily Morehouse](https://github.com/emilyemorehouse) | 2018-09-14 | |
| ❌ | [Pablo Galindo](https://github.com/pablogsal) | 2018-06-06 | |
| 🤷 | [Mark Shannon](https://github.com/markshannon) | 2018-05-15 | |
| ✅ | [Petr Viktorin](https://github.com/encukou) | 2018-04-16 | |
| ❌ | [Nathaniel J. Smith](https://github.com/njsmith) | 2018-01-25 | |
| ✅ | [Julien Palard](https://github.com/JulienPalard) | 2017-12-08 | |
| ✅ | [Ivan Levkivskyi](https://github.com/ilevkivskyi) | 2017-12-06 | |
| ❌ | [Carol Willing](https://github.com/willingc) | 2017-05-24 | |
| ❌ | [Mariatta](https://github.com/Mariatta) | 2017-01-27 | |
| ❌ | [Xiang Zhang](https://github.com/zhangyangyu) | 2016-11-21 | |
| 🤷 | [Inada Naoki](https://github.com/methane) | 2016-09-26 | |
| 🤷 | [Xavier de Gaye](https://github.com/xdegaye) | 2016-06-03 | 2018-01-25 |
| 🤷 | [Davin Potts](https://github.com/applio) | 2016-03-06 | |
| ❌ | [Martin Panter](https://github.com/vadmium) | 2015-08-10 | 2020-11-26 |
| ✅ | [Paul Moore](https://github.com/pfmoore) | 2015-03-15 | |
| 🤷 | [Robert Collins](https://github.com/rbtcollins) | 2014-10-16 | |
| ❌ | [Berker Peksağ](https://github.com/berkerpeksag) | 2014-06-26 | |
| ❌ | [Steve Dower](https://github.com/zooba) | 2014-05-10 | |
| ✅ | [Kushal Das](https://github.com/kushaldas) | 2014-04-14 | |
| 🤷 | [Steven D'Aprano](https://github.com/stevendaprano) | 2014-02-08 | |
| ✅ | [Yury Selivanov](https://github.com/1st1) | 2014-01-23 | |
| ❌ | [Zachary Ware](https://github.com/zware) | 2013-11-02 | |
| ✅ | [Donald Stufft](https://github.com/dstufft) | 2013-08-14 | |
| ❌ | [Ethan Furman](https://github.com/ethanfurman) | 2013-05-11 | |
| ✅ | [Serhiy Storchaka](https://github.com/serhiy-storchaka) | 2012-12-26 | |
| ❌ | [Chris Jerdonek](https://github.com/cjerdonek) | 2012-09-24 | |
| ❌ | [Eric Snow](https://github.com/ericsnowcurrently) | 2012-09-05 | |
| ? | Peter Moody | 2012-05-20 | 2017-02-10 |
| ✅ | [Hynek Schlawack](https://github.com/hynek) | 2012-05-14 | |
| ? | Richard Oudkerk | 2012-04-29 | 2017-02-10 |
| ✅ | [Andrew Svetlov](https://github.com/asvetlov) | 2012-03-13 | |
| ❌ | [Petri Lehtinen](https://github.com/akheron) | 2011-10-22 | 2020-11-12 |
| 🤷 | [Meador Inge](https://github.com/meadori) | 2011-09-19 | 2020-11-26 |
| 🤷 | [Jeremy Kloth](https://github.com/jkloth) | 2011-09-12 | |
| ❌ | [Sandro Tosi](https://github.com/sandrotosi) | 2011-08-01 | |
| ❌ | [Alex Gaynor](https://github.com/alex) | 2011-07-18 | |
| ? | Charles-François Natali | 2011-05-19 | 2017-02-10 |
| ? | Nadeem Vawda | 2011-04-10 | 2017-02-10 |
| 🤷 | [Carl Friedrich Bolz-Tereick](https://github.com/cfbolz) | 2011-03-21 | |
| ✅ | [Jason R. Coombs](https://github.com/jaraco) | 2011-03-14 | |
| ? | Ross Lagerwall | 2011-03-13 | 2017-02-10 |
| ❌ | [Eli Bendersky](https://github.com/eliben) | 2011-01-11 | 2020-11-26 |
| 🤷 | [Ned Deily](https://github.com/ned-deily) | 2011-01-09 | |
| ❌ | [David Malcolm](https://github.com/davidmalcolm) | 2010-10-27 | 2020-11-12 |
| ✅ | [Tal Einat](https://github.com/taleinat) | 2010-10-04 | |
| ✅ | [Łukasz Langa](https://github.com/ambv) | 2010-09-08 | |
| ? | Daniel Stutzbach | 2010-08-22 | 2017-02-10 |
| 🤷 | [Éric Araujo](https://github.com/merwok) | 2010-08-10 | |
| ✅ | [Brian Quinlan](https://github.com/brianquinlan) | 2010-07-26 | |
| ❌ | [Alexander Belopolsky](https://github.com/abalkin) | 2010-05-25 | |
| ❌ | [Tim Golden](https://github.com/tjguk) | 2010-04-21 | |
| ❌ | [Giampaolo Rodolà](https://github.com/giampaolo) | 2010-04-17 | |
| ? | Jean-Paul Calderone | 2010-04-06 | 2017-02-10 |
| ❌ | [Brian Curtin](https://github.com/briancurtin) | 2010-03-24 | |
| ? | Florent Xicluna | 2010-02-25 | 2017-02-10 |
| 🤷 | [Dino Viehland](https://github.com/DinoV) | 2010-02-23 | |
| ❌ | [Larry Hastings](https://github.com/larryhastings) | 2010-02-22 | |
| ❌ | [Victor Stinner](https://github.com/vstinner) | 2010-01-30 | |
| 🤷 | [Stefan Krah](https://github.com/skrah) | 2010-01-05 | 2020-10-07 |
| ❌ | [Doug Hellmann](https://github.com/dhellmann) | 2009-09-20 | 2020-11-11 |
| ? | Frank Wierzbicki | 2009-08-02 | 2017-02-10 |
| ❌ | [Ezio Melotti](https://github.com/ezio-melotti) | 2009-06-07 | |
| 🤷 | [Philip Jenvey](https://github.com/pjenvey) | 2009-05-07 | 2020-11-26 |
| ✅ | [Michael Foord](https://github.com/voidspace) | 2009-04-01 | |
| ❌ | [R. David Murray](https://github.com/bitdancer) | 2009-03-30 | |
| ✅ | [Chris Withers](https://github.com/cjw296) | 2009-03-08 | |
| ❌ | [Tarek Ziadé](https://github.com/tarekziade) | 2008-12-21 | 2017-02-10 |
| ? | Hirokazu Yamamoto | 2008-08-12 | 2017-02-10 |
| ❌ | [Armin Ronacher](https://github.com/mitsuhiko) | 2008-07-23 | 2020-11-26 |
| ❌ | [Antoine Pitrou](https://github.com/pitrou) | 2008-07-16 | |
| ❌ | [Senthil Kumaran](https://github.com/orsenthil) | 2008-06-16 | |
| ? | Jesse Noller | 2008-06-16 | 2017-02-10 |
| 🤷 | [Jesús Cea](https://github.com/jcea) | 2008-05-13 | |
| ? | Guilherme Polo | 2008-04-24 | 2017-02-10 |
| ? | Jeroen Ruigrok van der Werven | 2008-04-12 | 2017-02-10 |
| ❌ | [Benjamin Peterson](https://github.com/benjaminp) | 2008-03-25 | |
| ❌ | [David Wolever](https://github.com/wolever) | 2008-03-17 | 2020-11-21 |
| ❌ | [Trent Nelson](https://github.com/tpn) | 2008-03-17 | 2020-11-26 |
| ❌ | [Mark Dickinson](https://github.com/mdickinson) | 2008-01-06 | |
| 🤷 | [Amaury Forgeot d'Arc](https://github.com/amauryfa) | 2007-11-09 | 2020-11-26 |
| ❌ | [Christian Heimes](https://github.com/tiran) | 2007-10-31 | |
| ? | Bill Janssen | 2007-08-28 | 2017-02-10 |
| ? | Jeffrey Yasskin | 2007-08-09 | 2017-02-10 |
| ? | Mark Summerfield | 2007-08-01 | 2017-02-10 |
| 🤷 | [Alexandre Vassalotti](https://github.com/avassalotti) | 2007-05-21 | 2020-11-12 |
| ? | Travis E. Oliphant | 2007-04-17 | 2017-02-10 |
| ❌ | [Eric V. Smith](https://github.com/ericvsmith) | 2007-02-28 | |
| ❌ | [Josiah Carlson](https://github.com/josiahcarlson) | 2007-01-06 | 2017-02-10 |
| ? | Collin Winter | 2007-01-05 | 2017-02-10 |
| ? | Richard Jones | 2006-05-23 | 2017-02-10 |
| ? | Kristján Valur Jónsson | 2006-05-17 | 2017-02-10 |
| 🤷 | [Jack Diederich](https://github.com/jackdied) | 2006-05-17 | 2020-11-26 |
| ? | Steven Bethard | 2006-04-27 | 2017-02-10 |
| ? | Gerhard Häring | 2006-04-23 | 2017-02-10 |
| ? | George Yoshida | 2006-04-17 | 2017-02-10 |
| ❌ | [Ronald Oussoren](https://github.com/ronaldoussoren) | 2006-03-03 | |
| ❌ | [Alyssa Coghlan](https://github.com/ncoghlan) | 2005-10-16 | |
| ❌ | [Georg Brandl](https://github.com/birkenfeld) | 2005-05-28 | |
| 🤷 | [Terry Jan Reedy](https://github.com/terryjreedy) | 2005-04-07 | |
| 🤷 | [Bob Ippolito](https://github.com/etrepum) | 2005-03-02 | 2017-02-10 |
| ? | Peter Astrand | 2004-10-21 | 2017-02-10 |
| ❌ | [Facundo Batista](https://github.com/facundobatista) | 2004-10-16 | |
| ? | Sean Reifschneider | 2004-09-17 | 2017-02-10 |
| ? | Johannes Gijsbers | 2004-08-14 | 2005-07-27 |
| 🤷 | [Matthias Klose](https://github.com/doko42) | 2004-08-04 | |
| 🤷 | [PJ Eby](https://github.com/pjeby) | 2004-03-24 | 2020-11-26 |
| ❌ | [Vinay Sajip](https://github.com/vsajip) | 2004-02-20 | |
| ❌ | [Hye-Shik Chang](https://github.com/hyeshik) | 2003-12-10 | |
| ? | Armin Rigo | 2003-10-24 | 2012-06-01 |
| ? | Andrew McNamara | 2003-06-09 | 2017-02-10 |
| ? | Samuele Pedroni | 2003-05-16 | 2017-02-10 |
| 🤷 | [Alex Martelli](https://github.com/aleaxit) | 2003-04-22 | |
| ✅ | [Brett Cannon](https://github.com/brettcannon) | 2003-04-18 | |
| ? | David Goodger | 2003-01-02 | 2017-02-10 |
| ? | Gustavo Niemeyer | 2002-11-05 | 2017-02-10 |
| ? | Tony Lownds | 2002-09-22 | 2017-02-10 |
| ✅ | [Steve Holden](https://github.com/holdenweb) | 2002-06-14 | 2017-02-10 |
| ❌ | [Christian Tismer](https://github.com/ctismer) | 2002-05-17 | |
| ? | Jason Tishler | 2002-05-15 | 2017-02-10 |
| ❌ | [Walter Dörwald](https://github.com/doerwalter) | 2002-03-21 | |
| ? | Andrew MacIntyre | 2002-02-17 | 2016-01-02 |
| ✅ | [Gregory P. Smith](https://github.com/gpshead) | 2002-01-08 | |
| ? | Anthony Baxter | 2001-12-21 | 2017-02-10 |
| ? | Neal Norwitz | 2001-12-19 | 2017-02-10 |
| ✅ | [Raymond Hettinger](https://github.com/rhettinger) | 2001-12-10 | |
| ? | Chui Tey | 2001-10-31 | 2017-02-10 |
| ? | Michael W. Hudson | 2001-08-27 | 2017-02-10 |
| ? | Finn Bock | 2001-08-23 | 2005-04-13 |
| ? | Piers Lauder | 2001-07-20 | 2017-02-10 |
| 🤷 | [Kurt B. Kaiser](https://github.com/kbkaiser) | 2001-07-03 | |
| ? | Steven M. Gava | 2001-06-25 | 2017-02-10 |
| ? | Steve Purcell | 2001-03-22 | 2017-02-10 |
| ? | Jim Fulton | 2000-10-06 | 2017-02-10 |
| ? | Ka-Ping Yee | 2000-10-03 | 2017-02-10 |
| ❌ | [Lars Gustäbel](https://github.com/gustaebel) | 2000-09-21 | 2020-11-26 |
| ❌ | [Neil Schemenauer](https://github.com/nascheme) | 2000-09-15 | |
| ? | Martin v. Löwis | 2000-09-08 | 2017-02-10 |
| 🤷 | [Thomas Heller](https://github.com/theller) | 2000-09-07 | 2020-11-18 |
| ? | Moshe Zadka | 2000-07-29 | 2005-04-08 |
| 🤷 | [Thomas Wouters](https://github.com/Yhg1s) | 2000-07-14 | |
| ? | Peter Schneider-Kamp | 2000-07-10 | 2017-02-10 |
| ? | Paul Prescod | 2000-07-01 | 2005-04-30 |
| ❌ | [Tim Peters](https://github.com/tim-one) | 2000-06-30 | |
| ❌ | [Skip Montanaro](https://github.com/smontanaro) | 2000-06-30 | 2015-04-21 |
| ? | Fredrik Lundh | 2000-06-29 | 2017-02-10 |
| 🤷 | [Mark Hammond](https://github.com/mhammond) | 2000-06-09 | |
| ❌ | [Marc-André Lemburg](https://github.com/malemburg) | 2000-06-07 | |
| ? | Trent Mick | 2000-06-06 | 2017-02-10 |
| ? | Eric S. Raymond | 2000-06-02 | 2017-02-10 |
| ? | Greg Stein | 1999-11-07 | 2017-02-10 |
| ? | Just van Rossum | 1999-01-22 | 2017-02-10 |
| ? | Greg Ward | 1998-12-18 | 2017-02-10 |
| ❌ | [Andrew Kuchling](https://github.com/akuchling) | 1998-04-09 | |
| 🤷 | Ken Manheimer | 1998-03-03 | 2005-04-08 |
| 🤷 | [Jeremy Hylton](https://github.com/jeremyhylton) | 1997-08-13 | 2020-11-26 |
| 🤷 | Roger E. Masse | 1996-12-09 | 2017-02-10 |
| ❌ | [Fred Drake](https://github.com/freddrake) | 1996-07-23 | |
| ❌ | [Barry Warsaw](https://gitlab.com/warsaw) | 1994-07-25 | |
| ❌ | [Jack Jansen](https://github.com/jackjansen) | 1992-08-13 | |
| 🤷 | [Sjoerd Mullender](https://github.com/sjoerdmullender) | 1992-08-04 | 2020-11-14 |
| ✅ | [Guido van Rossum](https://github.com/gvanrossum) | 1989-12-25 | |

## Summary

Numbers:

* Total: 190
* Currently active: 109
* ✅: 37
* ❌: 62
* 🤷: 37
* ?: 54

All results from old to new:

✅ 🤷 ❌ ❌ ❌ 🤷 🤷 🤷 ❌ ? ? ? ? ? ❌ 🤷 ? ❌ ❌ ? ? 🤷 ? 🤷 ? ❌ ❌ ? ? ? ? 🤷 ? ? ? ? ✅ ? ? ✅ ? ❌ ? ❌ ✅ ? ? ? ✅ 🤷 ? ? ? ❌ ❌ 🤷 🤷 ? ? ❌ ? 🤷 🤷 ❌ ❌ ❌ ? ? ? 🤷 ? ? ? ❌ ❌ ? 🤷 ? ? ? ❌ 🤷 ❌ ❌ ❌ ❌ ? ? 🤷 ? ❌ ❌ ❌ ? ❌ ✅ ❌ ✅ 🤷 ❌ ? ❌ 🤷 ❌ ❌ 🤷 ? ❌ ? ❌ ❌ ❌ ✅ 🤷 ? ✅ ✅ ❌ 🤷 ❌ ? ✅ 🤷 ? ? ❌ ❌ 🤷 🤷 ❌ ✅ ? ✅ ? ❌ ❌ ✅ ❌ ✅ ❌ ✅ 🤷 ✅ ❌ ❌ 🤷 ✅ ❌ 🤷 🤷 🤷 ❌ ❌ ❌ ✅ ✅ ❌ ✅ 🤷 ❌ ❌ ❌ 🤷 ❌ ❌ ✅ ❌ 🤷 ❌ ✅ 🤷 ✅ ✅ ✅ 🤷 ✅ 🤷 ❌ ✅ 🤷 ✅ ✅ ✅ ✅ ✅ ✅ ✅ ✅ ❌ ✅

Results from old to new with removed unknowns:

✅ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ✅ ✅ ❌ ❌ ✅ ✅ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ✅ ❌ ✅ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ✅ ✅ ✅ ❌ ❌ ✅ ❌ ❌ ❌ ✅ ✅ ❌ ❌ ✅ ❌ ✅ ❌ ✅ ✅ ❌ ❌ ✅ ❌ ❌ ❌ ❌ ✅ ✅ ❌ ✅ ❌ ❌ ❌ ❌ ❌ ✅ ❌ ❌ ✅ ✅ ✅ ✅ ✅ ❌ ✅ ✅ ✅ ✅ ✅ ✅ ✅ ✅ ✅ ❌ ✅

Results from old to new for currently active members:

✅ ❌ ❌ ❌ ❌ ❌ 🤷 ❌ 🤷 ❌ 🤷 ✅ ✅ ❌ ❌ ✅ 🤷 ❌ ❌ 🤷 ❌ 🤷 ❌ ❌ ❌ ❌ ❌ ❌ ❌ 🤷 ❌ ❌ ✅ ❌ ✅ ❌ ❌ ❌ 🤷 ❌ ❌ ❌ ❌ ✅ 🤷 ✅ ✅ 🤷 ✅ 🤷 ❌ ❌ 🤷 ✅ ✅ ❌ ❌ ✅ ❌ ✅ ❌ ✅ 🤷 ✅ ❌ ❌ 🤷 ✅ 🤷 🤷 ❌ ❌ ❌ ✅ ✅ ❌ ✅ 🤷 ❌ ❌ ❌ 🤷 ❌ ❌ ✅ ❌ 🤷 ❌ ✅ 🤷 ✅ ✅ ✅ 🤷 ✅ 🤷 ❌ ✅ 🤷 ✅ ✅ ✅ ✅ ✅ ✅ ✅ ✅ ❌ ✅

* The total number of Python core devs using type annotations depends on how you count:
  * 19% (37/190) if you count unknowns.
  * 37% (37/99) if you consider only people with recent open-source activity.
  * 33% (36/109) or 41% (36/86) if you count only current team members (including and excluding unknowns).
  * 71% (15/21) if you count only people who joined the team since 2020.
* Around 48% of all Python core developers don't have their own open-source projects and haven't made any open-source contributions in recent years. Probably, many of them are simply retired; the language is over 30 years old.
