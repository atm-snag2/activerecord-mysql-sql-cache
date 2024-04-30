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
              case value
              when String
                distinct = ' DISTINCT '
                select = 'SELECT '
                if value =~ /^#{select}/
                  if idx = value.index(distinct)
                    value.insert(idx + distinct.length, o.mysql_sql_cache.to_s)
                  else
                    value.insert(select.length, o.mysql_sql_cache.to_s)
                  end
                end
              else # Arel 6.0+
                if idx = value.index('DISTINCT')
                  value.insert(idx + 1, o.mysql_sql_cache.to_s)
                else
                  value.insert(1, o.mysql_sql_cache.to_s)
                end
              end
              result
            end
          end
        end
      end
    end
  end
end
