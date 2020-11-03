# frozen_string_literal: true

class Invoice < ApplicationRecord
  has_many :invoice_lines
  has_many :payments

  sql_attribute :title, <<~SQL
    number || ' | ' || reference
  SQL

  sql_attribute :total_amount, <<~SQL
    SELECT SUM(units * unit_price)
    FROM invoice_lines
    WHERE invoice_lines.invoice_id = invoices.id
  SQL

  sql_attribute 'total_paid', <<~SQL
    SELECT SUM(amount)
    FROM payments
    WHERE payments.invoice_id = invoices.id
  SQL
end
