class AlterCodeNumericOnCountry < ActiveRecord::Migration
  def change
    change_table :countries do |t|
      t.change :code_numeric, :string
    end
  end
end
