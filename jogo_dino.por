programa
{
	inclua biblioteca Graficos --> g
	inclua biblioteca Teclado --> t
	inclua biblioteca Util --> u
	inclua biblioteca Tipos --> tp
	inclua biblioteca Sons --> s

	const inteiro LARGURA_DA_TELA = 800, ALTURA_DA_TELA = 600
	const logico DEBUG = verdadeiro

	const inteiro FPS = 60
	inteiro taxa_quadro_alvo = (1000 / FPS)
	inteiro tempo_ultimo_quadro = 0
	real fps = 0.0

	logico fim_jogo = falso

	const inteiro ALTURA_CHAO = 400

	const inteiro ALTURA_DINO = 80
	inteiro posicao_x_dino = 50, posicao_y_dino = ALTURA_CHAO - ALTURA_DINO
	logico pulando = falso
	const inteiro ALTURA_MAXIMA_PULO = 100
	const inteiro VELOCIDADE_PULO = 850
	const inteiro VELOCIDADE_QUEDA = 450
	inteiro grafico_dino = 0
	logico colidindo = falso

	inteiro posicao_x_obstaculo = LARGURA_DA_TELA
	inteiro velocidade_obstaculo = 150

	inteiro pontuacao = 0
	const inteiro POSICAO_X_PONTUACAO = 750
	const inteiro POSICAO_Y_PONTUACAO = 25

	// SONS
	inteiro som_pulo = 0
	inteiro som_colisao = 0

	// DEBUG
	logico anda_dir = falso
	logico anda_esq = falso
	
	funcao inicio()
	{	
		inicializa_jogo()

		enquanto(verdadeiro) {
			le_entrada_usuario()
			atualiza()
			desenha()
		}

		finalizar()
	}

	funcao inicializa_jogo() {
		cria_janela()
		carrega_imagens()
		carrega_sons()
	}

	funcao cria_janela() {
		g.iniciar_modo_grafico(verdadeiro)
		g.definir_dimensoes_janela(LARGURA_DA_TELA, ALTURA_DA_TELA)
		g.definir_titulo_janela("Jogo do Dino")
	}

	funcao carrega_imagens() {
		grafico_dino = g.carregar_imagem("./dino_sprite.png")
		grafico_dino = g.redimensionar_imagem(grafico_dino, 80, ALTURA_DINO, verdadeiro)
	}

	funcao carrega_sons() {
		som_pulo = s.carregar_som("./som_pulo.wav")
		som_colisao = s.carregar_som("./som_colisao.wav")
	}

	funcao le_entrada_usuario() {
		se (t.tecla_pressionada(t.TECLA_ESC)) {	
			fim_jogo = verdadeiro
		}

		se (t.tecla_pressionada(t.TECLA_ESPACO) e dino_no_chao()) {
			pula()
		}

		// DEBUG
		se (t.tecla_pressionada(t.TECLA_D)) {
			anda_dir = verdadeiro
		} senao {
			anda_dir = falso
		}

		se (t.tecla_pressionada(t.TECLA_A)) {
			anda_esq = verdadeiro
		} senao {
			anda_esq = falso
		}
	}

	funcao atualiza() {
		sincroniza_taxa_quadro()
		real delta = (u.tempo_decorrido() - tempo_ultimo_quadro) / 1000.0
		tempo_ultimo_quadro = u.tempo_decorrido()

		se (nao colidindo) {
			atualiza_dino(delta)
	
			atualiza_obstaculo(delta)

			se (verifica_colisao(posicao_x_dino, posicao_y_dino, 60, 60, posicao_x_obstaculo, ALTURA_CHAO - 60, 30, 60)) {
				colidindo = verdadeiro
				s.reproduzir_som(som_colisao, falso)
			} senao {
				colidindo = falso
			}
	
			pontuacao += 1
	
			se (pontuacao % 200 == 0) {
				velocidade_obstaculo += 50
			}
	
			fps = 1.0 / delta
		} senao {
			fim_jogo = verdadeiro
		}
	}

	funcao logico verifica_colisao(inteiro pos_x1, inteiro pos_y1, inteiro largura1, inteiro altura1, inteiro pos_x2, inteiro pos_y2, inteiro largura2, inteiro altura2) {
	    retorne (pos_x1 < pos_x2 + largura2) 
	    		e (pos_x1 + largura1 > pos_x2)
	    		e (pos_y1 < pos_y2 + altura2) 
	    		e (pos_y1 + altura1 > pos_y2)
	}

	funcao sincroniza_taxa_quadro() {
		enquanto (u.tempo_decorrido() < (tempo_ultimo_quadro + taxa_quadro_alvo)) {
			
		}
	}

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

		// DEBUG
		se (anda_dir) {
			posicao_x_dino += 200 * delta
		}
		se (anda_esq) {
			posicao_x_dino -= 200 * delta
		}
	}

	funcao pula() { 
		pulando = verdadeiro
		s.reproduzir_som(som_pulo, falso)
	}

	funcao desenha() {
		// pinta fundo de branco
		g.definir_cor(g.COR_BRANCO)
		g.limpar()

		// desenha dino
		g.desenhar_imagem(posicao_x_dino, posicao_y_dino, grafico_dino)

		// desenha chão
		g.definir_cor(g.COR_PRETO)
		g.desenhar_linha(0, ALTURA_CHAO, LARGURA_DA_TELA, ALTURA_CHAO)

		// desenha obstáculo
		g.desenhar_retangulo(posicao_x_obstaculo, ALTURA_CHAO - 60, 30, 60, falso, verdadeiro)

		// desenha pontuação
		g.definir_tamanho_texto(18.0)
		g.desenhar_texto(POSICAO_X_PONTUACAO, POSICAO_Y_PONTUACAO, tp.inteiro_para_cadeia(pontuacao, 10))
		
		se (DEBUG) {
			g.desenhar_texto(10, 10, "FPS: " + tp.real_para_inteiro(fps))
			g.desenhar_texto(10, 30, "Colidindo: " + tp.logico_para_cadeia(colidindo))
		}

		se (fim_jogo) {
			g.definir_tamanho_texto(32.0)
			g.desenhar_texto(300, 300, "FIM DE JOGO!")
		}
		
		g.renderizar()
	}

	funcao atualiza_obstaculo(real delta) {
		posicao_x_obstaculo -= velocidade_obstaculo * delta

		se (posicao_x_obstaculo < -20) {
			posicao_x_obstaculo = LARGURA_DA_TELA
		}
	}
	
	funcao finalizar()
	{
		liberar_imagens()
		g.encerrar_modo_grafico()

		s.liberar_som(som_pulo)
	}

	funcao liberar_imagens() {
		g.liberar_imagem(grafico_dino)
	}
}
/* $$$ Portugol Studio $$$ 
 * 
 * Esta seção do arquivo guarda informações do Portugol Studio.
 * Você pode apagá-la se estiver utilizando outro editor.
 * 
 * @POSICAO-CURSOR = 4891; 
 * @PONTOS-DE-PARADA = ;
 * @SIMBOLOS-INSPECIONADOS = ;
 * @FILTRO-ARVORE-TIPOS-DE-DADO = inteiro, real, logico, cadeia, caracter, vazio;
 * @FILTRO-ARVORE-TIPOS-DE-SIMBOLO = variavel, vetor, matriz, funcao;
 */