programa
{
	inclua biblioteca Graficos --> g
	inclua biblioteca Teclado --> t
	inclua biblioteca Util --> u
	inclua biblioteca Tipos --> tp
	inclua biblioteca Sons --> s

	// CONFIG
	const inteiro LARGURA_TELA = 800, ALTURA_TELA = 600
	const cadeia DIR_GRAFICOS = "./graficos"
	const cadeia DIR_SONS = "./sons"

	// DEBUG
	const logico DEBUG = falso
	real fps = 0.0
	
	// FPS
	const inteiro FPS = 60
	inteiro taxa_quadro_alvo = (1000 / FPS)
	inteiro tempo_ultimo_quadro = 0

	// ESTADO DO JOGO
	logico fim_jogo = falso
	logico fim_execucao = falso
	const real TAMANHO_TEXTO_FIM_JOGO = 32.0
	const inteiro POSICAO_TEXTO_FIM_JOGO = 300
	
	// CENÁRIO
	const inteiro ALTURA_CHAO = 400

	// DINO
	const inteiro ALTURA_DINO = 88
	const inteiro LARGURA_DINO = 94
	const inteiro DIMENSAO_COLISAO_DINO = 60
	const inteiro POSICAO_X_DINO_INICIAL = 50
	const inteiro FATOR_ANIMACAO_DINO = 15
	inteiro posicao_x_dino = POSICAO_X_DINO_INICIAL, posicao_y_dino = ALTURA_CHAO - ALTURA_DINO
	logico pulando = falso
	const inteiro ALTURA_MAXIMA_PULO = 100
	const inteiro VELOCIDADE_PULO = 850
	const inteiro VELOCIDADE_QUEDA = 450
	logico colidindo = falso
	inteiro grafico_dino_pulando = 0
	inteiro grafico_dino_caminhando = 0
	inteiro enquadramento_animacao_dino = 0

	// OBSTÁCULO
	const inteiro ALTURA_OBSTACULO = 50
	const inteiro LARGURA_OBSTACULO = 25
	const inteiro POSICAO_X_OBSTACULO_LIMITE = -20
	const inteiro VELOCIDADE_INICIAL_OBSTACULO = 150
	const inteiro INTERVALO_AUMENTO_VELOCIDADE = 200
	const inteiro FATOR_AUMENTO_VELOCIDADE = 50
	inteiro posicao_x_obstaculo = LARGURA_TELA
	inteiro posicao_y_obstaculo = ALTURA_CHAO - ALTURA_OBSTACULO + 6
	inteiro velocidade_obstaculo = VELOCIDADE_INICIAL_OBSTACULO
	inteiro grafico_obstaculo = 0

	// PONTUAÇÃO
	inteiro pontuacao = 0
	const inteiro POSICAO_X_PONTUACAO = 750
	const inteiro POSICAO_Y_PONTUACAO = 25
	const real TAMANHO_TEXTO_PONTUACAO = 18.0

	// SONS
	inteiro som_pulo = 0
	inteiro som_colisao = 0
	
	funcao inicio()
	{	
		inicializa_jogo()

		// laço principal
		enquanto(nao fim_execucao) {
			le_entrada_usuario()
			atualiza()
			desenha()
		}

		finalizar()
	}

	// FPS
	funcao sincroniza_taxa_quadro() {
		enquanto (u.tempo_decorrido() < (tempo_ultimo_quadro + taxa_quadro_alvo)) {
			
		}
	}

	// INÍCIO FUNÇÕES DE CONFIGURAÇÃO
	funcao inicializa_jogo() {
		tempo_ultimo_quadro = u.tempo_decorrido()
		cria_janela()
		carrega_imagens()
		carrega_sons()
	}

	funcao cria_janela() {
		g.iniciar_modo_grafico(falso) // parâmetro manter_visivel não funciona
		g.definir_dimensoes_janela(LARGURA_TELA, ALTURA_TELA)
		g.definir_titulo_janela("Jogo do Dino")
	}

	funcao carrega_imagens() {
		grafico_dino_caminhando = g.carregar_imagem(DIR_GRAFICOS + "/sprites_dino.png")		
		grafico_dino_pulando = g.carregar_imagem(DIR_GRAFICOS + "/sprite_dino_parado.png")
		grafico_obstaculo = g.carregar_imagem(DIR_GRAFICOS + "/sprite_obstaculo.png")
	}

	
	funcao carrega_sons() {
		som_pulo = s.carregar_som(DIR_SONS + "/som_pulo.wav")
		som_colisao = s.carregar_som(DIR_SONS + "/som_colisao.wav")
	}
	
	funcao reiniciar_jogo() {
		// restaura variáveis do dino
		posicao_x_dino = POSICAO_X_DINO_INICIAL
		posicao_y_dino = ALTURA_CHAO - ALTURA_DINO
		pulando = falso
		colidindo = falso

		// restaura variáveis do obstáculo
		posicao_x_obstaculo = LARGURA_TELA
		velocidade_obstaculo = VELOCIDADE_INICIAL_OBSTACULO

		// restaura pontuação
		pontuacao = 0

		// restaura estado do jogo
		fim_jogo = falso
	}

	funcao finalizar() {
		liberar_imagens()
		g.encerrar_modo_grafico()
		s.liberar_som(som_pulo)
		s.liberar_som(som_colisao)
	}

	funcao liberar_imagens() {
		g.liberar_imagem(grafico_dino_pulando)
		g.liberar_imagem(grafico_dino_caminhando)
		g.liberar_imagem(grafico_obstaculo)
	}
	// FIM FUNÇÕES DE CONFIGURAÇÃO

	// INÍCIO FUNÇÕES DO LAÇO PRINCIPAL
	funcao le_entrada_usuario() {
		se (t.tecla_pressionada(t.TECLA_ESC)) {	
			fim_execucao = verdadeiro
		}

		se (nao fim_jogo e t.tecla_pressionada(t.TECLA_ESPACO) e dino_no_chao()) {
			pula()
		} senao se (fim_jogo e t.tecla_pressionada(t.TECLA_ESPACO)) {
			reiniciar_jogo()
		}
	}

	funcao atualiza() {
		sincroniza_taxa_quadro()
		real delta = (u.tempo_decorrido() - tempo_ultimo_quadro) / 1000.0
		tempo_ultimo_quadro = u.tempo_decorrido()

		se (nao colidindo) {
			atualiza_dino(delta)
	
			atualiza_obstaculo(delta)

			verifica_colisao()

			aumenta_pontuacao()

			aumenta_velocidade_obstaculo()
	
			se (DEBUG) {
				fps = 1.0 / delta
			}
		} senao {
			fim_jogo = verdadeiro
		}
	}

	funcao desenha() {
		// pinta fundo de branco
		g.definir_cor(g.COR_BRANCO)
		g.limpar()
		
		// desenha chão
		g.definir_cor(g.COR_PRETO)
		g.desenhar_linha(0, ALTURA_CHAO, LARGURA_TELA, ALTURA_CHAO)

		// desenha obstáculo
		g.desenhar_imagem(posicao_x_obstaculo, posicao_y_obstaculo, grafico_obstaculo)

		// desenha pontuação
		g.definir_tamanho_texto(TAMANHO_TEXTO_PONTUACAO)
		g.desenhar_texto(POSICAO_X_PONTUACAO, POSICAO_Y_PONTUACAO, tp.inteiro_para_cadeia(pontuacao, 10))
		
		se (DEBUG) {			
			g.desenhar_texto(10, 10, "FPS: " + tp.real_para_inteiro(fps))
		}
		
		desenha_dino()

		// exibe mensagem de fim de jogo
		se (fim_jogo) {
			g.definir_cor(g.COR_PRETO)
			g.definir_tamanho_texto(TAMANHO_TEXTO_FIM_JOGO)
			g.desenhar_texto(POSICAO_TEXTO_FIM_JOGO, POSICAO_TEXTO_FIM_JOGO, "FIM DE JOGO")
			g.definir_tamanho_texto(TAMANHO_TEXTO_PONTUACAO)
			g.desenhar_texto(POSICAO_TEXTO_FIM_JOGO - 50, POSICAO_TEXTO_FIM_JOGO + 50, "Aperte [ ESPAÇO ] para jogar novamente")
		}

		// renderiza o buffer
		g.renderizar()
	}
	// FIM FUNÇÕES DO LAÇO PRINCIPAL

	// INÍCIO FUNÇÕES DO DINO
	funcao logico dino_no_chao() {
		retorne posicao_y_dino == ALTURA_CHAO - ALTURA_DINO
	}

	funcao atualiza_dino(real delta) {
		se (pulando e posicao_y_dino >= ALTURA_MAXIMA_PULO) {
			posicao_y_dino -= VELOCIDADE_PULO * delta
		} senao se (posicao_y_dino < ALTURA_CHAO) {
			pulando = falso
			posicao_y_dino += VELOCIDADE_QUEDA * delta

			se (posicao_y_dino >= ALTURA_CHAO - ALTURA_DINO) {	
				posicao_y_dino = ALTURA_CHAO - ALTURA_DINO
			}
		}
	}

	funcao desenha_dino() {
		se (nao dino_no_chao()) {
			g.desenhar_imagem(posicao_x_dino, posicao_y_dino, grafico_dino_pulando)
		} senao {
			anima_dino()
			g.desenhar_porcao_imagem(posicao_x_dino, posicao_y_dino, enquadramento_animacao_dino, 0, LARGURA_DINO, ALTURA_DINO, grafico_dino_caminhando)
		}

		se (DEBUG e colidindo) {
			g.definir_cor(g.COR_VERMELHO)
			g.desenhar_retangulo(posicao_x_dino, posicao_y_dino, LARGURA_DINO, ALTURA_DINO, falso, falso)
		}
	}

	funcao anima_dino() {
		se (pontuacao % FATOR_ANIMACAO_DINO == 0) {
			se (enquadramento_animacao_dino == 0) {
				enquadramento_animacao_dino = LARGURA_DINO
			} senao {
				enquadramento_animacao_dino = 0
			}
		}
	}

	funcao pula() { 
		pulando = verdadeiro
		s.reproduzir_som(som_pulo, falso)
	}
	// FIM FUNÇÕES DO DINO
	
	// INÍCIO FUNÇÕES DO OBSTÁCULO
	funcao aumenta_velocidade_obstaculo() {
		se (pontuacao % INTERVALO_AUMENTO_VELOCIDADE == 0) {
			velocidade_obstaculo += FATOR_AUMENTO_VELOCIDADE
		}
	}

	funcao atualiza_obstaculo(real delta) {
		posicao_x_obstaculo -= velocidade_obstaculo * delta

		se (posicao_x_obstaculo < POSICAO_X_OBSTACULO_LIMITE) {
			posicao_x_obstaculo = LARGURA_TELA
		}
	}
	// FIM FUNÇÕES DO OBSTÁCULO

	// INÍCIO FUNÇÕES DE REGRAS/MECÂNICAS DO JOGO
	funcao aumenta_pontuacao() {
		pontuacao += 1
	}

	funcao verifica_colisao() {
		se (esta_colidindo(posicao_x_dino, posicao_y_dino, DIMENSAO_COLISAO_DINO, DIMENSAO_COLISAO_DINO, posicao_x_obstaculo, posicao_y_obstaculo, LARGURA_OBSTACULO, ALTURA_OBSTACULO)) {
			colidindo = verdadeiro
			s.reproduzir_som(som_colisao, falso)
		} senao {
			colidindo = falso
		}
	}

	funcao logico esta_colidindo(inteiro pos_x1, inteiro pos_y1, inteiro largura1, inteiro altura1, inteiro pos_x2, inteiro pos_y2, inteiro largura2, inteiro altura2) {
	    retorne (pos_x1 < pos_x2 + largura2) 
	    		e (pos_x1 + largura1 > pos_x2)
	    		e (pos_y1 < pos_y2 + altura2) 
	    		e (pos_y1 + altura1 > pos_y2)
	}
	// FIM FUNÇÕES DE REGRAS/MECÂNICAS DO JOGO
}
/* $$$ Portugol Studio $$$ 
 * 
 * Esta seção do arquivo guarda informações do Portugol Studio.
 * Você pode apagá-la se estiver utilizando outro editor.
 * 
 * @POSICAO-CURSOR = 349; 
 * @PONTOS-DE-PARADA = ;
 * @SIMBOLOS-INSPECIONADOS = ;
 * @FILTRO-ARVORE-TIPOS-DE-DADO = inteiro, real, logico, cadeia, caracter, vazio;
 * @FILTRO-ARVORE-TIPOS-DE-SIMBOLO = variavel, vetor, matriz, funcao;
 */