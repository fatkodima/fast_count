# frozen_string_literal: true

require "test_helper"

class FastCountTest < Minitest::Test
  def setup
    FastCount.install
    @connection = ActiveRecord::Base.connection
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

  private
    def postgresql?
      @connection.adapter_name.match?(/postg/i)
    end

    def mysql?
      @connection.adapter_name.match?(/mysql/i)
    end
end
