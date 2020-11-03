# SQL Attributes
This gem is here to help you with fetching record specific data from the database using subqueries. You could also use this gem as an alternative for counter caches but of course you should think about this carefully since it can be read heavy.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'sql_attributes'
```
   
The of course run `bundle install`. 

## Usage
It starts by defining an SQL attribute on a class:

```ruby
class Author < ApplicationRecord
  sql_attribute :books_count, <<~SQL
    SELECT COUNT(*)
    FROM books
    WHERE books.author_id = books.id
  SQL
  
  sql_attribute :total_pages, <<~SQL
    SELECT SUM(books.pages)
    FROM books
    WHERE books.author_id = books.id
  SQL

  # Note that this aggregation method `GROUP_CONCAT` is different for other databases like Postgres 
  sql_attribute :publisher_names, <<~SQL
    SELECT DISTINCT GROUP_CONCAT(publishers.name, ' - ')
    FROM publishers
    INNER JOIN books ON books.publisher_id = publishers.id
    WHERE books.author_id = authors.id
    GROUP BY books.author_id
  SQL
end
```

Before you can access the attribute, you have to include it to the SQL query. An error will be raised if you dont: 
```ruby
authors = Author.all
authors.map(&:books_count) # => raises SqlAttributes::NotLoaded
authors.map(&:total_pages) # => raises SqlAttributes::NotLoaded
```

You can tell ActiveRecord / Arel to include a specific attribute by using the `with_<NAME>` helpers: 
```ruby
authors = Author.with_books_count.all
authors.map(&:books_count) # => [1, 2]
authors.map(&:total_pages) # => raises SqlAttributes::NotLoaded
```

These methods are chainable and can be combined with normal scopes:
```ruby
authors = Author.where(publisher_id: 42).with_books_count.with_total_pages.all
authors.map(&:books_count) # => [1, 2]
authors.map(&:total_pages) # => [300, 500]
```

You can also load the attributes with the `with_sql_attributes` helper:
```ruby
authors = Author.with_sql_attributes(:books_count, :publisher_names)
authors.map(&:books_count) # => [1, 2]
authors.map(&:total_pages) # => raises SqlAttributes::NotLoaded
```

If you don't pass any argument, it will load all SQL attributes:
```ruby
authors = Author.with_sql_attributes
authors.map(&:books_count) # => [1, 2]
authors.map(&:total_pages) # => [300, 500]
```

## Releasing new version
Publishing a new version is handled by the publish workflow. This workflow publishes a GitHub release to rubygems and GitHub package registry with the version defined in the release.

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/Drieam/sql_attributes.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Credits
A big inspration is [this blog](https://medium.com/@eric.programmer/the-sql-alternative-to-counter-caches-59e2098b7d7) about `The SQL Alternative To Counter Caches`.
 
The most important example from this blog:

```ruby
class Author < ApplicationRecord
  scope :with_counts, -> {
   select <<~SQL
     authors.*,
     (
       SELECT COUNT(books.id) FROM books
       WHERE author_id = authors.id
     ) AS books_count
   SQL
  }
end
```

With this gem, this can be rewritten to

```ruby
class Author < ApplicationRecord
  sql_attribute :books_count, <<~SQL
    SELECT COUNT(books.id) 
    FROM books
    WHERE author_id = authors.id
  SQL
end
```

Also some ideas where 'stolen' from [this blog](https://engineering.culturehq.com/posts/2019-01-18-dynamic-activerecord-columns) about `Dynamic ActiveRecord columns`.
