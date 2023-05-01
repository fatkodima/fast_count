# frozen_string_literal: true

module FastCount
  module Adapters
    # @private
    class MysqlAdapter < BaseAdapter
      # Documentation says, that this value may vary from
      # the actual value by as much as 40% to 50%.
      def fast_count(table_name, threshold)
        estimate = @connection.select_one("SHOW TABLE STATUS LIKE #{@connection.quote(table_name)}")["Rows"]
        if estimate >= threshold
          estimate
        else
          @connection.select_value("SELECT COUNT(*) FROM #{@connection.quote_table_name(table_name)}")
        end
      end

      # Tree format was added in MySQL 8.0.16.
      # For other formats I wasn't able to find an easy way to get this count.
      def estimated_count(sql)
        query_plan = @connection.select_value("EXPLAIN format=tree #{sql}")
        query_plan.match(/rows=(\d+)/)[1].to_i
      end

      # MySQL already supports "Loose Index Scan" (see https://dev.mysql.com/doc/refman/8.0/en/group-by-optimization.html),
      # so we can just directly run the query.
      def fast_distinct_count(table_name, column_name)
        unless index_exists?(table_name, column_name)
          raise "Index starting with '#{column_name}' must exist on '#{table_name}' table"
        end

        @connection.select_value(<<~SQL)
          SELECT COUNT(*) FROM (
            SELECT DISTINCT #{@connection.quote_column_name(column_name)} FROM #{@connection.quote_table_name(table_name)}
          ) AS tmp
        SQL
      end

      private
        def index_exists?(table_name, column_name)
          indexes = @connection.schema_cache.indexes(table_name)
          indexes.find do |index|
            index.using == :btree && Array(index.columns).first == column_name.to_s
          end
        end
    end
  end
end
