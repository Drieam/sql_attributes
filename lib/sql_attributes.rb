# frozen_string_literal: true

module SqlAttributes
  class NotLoaded < StandardError; end

  class NotDefined < StandardError; end

  def sql_attributes
    @sql_attributes ||= ActiveSupport::HashWithIndifferentAccess.new
  end

  def with_sql_attributes(*attributes)
    requested_attributes =
      if attributes.length.positive?
        Array.wrap(attributes).flatten.compact
      else
        sql_attributes.keys
      end

    requested_attributes.inject(all) do |scope, name|
      unless sql_attributes.key?(name)
        raise NotDefined, "You want to load dynamic SQL attribute `#{name}` but it is not defined."
      end

      scope.public_send("with_#{name}")
    end
  end

  def sql_attribute(name, subquery)
    sql_attributes[name] = subquery.squish

    scope "with_#{name}".to_sym, lambda {
      select(
        arel.projections,
        "(#{subquery.squish}) as #{name}"
      )
    }

    define_method(name) do
      return read_attribute(name) if has_attribute?(name)

      raise NotLoaded, <<~MESSAGE
        Dynamic SQL attribute `#{name}` not loaded from the database.

          Use the `with_sql_attributes` scope to load the attribute.

      MESSAGE
    end
  end
end

ActiveSupport.on_load(:active_record) do
  extend SqlAttributes
end
