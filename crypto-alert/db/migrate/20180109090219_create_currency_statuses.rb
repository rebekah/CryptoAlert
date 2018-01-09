class CreateCurrencyStatuses < ActiveRecord::Migration[5.1]
  def change
    create_table :currency_statuses do |t|
      t.string :symbol
      t.string :comparator
      t.float :value
    end
  end
end
