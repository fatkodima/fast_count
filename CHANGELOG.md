## master (unreleased)

- Support for quickly getting an exact number of distinct values in a column

    It is suited for cases, when there is a small amount of distinct values in a column compared to a total number
    of values (for example, 10M rows total and 200 distinct values).
    Runs orders of magnitude faster than `SELECT COUNT(DISTINCT column) FROM table`.

    Example:
    ```ruby
    User.fast_distinct_count(column: :company_id)
    ```

- Support PostgreSQL schemas for `#fast_count`

## 0.1.0 (2023-04-26)

- First release
