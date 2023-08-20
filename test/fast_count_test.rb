# frozen_string_literal: true

require "test_helper"

class FastCountTest < Minitest::Test
  def setup
    FastCount.install
    @connection = ActiveRecord::Base.connection
    @connection.schema_cache.clear!
  end

  def teardown
    FastCount.uninstall
    User.delete_all
  end

  def test_fast_count
    assert_kind_of Integer, User.fast_count
  end

  def test_fast_count_returns_exact_count_when_under_threshold
    10.times { User.create! }
    if postgresql?
      @connection.execute("ANALYZE users")
    elsif mysql?
      @connection.execute("ANALYZE TABLE users")
    end

    assert_equal 10, User.fast_count
  end

  def test_fast_count_works_with_postgresql_partitioned_tables
    skip unless postgresql?

    begin
      @connection.execute(<<~SQL)
        CREATE TABLE projects(id integer) PARTITION BY RANGE(id);
        CREATE TABLE projects_1_10 PARTITION OF projects FOR VALUES FROM (1) TO (10);
        CREATE TABLE projects_11_20 PARTITION OF projects FOR VALUES FROM (11) TO (20);
        CREATE TABLE projects_21_30 PARTITION OF projects FOR VALUES FROM (21) TO (30);
      SQL

      ids = [1, 2, 12, 15, 16, 22] # spanning all the partitions
      ids.each { |id| Project.create!(id: id) }

      assert_equal ids.size, Project.fast_count
    ensure
      @connection.drop_table(:projects, if_exists: true)
    end
  end

  class TestSchemaUser < ActiveRecord::Base
    self.table_name = "test_schema.users"
  end

  def test_fast_count_works_with_postgresql_schemas
    skip unless postgresql?

    begin
      @connection.create_schema("test_schema")
      @connection.create_table("test_schema.users")
      2.times { TestSchemaUser.create! }

      assert_equal 2, TestSchemaUser.fast_count
    ensure
      @connection.drop_schema("test_schema")
    end
  end

  def test_fast_count_respects_configured_threshold
    previous = FastCount.threshold
    FastCount.threshold = 10

    5.times { User.create! }
    if postgresql?
      @connection.execute("ANALYZE users")
    elsif mysql?
      @connection.execute("ANALYZE TABLE users")
    end

    assert_equal 5, User.fast_count
  ensure
    FastCount.threshold = previous
  end

  def test_estimated_count
    assert_kind_of Integer, User.where(admin: true).estimated_count
  end

  def test_fast_distinct_count_raises_if_missing_index
    skip unless postgresql? || mysql?

    error = assert_raises(RuntimeError) do
      User.fast_distinct_count(column: :company_id)
    end
    assert_match("Index starting with 'company_id' must exist on 'users' table", error.message)
  end

  def test_fast_distinct_count_raises_if_incorrect_index_exists
    skip unless postgresql? || mysql?

    begin
      @connection.add_index(:users, [:name, :company_id]) # 'company_id' is not a prefix
      error = assert_raises(RuntimeError) do
        User.fast_distinct_count(column: :company_id)
      end
      assert_match("Index starting with 'company_id' must exist on 'users' table", error.message)
    ensure
      @connection.remove_index(:users, [:name, :company_id])
    end
  end

  def test_fast_distinct_count
    @connection.add_index(:users, :company_id)
    @connection.execute(<<~SQL)
      INSERT INTO users (company_id) VALUES (1), (2), (3), (2), (2), (3), (4)
    SQL

    assert_equal 4, User.fast_distinct_count(column: :company_id)
  ensure
    @connection.remove_index(:users, :company_id)
  end

  def test_fast_distinct_count_on_primary_key
    error = assert_raises(RuntimeError) do
      User.fast_distinct_count(column: :id)
    end
    assert_equal "Use `#fast_count` when counting primary keys.", error.message
  end

  def test_fast_distinct_count_counts_nulls
    @connection.add_index(:users, :company_id)
    @connection.execute(<<~SQL)
      INSERT INTO users (company_id) VALUES (1), (2), (3), (2), (null), (null), (4)
    SQL

    assert_equal 5, User.fast_distinct_count(column: :company_id)
  ensure
    @connection.remove_index(:users, :company_id)
  end

  private
    def postgresql?
      @connection.adapter_name.match?(/postg/i)
    end

    def mysql?
      @connection.adapter_name.match?(/mysql/i)
    end
end
