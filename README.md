Description
===========
This cookbook intents to install a full-blown mail server stack on a clean node.
The core components are:
  - postfix
  - dovecot
  - amavisd
  - clamav (virus scanner)
  - spamassassin (spam filter)
  - postfixadmin (administrative web interface)

It further installs PostgreSQL to store the account / domain data and lighttpd to serve postfixadmin.

Right now none of these components is optional and the separation is not fully clear.
It is planned for the future though to add some configuration options. 

Requirements
============
This has only been tested on a freshly installed Ubuntu 12.04 LTS node.
It is not very likely to work on non-Ubuntu/Debian distributions.

Cookbook dependencies are:
  - postgresql
  - database
  - lighttpd
 
Attributes
==========
none, yet

Usage
=====
Add the cookbook and it's requirements to your local Chef repository and to the nodes run list.
Then let Chef do all the work for you.

Contributing
============
Any help and contributions in the form of pull requests or bug reports are appreciated! 

