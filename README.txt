= Ronin SQL

* http://ronin.rubyforge.org/sql/
* Postmodern Modulus III

== DESCRIPTION:

Ronin SQL is a Ruby library for Ronin that provids support for SQL related
security tasks.

Ronin is a Ruby platform designed for information security and data
exploration tasks. Ronin allows for the rapid development and distribution
of code over many of the common Source-Code-Management (SCM) systems.

=== Free

All source code within Ronin is licensed under the GPL-2, therefore no user
will ever have to pay for Ronin or updates to Ronin. Not only is the
source code free, the Ronin project will not sell enterprise grade security
snake-oil solutions, give private training classes or later turn Ronin into
commercial software.

=== Modular

Ronin was not designed as one monolithic library but instead as a collection
of libraries which can be individually installed. This allows users to pick
and choose what functionality they want in Ronin.

=== Decentralized

Ronin does not have a central repository of exploits and payloads which
all developers contribute to. Instead Ronin has Overlays, repositories of
code that can be hosted on any CVS/SVN/Git/Rsync server. Users can then use
Ronin to quickly install or update Overlays. This allows developers and
users to form their own communities, independent of the main developers
of Ronin.

== FEATURES:

* Provides an Domain Specific Language (DSL) for crafting normal SQL and
  SQL injections.
* Provides tests for finding SQL injections.

== INSTALL:

  $ sudo gem install ronin-sql

== EXAMPLES:

* Generate valid SQL using the Ronin SQL DSL.

  puts Code.sql {
    select(:from => :users, :where => (name == 'bob'))
  }
  SELECT * FROM users WHERE name = 'bob'
  => nil

* Generate valid SQL injections using the Ronin SQL injection DSL.

  puts Code.sql_injection {
    escape_string { has_table?(:users) }
  }
  ' AND (SELECT count(*) FROM users) = 1 --
  => nil

== LICENSE:

Ronin SQL - A Ruby library for Ronin that provids support for SQL related
security tasks.

Copyright (c) 2006-2008 Hal Brodigan (postmodern.mod3 at gmail.com)

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
