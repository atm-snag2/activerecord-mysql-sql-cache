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
              case result
              when String
                distinct = ' DISTINCT '
                select = 'SELECT '
                if result =~ /^#{select}/
                  if idx = result.index(distinct)
                    result.insert(idx + distinct.length, o.mysql_sql_cache.to_s)
                  else
                    result.insert(select.length, o.mysql_sql_cache.to_s)
                  end
                end
              else # Arel 6.0+
                if idx = result.value.index('DISTINCT')
                  result.value.insert(idx + 1, o.mysql_sql_cache.to_s)
                else
                  result.value.insert(1, o.mysql_sql_cache.to_s)
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
