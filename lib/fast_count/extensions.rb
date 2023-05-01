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
