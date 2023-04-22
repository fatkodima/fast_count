# frozen_string_literal: true

module FastCount
  module Adapters
    # @private
    class PostgresqlAdapter < BaseAdapter
      def install
        @connection.execute(<<~SQL)
          CREATE FUNCTION fast_count(table_name text, threshold bigint) RETURNS bigint AS $$
          DECLARE count bigint;
            BEGIN
              EXECUTE '
                WITH tables_counts AS (
                  -- inherited and partitioned tables counts
                  SELECT
                    ((SUM(child.reltuples::float) / greatest(SUM(child.relpages), 1))) *
                      (SUM(pg_relation_size(child.oid))::float / (current_setting(''block_size'')::float))::integer AS estimate
                  FROM pg_inherits
                    INNER JOIN pg_class parent ON pg_inherits.inhparent = parent.oid
                    INNER JOIN pg_class child  ON pg_inherits.inhrelid  = child.oid
                  WHERE parent.relname = ''' || table_name || '''

                  UNION ALL

                  -- table count
                  SELECT
                    (reltuples::float / greatest(relpages, 1)) *
                      (pg_relation_size(pg_class.oid)::float / (current_setting(''block_size'')::float))::integer AS estimate
                  FROM pg_class
                  WHERE relname = '''|| table_name ||'''
                )

                SELECT
                  CASE
                  WHEN SUM(estimate) < '|| threshold ||' THEN (SELECT COUNT(*) FROM "'|| table_name ||'")
                  ELSE SUM(estimate)
                  END AS count
                FROM tables_counts' INTO count;
              RETURN count;
            END
          $$ LANGUAGE plpgsql;
        SQL
      end

      def uninstall
        @connection.execute("DROP FUNCTION IF EXISTS fast_count(text, bigint)")
      end

      def fast_count(table_name, threshold)
        @connection.select_value(
          "SELECT fast_count(#{@connection.quote(table_name)}, #{@connection.quote(threshold)})"
        ).to_i
      end

      def estimated_count(sql)
        query_plan = @connection.select_value("EXPLAIN #{sql}")
        query_plan.match(/rows=(\d+)/)[1].to_i
      end
    end
  end
end
