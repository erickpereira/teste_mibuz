class CreateItens < ActiveRecord::Migration
  def change
    create_table :itens do |t|
      t.references :balancete, index: true
      t.integer :codigo_primario
      t.string :nome
      t.decimal :saldo_anterior_valor
      t.decimal :debito_valor
      t.decimal :credito_valor
      t.references :item, index: true

      t.timestamps
    end
  end
end
