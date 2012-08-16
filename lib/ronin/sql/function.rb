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

require 'ronin/sql/formattable'

module Ronin
  module SQL
    class Function

      include Formattable

      # The name of the function
      attr_reader :name

      # The arguments of the function
      attr_reader :arguments

      #
      # Creates a new Function object.
      #
      # @param [Symbol] name
      #   The name of the function.
      #
      # @param [Array] arguments
      #   The arguments of the function.
      #
      def initialize(name,arguments=[])
        @name      = name
        @arguments = arguments
      end

      #
      # Formats the function.
      #
      # @param [Formatter] formatter
      #   The formatter to use.
      #
      # @return [String]
      #   The formatted SQL function.
      #
      def format(formatter)
        formatter.function(@name,*@arguments)
      end

    end
  end
end
