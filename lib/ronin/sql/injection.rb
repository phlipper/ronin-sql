#
# Ronin SQL - A Ruby DSL for crafting SQL Injections.
#
# Copyright (c) 2007-2013 Hal Brodigan (postmodern.mod3 at gmail.com)
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

require 'ronin/sql/binary_expr'
require 'ronin/sql/literals'
require 'ronin/sql/clauses'
require 'ronin/sql/program'

module Ronin
  module SQL
    #
    # Represents a SQL injection (SQLi).
    #
    class Injection < Program

      include Literals
      include Clauses

      # Default place holder values.
      PLACE_HOLDERS = {
        integer: 1,
        decimal: 1.0,
        string:  '1',
        list:    [nil],
        column:  :id
      }

      # The type of element to escape out of
      attr_reader :escape

      # The place holder data
      attr_reader :place_holder

      # The expression that will be injected
      attr_reader :expression

      #
      # Initializes a new SQL injection.
      #
      # @param [Hash] options
      #   Additional injection options.
      #
      # @option options [:integer, :decimal, :string, :column] :escape (:integer)
      #   The type of element to escape out of.
      #
      # @option options [Boolean] :terminate
      #   Specifies whether to terminate the SQLi with a comment.
      #
      # @option options [String, Symbol, Integer] :place_holder
      #   Place-holder data.
      #
      def initialize(options={},&block)
        super()

        @escape       = options.fetch(:escape,:integer)
        @place_holder = options.fetch(:place_holder) do
          PLACE_HOLDERS.fetch(@escape)
        end

        @expression = @place_holder

        instance_eval(&block) if block
      end

      #
      # Appends an `AND` expression to the injection.
      #
      # @yield []
      #   The return value of the block will be used as the right-hand side
      #   operand.
      #
      # @return [self]
      #
      def and(&block)
        value = instance_eval(&block)

        @expression = BinaryExpr.new(@expression,:AND,value)
        return self
      end

      #
      # Appends an `OR` expression to the injection.
      #
      # @yield []
      #   The return value of the block will be used as the right-hand side
      #   operand.
      #
      # @return [self]
      #
      def or(&block)
        value = instance_eval(&block)

        @expression = BinaryExpr.new(@expression,:OR,value)
        return self
      end

      #
      # Converts the SQL injection to SQL.
      #
      # @param [Hash] options
      #   Additional options for {Emitter#initialize}.
      #
      # @option options [Boolean] :terminate
      #   Specifies whether to terminate the injection with `;--`.
      #
      # @return [String]
      #   The raw SQL.
      #
      def to_sql(options={})
        emitter = emitter(options)
        sql     = ''

        sql << emitter.emit(@expression)

        unless clauses.empty?
          sql << ' ' << emitter.emit_clauses(clauses)
        end

        unless statements.empty?
          sql << '; ' << emitter.emit_program(self)
        end

        case @escape
        when :string, :list
          if (options[:terminate] || (sql[0,1] != sql[-1,1]))
            # terminate the expression
            sql << ';--'
          else
            sql = sql[0..-2]
          end

          # balance the quotes
          sql = sql[1..-1]
        else
          if options[:terminate]
            # terminate the expression
            sql << ';--'
          end
        end

        return sql
      end

    end
  end
end
