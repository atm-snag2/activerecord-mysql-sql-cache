require 'active_support/concern'

module ActiverecordMysqlSqlCache
  module Patches
    module Arel
      module Visitors
        module MySQL
          extend ActiveSupport::Concern

          included do |base|
            base.prepend(SqlCache)
          end

          module SqlCache
            def visit_Arel_Nodes_SelectCore(o, collector)
              result = super(o, collector)
              value = if result.respond_to?(:value)
                        result.value
                      else
                        result
                      end
              mysql_sql_cache_str = o.mysql_sql_cache.to_s
              if mysql_sql_cache_str != ''
                case value
                when String
                  string_insert!(value, mysql_sql_cache_str)
                else # Arel 6.x
                  array_insert!(value, mysql_sql_cache_str)
                end
              end
              result
            end

            def string_insert!(value, insert_str)
              from = ' FROM '
              distinct = ' DISTINCT '
              select = 'SELECT '
              return unless value =~ /^#{select}/
              idx = value.index(distinct)
              from_pos = value.index(from)
              pos = if idx && (!from_pos || idx < from_pos)
                      idx + distinct.length
                    else
                      select.length
                    end
              value.insert(pos, insert_str)
            end

            def array_insert!(value, insert_str)
              idx = value.index('DISTINCT')
              from_pos = value.index('FROM')
              pos = if idx && (!from_pos || idx < from_pos)
                      idx + 1
                    else
                      1
                    end
              value.insert(pos, insert_str)
            end
          end
        end
      end
    end
  end
end
