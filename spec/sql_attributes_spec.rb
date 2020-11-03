# frozen_string_literal: true

RSpec.describe SqlAttributes do
  let!(:invoice) { Invoice.create!(number: '2020-0042', reference: 'My cool new course') }
  let!(:invoice_lines) do
    [
      invoice.invoice_lines.create!(name: 'Introduction', units: 1, unit_price: 52.25),
      invoice.invoice_lines.create!(name: 'Books', units: 3, unit_price: 1.99)
    ]
  end
  let!(:payments) do
    [
      invoice.payments.create!(amount: 10.25),
      invoice.payments.create!(amount: 10)
    ]
  end

  it 'has a version number' do
    expect(described_class::VERSION).not_to be nil
  end

  describe '#sql_attributes' do
    it 'returns all defined SQL attributes with their squished subquery' do
      expect(Invoice.sql_attributes.symbolize_keys).to eq(
        title: "number || ' | ' || reference",
        total_amount: 'SELECT SUM(units * unit_price) FROM invoice_lines WHERE invoice_lines.invoice_id = invoices.id',
        total_paid: 'SELECT SUM(amount) FROM payments WHERE payments.invoice_id = invoices.id'
      )
    end

    it 'can also be fetched by string' do
      expect(Invoice.sql_attributes).to have_key(:title)
      expect(Invoice.sql_attributes).to have_key('title')
      expect(Invoice.sql_attributes).to have_key(:total_paid)
      expect(Invoice.sql_attributes).to have_key('total_paid')
    end
  end

  describe '#with_<NAME> scopes' do
    it 'loads the virtual string concatenated attribute' do
      expect(Invoice.with_title.find(invoice.id).title).to eq '2020-0042 | My cool new course'
    end

    it 'loads the virtual subquery attibute' do
      expect(Invoice.with_total_amount.find(invoice.id).total_amount).to eq 58.22
    end

    it 'does not load other attributes' do
      expect do
        Invoice.with_title.find(invoice.id).total_amount
      end.to raise_error SqlAttributes::NotLoaded
    end
  end

  describe '#with_sql_attributes' do
    it 'loads the attribute if a single string is provided' do
      expect(Invoice.with_sql_attributes('title').find(invoice.id).title).to eq '2020-0042 | My cool new course'
    end

    it 'loads the attribute if a single symbol is provided' do
      expect(Invoice.with_sql_attributes(:title).find(invoice.id).title).to eq '2020-0042 | My cool new course'
    end

    it 'does not load other attributes if single attribute is provided' do
      expect do
        Invoice.with_sql_attributes(:title).find(invoice.id).total_amount
      end.to raise_error SqlAttributes::NotLoaded
    end

    it 'loads both attributes if two arguments are provided' do
      invoice_with_attributes = Invoice.with_sql_attributes('total_amount', :title).find(invoice.id)
      expect(invoice_with_attributes.title).to eq '2020-0042 | My cool new course'
      expect(invoice_with_attributes.total_amount).to eq 58.22
      expect { invoice_with_attributes.total_paid }.to raise_error SqlAttributes::NotLoaded
    end

    it 'loads all attributes if no argument provided' do
      invoice_with_attributes = Invoice.with_sql_attributes.find(invoice.id)
      expect(invoice_with_attributes.title).to eq '2020-0042 | My cool new course'
      expect(invoice_with_attributes.total_amount).to eq 58.22
      expect(invoice_with_attributes.total_paid).to eq 20.25
    end

    it 'loads no attributes if argument is nil' do
      invoice_with_attributes = Invoice.with_sql_attributes(nil).find(invoice.id)
      expect { invoice_with_attributes.title }.to raise_error SqlAttributes::NotLoaded
      expect { invoice_with_attributes.total_amount }.to raise_error SqlAttributes::NotLoaded
      expect { invoice_with_attributes.total_paid }.to raise_error SqlAttributes::NotLoaded
    end

    it 'loads no attributes if argument is empty array' do
      invoice_with_attributes = Invoice.with_sql_attributes([]).find(invoice.id)
      expect { invoice_with_attributes.title }.to raise_error SqlAttributes::NotLoaded
      expect { invoice_with_attributes.total_amount }.to raise_error SqlAttributes::NotLoaded
      expect { invoice_with_attributes.total_paid }.to raise_error SqlAttributes::NotLoaded
    end

    it 'loads both attributes if two attributes are provided in an array' do
      invoice_with_attributes = Invoice.with_sql_attributes(['total_amount', :title]).find(invoice.id)
      expect(invoice_with_attributes.title).to eq '2020-0042 | My cool new course'
      expect(invoice_with_attributes.total_amount).to eq 58.22
      expect { invoice_with_attributes.total_paid }.to raise_error SqlAttributes::NotLoaded
    end

    it 'raises an error if attribute is unknown' do
      expect do
        Invoice.with_sql_attributes(:unknown_attribute).find(invoice.id)
      end.to raise_error SqlAttributes::NotDefined
    end
  end
end
