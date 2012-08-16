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

require 'ronin/formatting/text'
require 'ronin/formatting/sql'

module Ronin
  module SQL
    class Formatter

      # aliased keywords
      ALIASES = {
        :all => '*',
        :eq  => '=',
        :neq => '!=',
        :lt  => '<',
        :le  => '<=',
        :gt  => '>',
        :ge  => '>='
      }

      # Default case preference
      DEFAULT_CASE = :none

      # Default quoting preference
      DEFAULT_QUOTES = :single

      # Default parenthesis preference
      DEFAULT_PARENS = :more

      # Controls the casing of keywords
      attr_reader :case

      # Controls the quoting of strings
      attr_reader :quotes

      # The quotation character to use
      attr_reader :quote

      # Controls whether all strings will be hex-escaped
      attr_reader :hex_escape

      # Controls the amount of parenthesis surrounding lists
      attr_reader :parens

      # The String to separate text
      attr_reader :space

      #
      # Sets the style options.
      #
      # @param [Hash] options
      #   Style options.
      #
      # @option options [Symbol] :case (DEFAULT_CASE)
      #   Controls the case of keywords. May be either `:none`, `:lower`,
      #   `:upper` or `:random`
      #
      # @option options [Symbol] :quotes (DEFAULT_QUOTES)
      #   Controls the quoting style of strings. May be either `:single`
      #   or `:double`.
      #
      # @option options [Boolean] :hex_escape (false)
      #   Forces all Strings to be hex-escaped.
      #
      # @option options [Symbol] :parens (DEFAULT_PARENS)
      #   Reduces the amount of parenthesis when elementizing lists.
      #   May be either `:less`, `:more`.
      #
      # @option options [Boolean, String] :space
      #   Controls whether spaces are used to separate keywords,
      #   or other kinds of white-space.
      #
      def initialize(options={})
        @case       = options.fetch(:case,DEFAULT_CASE)
        @quotes     = options.fetch(:quotes,DEFAULT_QUOTES)
        @hex_escape = options.fetch(:hex_escape,false)
        @parens     = options.fetch(:parens,DEFAULT_PARENS)

        @quote = case @quotes
                 when :single then "'"
                 when :double then '"'
                 when :tick   then "`"
                 else
                   raise(ArgumentError,"invalid quoting style: #{@quotes}")
                 end

        @space = case options[:space]
                 when true, nil then ' '
                 when false     then '/**/'
                 else           options[:space].to_s
                 end
      end

      #
      # Encodes the given keyword.
      #
      # @param [Symbol] name
      #   The name of the keyword.
      #
      # @return [String]
      #   The encoded keyword.
      #
      def keyword(name)
        name = ALIASES.fetch(name,name.to_s)

        case @case
        when :lower  then name.downcase
        when :upper  then name.upcase
        when :random then name.random_case
        else              name
        end
      end

      #
      # Encodes a NULL keyword.
      #
      # @return [String]
      #   The encoded SQL NULL value.
      #
      def null
        keyword :null
      end

      #
      # Encodes a Boolean value.
      #
      # @param [Boolean] bool
      #   The Boolean value.
      #
      # @return [String]
      #   The encoded SQL Boolean value.
      #
      def boolean(bool)
        keyword(bool == true ? :true : :false)
      end

      #
      # Encodes the integer.
      #
      # @param [Integer, String] integer
      #   The integer to encode.
      #
      # @return [String]
      #   The encoded integer.
      #
      def integer(integer)
        integer.to_i.to_s
      end

      #
      # Encodes the floating point number.
      #
      # @param [Float, Integer, String] float
      #   The floating point number to encode.
      #
      # @return [String]
      #   The encoded floating point number.
      #
      def float(float)
        float.to_f.to_s
      end

      #
      # Encodes the string.
      #
      # @param [String, Integer] text
      #   The string to encode.
      #
      # @return [String]
      #   The encoded string.
      #
      def string(text)
        text = text.to_s

        if @hex_escape
          keyword(:hex) + parens(text.sql_encode)
        else
          text.sql_escape(@quotes)
        end
      end

      #
      # Wraps a value in parenthesis.
      #
      # @param [String] value
      #   The value to wrap.
      #
      # @return [String]
      #   The wrapped value.
      #
      def parens(value)
        "(#{value})"
      end

      #
      # Joins a series of SQL fragments with spaces.
      #
      # @param [Array<String>] elements
      #   The SQL elements to join.
      #
      # @return [String]
      #   The joined SQL expression.
      #
      def join(*elements)
        elements.join(@space)
      end

      #
      # Wraps a list of elements in parenthesis.
      #
      # @param [Array<String>] elements
      #   The list elements to join.
      #
      # @return [String]
      #   The wrapped comma-separated list.
      #
      def join_list(*elements)
        value = elements.join(',')

        if (@parens == :more || (@parens == :less && elements.empty?))
          value = parens(value)
        end

        return value
      end

      #
      # Encodes the list of elements.
      #
      # @param [Array] elements
      #   The list of elements to encode.
      #
      # @see join_list
      #
      def list(*elements)
        join_list(*elements.map { |element| format(element) })
      end

      #
      # Encodes a Hash.
      #
      # @param [Hash] hash
      #   The hash to be encoded.
      #
      # @return [String]
      #   The encoded Hash.
      #
      def hash(hash)
        join_list(*hash.to_a.map { |name,value|
          name  = keyword(name)
          value = format(value)

          "#{name}=#{value}"
        })
      end

      #
      # Encodes a function call.
      #
      # @param [Symbol] name
      #   The name of the function to be called.
      #
      # @param [Array] arguments
      #   The optional arguments to call the function with.
      #
      # @return [String]
      #   The formatted function.
      #
      def function(name,*arguments)
        keyword(name) + list(*arguments)
      end

      #
      # Formats a SQL expression.
      #
      # @param [#to_sql, #to_s] expression
      #   The SQL expression to format.
      #
      # @return [String]
      #   The formatted SQL fragment.
      #
      def sql(expression)
        if expression.respond_to?(:to_sql) then expression.to_sql
        else                                    expression.to_s
        end
      end

      #
      # Formats a element.
      #
      # @param [Hash, Array, Symbol, String, Integer, Float, nil, true, false,
      #         Formattable, #to_sql, #to_s] element
      #   The element to format.
      #
      # @return [String]
      #   The formatted element.
      #
      def format(element)
        case element
        when nil         then null
        when true, false then boolean(element)
        when Integer     then integer(element)
        when Float       then float(element)
        when Symbol      then keyword(element)
        when String      then string(element)
        when Array       then list(*element)
        when Hash        then hash(element)
        when Formattable then element.format(self)
        else                  sql(element)
        end
      end

      #
      # Formats multiple elements into a SQL expression.
      #
      # @param [Array] elements
      #   The elements to format.
      #
      # @return [String]
      #   The joined SQL expression.
      #
      def format_elements(*elements)
        join(*elements.map { |element| format(element) })
      end

    end
  end
end
