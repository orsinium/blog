---
title: "Diving into PyPI package name squatting"
date: 2023-10-13
tags:
  - python
---

All sufficiently big public package registries are a mess full of malware, name squatting and drama:

* [crates.io](https://crates.io/) has [a single user](https://crates.io/users/swmon) owning names like "any", "bash", and "class".
* [npmjs.com](https://www.npmjs.com/) had a [drama with left-pad](https://en.wikipedia.org/wiki/Npm#Dependency_chain_issues) when a single maintainer of a single one-liner package broke the internet.
* [pypi.org](https://pypi.org/) appears in tech news monthly with another group of researches discovering another malware campaign.

Today PyPI malware [made news yet again](https://arstechnica.com/security/2023/11/developers-targeted-with-malware-that-monitors-their-every-move/), so I decided to take look at the other side of PyPI: name squatting and some other interesting stats along the way.

## Get the data

We could manually try random package names and check their owner but there is a better way. [Seth Michael Larson](https://sethmlarson.dev/), the [Security Developer-in-Residence at the Python Software Foundation](https://pyfound.blogspot.com/2023/06/announcing-our-new-security-developer.html) has a public repository [pypi-data](https://github.com/sethmlarson/pypi-data) with a partiual dump of the PyPI database.

1. [Download the latest dump](https://github.com/sethmlarson/pypi-data/releases). If you want to reproduce my results, pick the same as I'm going to use: [2023-10-31](https://github.com/sethmlarson/pypi-data/releases/tag/2023.10.31) (spooky! 🎃).
1. Extract: `gunzip pypi.db.gz`.
1. Either open the dump in the sqlite CLI (`sqlite3 pypi.db`) or use the [DB Browser for SQLite](https://sqlitebrowser.org/) GUI which is very cool (but may crash if you're not careful with queries you run).

## Probing the data

The table `packages` contains all packages with their name, the latest released version number, last updated date, and some other info. For example, let's select stats for [textdistance](https://github.com/life4/textdistance):

```sql
SELECT * FROM packages WHERE name = 'textdistance';
```

| field                  | value               |
| ---------------------- | ------------------- |
| name                   | textdistance        |
| version                | 4.6.0               |
| requires_python        | >=3.5               |
| yanked                 | 0                   |
| has_binary_wheel       | 0                   |
| has_vulnerabilities    | 0                   |
| first_uploaded_at      | 2023-09-28T08:30:50 |
| last_uploaded_at       | 2023-09-28T08:30:51 |
| recorded_at            | 2023-10-30 21:49:00 |
| downloads              | 308733              |
| scorecard_overall      | 4.8                 |
| in_google_assured_oss  | 0                   |

Unfortunately, we don't have any information about past releases, like how many releases the package had, how many files, when the first one was uploaded, etc. Also, maintainers are in a separate table because a single package may have multiple maintainers and maintainers may have multiple packages ([many-to-many](https://en.wikipedia.org/wiki/Many-to-many_(data_model))):

```sql
SELECT * FROM maintainers WHERE package_name = 'textdistance';
```

| field        | value        |
| ------------ | ------------ |
| name         | orsinium     |
| package_name | textdistance |

## Finding the most prolific users

Who published the most packages?

```sql
SELECT      maintainers.name, COUNT(*) as cnt
FROM        packages, maintainers
WHERE       packages.name = maintainers.package_name
GROUP BY    maintainers.name
ORDER BY    cnt DESC
LIMIT       20;
```

| name                                                 | cnt   |
| ---------------------------------------------------- | ----- |
| [OCA](pypi.org/user/OCA)                             | 14928 |
| [alexjxd](pypi.org/user/alexjxd)                     | 1577  |
| [wix-ci](pypi.org/user/wix-ci)                       | 1539  |
| [yandex-bot](pypi.org/user/yandex-bot)               | 1196  |
| [openstackci](pypi.org/user/openstackci)             | 735   |
| [vemel](pypi.org/user/vemel)                         | 734   |
| [microsoft](pypi.org/user/microsoft)                 | 671   |
| [davisagli](pypi.org/user/davisagli)                 | 520   |
| [hansalemao](pypi.org/user/hansalemao)               | 501   |
| [hannosch](pypi.org/user/hannosch)                   | 500   |
| [icemac](pypi.org/user/icemac)                       | 449   |
| [google_opensource](pypi.org/user/google_opensource) | 415   |
| [faassen](pypi.org/user/faassen)                     | 401   |
| [agroszer](pypi.org/user/agroszer)                   | 361   |
| [dlech](pypi.org/user/dlech)                         | 360   |
| [thejcannon](pypi.org/user/thejcannon)               | 360   |
| [adafruit-travis](pypi.org/user/adafruit-travis)     | 352   |
| [pycopy-lib](pypi.org/user/pycopy-lib)               | 347   |
| [azure-sdk](pypi.org/user/azure-sdk)                 | 343   |
| [aws-cdk](pypi.org/user/aws-cdk)                     | 337   |

You may recognize some names on the list.

* The apparent leader is [OCA](pypi.org/user/OCA), also known as [Odoo Community Association](https://odoo-community.org/). [Odoo](https://en.wikipedia.org/wiki/Odoo) is a popular [open-source](https://github.com/odoo/odoo) enterprise CRM with Python backend. Their PyPI account holds a bunch of Odoo plugins.
* Next goes [alexjxd](https://pypi.org/user/alexjxd/), also known as [Alex Jiang](https://github.com/AlexJXD). THis is an Alibaba employee, and their account holds [alibabacloud-python-sdk](https://github.com/aliyun/alibabacloud-python-sdk) componenets. It is poorly documented but what I noticed is that all components have a date suffix, like `ddosbgp-20180201`. So, it's some kind of additional versioning going on.
* The third place goes to [wix-ci](https://pypi.org/user/wix-ci/), holding a bunch of plugins for [wix.com](https://www.wix.com/).
* The [yandex-bot](https://pypi.org/user/yandex-bot/), claimed to be owned by "[Yandex](https://en.wikipedia.org/wiki/Yandex) Security Team", owns 1200 names, including names like [and](https://pypi.org/project/and/), [nu](https://pypi.org/project/nu/), [aiostat](https://pypi.org/project/aiostat/), [apilib](https://pypi.org/project/apilib/), [cpp_grader](https://pypi.org/project/cpp_grader/), [tmp2](https://pypi.org/project/tmp2/), [minify](https://pypi.org/project/minify/), and many other generic names. Each description says: "A package to prevent Dependency Confusion attacks against Yandex". So, we see name squatting to prevent name squatting. "The best defense is a good offense". Should this be allowed? And the whole situation suddenly takes political turn when you consider that Yandex LLC is a Russian company.

You can check the rest of the list yourself if you're curious. For now, let's find something more interesting.

## Finding the top name squatters

[Name squatting](https://en.wikipedia.org/wiki/Cybersquatting) is when someone registers a bunch of common names to sell them later. It is very common with DNS, social media, and package registries. This is why Steam is [steampowered.com](https://store.steampowered.com/).

The best heuristic would be to find users with the most single-release packages, but we don't have this information in the dataset. Instead, we can have a look at users with all packages having the same version number. The assumption is that when all names registered using one tool or one placeholder project metadata, they all will have the same version.

```sql
SELECT
    maintainers.name,
    packages.name,
    version,
    COUNT(*) as cnt_prj,
    COUNT(DISTINCT version) as cnt_ver
FROM      packages, maintainers
WHERE     packages.name = maintainers.package_name
GROUP BY  maintainers.name
HAVING    cnt_ver = 1
ORDER BY  cnt_prj DESC
LIMIT     20;
```

| maintainer | package | version | projects |
| ---------- | ------- | ------- | -------- |
| [wix-ci](https://pypi.org/user/wix-ci) | [artifactory-check](https://pypi.org/project/artifactory-check) | 0.0.1 | 1539 |
| [alexanderkjall](https://pypi.org/user/alexanderkjall) | [abyss-airflow-reprocessor](https://pypi.org/project/abyss-airflow-reprocessor) | 0.0.1 | 243 |
| [doxops](https://pypi.org/user/doxops) | [data-dags](https://pypi.org/project/data-dags) | 0.0.1 | 53 |
| [akarmakar](https://pypi.org/user/akarmakar) | [nvidia-cudf-cu11](https://pypi.org/project/nvidia-cudf-cu11) | 0.0.1.dev5 | 48 |
| [shadowwalker2718](https://pypi.org/user/shadowwalker2718) | [audiolm](https://pypi.org/project/audiolm) | 0.0.1.dev0 | 41 |
| [tanium-security](https://pypi.org/user/tanium-security) | [macmiller-common](https://pypi.org/project/macmiller-common) | 0.0.dev1 | 29 |
| [wxpay_sec_team](https://pypi.org/user/wxpay_sec_team) | [autogencase](https://pypi.org/project/autogencase) | 0.0.1 | 29 |
| [squadrone](https://pypi.org/user/squadrone) | [algorand-wallet-client](https://pypi.org/project/algorand-wallet-client) | 0.0.0 | 28 |
| [GHGSat](https://pypi.org/user/GHGSat) | [gfa-ghg-hres](https://pypi.org/project/gfa-ghg-hres) | 0.1.1 | 24 |
| [aws-solutions-konstruk-support](https://pypi.org/user/aws-solutions-konstruk-support) | [aws-solutions-konstruk-aws-apigateway-dynamodb](https://pypi.org/project/aws-solutions-konstruk-aws-apigateway-dynamodb) | 0.8.1 | 24 |
| [coalgo](https://pypi.org/user/coalgo) | [coalg](https://pypi.org/project/coalg) | 0.0.0 | 24 |
| [elula-ai](https://pypi.org/user/elula-ai) | [elulalib](https://pypi.org/project/elulalib) | 0.0.0 | 23 |
| [felya152](https://pypi.org/user/felya152) | [felya-1-1](https://pypi.org/project/felya-1-1) | 0.1.0 | 23 |
| [girder-robot](https://pypi.org/user/girder-robot) | [girder](https://pypi.org/project/girder) | 3.1.24 | 22 |
| [deeznuts1337](https://pypi.org/user/deeznuts1337) | [cloudsec](https://pypi.org/project/cloudsec) | 0.0.0 | 19 |
| [mapsme](https://pypi.org/user/mapsme) | [omim-airmaps](https://pypi.org/project/omim-airmaps) | 10.3.0rc2 | 19 |
| [souljaboy](https://pypi.org/user/souljaboy) | [eai](https://pypi.org/project/eai) | 0.1 | 19 |
| [hashemshaiban](https://pypi.org/user/hashemshaiban) | [aladrisy](https://pypi.org/project/aladrisy) | 0.0.1 | 18 |
| [stastnypremysl](https://pypi.org/user/stastnypremysl) | [pycom-artifactory-automation](https://pypi.org/project/pycom-artifactory-automation) | 0.0.1 | 18 |
| [edtb](https://pypi.org/user/edtb) | [testwizard-android-set-top-box](https://pypi.org/project/testwizard-android-set-top-box) | 3.7.0 | 17 |

* The thing I haven't noticed about [wix-ci](https://pypi.org/user/wix-ci/) before is that all the packages are released in one go, between 2021-02-11 and 2021-02-14, and haven't been touched since. And when I check the content of the packages, they are all empty, without any code inside. Busted!
* [alexanderkjall](https://pypi.org/user/alexanderkjall/), also known as [Alexander Kjäll](https://github.com/alexanderkjall), holds 244 packages with the description "PyPi package created by [Schibsted](https://schibsted.com/)'s Product & Application Security team". Yet another example of "to prevent squatting, let's squad first". The names include [schlearn](https://pypi.org/project/schlearn) (which sounds like [sklearn](https://pypi.org/project/sklearn)), [s3-helpers](https://pypi.org/project/s3-helpers), [christian](https://pypi.org/project/christian), [ip-library](https://pypi.org/project/ip-library), [datadog-linter](https://pypi.org/project/datadog-linter), etc.
* [doxops](https://pypi.org/user/doxops) is yeat another company squatting their private names.
* [akarmakar](https://pypi.org/user/akarmakar/) squats package names for nvidia, like [nvidia-raft-dask-cu116](https://pypi.org/project/nvidia-raft-dask-cu116/). If you try to install any of these, you'll get an installation failure telling you to use [NVIDIA Python Package Index](https://pypi.org/project/nvidia-pyindex/). This is similar to other case of "safety squatting" but at least this time it serves a purpose for a public project users, not just a single company employees.
* [shadowwalker2718](https://pypi.org/user/shadowwalker2718/) is the first instance of name squatting on the list done not by a big company. All the names they hold are the names of the real ML projects which you find on GitHub but which don't provide a PyPI distribution. They squatted [chatdoctor](https://pypi.org/project/chatdoctor/) for [ChatDoctor](https://github.com/Kent0n-Li/ChatDoctor), [controlnet](https://pypi.org/project/controlnet/) for [ControlNet](https://github.com/lllyasviel/ControlNet), [autogpt](https://pypi.org/project/autogpt/) for [AutoGPT](https://github.com/Significant-Gravitas/AutoGPT), etc. Most of the registered projects have the description copied from the real project and even some dependencies but no code inside.

I checked more users from the list. Lots and lots of squatters. Some are companies squatting their internal names, some are individuals holding nice names for sale.

## Finding more squatters

We can tweak the query above to show us people with versions between 2 and 5. Some of the squatters might sligtly change the version number or re-release a package with new fake content.

```sql
SELECT
    maintainers.name,
    packages.name,
    version,
    COUNT(*) as cnt_prj,
    COUNT(DISTINCT version) as cnt_ver
FROM     packages, maintainers
WHERE    packages.name = maintainers.package_name
GROUP BY maintainers.name
HAVING   cnt_ver BETWEEN 2 AND 5
ORDER BY cnt_prj DESC
LIMIT    20;
```

|             maintainer    |      package                   |   version   | cnt_prj | cnt_ver |
|-------------------------------|------------------------------------------|-------------|---------|---------|
| [thejcannon](https://pypi.org/user/thejcannon)                    | botocore-a-la-carte                      | 1.31.73     | 360     | 3       |
| [stale.pettersen.schibsted](https://pypi.org/user/stale.pettersen.schibsted)     | apikeycheck                              | 0.0.1       | 224     | 2       |
| [anon_ssregistrar](https://pypi.org/user/anon_ssregistrar)              | addr-match                               | 0.0.0       | 218     | 3       |
| [noteed](https://pypi.org/user/noteed)                        | openerp-account                          | 7.0.406     | 206     | 2       |
| [pokoli](https://pypi.org/user/pokoli)                        | proteus                                  | 7.0.0       | 193     | 5       |
| [DnA_DGAT_Chapter](https://pypi.org/user/DnA_DGAT_Chapter)              | abcdefg                                  | 0.0.0       | 160     | 2       |
| [wangc](https://pypi.org/user/wangc)                         | lab-b                                    | 1.0         | 119     | 3       |
| [tcw](https://pypi.org/user/tcw)                           | an                                       | 0.0.4       | 114     | 5       |
| [sifer](https://pypi.org/user/sifer)                         | aaaaa                                    | 1.0.1       | 98      | 2       |
| [aws-solutions-constructs-team](https://pypi.org/user/aws-solutions-constructs-team) | aws-solutions-constructs-aws-alb-fargate | 2.45.0      | 86      | 3       |
| [takealot](https://pypi.org/user/takealot)                      | ab-test-client                           | 0.0.1rc0    | 82      | 4       |
| [kafkaservices](https://pypi.org/user/kafkaservices)                 | audit-friday                             | 0.1         | 74      | 4       |
| [yinsuo.mys](https://pypi.org/user/yinsuo.mys)                    | haas-python-ads1xx5                      | 0.0.8       | 74      | 3       |
| [Pinkyy](https://pypi.org/user/Pinkyy)                        | aisi-od-training                         | 0.0.1rc1    | 72      | 3       |
| [se2862890720](https://pypi.org/user/se2862890720)                  | ci-connector                             | 0.0.47      | 57      | 2       |
| [mdazam1942](https://pypi.org/user/mdazam1942)                    | car-connector-framework                  | 4.0.1       | 56      | 5       |
| [rieder](https://pypi.org/user/rieder)                        | amuse                                    | 2023.10.0   | 50      | 5       |
| [cloudwright](https://pypi.org/user/cloudwright)                   | cloudwright-airtable                     | 0.0.0.post1 | 49      | 2       |
| [doerlbh](https://pypi.org/user/doerlbh)                       | aikido                                   | 0.0.0       | 49      | 5       |
| [elad_pt](https://pypi.org/user/elad_pt)                       | adios2                                   | 0.0.1       | 48      | 5       |

Another interesting query is to filter out maintainers having all packages with one of the predefined version numbers:

```sql
SELECT
    maintainers.name,
    packages.name,
    version,
    COUNT(*) as cnt
FROM     packages, maintainers
WHERE    packages.name = maintainers.package_name AND version IN ('0.0.0', '0.0.1', '0.1.0', '1.0.0')
GROUP BY maintainers.name
ORDER BY cnt DESC
LIMIT    20;
```

|           maintainer            |           package            | version | cnt  |
|---------------------------|---------------------------|---------|------|
| [wix-ci](https://pypi.org/user/wix-ci)                    | artifactory-check         | 0.0.1   | 1539 |
| [alexjxd](https://pypi.org/user/alexjxd)                   | alibabacloud-acm20200206  | 1.0.0   | 415  |
| [platform-kiwi](https://pypi.org/user/platform-kiwi)             | alertlib                  | 0.0.0   | 269  |
| [alexanderkjall](https://pypi.org/user/alexanderkjall)            | abyss-airflow-reprocessor | 0.0.1   | 243  |
| [stale.pettersen.schibsted](https://pypi.org/user/stale.pettersen.schibsted) | apikeycheck               | 0.0.1   | 223  |
| [anon_ssregistrar](https://pypi.org/user/anon_ssregistrar)          | addr-match                | 0.0.0   | 218  |
| [airbyte-engineering](https://pypi.org/user/airbyte-engineering)       | airbyte-source-gong       | 0.1.0   | 186  |
| [DnA_DGAT_Chapter](https://pypi.org/user/DnA_DGAT_Chapter)          | abcdefg                   | 0.0.0   | 160  |
| [pycopy-lib](https://pypi.org/user/pycopy-lib)                | pycopy-aifc               | 0.0.0   | 151  |
| [micropython-lib](https://pypi.org/user/micropython-lib)           | micropython-aifc          | 0.0.0   | 138  |
| [workiva](https://pypi.org/user/workiva)                   | admin-frugal              | 0.0.0   | 123  |
| [openstackci](https://pypi.org/user/openstackci)               | act                       | 0.0.1   | 112  |
| [microsoft](https://pypi.org/user/microsoft)                 | archai                    | 1.0.0   | 107  |
| [sifer](https://pypi.org/user/sifer)                     | bbbb                      | 1.0.0   | 96   |
| [datakund_test](https://pypi.org/user/datakund_test)             | allmovie-scraper          | 1.0.0   | 91   |
| [azure-sdk](https://pypi.org/user/azure-sdk)                 | azure-agrifood-nspkg      | 1.0.0   | 75   |
| [heyWFeng](https://pypi.org/user/heyWFeng)                  | decrypt4pdf               | 0.0.1   | 63   |
| [mvinyard2](https://pypi.org/user/mvinyard2)                 | adata-query               | 0.0.1   | 60   |
| [doxops](https://pypi.org/user/doxops)                    | data-dags                 | 0.0.1   | 53   |
| [abhishek4273](https://pypi.org/user/abhishek4273)              | monk-colab                | 0.0.1   | 50   |

This method gives quite a few false-positives (legit people who release lots of one-off packages) but still, finds some interesting cases.

## Putting it all together

So, how many squatters we've found? Combining all the methods above and manually removing false-positives:

Companies:

1. [airbyte-engineering](https://pypi.org/user/airbyte-engineering) (Airbyte)
1. [akarmakar](https://pypi.org/user/akarmakar) (Nvidia)
1. [alexanderkjall](https://pypi.org/user/alexanderkjall) (Schibsted)
1. [alexjxd](https://pypi.org/user/alexjxd) (Alibaba)
1. [doxops](https://pypi.org/user/doxops) (Dox)
1. [elad_pt](https://pypi.org/user/elad_pt) (Cycode)
1. [Pinkyy](https://pypi.org/user/Pinkyy) (SBB)
1. [platform-kiwi](https://pypi.org/user/platform-kiwi) (Kiwi)
1. [wix-ci](https://pypi.org/user/wix-ci) (Wix)
1. [workiva](https://pypi.org/user/workiva) (Workiva)
1. [yandex-bot](pypi.org/user/yandex-bot) (Yandex)

Individual squatters:

1. [anon_ssregistrar](https://pypi.org/user/anon_ssregistrar)
1. [datakund_test](https://pypi.org/user/datakund_test)
1. [DnA_DGAT_Chapter](https://pypi.org/user/DnA_DGAT_Chapter)
1. [doerlbh](https://pypi.org/user/doerlbh)
1. [eywalker](https://pypi.org/user/eywalker)
1. [kafkaservices](https://pypi.org/user/kafkaservices)
1. [kislyuk](https://pypi.org/user/kislyuk)
1. [mvinyard2](https://pypi.org/user/mvinyard2)
1. [rebelliondefense](https://pypi.org/user/rebelliondefense)
1. [se2862890720](https://pypi.org/user/se2862890720)
1. [shadowwalker2718](https://pypi.org/user/shadowwalker2718)
1. [sifer](https://pypi.org/user/sifer)
1. [takealot](https://pypi.org/user/takealot)
1. [tcw](https://pypi.org/user/tcw)
1. [wangc](https://pypi.org/user/wangc)

With a better dataset, we could have better heuristics. Maybe, one day, I'll go and find packages with only one small release with almost no code inside. Or a bunch of packages reserved in one go.

## Questions to think about

1. Should name squatting be allowed?  Should the PyPI team care?
1. Should we do something?
1. Should we allow private companies to reserve names from their internal registry "for security reasons"?
1. Should all package names be namespaced to the author, like on GitHub or Docker Hub?
1. Should we limit the number of packages per user? Should we tell Microsoft to go and maintain their own PyPI instance?
