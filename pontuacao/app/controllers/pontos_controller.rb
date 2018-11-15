require 'csv'
require 'listen'

class PontosController < ApplicationController

    def index
        #Recuperar os profiles do banco e ordenar pela pontuação descrescente
        @pontos = Ponto.order pontuacao: :desc

    end

    def ping
        #Recuperar os profiles do banco e ordenar pela pontuação descrescente
        @pontos = Ponto.order pontuacao: :desc
        #retornar apenas a tabela do html
        render :layout => false
    end

    #Costante para setar o valor máximo da pontuação
    MAX_PONTO = 3126
    
    #Verificar no diretório se um arquivo foi adicionado ou editado
    #Considerando apenas o valor relativo da path
    listener = Listen.to("storage/", only: /\.csv/, relative: true) do |modified, added, removed|
        
        file_path = added[0]
        #Melhorias
        #Fazer encapsulamento: criar função set_File() que retorna os arquivos do diretório
        #criar função set_CSV() que retorna as linhas referente aos registros de pontuação
        #criar função gera_pontuacao() sem retorno para validar e salvar no banco
        files = Dir[file_path]

        for file in files do

            CSV.foreach(file) do |rows|

                for row in rows do
        
                    ls_atributos = row.split(";")

                    data_da_pontuacao = ls_atributos[0]
                    nome = ls_atributos[1]
                    user_id = ls_atributos[2].to_i
                    pontos_ganhos = ls_atributos[3].to_i

                    #Verificar a existência do usuário
                    if Ponto.exists?(user_id: user_id)

                        update_pontos = Ponto.find_by(user_id: user_id)
                        
                        pontos_atual = update_pontos.pontuacao
                        
                        #Validar a quantidade máxima recebida
                        if pontos_atual + pontos_ganhos >= MAX_PONTO
                            novo_pontos = MAX_PONTO
                        else
                            novo_pontos = pontos_atual + pontos_ganhos
                        end

                        update_pontos.pontuacao = novo_pontos
                        update_pontos.dataPontuacao = data_da_pontuacao
                        update_pontos.save

                    else

                        #Validar a quantidade máxima recebida
                        if pontos_ganhos >= MAX_PONTO
                            novo_pontos = MAX_PONTO
                        else
                            novo_pontos =  pontos_ganhos
                        end

                        create_pontos = Ponto.create(user_id: user_id, nome: nome, pontuacao: novo_pontos, dataPontuacao: data_da_pontuacao)
                    
                    end


                end
            end
        end
        
    end
    
    listener.start


end
