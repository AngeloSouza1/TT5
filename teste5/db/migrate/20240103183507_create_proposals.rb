class CreateProposals < ActiveRecord::Migration[7.1]
  def change
    create_table :proposals do |t|
      t.string :title
      t.string :duration

      t.timestamps
    end
  end
end
