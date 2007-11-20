#
# Ronin SQL - A Ronin library providing support for SQL related security
# tasks.
#
# Copyright (c) 2007 Hal Brodigan (postmodern at users.sourceforge.net)
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

require 'ronin/code/sql/keyword'

module Ronin
  module Code
    module SQL
      class Expr

        def initialize(style)
          @style = style
        end

        def is_null?
          self.is?(@style.dialect.null)
        end

        def not_null?
          self.is_not?(@style.dialect.null)
        end

        def in?(*range)
          In.new(@style,self,*range)
        end

        def ===(*range)
          in?(*range)
        end

        def not_in?(*range)
          in?(*range).not!
        end

        def compile
          # place holder
        end

        def to_s
          compile
        end

        protected

        def keyword(value)
          keyword_cache[value.to_sym]
        end

        def keywords(*values)
          values.map { |value| keyword(value) }
        end

        def Expr.keyword(id,value=id.to_s.upcase)
          id = id.to_s.downcase
          class_eval <<-end_eval
      protected

      def keyword_#{id}
      keyword('#{value}')
      end
    end_eval
        end

        def Expr.binary_op(op,*ids)
          for id in ids
            class_eval <<-end_eval
        def #{id}(expr)
            BinaryExpr.new(@style,'#{op}',self,expr)
          end
      end_eval
        end
      end

      binary_op '=', '==', :equals?
      binary_op '!=', :not_equals?
      binary_op '<>', '<=>', :different?
      binary_op '>', '>', :greater?
      binary_op '>=', '>=', :greater_equal?
      binary_op '<', '<', :less?
      binary_op '<=', '<=', :less_equal?
      binary_op 'IS', :is?
      binary_op 'IS NOT', :is_not?
      binary_op 'AS', :as
      binary_op 'CAST', :cast

      def Expr.like_op(op,*ids)
        for id in ids
          class_eval <<-end_eval
        def #{id}(expr,escape=nil)
          LikeExpr.new(@style,'#{op}',self,expr,escape)
        end
      end_eval
      end
    end

    like_op 'LIKE', :like
    like_op 'GLOB', :glob
    like_op 'REGEXP', :regexp
    like_op 'MATCH', :match

    def Expr.unary_op(op,*ids)
      for id in ids 
        class_eval <<-end_eval
        def #{id}
        UnaryExpr.new(@style,'#{op}',self)
        end
      end_eval
      end
    end

    unary_op 'NOT', :not!
    unary_op 'EXISTS', :exists?

    def dialect?
      @style.dialect
    end

    def multiline?
      @style.multiline
    end

    def lowercase?
      @style.lowercase
    end

    def less_parenthesis?
      @style.less_parenthesis
    end

    def compile_space
      @style.compile_space
    end

    def preappend_space(str)
      @style.preappend_space(str)
    end

    def append_space(str)
      @style.append_space(str)
    end

    def compile_newline
      @style.compile_newline
    end

    def quote_string(data)
      @style.quote_string(data)
    end

    def compile_keyword(name)
      @style.compile_keyword(name)
    end

    def compile_list(*expr)
      @style.compile_list(*expr)
    end

    def compile_datalist(*expr)
      @style.compile_list(*expr)
    end

    def compile_row(*expr)
      @style.compile_row(*expr)
    end

    def compile_data(data)
      @style.compile_data(data)
    end

    def compile_expr(*expr)
      @style.compile_expr(*expr)
    end

    def compile_lines(lines,separator=compile_newline)
      @style.compile_lines(lines,separator)
    end

    private

    def keyword_cache
      @keyword_cache ||= Hash.new { |hash,key| hash[key] = Keyword.new(@style,key) }
    end

  end
end
  end
end
