class CreatePontos < ActiveRecord::Migration[5.2]
  def change
    create_table :pontos do |t|
      t.integer :user_id
      t.string :nome
      t.integer :pontuacao
      t.date :dataPontuacao

      t.timestamps
    end
  end
end
