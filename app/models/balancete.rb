class Balancete < ActiveRecord::Base
  has_many :itens

  def todos_itens
    todos = []
    self.itens.each do |item|
      todos << item.mostrar_itens
    end
    todos.flatten
  end

end
