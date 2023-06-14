.text

init:
            jal     	main                    # executa o procedimento principal
finit:
            move	$a0, $v0                # $a0 <- código de retorno do programa
            li      	$v0, 17                 # $v0 <- número do serviço exit2
            syscall                         # executamos o serviço exit 2

########################################################################################################################

# argumentos (parâmetros do procedimento)
# $a0       :       endereço da string com o nome do arquivo
# retorno do procedimento:
# $v0       :       descritor do arquivo

arquivo_abrir_leitura:
# este procedimento abre o arquivo para fazer a leitura das intruções que estão nele
# prólogo
# corpo do procedimento
# Abrimos um arquivo para a leitura
            li      	$a1, 0                  # $a1 <- flag igual a 0: abre o arquivo para leitura.
            li      	$a2, 0                  # $a2 <- modo. Não é usado
            li      	$v0, 13                 # $v0 <- serviço 13: abre arquivo para leitura ou escrita
            syscall                         # realizamos uma chamada ao sistema, para a abertura do arquivo
# epílogo
            jr	$ra                     # retorma ao procedimento chamador

########################################################################################################################

# argumentos (parâmetros do procedimento)
# $a0       :       descritor do arquivo      
arquivo_fechar:
# esteprocedimento fecha o arquivo

# prólogo
# corpo do procedimento
# Fechamos o arquivo com o serviço 16:
#   (i) Carregamos em $a0 o descritor do arquivo
#  (ii) Carregamos em $v0 o número do serviço para fechar o arquivo: 16
# (iii) Realizamos uma chamada ao sistema para executarmos o fechamento do arquivo.
            # $a0 é carregado com o descritor do arquivo.
            li      	$v0, 16                 # $v0 <- serviço 16: fechamos o arquivo com o descritor em $a0
            syscall                         # realizamos uma chamada ao sistema, fechando o arquivo com o descritor em $a0
# epílogo
            jr	$ra                     # retorna ao procedimento chamador

########################################################################################################################

# argumentos (parâmetros do procedimento)
# $a0       :       descritor do arquivo
# $a1       :       o endereço do buffer de leitura
# 
# valor de retorno
# $v0       :       número de bytes lidos do arquivo
arquivo_leia_registro:
#aqui ocorre a leitura dos bytes do arquivo .bin
# prólogo
# corpo do procedimento
#   (i) Carregamos em $a0 o descritor do arquivo.
#  (ii) Carregamos em $a1 o endereço do buffer de leitura
# (iii) Carregamos em $a2 o número de bytes que serão lidos do arquivo para o buffer de leitura
#  (iv) Carregamos em $v0 o número do serviço: 14
#   (v) Realizamos uma chamada ao sistema para executarmos a leitura do arquivo
            lw      	$a0, 0($t0)             # $a0 <- descritor do arquivo. $t0 contém o endereço do descritor_arquivo
            la	$a1, buffer_leitura     # $a1 <- endereço do buffer com os dados que serão escritos
            li      	$a2, 4                  # $a2 <- número de bytes que serão lidos do arquivo para o buffer
            li      	$v0, 14                 # $v0 <- serviço 14: leia um arquivo
            syscall                         # realiza uma chamada ao sistema, lendo 4 bytes para o buffer no arquivo
# epílogo
            jr	$ra                     # retornamos ao procedimento chamador

########################################################################################################################

# argumentos
# $a0       :       endereço do buffer de leitura

# mapa da pilha
# $sp + 8   :       $a0
# $sp + 4   :       $ra     endereço de retorno
# $sp + 0   :       $s0     
registro_processa:
# aqui é feito a uniao dos bytes lidos no formato litte endian
# prólogo   
            addiu   	$sp, $sp, -12           # ajustamos a pilha
            sw      	$a0, 8($sp)             # armazenamos na pilha o argumento com o endereço do buffer de leitura
            sw      	$ra, 4($sp)             # armazenamos na pilha o endereço de retorno
            sw      	$s0, 0($sp)             # armazenamos $s0 na pilha
            
# corpo do programa
rp_for_inicializa:
            li      	$s0, 0                  # $s0 <- guarda o número do campo a ser processado
            j 	rp_for_condicao               # verificamos se existem campos a serem apresentados
            
rp_for_codigo:
            # carregamos o registro
            lw      	$t0, 8($sp)             # $t0 <- endereço do buffer
            lw      	$t1, 0($t0)             # $t1 <- registro
            
            sw 	$t1, instrucao		# guarde o a instrucao completa na memoria


            
separacao_dos_campos:
# esta funcao e reponsavel por separar todos os campos de todas as intruces
	ll 	$t3, instrucao # pegue o conteúdo de instrucao e armazene em St3
campo_opcode:
# separa o opcode
	li 	$t1, 0xfc000000 #criar uma mascara para separar o opcode
	and 	$t2, $t3, $t1 # faça uma and entre St1 e St0 e armazene em St2
	srl 	$t2, $t2, 26 # mova para direita x bits.
	sw 	$t2, opcode
	
campo_rs:
# separa o rs
	li 	$t1, 0x03e00000 #criar uma mascara para separar rs
	and 	$t2, $t3, $t1 #separando 25 a 21 bits da instrucao
	srl 	$t2, $t2, 21 # mova para direita x bits
	sw 	$t2, rs # guarde na memoria

campo_rt:
#separa o rt
	li 	$t1, 0x001f0000#criar uma mascara para separar rt
	and 	$t2, $t3, $t1 # separando os bits
	srl 	$t2, $t2, 16 # mova para direita x bits
	sw 	$t2, rt # guarde na memoria

campo_rd:
#  separa o rd
	li 	$t1, 0x0000f800 #criar uma mascara para separar rd
	and 	$t2, $t3, $t1 #separando os bits
	srl 	$t2, $t2, 11 # mova para direita x bits
	sw 	$t2, rd # guarde na memoria

campo_shampt:
# separa o shampt
	li 	$t1, 0x000007c0 # criar uma mascara para separar shampt
	and 	$t2, $t3, $t1 # separando os bits
	srl 	$t2, $t2, 6 # mova para direita x bits
	sw 	$t2, shampt # guarde na memoria

campo_funct:
# separa o funct
	li 	$t1, 0x0000003f #criar uma mascara para separar funct
	and 	$t2, $t3, $t1 # separando os bits
	sw 	$t2, funct # guarde na memoria

campo_valor_imediato:
# separa os 16 bits do valor imediato e descobre calcular ele
	li 	$t1, 0x0000ffff #criar uma mascara para separar valor_imediato
	and 	$t2, $t3, $t1 # separando os bits
	sw 	$t2, valor_imediato # guarde na memoria

campo_endereco:
# separa os 26 bits do endereco e calcula ele 
	li 	$t1, 0x03ffffff #criar uma mascara para separar endereco
	and	$t2, $t3, $t1 # separando os bits
	sw 	$t2, endereco_imediato # guarde na memoria
	
traducao_da_instrucao:
	# aqui ocorre a tradução da instrucao de linguagem de maquina para assembly
	
resultado:
# este procedimento mostra o endereco da instrucao lida, e ela propria em hexadecimal
	li 	$v0, 34			#mostre o endereco da instrução
	ll 	$a0, endereco_da_instrucao
	syscall
	    
	li 	$a0, '\t'  # imprima um tab para organizar as informacoes
	li 	$v0, 11
	syscall
	    
            li      	$v0, 34                 # $v0 <- número do serviço para imprimir um inteiro em hexadecimal
            ll 	$a0, instrucao
            syscall                         # imprimimos o campo
            
            # aqui deve ser mostrado a instrução em assembly
            
            # pulamos a linha
            li      	$a0, '\n'               # $a0 <- nova linha
            li      	$v0, 11                 # $v0 <- serviço para imprimir um caractere
            syscall                         # imprimimos uma nova linha.
	
rp_for_incremento:
# faca o ingcremento das variaveis do laco for
            addiu   	$s0, $s0, 4             # incrementamos o número do campo
            
            ll      	$s7, endereco_da_instrucao	# incrementamos o endereco do programa
            add 	$s7, $s7, 4
            sw 	$s7, endereco_da_instrucao
            
rp_for_condicao:
# teste a condicao do laco de repeticao
            slti    	$t0, $s0, 4             # $t0 = 1 se existem campos a serem apresentados
            bne     	$t0, $zero, rp_for_codigo # apresenta o campo
            
# epílogo
            lw	    $s0, 0($sp)             # restauramos $s0
            lw      	$ra, 4($sp)             # restauramos o endereço de retorno
            addiu  	$sp, $sp, 12            # restauramos a pilha
            jr	$ra                     # retorna ao processo chamador

########################################################################################################################

# Mapa da pilha
# $sp + 4   :   $ra     endereço de retorno do procedimento 
# $sp + 0   :   código de retorno do procedimento main: 0 = SUCESSO
main:
# prólogo
            addiu   	$sp, $sp, -8            # ajustamos a pilha
            sw	$ra, 4($sp)             # armazenamos $ra na pilha
            
# corpo do procedimento
            sw	$zero, 0($sp)           # código de retorno = 0 = SUCESSO
            # abrimos o arquivo para leitura
            la	$a0, arquivo_leitura    # $a0 <- endereço da string com o nome do arquivo
            jal     	arquivo_abrir_leitura   # abre o arquivo para a leitura
            la      	$t0, descritor_arquivo  # $t0 <- endereço onde será armazenado o descritor do arquivo
            sw     	$v0, 0($t0)             # armazenamos em descritor_arquivo o descritor encontrado na abertura do arquivo
            # se o arquivo não pode ser aberto, tratamos o erro
            slt     	$t0, $v0, $zero         # se o descritor for menor que 0
            bne     	$t0, $zero, main_if_arquivo_nao_pode_ser_aberto
            
main_if_arquivo_aberto:
            j       	main_if_arquivo_fim     # sem erro de abertura: continua com o programa
            
main_if_arquivo_nao_pode_ser_aberto:
# mostra que houve erro na abrertura do arquivo
            la      	$a0, str_erro_abertura_arquivo  # $a0 <- endereço da string com a mensagem de erro
            li      	$v0, 4                  # $v0 <- serviço 4: imprime uma string
            syscall                         # imprimimos a mensagem de erro
            li      	$v0, 1                  # $v0 <- 1, valor de retorno indicando erro no programa
            bne     	$t0, $zero, fim_leitura_registros # encerra o procedimento mais
            
main_if_arquivo_fim:
            # lemos um registro do arquivo (uma palavra, 4 bytes)
            
main_while:
            j       	main_while_verifica_condicao
            
main_while_codigo:
            # verificamos se o número de bytes lido é 4
            slti    	$t0, $v0, 4             # se um registro não pôde ser lida do arquivo de entrada
            bne	$t0, $zero,main_if_leitura_registro_erro # termina o programa
            
main_if_leitura_registro_ok:
            la      	$a0, buffer_leitura     # $a0 <- endereço do buffer de leitura
            jal     	registro_processa       # processa o registro lido do arquivo de entrada
            j       	main_if_leitura_registro_fim # termina o processamento do registro
            
main_if_leitura_registro_erro:
# imprime uma mensagem de erro caso o arquivo nçao seja aberto
            la      	$a0, str_erro_leitura_registro  # $a0 <- endereço da string com a mensagem de erro
            li      	$v0, 4                  # $v0 <- serviço 4: imprime uma string
            syscall                         # imprimimos a mensagem de erro
            li      	$v0, 1                  # $v0 <- 1, valor de retorno indicando erro no programa
            bne     	$t0, $zero, fim_leitura_registros # encerra o procedimento mais       
                 
main_if_leitura_registro_fim:

main_while_verifica_condicao:
            la      	$t0, descritor_arquivo  # $t0 <- endereço onde será armazenado o descritor do arquivo
            lw      	$a0, 0($t0)             # $a0 <- descritor do arquivo
            la      	$a1, buffer_leitura     # $a1 <- endereço do buffer de leitura
            jal     	arquivo_leia_registro   # tentamos ler um registro (4 bytes), $v0 retorna o número de bytes lidos
            bne     	$v0, $zero, main_while_codigo # se não chegamos ao final do arquivo, processamos o registro
            
fim_leitura_registros:
# fechaamento do arquivo quanado terminar o programa
            la      	$t0, descritor_arquivo  # $t0 <- endereço do descritor do arquivo
            lw      	$a0, 0($t0)             # $a0 <- descritor do arquivo
            jal     	arquivo_fechar          # fechamos o arquivo

# epílogo
            lw      	$ra, 4($sp)             # restauramos o endereço de retorno
            lw      	$v0, 0($sp)             # $v0 <- código de retorno do procedimento: 0 = SUCESSO
	addiu   	$sp, $sp, 8             # restauramos a pilha
            jr	$ra                     # retornamos ao procedimento chamador
########################################################################################################################


.data
descritor_arquivo: 	.word 0                  # descritor do arquivo: um inteiro não negativo
arquivo_leitura: 	.asciiz "trab.bin"         # nome do arquivo
.align 2                                    # Alinhamos o endereço de buffer para ser múltiplo de 4, senão erro:
                                            # "store address not aligned on word boundary" ou endereço de armazenamento
                                            # não está alinhado com os limites da palavra
buffer_leitura: 	.space 32                   # buffer para a leitura do arquivo
buffer_escrita: 	.space 32

str_erro_abertura_arquivo: .asciiz "[ERRO] O arquivo não pôde ser aberto\n"
str_erro_leitura_registro: .asciiz "[ERRO] Erro de leitura do arquivo\n"

campos_mascaras:
mascara_ID: 	.word 0xFF000000                    # 0
mascara_P1: 	.word 0x00FF0000                    # 1
mascara_P2: 	.word 0x0000FF00                    # 2
mascara_E: 		.word 0x000000FF                    # 3

instrucao: 		.word 0
opcode: 		.word 0
rs: 		.word 0
rt: 		.word 0
rd: 		.word 0
shampt: 		.word 0
funct: 		.word 0
valor_imediato: 	.word 0
endereco_imediato: 	.word 0
endereco_da_instrucao: 	.word 0x00400000

zero:		.asciiz "$zero "
at:		.asciiz "$at "
v0:		.asciiz "$v0 "
v1:		.asciiz "$v1 "
a0:		.asciiz "$a0 "
a1:		.asciiz "$a1 "
a2:		.asciiz "$a2 "
a3:		.asciiz "$a3 "
t0:		.asciiz "$t0 "
t1:		.asciiz "$t1 "
t2:		.asciiz "$t2 "
t3:		.asciiz "$t3 "
t4:		.asciiz "$t4 "
t5:		.asciiz "$t5 "
t6:		.asciiz "$t6 "
t7:		.asciiz "$t7 "
s0:		.asciiz "$s0 "
s1:		.asciiz "$s1 "
s2:		.asciiz "$s2 "
s3:		.asciiz "$s3 "
s4:		.asciiz "$s4 "
s5:		.asciiz "$s5 "
s6:		.asciiz "$s6 "
s7:		.asciiz "$s7 "
t8:		.asciiz "$t8 "
t9:		.asciiz "$t9 "
k0:		.asciiz "$k0 "
k1:		.asciiz "$k1 "
gp:		.asciiz "$gp "
sp:		.asciiz "$sp "
fp:		.asciiz "$fp "
ra:		.asciiz "$ra "




      
