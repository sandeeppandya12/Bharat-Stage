class CreateBxBlockContentManagementTestimonials < ActiveRecord::Migration[6.1]
  def change
    create_table :testimonials do |t|
      t.string :name
      t.string :designation
      t.text :content

      t.timestamps
    end
  end
end
