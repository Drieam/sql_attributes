# frozen_string_literal: true

ActiveRecord::Schema.define do
  create_table :invoices do |t|
    t.string :number
    t.string :reference
  end

  create_table :invoice_lines do |t|
    t.belongs_to :invoice
    t.string :name
    t.integer :units
    t.decimal :unit_price
  end

  create_table :payments do |t|
    t.belongs_to :invoice
    t.decimal :amount
  end
end
