# 12 — Microinterações, ritmo e detalhes que fazem KubRogue ser memorável

> Documento de direção de experiência: especifica a sensação de jogar, as microanimações, os sinais e o comportamento de elementos que **já pertencem** ao MVP. Nenhum recurso desta lista substitui um cubo lógico funcionando.

## 1. Três segundos iniciais

Ao iniciar uma run, a câmera revela o gramado aberto do Jardim dos Cubos. O cursor de mão 2D surge sob o ponteiro e se aproxima da região central e o primeiro cubo 2x2 aparece em um pulso suave no chão. O jogador deve ver instantaneamente: mão -> cubo -> movimento da camada -> alteração da cor -> recompensa. Evitar apresentação longa ou cutscene.

**Primeira regra de ouro:** uma interação nova deve ser comunicada por movimento e feedback, não por parágrafos de tutorial.

## 2. Coreografia de um toque (target 0,34 s por ação)

1. **Hover, 0–1 frame:** contorno de foco aparece; mão inclina dedos, placa simples informa “3 giros”.
2. **Input aceito:** feedback imediato mesmo que a rotação visual demore alguns frames; dedo se move, um brilho destaca a camada afetada.
3. **Giro real, ~0,22–0,30 s:** camadas giram em eixo válido; som de clique plástico levemente variado; easing rápido, não instantâneo.
4. **Encaixe:** snap discreto no último frame e pulso de adesivos; contador reduz em um.
5. **Continuidade:** se o botão continuar pressionado, próximo movimento só inicia depois do cooldown e sem sobreposição ilegal.

Em comando inválido/fora de alcance, não tocar som de sucesso nem reduzir contador; indicação breve e opcional de distância pode aparecer sem punir o jogador.

## 3. Resolver um cubo: celebração em cinco camadas

- Estado final alinhado fica legível por **pelo menos 0,15 s**.
- Um brilho percorre de dentro para fora as faces uniformes, sem mudar a cor real dos adesivos.
- Pequena elevação/salto do cubo com squash-and-stretch **apenas no nó raiz**, não nas peças internas.
- Partículas originais em quadradinhos/losangos nas seis cores, poucos e rápidos.
- Texto flutuante “Resolvido! +10 moedas” e uma indicação de “+1 XP” separada, que converge visualmente ao HUD.
- Som de conclusão com cadência agradável e sutil variação de pitch, sem ficar mais alto a cada combo.

Pagamento é do evento lógico único de solução; os efeitos **não devem criar dinheiro** nem poder disparar evento outra vez.

## 4. A mão como personagem

**Silhueta:** cursor vetorial 2D de luva/cartoon com dedos arredondados e punho curto; sem malha 3D. Ela não precisa ter rosto ou ser realista.

**Estados básicos:**
- Idle: movimento respiratório lento, totalmente subordinado ao ponteiro.
- Movimento: cursor acompanha diretamente o ponteiro no plano da tela; sem smoothing de posição ou atraso do clique.
- Hover: ponta do indicador 2D destacada e pequeno círculo; o cubo no mundo mantém seu anel de foco.
- Ação: pulso do desenho 2D do punho, sincronizado à camada 3D.
- Cooldown: breve retorno com molas suaves.
- Vitória: gesto alegre curto sem bloquear HUD.
- Derrota: desaceleração e baixar a mão, depois resumo.
- Pausa/overlay: cursor nativo aparece para interagir com menus; mão 2D não captura input.

Upgrade **Pulso ágil** pode mudar discretamente a cor do rastro, mas todo feedback de poder precisa também aparecer em números para acessibilidade.

## 5. Cubos: personalidades sem quebrar o quebra-cabeça

- **Aprendiz 2x2:** leve balanço, expressão por uma carinha em ícone flutuante acima do cubo ou no aro externo, **nunca impressa sobre um adesivo que precise girar**; sombra pequena.
- **Reforçado 2x2:** contorno duplo, aro pequeno flutuante e passos lentos; marca de “mais giros” em ícone textual.
- **Elite 3x3:** entrada de destaque, vibração curta do solo e trilha de símbolos geométricos, mantendo sticker layout real.

Movimento ambiental do corpo usa transformação do root, **independente** dos pivôs de camada; visual e lógica jamais assumem que adesivos mudaram por um balanço externo.

## 6. Pressão de onda sem virar outro gênero

- Som das mudanças de onda é agradável, curto e distinto.
- Últimos 10 segundos: relógio pulsa com número e ícone, música ganha pulsação; reduzir intensidade se modo de conforto ativo.
- Alvo reforçado exige mais giros, então a estratégia é equilibrar limpar cubos fáceis para XP e enfrentar os resistentes sem estourar o tempo.
- Aviso de estabilidade perdida: pequeno ripple na grama e número "-25", sem efeito de dano corporal.
- Elite surge cedo o suficiente para o jogador realmente tentar resolver antes do timer expirar; não nasce automaticamente só no segundo final.

O MVP NÃO simula esquiva, projéteis ou dano de contato. Se testes mostrarem pouca interação, estudar isso **depois** de provar que girar cubos é divertido.

## 7. Experiência de escolher habilidades

- Carta aparece após solução e fim de animação, com jogo pausado. Nunca enquanto um giro está no ar.
- Três opções em cards legíveis (título, ícone, efeito numérico, nível atual, descrição concisa).
- **Feedback de escolha:** pequena animação de símbolo entrando no contador de habilidade no HUD. Uma comparação “Antes -> Depois” mostra o valor modificado.
- Após confirmar, retomar pelo estado exato de timer, cubos e mão. Sem saltos de frame ou spawns retroativos.
- Se a run termina no mesmo momento do level-up, prioridade para vitória/derrota; não mostrar carta inútil no pós-jogo.

## 8. Hub com coerência visual com o campo

A hub é uma **mesa de trabalho geométrica** ou um recorte do jardim com um cubo de demonstração rodando suavemente, não um menu sci-fi. Layout principal: Jogar em destaque, saldo de moedas, Loja de melhorias, Tutorial, Configurações e Sair. Na loja, cada compra produz ação breve de um selo de papel sendo carimbado; usar efeitos baratos e originais.

Evitar a sensação de “outro jogo” entre a hub e a arena. Paleta, cantos arredondados, tipografia e sons pertencem à mesma identidade.

## 9. Mínimo de áudio e atmosfera

Áudio em camadas com volume configurável:
- Campo: loop musical leve, poucos instrumentos, clima alegre; opcionalmente vento/pássaros muito suaves.
- Movimento: clique mecânico de plástico seco, 2–3 variações de timbre.
- Solução: três notas ascendentes curtas, não estridentes.
- Moedas: estalo pequeno separado, com agrupamento em casos de solução rápida.
- Evolução: som cristalino curto, distinto do pagamento.
- Elite: batida grave curta e camada rítmica adicional, sem mudar de bioma.
- Falha: tom descendente leve, sem assustar.

Se 10 cubos forem resolvidos em poucos segundos, limitar canais/mesclar moedas para evitar cacofonia; som do giro deve continuar distinguível.

## 10. Roteiro de um clipe demonstrativo de 25–35 segundos

**0–5 s:** gramado aberto, mão aponta para primeiro 2x2. **5–10 s:** 2–4 giros visíveis, faces alinhadas e +moedas. **10–17 s:** novos cubos surgem pelo campo, a mão se desloca e escolhe alvos. **17–23 s:** oferta de 3 cartas, uma selecionada com mudança imediata no HUD. **23–30 s:** elite 3x3, rotações mais complexas, conclusão e tela “O Jardim foi organizado!”. Esse clipe descreve um *objetivo de apresentação* — não é vídeo criado nesta etapa.

## 11. Critérios de aceite de experiência

- [ ] Reconhecer um giro válido sem olhar o contador.
- [ ] Diferenciar som/feedback de giro, solução, XP e moedas.
- [ ] Animação final preserva estado lógico claramente resolvido.
- [ ] A mão não tapa a face selecionada em 720p.
- [ ] Jogar segurando o botão é confortável por pelo menos 5 min.
- [ ] Pausa, carta e fim de run não deixam efeitos soltos executando ações.
- [ ] Configurações de efeitos/redução de movimento funcionam durante uma run.
- [ ] O vídeo de demonstração pode ser gravado **com o gameplay real**, sem montagens simulando recursos ausentes.

## 12. Aprofundamentos possíveis pós-MVP

Reações do gramado ao movimento da mão, skins temáticas de luvas, skins de adesivos, novas animações de vitória, 4x4, variantes do mesmo campo em diferentes horários, modo foto e eventos ambientais; todos opcionais.

## 13. Ajuste aprovado de direção após screenshot do C1

O 2×2 deve ter **quatro adesivos contíguos em cada face**, separados apenas por uma pequena junta escura entre cubinhos de borda arredondada. Não aceitar aparência de quatro pilares ou blocos desconectados em captura, no giro ou após snap. A mão definitiva da gameplay será **2D em CanvasLayer**, de cor neutra, ponta do indicador como hotspot e aro breve ao selecionar; nunca usar mão tridimensional grande sobre os cubos. O 3×3 continua uma malha tridimensional de peças reais, e a direção espacial de Jardim dos Cubos não muda.
