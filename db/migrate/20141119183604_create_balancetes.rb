class CreateBalancetes < ActiveRecord::Migration
  def change
    create_table :balancetes do |t|

      t.timestamps
    end
  end
end
