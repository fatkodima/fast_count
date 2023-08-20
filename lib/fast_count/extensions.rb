# frozen_string_literal: true

module FastCount
  module Extensions
    module ModelExtension
      # Returns an estimated number of rows in the table.
      # Runs in milliseconds.
      #
      # @example
      #   User.fast_count
      #   User.fast_count(threshold: 50_000)
      #
      def fast_count(threshold: FastCount.threshold)
        adapter = Adapters.for_connection(connection)
        adapter.fast_count(table_name, threshold)
      end

      # Returns an exact number of distinct values in a column.
      # It is suited for cases, when there is a small amount
      # of distinct values in a column compared to a total number
      # of values (for example, 10M rows total and 500 distinct values).
      #
      # Runs orders of magnitude faster than 'SELECT COUNT(DISTINCT column) ...'.
      #
      # Note: You need to have an index starting with the specified column
      # for this to work.
      #
      # Uses an "Loose Index Scan" technique (see https://wiki.postgresql.org/wiki/Loose_indexscan).
      #
      # @example
      #   User.fast_distinct_count(column: :company_id)
      #
      def fast_distinct_count(column:)
        if column.to_s == primary_key
          raise "Use `#fast_count` when counting primary keys."
        end

        adapter = Adapters.for_connection(connection)
        adapter.fast_distinct_count(table_name, column)
      end
    end

    module RelationExtension
      # Returns an estimated number of rows that the query will return
      # (without actually executing it).
      #
      # @example
      #   User.where.missing(:avatar).estimated_count
      #
      def estimated_count
        adapter = Adapters.for_connection(connection)
        adapter.estimated_count(to_sql)
      end
    end
  end
end
