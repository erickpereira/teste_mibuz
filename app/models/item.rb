class Item < ActiveRecord::Base
  has_many    :itens
  belongs_to  :balancete
  belongs_to  :item

  before_create :atribuir_codigo_primario

  def mostrar_itens
    if self.itens.empty?
      [self]
    else
      [self] + itens.collect {|x| [x.mostrar_itens]}
    end
  end

  def saldo_anterior
    valor_do_campo('saldo_anterior')
  end

  def debito
    valor_do_campo('debito')
  end

  def credito
    valor_do_campo('credito')
  end

  def saldo_atual
    saldo_anterior  = self.saldo_anterior.nil? ? 0 : self.saldo_anterior
    debito          = self.debito.nil? ? 0 : self.debito
    credito         = self.credito.nil? ? 0 : self.credito
    if self.grupo_ativo?
      saldo_anterior + debito - credito
    else
      saldo_anterior - debito + credito
    end
  end

  def grupo_ativo?
    if self.balancete.present?
      self.nome.downcase.eql? 'ativo'
    else
      self.item.grupo_ativo?
    end
  end

  def codigo
    if self.balancete.present?
      "#{self.codigo_primario.to_s}"
    else
      "#{self.item.codigo}.#{self.codigo_primario.to_s}"
    end
  end

  private 

  def valor_do_campo(nome_campo)
    if itens.empty? and not balancete.present? and item.present?
      self.send(nome_campo+'_valor')
    else
      itens.inject(0){ |acc,val| acc + (val.send(nome_campo).nil? ? 0 : val.send(nome_campo)) }
    end
  end

  def atribuir_codigo_primario
    if self.item.present?
      self.codigo_primario = self.item.itens.empty? ? 1 : self.item.itens.last.codigo_primario + 1
    elsif self.balancete.present?
      self.codigo_primario = self.balancete.itens.empty? ? 1 : self.balancete.itens.last.codigo_primario + 1
    end
  end

end
