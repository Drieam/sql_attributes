# frozen_string_literal: true

class InvoiceLine < ApplicationRecord
  belongs_to :invoice
end
