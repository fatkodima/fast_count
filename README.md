# FastCount

[![Build Status](https://github.com/fatkodima/fast_count/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/fatkodima/fast_count/actions/workflows/ci.yml)

Unfortunately, it's currently notoriously difficult and expensive to get an exact count on large tables.

Luckily, there are [some tricks](https://www.citusdata.com/blog/2016/10/12/count-performance) for quickly getting fairly accurate estimates. For example, on a PostgreSQL table with over 450 million records, you can get a 99.82% accurate count within a fraction of the time. See the table below for an example dataset.

| SQL | Result | Accuracy | Time |
| --- | --- | --- | --- |
| `SELECT count(*) FROM small_table` | `2037104` | `100.000%` | `4.900s` |
| `SELECT fast_count('small_table')` | `2036407` | `99.965%` | `0.050s` |
| `SELECT count(*) FROM medium_table` | `81716243` | `100.000%` | `257.5s` |
| `SELECT fast_count('medium_table')` | `81600513` | `99.858%` | `0.048s` |
| `SELECT count(*) FROM large_table` | `455270802` | `100.000%` | `310.6s` |
| `SELECT fast_count('large_table')` | `454448393` | `99.819%` | `0.046s` |

*These metrics were pulled from real PostgreSQL databases being used in a production environment.*

For MySQL, this gem uses internal statistics to return the estimated table's size. And as [per documentation](https://dev.mysql.com/doc/refman/8.0/en/show-table-status.html), it may vary from the actual value by as much as 40% to 50%.
But still is useful to get a rough idea of the number of rows in very large tables (where `COUNT(*)` can literally take hours).

Supports PostgreSQL, MySQL, MariaDB, and SQLite.

## Requirements

- Ruby 2.7+
- ActiveRecord 6+

If you need support for older versions, [open an issue](https://github.com/fatkodima/fast_count/issues/new).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fast_count'
```

And then execute:

```sh
$ bundle
```

Or install it yourself as:

```sh
$ gem install fast_count
```

If you are using PostgreSQL, you need to create a database function, used internally:

```sh
$ rails generate migration install_fast_count
```

with the content:

```ruby
class InstallFastCount < ActiveRecord::Migration[7.0]
  def up
    FastCount.install
  end

  def down
    FastCount.uninstall
  end
end
```

## Usage

### Estimated table count

To quickly get an estimated count of the rows in a table:

```ruby
User.fast_count # => 1_254_312_219
```

### Result set size estimation

If you want to quickly get an estimation of how many rows will the query return, without actually executing it, you can run:

```ruby
User.where.missing(:avatar).estimated_count # => 324_200
```

**Note**: `estimated_count` relies on the database query planner estimations (basically on the output of `EXPLAIN`) to get its results and can be very imprecise. It is better be used to get an idea of the order of magnitude of the future result.

### Exact distinct values count

To quickly get an exact number of distinct values in a column, you can run:

```ruby
User.fast_distinct_count(column: :company_id) # => 243
```

It is suited for cases when there is a small amount of distinct values in a column compared to a total number
of values (for example, 10M rows total and 200 distinct values).

Runs orders of magnitude faster than `SELECT COUNT(DISTINCT column) FROM table`.

**Note**: You need to have an index starting with the specified column for this to work.

Uses a ["Loose Index Scan" technique](https://wiki.postgresql.org/wiki/Loose_indexscan).

## Configuration

You can override the following default options:

```ruby
# Determines for how large tables this gem should get the exact row count using SELECT COUNT.
# If the approximate row count is smaller than this value, SELECT COUNT will be used,
# otherwise the approximate count will be used.
FastCount.threshold = 100_000
```

## Credits

Thanks to [quick_count gem](https://github.com/TwilightCoders/quick_count) for the original idea.

## Development

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fatkodima/fast_count.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
