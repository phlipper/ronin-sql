#
# Ronin SQL - A Ronin library providing support for SQL related security
# tasks.
#
# Copyright (c) 2007-2010 Hal Brodigan (postmodern.mod3 at gmail.com)
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

require 'ronin/code/sql/encoder'
require 'ronin/formatting/text'
require 'ronin/formatting/sql'

module Ronin
  module Code
    module SQL
      class Fragment

        include Encoder

        # Elements of the fragment
        attr_accessor :elements

        #
        # Creates a new Fragment object.
        #
        # @param [Array] elements
        #   Initial elements of the fragment.
        #
        # @param [Hash] options
        #   Additional options.
        #
        # @option options [Symbol] :case (Style::DEFAULT_CASE)
        #   Controls the case of keywords. May be either `:lower`,
        #   `:upper` or `:random`
        #
        # @option options [Symbol] :quotes (Style::DEFAULT_QUOTES)
        #   Controls the quoting style of strings. May be either `:single`
        #   or `:double`.
        #
        # @option options [Boolean] :hex_escape (false)
        #   Forces all Strings to be hex-escaped.
        #
        # @option options [Symbol] :parens (Style::DEFAULT_PARENS)
        #   Reduces the amount of parenthesis when tokenizing lists.
        #   May be either `:less`, `:more`.
        #
        # @option options [Boolean] :spaces (true)
        #   Controls whether spaces are used to separate keywords,
        #   or other kinds of white-space.
        #
        # @since 0.3.0
        #
        def initialize(elements=[],options={})
          super(options)

          @elements = elements
        end

        #
        # Appends a single element.
        #
        # @param [Object] element
        #   The element to append.
        #
        # @return [Fragment]
        #   The fragment with the appended element.
        #
        # @since 0.3.0
        #
        def <<(element)
          @elements << element
          return self
        end

        #
        # Encoder method which first creates SQL code, then escapes it
        # for use in SQL Injections.
        #
        # @param [Hash] options
        #   Additional options.
        #
        # @option options [Symbol] :escape
        #   The type of escape strategy to use. May be either `:integer`,
        #   `:string` or `:statement`.
        #
        # @option options [String, Integer] :value
        #   The value to pre-append to the SQL Injection.
        #
        # @option options [Boolean] :terminate
        #   Specifies whether or not to terminate the SQL Injection with
        #   a SQL single-line comment (`--`).
        #
        # @return [String]
        #   The encoded SQL Injection.
        #
        # @since 0.3.0
        #
        def to_sqli(options={})
          case options[:escape]
          when :integer
            inj = join_elements(encode_integer(options[:value]), *tokens)
          when :string
            inj = join_elements(encode_string(options[:value]), *tokens)

            unless options[:terminate]
              if inj[-1..-1] == inj[0..0]
                # remove the last quote
                inj = inj[0..-2]
              else
                # no last quote present, so comment out the rest
                inj << '--'
              end
            end

            # remove the first quote
            inj = inj[1..-1]
          when :statement
            # break out of the statement, and comment the rest out
            inj = ";#{self}"
          else
            inj = self.to_sql
          end

          if (options[:terminate] && (inj[-2..-1] != '--'))
            # comment terminate the injection, if we already haven't
            inj << '--'
          end

          return inj
        end

        protected

        #
        # Encodes the elements of the fragment into SQL tokens.
        #
        # @return [Array<String>]
        #   The token representation of the fragment.
        #
        # @since 0.3.0
        #
        def tokens
          encode(*@elements)
        end

      end
    end
  end
end
