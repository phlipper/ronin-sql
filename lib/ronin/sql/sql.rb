#
# Ronin SQL - A Ruby DSL for crafting SQL Injections.
#
# Copyright (c) 2007-2012 Hal Brodigan (postmodern.mod3 at gmail.com)
#
# This file is part of Ronin SQL.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#

require 'ronin/sql/formatter'
require 'ronin/sql/fragment'
require 'ronin/sql/function'

module Ronin
  module SQL

    #
    # Creates a new Fragment object.
    #
    # @param [Array] elements
    #   The elements to populate the fragment with.
    #
    # @return [Fragment]
    #   The new fragment object.
    #
    # @example Create SQL fragments
    #   SQL[:and, 1, :eq, 1].to_s
    #   # => "and 1 = 1"
    #
    # @example Nesting SQL fragments
    #   SQL[:union, [:select, [1,2,3,4,:id], :from, :users]].to_s
    #   # => "union (select (1,2,3,4,id) from users)"
    #
    def self.[](*elements)
      Fragment.new(elements)
    end

    protected

    #
    # Transparently creates new Function objects.
    #
    # @param [Symbol] name
    #   The name of the SQL function that will be called.
    #
    # @param [Array] arguments
    #   Additional arguments for the SQL function.
    #
    # @return [Function]
    #   The new SQL function call.
    #
    # @example Create SQL function calls
    #   SQL.max(:id).to_s
    #   # => "max(id)
    #
    # @example Nesting SQL function calls
    #   SQL.ascii(SQL.substring(:name,1,10)).to_s
    #   # => "ascii(substring(name,1,10))
    #
    def self.method_missing(name,*arguments,&block)
      unless block then Function.new(name,arguments)
      else              super(name,*arguments,&block)
      end
    end

  end
end