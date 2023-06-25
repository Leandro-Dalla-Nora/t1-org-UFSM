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

resultado_inicial:
# este procedimento mostra o endereco de codigo da instrucao lida e a propria em hexadecimal
	li 	$v0, 34			# mostre o endereco da instrução
	ll 	$a0, pc
	syscall
	    
	li 	$a0, '\t'  # imprima um tab para organizar as informacoes
	li 	$v0, 11
	syscall
	    
            li      	$v0, 34                 # $v0 <- número do serviço para imprimir um inteiro em hexadecimal
            ll 	$a0, instrucao	# carregue da memoria o valor da instrucao
            syscall			# imprimimos o campo
            
            li 	$a0, '\t'  # imprima um tab para organizar as informacoes
	li 	$v0, 11
	syscall

########################

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
	sll	$t2, $t2, 2 # adicionando 2 bits a esquerada
	
	ll	$t4, pc # carregue o valor de pc
	addi	$t4, $t4, 4 # some 4
	andi	$t4, $t4, 0xF0000000 # pegue os 4 bits mais significativos
	
	or	$t2, $t2, $t4 # decubra o valor do campo endereco
	
	sw 	$t2, endereco_imediato # guarde na memoria

############################

traducao_da_instrucao:
	# aqui ocorre a tradução da instrucao de linguagem de maquina para assembly
	ll	$t1, opcode #carregue o valor do opcode
	
	li	$t2, 0x00000000 # if opcode == 0x00 é instrucao do tipo r
	beq	$t1, $t2, instrucao_do_tipo_r
	
	li	$t2, 0x00000002 # if opcode == 0x02 ou 0x003 é instrucao do tipo j
	beq	$t1, $t2, instrucao_do_tipo_j
	li	$t2, 0x00000003
	beq	$t1, $t2, instrucao_do_tipo_j
	
	j 	instrucao_do_tipo_i # o resto é instrucoa do tipo i
	
instrucao_do_tipo_r:
	ll	$t2, funct 	#pegue da memória o campo funct
	li	$t9, 1 # 1 = instrucao tipo r. $t9 sera usado para diferenciar cada instrucao, pois altera a ordem dos registradores
	
	if_add:
		beq 	$t2, 0x20, add_printar     # funct 0x20 - add
	else_if_adddu:
		beq	$t2, 0x21, addu_printar    # funct 0x21 - addu
	else_if_sub:
    		beq 	$t2, 0x22, sub_printar     # funct 0x22 - sub
    	else_if_and:
    		beq 	$t2, 0x24, and_printar     # funct 0x24 - and
    	else_if_or:
    		beq 	$t2, 0x25, or_printar      # funct 0x25 - or
    	else_if_nor:
    		beq 	$t2, 0x27, nor_printar     # funct 0x27 - nor
    	else_if_sll:
    		beq 	$t2, 0x00, sll_printar     # funct 0x00 - sll
    	else_if_srl:
    		beq 	$t2, 0x02, srl_printar     # funct 0x02 - srl
    	else_if_sçt:
    		beq 	$t2, 0x2a, slt_printar     # funct 0x2a - slt
    	else_if_jr:
    		beq 	$t2, 0x08, jr_printar      # funct 0x08 - jr
    	else_if_syscall:
    		beq	$t2, 0x0c, syscall_printar # funct 0x0c - syscall
    	else_if_mul:
    		beq	$t2, 0x18, mul_printar     # funct 0x1c -mul
    	else_instrucao_desconhecida:
    		j	instrucao_desconhecida

instrucao_do_tipo_j:
	ll	$t2, opcode	# carregue da memória o campo opcode
	
	if_j:
	    	beq 	$t2, 0x02, j_printar       # opcode 0x02 - j
	else_if_jal:
    		beq 	$t2, 0x03, jal_printar     # opcode 0x03 - jal
	j	else_instrucao_desconhecida
    			
instrucao_do_tipo_i:
	ll	$t2, opcode # carregue da memória o campo opcode
	li	$t9, 2 # 2 = instrucao tipo i
	
	if_beq:
		beq 	$t2, 0x04, beq_printar     # opcode 0x04 - beq
	else_if_bne:
    		beq 	$t2, 0x05, bne_printar     # opcode 0x05 - bne
    	else_if_addi:
    		beq 	$t2, 0x08, addi_printar     # opcode 0x08 - addi	
    	else_if_lw:
    		beq 	$t2, 0x23, lw_printar      # opcode 0x23 - lw
    	else_if_sw:
    		beq 	$t2, 0x2b, sw_printar      # opcode 0x2b - sw
    	else_if_lui:
    		beq 	$t2, 0x0f, lui_printar     # opcode 0x0f - lui
    	else_if_andi:
    		beq 	$t2, 0x0c, andi_printar    # opcode 0x0c - andi
    	else_if_ori:
    		beq 	$t2, 0x0d, ori_printar     # opcode 0x0d - ori
    	else_if_slti:
    		beq 	$t2, 0x0a, slti_printar    # opcode 0x0a - slti
    	else_if_sltiu:
    		beq 	$t2, 0x0b, sltiu_printar   # opcode 0x0b - sltiu
    	else_if_addiu:
    		beq	$t2, 0x09, addiu_printar   # opcode 0x09 - addiu
        	j	else_instrucao_desconhecida

#################################
instrucao_desconhecida: # mostre uma mensagem de erro se a instrucao nao foi reconhecida
	la	$a0, str_instrucao_desconhecida
	li	$v0, 4
	syscall 
	
	j	rp_for_incremento
	
add_printar: 
    	la 	$a0, add_instrucao
    	li 	$v0, 4
    	syscall
    	
    	j	while_printar_registradores

addiu_printar:
	li 	$t9, 	5 # 5 para a instrução addiu
	la 	$a0, addiu_instrucao
    	li 	$v0, 4
    	syscall
    	
    	j	while_printar_registradores
addu_printar:
	la 	$a0, addu_instrucao
    	li 	$v0, 4
    	syscall
    	
    	j	while_printar_registradores
addi_printar:
	la 	$a0, addi_instrucao
    	li 	$v0, 4
    	syscall
    	
    	j	while_printar_registradores
    	
sub_printar:
    	la 	$a0, sub_instrucao
    	li 	$v0, 4
    	syscall

    	j	while_printar_registradores
    	
and_printar:
    	la 	$a0, and_instrucao
    	li 	$v0, 4
    	syscall

    	j	while_printar_registradores
    	
or_printar:
    	la 	$a0, or_instrucao
    	li 	$v0, 4
    	syscall

    	j	while_printar_registradores
    	
nor_printar:
    	la 	$a0, nor_instrucao
    	li 	$v0, 4
    	syscall

    	j	while_printar_registradores
    	
mul_printar:
    	la 	$a0, mul_instrucao 
    	li 	$v0, 4
    	syscall

    	j	while_printar_registradores
	
sll_printar:
    	la 	$a0, sll_instrucao
    	li 	$v0, 4
    	syscall

    	j	while_printar_registradores
    	
srl_printar:
    	la 	$a0, srl_instrucao
    	li 	$v0, 4
    	syscall

    	j	while_printar_registradores
    	
slt_printar:
    	la 	$a0, slt_instrucao
    	li 	$v0, 4
    	syscall

    	j	while_printar_registradores
    	
jr_printar:
	li	$t9, 3 # para a instrucao jr
	
    	la 	$a0, jr_instrucao
    	li 	$v0, 4
    	syscall

    	j	while_printar_registradores
    	
beq_printar:
	li 	$t9, 4 # para a instrucao beq ou bne
	
    	la 	$a0, beq_instrucao
    	li 	$v0, 4
    	syscall

    	j	while_printar_registradores
    	
bne_printar:
	li 	$t9, 4 # para a instrucao beq ou bne
	
    	la 	$a0, bne_instrucao
    	li 	$v0, 4
   	syscall

    	j	while_printar_registradores
    	
lw_printar:
    	la 	$a0, lw_instrucao
    	li 	$v0, 4
    	syscall

    	j	while_printar_registradores
    	
sw_printar:
    	la 	$a0, sw_instrucao
    	li 	$v0, 4
    	syscall

    	j	while_printar_registradores
    	
lui_printar:
   	la 	$a0, lui_instrucao
    	li 	$v0, 4
    	syscall

    	j	while_printar_registradores
andi_printar:
    	la 	$a0, andi_instrucao
    	li 	$v0, 4
    	syscall

    	j	while_printar_registradores
    	
ori_printar:
    	la 	$a0, ori_instrucao
    	li 	$v0, 4
    	syscall

    	j	while_printar_registradores
slti_printar:
    	la 	$a0, slti_instrucao
    	li 	$v0, 4
    	syscall

    	j	while_printar_registradores
    	
sltiu_printar:
    	la 	$a0, sltiu_instrucao
    	li 	$v0, 4
    	syscall

    	j	while_printar_registradores
    	
j_printar:
    	la 	$a0, j_instrucao
    	li 	$v0, 4
    	syscall

    	j	printar_endereco
    	
jal_printar:
    	la 	$a0, jal_instrucao
    	li 	$v0, 4
    	syscall

    	j	printar_endereco
    	
syscall_printar:
	la 	$a0, syscall_instrucao
    	li 	$v0, 4
    	syscall

    	j	rp_for_incremento
    	

################################
while_printar_registradores:
	li 	$t5, 0 # T5 é um iterador para saber quantos registradores ou imn foram printados
	
	beq	$t9, 1, printar_registrador_rd # caso seja uma instrucao tipo r, vai printar rd, rs, rt
	beq	$t9, 2, printar_registrador_rt # caso seja uma instrucao tipo i, vai printar rt, imn, rs
	beq	$t9, 3, printar_registrador_rs # caso seja a instucao jr, vai printar rs
	beq	$t9, 4, printar_registrador_rs # caso seja a instucao beq ou bne, vai printar rt, imn, rs
	beq	$t9, 5, printar_registrador_rt # caso seja a instucao addiu, vai printar rt, rs, imn
	j	instrucao_desconhecida
	
	printar_registrador_rd:
		addi	$t5, $t5, 1 # iterador++
		
		ll	$v0, rd #printe o primeiro registrador da instrucao do tipo r		

		beq	$t8, 0, zero_printar		# if $t8 == $zero
		beq	$t8, 1, at_printar		# if $t8 == $at
		beq	$t8, 2, v0_printar		# if $t8 == $v0
		beq	$t8, 3, v1_printar		# if $t8 == $v1
		beq	$t8, 4, a0_printar		# if $t8 == $a0
		beq	$t8, 5, a1_printar		# if $t8 == $a1
		beq	$t8, 6, a2_printar		# if $t8 == $a2
		beq	$t8, 7, a3_printar		# if $t8 == $a3
		beq	$t8, 8, t0_printar		# if $t8 == $t0
		beq	$t8, 9, t1_printar		# if $t8 == $t1
		beq	$t8, 10, t2_printar		# if $t8 == $t2
		beq	$t8, 11, t3_printar		# if $t8 == $t3
		beq	$t8, 12, t4_printar		# if $t8 == $t4
		beq	$t8, 13, t5_printar		# if $t8 == $t5
		beq	$t8, 14, t6_printar		# if $t8 == $t6
		beq	$t8, 15, t7_printar		# if $t8 == $t7
		beq	$t8, 16, s0_printar		# if $t8 == $s0
		beq	$t8, 17, s1_printar		# if $t8 == $s1
		beq	$t8, 18, s2_printar		# if $t8 == $s2
		beq	$t8, 19, s3_printar		# if $t8 == $s3
		beq	$t8, 20, s4_printar		# if $t8 == $s4
		beq	$t8, 21, s5_printar		# if $t8 == $s5
		beq	$t8, 22, s6_printar		# if $t8 == $s6
		beq	$t8, 23, s7_printar		# if $t8 == $s7
		beq	$t8, 24, t8_printar		# if $t8 == $t8
		beq	$t8, 25, t9_printar		# if $t8 == $t9
		beq	$t8, 26, k0_printar		# if $t8 == $k0
		beq	$t8, 27, k1_printar		# if $t8 == $k1
		beq	$t8, 28, gp_printar		# if $t8 == $gp
		beq	$t8, 29, sp_printar		# if $t8 == $sp
		beq	$t8, 30, fp_printar		# if $t8 == $fp
		beq	$t8, 31, ra_printar		# if $t8 == $ra
				
	printar_registrador_rs:
		addi	$t5, $t5, 1 # iterador++
		
		ll	$t8, rs # printe o primeiro registrador da instrução do tipo i
		
		beq	$t8, 0, zero_printar		# if $t8 == $zero
		beq	$t8, 1, at_printar		# if $t8 == $at
		beq	$t8, 2, v0_printar		# if $t8 == $v0
		beq	$t8, 3, v1_printar		# if $t8 == $v1
		beq	$t8, 4, a0_printar		# if $t8 == $a0
		beq	$t8, 5, a1_printar		# if $t8 == $a1
		beq	$t8, 6, a2_printar		# if $t8 == $a2
		beq	$t8, 7, a3_printar		# if $t8 == $a3
		beq	$t8, 8, t0_printar		# if $t8 == $t0
		beq	$t8, 9, t1_printar		# if $t8 == $t1
		beq	$t8, 10, t2_printar		# if $t8 == $t2
		beq	$t8, 11, t3_printar		# if $t8 == $t3
		beq	$t8, 12, t4_printar		# if $t8 == $t4
		beq	$t8, 13, t5_printar		# if $t8 == $t5
		beq	$t8, 14, t6_printar		# if $t8 == $t6
		beq	$t8, 15, t7_printar		# if $t8 == $t7
		beq	$t8, 16, s0_printar		# if $t8 == $s0
		beq	$t8, 17, s1_printar		# if $t8 == $s1
		beq	$t8, 18, s2_printar		# if $t8 == $s2
		beq	$t8, 19, s3_printar		# if $t8 == $s3
		beq	$t8, 20, s4_printar		# if $t8 == $s4
		beq	$t8, 21, s5_printar		# if $t8 == $s5
		beq	$t8, 22, s6_printar		# if $t8 == $s6
		beq	$t8, 23, s7_printar		# if $t8 == $s7
		beq	$t8, 24, t8_printar		# if $t8 == $t8
		beq	$t8, 25, t9_printar		# if $t8 == $t9
		beq	$t8, 26, k0_printar		# if $t8 == $k0
		beq	$t8, 27, k1_printar		# if $t8 == $k1
		beq	$t8, 28, gp_printar		# if $t8 == $gp
		beq	$t8, 29, sp_printar		# if $t8 == $sp
		beq	$t8, 30, fp_printar		# if $t8 == $fp
		beq	$t8, 31, ra_printar		# if $t8 == $ra


	printar_registrador_rt:
		addi	$t5, $t5, 1 # iterador++
		
		ll	$t8, rt # imprima o registrador da instrucao jr
		
		beq	$t8, 0, zero_printar		# if $t8 == $zero
		beq	$t8, 1, at_printar		# if $t8 == $at
		beq	$t8, 2, v0_printar		# if $t8 == $v0
		beq	$t8, 3, v1_printar		# if $t8 == $v1
		beq	$t8, 4, a0_printar		# if $t8 == $a0
		beq	$t8, 5, a1_printar		# if $t8 == $a1
		beq	$t8, 6, a2_printar		# if $t8 == $a2
		beq	$t8, 7, a3_printar		# if $t8 == $a3
		beq	$t8, 8, t0_printar		# if $t8 == $t0
		beq	$t8, 9, t1_printar		# if $t8 == $t1
		beq	$t8, 10, t2_printar		# if $t8 == $t2
		beq	$t8, 11, t3_printar		# if $t8 == $t3
		beq	$t8, 12, t4_printar		# if $t8 == $t4
		beq	$t8, 13, t5_printar		# if $t8 == $t5
		beq	$t8, 14, t6_printar		# if $t8 == $t6
		beq	$t8, 15, t7_printar		# if $t8 == $t7
		beq	$t8, 16, s0_printar		# if $t8 == $s0
		beq	$t8, 17, s1_printar		# if $t8 == $s1
		beq	$t8, 18, s2_printar		# if $t8 == $s2
		beq	$t8, 19, s3_printar		# if $t8 == $s3
		beq	$t8, 20, s4_printar		# if $t8 == $s4
		beq	$t8, 21, s5_printar		# if $t8 == $s5
		beq	$t8, 22, s6_printar		# if $t8 == $s6
		beq	$t8, 23, s7_printar		# if $t8 == $s7
		beq	$t8, 24, t8_printar		# if $t8 == $t8
		beq	$t8, 25, t9_printar		# if $t8 == $t9
		beq	$t8, 26, k0_printar		# if $t8 == $k0
		beq	$t8, 27, k1_printar		# if $t8 == $k1
		beq	$t8, 28, gp_printar		# if $t8 == $gp
		beq	$t8, 29, sp_printar		# if $t8 == $sp
		beq	$t8, 30, fp_printar		# if $t8 == $fp
		beq	$t8, 31, ra_printar		# if $t8 == $ra
		

printar_valor_imn:
	addi	$t5, $t5, 1 # iterador++
	
	ll	$a0, valor_imediato
	li	$v0, 34
	syscall
	
	j	caracteres_especiais

printar_endereco_imn:
	addi	$t5, $t5, 1 # iterador++
	
	ll	$t7, valor_imediato
	sll 	$t7, $t7, 2 # desloque 2 bits a esquerda do valor imediato
	
	ll	$t6, pc
	add	$t6, $t6, 4 #some 4 ao pc
	
	add	$t4, $t6, $t7 # endereço da instrução alvo 
	
	sub	$a0, $t4, $t6 # endereço da instrução alvo - pc + 4
	div	$a0, $a0, 4 # divida por 4 para obter o endereço do desvio condicional
	
	li	$v0, 34
	syscall
	
	j	rp_for_incremento

printar_endereco:
# tem que terminar de calcular este valor
	addi	$t5, $t5, 1
	
	ll	$t6, pc
	addi	$t6, $t6, 4 # pc + 4
	li	$t4, 0xf0000000 # mascaara dos 4 bits mais significativos
	and	$t6, $t6, $t4 # faça uma and do pc +4 e mantenha os 4 bits mais significativos
	
	ll	$t7, endereco_imediato
	#sll	$t7, $t7, 2 # faça um deslocamoento logico a esquera de 2 bits
	
	or	$a0, $t6, $t7 # descubra o endereço
	li	$v0, 34
	syscall
	
	j	rp_for_incremento

zero_printar:
	la	$a0, zero
	li	$v0, 4
	syscall
	j	caracteres_especiais

at_printar:
	la	$a0, at
	li	$v0, 4
	syscall
	j	caracteres_especiais

v0_printar:
	la	$a0, v0
	li	$v0, 4
	syscall
	j	caracteres_especiais

v1_printar:
	la	$a0, v1
	li	$v0, 4
	syscall
	j	caracteres_especiais

a0_printar:
	la	$a0, a0
	li	$v0, 4
	syscall
	j	caracteres_especiais

a1_printar:
	la	$a0, a1
	li	$v0, 4
	syscall
	j	caracteres_especiais

a2_printar:
	la	$a0, a2
	li	$v0, 4
	syscall
	j	caracteres_especiais

a3_printar:
	la	$a0, a3
	li	$v0, 4
	syscall
	j	caracteres_especiais

t0_printar:
	la	$a0, t0
	li	$v0, 4
	syscall
	j	caracteres_especiais

t1_printar:
	la	$a0, t1
	li	$v0, 4
	syscall
	j	caracteres_especiais

t2_printar:
	la	$a0, t2
	li	$v0, 4
	syscall
	j	caracteres_especiais

t3_printar:
	la	$a0, t3
	li	$v0, 4
	syscall
	j	caracteres_especiais

t4_printar:
	la	$a0, t4
	li	$v0, 4
	syscall
	j	caracteres_especiais

t5_printar:
	la	$a0, t5
	li	$v0, 4
	syscall
	j	caracteres_especiais

t6_printar:
	la	$a0, t6
	li	$v0, 4
	syscall
	j	caracteres_especiais

t7_printar:
	la	$a0, t7
	li	$v0, 4
	syscall
	j	caracteres_especiais

s0_printar:
	la	$a0, s0
	li	$v0, 4
	syscall
	j	caracteres_especiais

s1_printar:
	la	$a0, s1
	li	$v0, 4
	syscall
	j	caracteres_especiais

s2_printar:
	la	$a0, s2
	li	$v0, 4
	syscall
	j	caracteres_especiais

s3_printar:
	la	$a0, s3
	li	$v0, 4
	syscall
	j	caracteres_especiais

s4_printar:
	la	$a0, s4
	li	$v0, 4
	syscall
	j	caracteres_especiais

s5_printar:
	la	$a0, s5
	li	$v0, 4
	syscall
	j	caracteres_especiais

s6_printar:
	la	$a0, s6
	li	$v0, 4
	syscall
	j	caracteres_especiais

s7_printar:
	la	$a0, s7
	li	$v0, 4
	syscall
	j	caracteres_especiais

t8_printar:
	la	$a0, t8
	li	$v0, 4
	syscall
	j	caracteres_especiais

t9_printar:
	la	$a0, t9
	li	$v0, 4
	syscall
	j	caracteres_especiais

k0_printar:
	la	$a0, k0
	li	$v0, 4
	syscall
	j	caracteres_especiais

k1_printar:
	la	$a0, k1
	li	$v0, 4
	syscall
	j	caracteres_especiais

gp_printar:
	la	$a0, gp
	li	$v0, 4
	syscall
	j	caracteres_especiais

sp_printar:
	la	$a0, sp
	li	$v0, 4
	syscall
	j	caracteres_especiais

fp_printar:
	la	$a0, fp
	li	$v0, 4
	syscall
	j	caracteres_especiais

ra_printar:
	la	$a0, ra
	li	$v0, 4
	syscall
	j	caracteres_especiais

caracteres_especiais:
	beq	$t9, 3, rp_for_incremento # se a instrução for jr, ele já printou o rs e vai para a próxima instrução
	
	beq	$t5, 1, printar_virgula # printou o primeiro registrador e printa a vírgula em seguida 
	beq	$t5, 2, abrir_parentestes_ou_virgula
	beq	$t5, 3, fechar_parentestes_incrementar
	
	abrir_parentestes_ou_virgula: 
		bne	$t9, 2, printar_virgula
		
	printar_abrir_parenteses:
		la	$a0, abre_parenteses
		li	$v0, 4
		syscall
		
		j 	while_condicao
	
	printar_virgula:
		la	$a0, virgula
		li	$v0, 4
		syscall
		
		j 	while_condicao
	
	fechar_parentestes_incrementar:
		bne	$t9, 2, while_condicao
		
		la	$a0, fecha_parenteses
		li	$v0, 4
		syscall
		

while_condicao: 
	beq	$t5, 1, printar_segundo_elemento 
	beq	$t5, 2, printar_terceiro_elemento
	beq	$t5, 3, rp_for_incremento
	
	printar_segundo_elemento:
		beq	$t9, 1, printar_registrador_rs
		beq	$t9, 2, printar_valor_imn
		beq	$t9, 4, printar_registrador_rt
		beq	$t9, 5, printar_registrador_rs
	
	printar_terceiro_elemento:
		beq	$t9, 1, printar_registrador_rt
		beq	$t9, 2, printar_registrador_rs
		beq	$t9, 4, printar_endereco_imn
		beq	$t9, 5, printar_valor_imn


#########################################################################################################
rp_for_incremento:
# faca o ingcremento das variaveis do laco for
	li	$a0, 10 #imprimma \n
	li	$v0, 11
	syscall
	
            addiu   	$s0, $s0, 4             # incrementamos o número do campo
            
            ll      	$s1, pc	# incrementamos o endereco do programa, que inicia em 0x00400000
            add 	$s1, $s1, 4
            sw 	$s1, pc
            
rp_for_condicao:
# teste a condicao do laco de repeticao
            slti    	$t0, $s0, 4             # $t0 = 1 se existem campos a serem apresentados
            bne     	$t0, $zero, rp_for_codigo # apresenta o campo
            
# epílogo
            lw	$s0, 0($sp)             # restauramos $s0
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
# fechamento do arquivo quanado terminar o programa
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
str_instrucao_desconhecida: .asciiz "[ERRO] Erro instrucão desconhecida"

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
pc: 		.word 0x00400000

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

mul_instrucao:	.asciiz "mul "
syscall_instrucao: 	.asciiz "syscall"
add_instrucao:	.asciiz "add "
addiu_instrucao:	.asciiz "addiu "
addu_instrucao:	.asciiz "addu "
addi_instrucao:	.asciiz "addi "
sub_instrucao:	.asciiz "sub "
and_instrucao:	.asciiz "and "
or_instrucao:	.asciiz "or "
nor_instrucao:	.asciiz "nor "
sll_instrucao:	.asciiz "sll "
srl_instrucao:	.asciiz "srl "
slt_instrucao:	.asciiz "slt "
jr_instrucao:	.asciiz "jr "
beq_instrucao:	.asciiz "beq "
bne_instrucao:	.asciiz "bne "
lw_instrucao:	.asciiz "lw "
sw_instrucao:	.asciiz "sw "
lui_instrucao:	.asciiz "lui "
andi_instrucao:	.asciiz "andi "
ori_instrucao:	.asciiz "ori "
slti_instrucao:	.asciiz "slti "
sltiu_instrucao:	.asciiz "sltiu "
j_instrucao:	.asciiz "j "
jal_instrucao:	.asciiz "jal "

abre_parenteses: 	.asciiz "("
fecha_parenteses:	.asciiz ")"
virgula:		.asciiz ", "


