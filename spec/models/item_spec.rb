require "rails_helper"

RSpec.describe Item, type: :model do
  it "1 grupo sem sub-grupo" do
    balancete = Balancete.create!
    grupo     = Item.create!(nome: 'GRUPO 1', balancete: balancete)
    expect(Item.all.size).to eq(1)
    expect(Balancete.all.size).to eq(1)
  end

  it "1 grupo com 1 sub-grupo" do
    balancete = Balancete.create!
    grupo     = Item.create!(nome: 'GRUPO 1', balancete: balancete)
    subgrupo  = Item.create!(nome: 'SUB GRUPO 1', item: grupo)
    expect(Item.all.size).to eq(2)
    expect(Balancete.all.size).to eq(1)
    expect(Balancete.last.todos_itens.size).to eq(2)
  end

  it "1 grupo com 2 sub-grupos" do
    balancete = Balancete.create!
    grupo     = Item.create!(nome: 'GRUPO 1', balancete: balancete)
    subgrupo  = Item.create!(nome: 'SUB GRUPO 1', item: grupo)
    subgrupo2 = Item.create!(nome: 'SUB GRUPO 2', item: grupo)
    expect(Item.all.size).to eq(3)
    expect(Balancete.all.size).to eq(1)
    expect(Balancete.last.todos_itens.size).to eq(3)
  end

  it "1 grupo com 1 sub-grupo e 1 conta sintética" do
    balancete       = Balancete.create!
    grupo           = Item.create!(nome: 'GRUPO 1', balancete: balancete)
    subgrupo        = Item.create!(nome: 'SUB GRUPO 1', item: grupo)
    conta_sintetica = Item.create!(nome: 'SINTETICA 1', item: subgrupo)
    expect(Item.all.size).to eq(3)
    expect(Balancete.all.size).to eq(1)
    expect(Balancete.last.todos_itens.size).to eq(3)
  end

  it "1 grupo com 1 sub-grupo, 1 conta sintética e 1 conta analitica" do
    balancete       = Balancete.create!
    grupo           = Item.create!(nome: 'GRUPO 1', balancete: balancete)
    subgrupo        = Item.create!(nome: 'SUB GRUPO 1', item: grupo)
    conta_sintetica = Item.create!(nome: 'SINTETICA 1', item: subgrupo)
    conta_analitica = Item.create!(nome: 'ANALITICA 1', item: conta_sintetica)
    expect(Item.all.size).to eq(4)
    expect(Balancete.all.size).to eq(1)
    expect(Balancete.last.todos_itens.size).to eq(4)
  end

  it "1 grupo com 1 sub-grupo, 1 conta sintética, 1 conta analitica e valores atribuidos" do
    balancete       = Balancete.create!
    grupo           = Item.create!(nome: 'ATIVO', balancete: balancete)
    subgrupo        = Item.create!(nome: 'SUB GRUPO 1', item: grupo)
    conta_sintetica = Item.create!(nome: 'SINTETICA 1', item: subgrupo)
    conta_analitica = Item.create!(nome: 'ANALITICA 1', item: conta_sintetica, saldo_anterior_valor: 1000, debito_valor: 6000, credito_valor: 1000)
    expect(Item.all.size).to eq(4)
    expect(Balancete.all.size).to eq(1)
    expect(Balancete.last.todos_itens.size).to eq(4)
    balancete = Balancete.last
    expect(grupo.saldo_anterior).to eq(conta_analitica.saldo_anterior_valor)
    expect(subgrupo.saldo_anterior).to eq(conta_analitica.saldo_anterior_valor)
    expect(conta_sintetica.saldo_anterior).to eq(conta_analitica.saldo_anterior_valor)
    expect(conta_analitica.saldo_atual).to eq(conta_analitica.saldo_anterior_valor + conta_analitica.debito_valor - conta_analitica.credito_valor)
    expect(grupo.codigo).to eq('1')
    expect(subgrupo.codigo).to eq('1.1')
    expect(conta_sintetica.codigo).to eq('1.1.1')
    expect(conta_analitica.codigo).to eq('1.1.1.1')
  end

  it "1 grupo com 1 sub-grupo, 1 conta sintética, 2 contas analiticas e valores atribuidos" do
    balancete         = Balancete.create!
    grupo             = Item.create!(nome: 'ATIVO', balancete: balancete)
    subgrupo          = Item.create!(nome: 'SUB GRUPO 1', item: grupo)
    conta_sintetica   = Item.create!(nome: 'SINTETICA 1', item: subgrupo)
    conta_analitica   = Item.create!(nome: 'ANALITICA 1', item: conta_sintetica, saldo_anterior_valor: 1000, debito_valor: 6000, credito_valor: 1000)
    conta_analitica2  = Item.create!(nome: 'ANALITICA 2', item: conta_sintetica, saldo_anterior_valor: 1500, debito_valor: 3000, credito_valor: 1000)
    expect(Item.all.size).to eq(5)
    expect(Balancete.all.size).to eq(1)
    expect(Balancete.last.todos_itens.size).to eq(5)
    balancete = Balancete.last
    saldo_anterior_total = conta_analitica.saldo_anterior_valor + conta_analitica2.saldo_anterior_valor
    debito_total = conta_analitica.debito_valor + conta_analitica2.debito_valor
    credito_total = conta_analitica.credito_valor + conta_analitica2.credito_valor
    expect(grupo.saldo_anterior).to eq(saldo_anterior_total)
    expect(subgrupo.saldo_anterior).to eq(saldo_anterior_total)
    expect(conta_sintetica.saldo_anterior).to eq(saldo_anterior_total)
    expect(conta_sintetica.saldo_atual).to eq(saldo_anterior_total + debito_total - credito_total)
    expect(grupo.codigo).to eq('1')
    expect(subgrupo.codigo).to eq('1.1')
    expect(conta_sintetica.codigo).to eq('1.1.1')
    expect(conta_analitica.codigo).to eq('1.1.1.1')
    expect(conta_analitica2.codigo).to eq('1.1.1.2')
  end

  describe 'itens com valores', type: :model do

    before(:each) do
      @balancete            = Balancete.create!
      @grupo                = Item.create!(nome: 'ATIVO', balancete: @balancete)
      @subgrupo             = Item.create!(nome: 'SUB GRUPO 1', item: @grupo)
      @conta_sintetica      = Item.create!(nome: 'SINTETICA 1', item: @subgrupo)
      @conta_analitica      = Item.create!(nome: 'ANALITICA 1', item: @conta_sintetica, saldo_anterior_valor: 1000, debito_valor: 6000, credito_valor: 1000)
      @conta_analitica2     = Item.create!(nome: 'ANALITICA 2', item: @conta_sintetica, saldo_anterior_valor: 1500, debito_valor: 3000, credito_valor: 1000)
      @saldo_anterior_total = @conta_analitica.saldo_anterior_valor + @conta_analitica2.saldo_anterior_valor
      @debito_total         = @conta_analitica.debito_valor + @conta_analitica2.debito_valor
      @credito_total        = @conta_analitica.credito_valor + @conta_analitica2.credito_valor
    end

    it "e 3 contas analiticas" do
      conta_analitica3 = Item.create!(nome: 'ANALITICA 3', item: @conta_sintetica, saldo_anterior_valor: 2000, debito_valor: 2000, credito_valor: 1000)
      expect(@grupo.saldo_anterior).to eq(@saldo_anterior_total+conta_analitica3.saldo_anterior_valor)
    end

    it "e grupo passivo" do
      @grupo.update_attribute(:nome, 'PASSIVO')
      expect(@conta_sintetica.saldo_atual).to eq(@saldo_anterior_total - @debito_total + @credito_total)
    end
  end
end
