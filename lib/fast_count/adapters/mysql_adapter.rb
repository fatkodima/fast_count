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
    end
  end
end
