maintainer       "Pascal Ehlert"
maintainer_email "pascal@hacksrus.net"
license          "All rights reserved"
description      "Installs and configures a full mail server stack with postfix, dovecot, clamav, spamassassin, amavis and postfixadmin"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
depends          "database"
depends          "lighttpd"
version          "0.1.0"
