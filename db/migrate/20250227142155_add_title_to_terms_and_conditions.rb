class AddTitleToTermsAndConditions < ActiveRecord::Migration[6.1]
  def change
    add_column :bx_block_terms_and_conditions_terms_and_conditions, :title, :string
  end
end
