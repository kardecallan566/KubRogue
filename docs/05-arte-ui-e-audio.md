# 05 — Direção artística, arena, interface, acessibilidade e som

## 1. Direção geral

**Fantasia de brinquedos de mesa:** cubos 3D brilhantes, bordas arredondadas, adesivos coloridos com leve volume, mão estilizada, cenário limpo e efeitos de organização. Personalidade original: estúdio de cubos/magia geométrica, não mineração, pedras, picareta, destruição ou violência.

**Tom:** lúdico, satisfatório, colorido, com feedback forte mas sem poluição de partículas.

## 2. Mapa principal: Jardim dos Cubos

O cenário segue o **princípio espacial de King of Pickaxe**: campo gramado aberto, tons verde-pastel, manchas suaves, poucos tufos pequenos e **muito espaço negativo** para destacar os cubos. A arte é autoral, nunca extraída da referência.

- **Sem plataforma circular**, borda, muro, cerca, labirinto, árvores altas ou tile-grid.
- Piso 3D fosco que **extrapola a tela**, porém área útil invisível limitada ao enquadramento. Não prometer mundo infinito.
- Câmera **ortográfica fixa**, próxima da vertical (15–25° fora do topo), com volume suficiente para ver camadas 3D.
- Cubos surgem em anel periférico visível, com distância segura da mão, HUD e outros cubos. Antes da elite da onda 5, reservar o quarto slot.
- Sombras de contato suaves, vegetação sem colisão e manchas de cor original; luz muda discretamente nas ondas, sem troca de mapa.
- Interface periférica legível e feedback concentrado na mão/cubos, não no cenário.
- Avaliar 720p, 1080p, 16:10, densidade da folhagem e FPS com 4 atores.

Especificação integral e critérios de teste: [11 — Mapa aberto](11-mapa-campo-aberto-e-camera.md).

## 3. Cubos

- Cores clássicas ou paleta própria de alto contraste; consistência de faces obrigatória.
- Material tipo plástico com reflexo discreto e chanfro para capturar luz sem parecer vidro.
- Inicialmente embaralhado, cada cubo mostra mistura visível de cores.
- Ao selecionar: contorno de baixa espessura + sombra realçada; ao girar: trilha curta de brilho no eixo; ao concluir: flash suave, adesivos alinhados, pequena elevação e desaparecimento por escala/opacidade.
- Reforçado: aro/placa ou moldura diferente e movimentos mais numerosos; não apenas recolorir o cubo.
- Elite 3x3: entrada com título curto e escala levemente maior; 26 cubinhos visíveis com giro por camada correto; evidência visual clara de que é mais complexo.
- Jamais esconder um cubo atrás do número de moedas ou das cartas.

## 4. Mão protagonista

- Mão estilizada flutuante em 3D, com silhueta reconhecível contra cubos.
- Estado neutro: ligeira inclinação acompanhando movimento do mouse.
- Estado hover: dedos se preparam; cursor/contorno sinaliza cubo alcançável.
- Estado ação: giro de punho e toque de dedo sincronizados com o movimento da camada.
- Estado cooldown: retorno elástico leve; não usar animação longa que atrase controles.
- Estado vitória: gesto alegre curto.
- Evolução visual opcional mínima: brilho/tom da luva com carta ativa, sem depender disso para entendimento.

Não usar uma mão humana realista altamente detalhada que ocupe demais a tela. Dimensão e transparência devem evitar cobrir a informação do cubo.

## 5. Feedback obrigatório

| Evento | Visual | Som |
|---|---|---|
| Passar sobre cubo | Outline e contador | Som discreto opcional |
| Giro válido | Rotação da camada e pulso da mão | Clique mecânico curto, com variação leve |
| Giro extra da carta | Dois giros visíveis e brilho distinto | Segundo clique diferente |
| Cubo concluído | Estado uniforme + partículas + “+moedas” | Acorde breve recompensador |
| XP/nível | Barra cresce e pulsa | Sinal suave de evolução |
| Últimos 10 s | Relógio enfatizado, sem tremer tela | Tique leve com opção reduzir |
| Erro/expiração | Cubo some com aviso e estabilidade reduz | Tom de atenção, não estridente |
| Vitória final | Congelamento breve, confete controlado | Fanfarrinha própria curta |

Implementar screen shake desligável e partículas configuráveis; o jogador deve conseguir ler alvos mesmo na pior combinação de habilidades.

## 6. HUD em jogo (16:9 base)

- **Superior esquerdo:** onda atual (ex.: 2/5), timer e contador “resolvidos / previstos”.
- **Superior centro:** estabilidade (0–100 ou 0–115), com cor + número + ícone; não depender apenas de cor.
- **Superior direito:** moedas ganhas na run e ícone de carteira; tooltip deixa claro que ficam salvas.
- **Inferior esquerdo:** barra de XP e nível.
- **Inferior direito:** lista compacta das habilidades ativas, expansível ao clicar; botão de pausa acessível.
- **Próximo ao cubo em foco:** movimentos restantes, valor de moedas e marca de seleção.
- **Centro:** somente notificações efêmeras de level-up, fim de onda e elite; não colocar elementos fixos cobrindo cubos.

Escalar fontes e layout para 1280x720 e 1920x1080 sem sobreposição. HUD usa container responsivo e margem segura; no futuro, suportar 16:10 e 21:9.

## 7. Menus principais

**Hub:** título KubRogue, destaque de Jogar, total de moedas, atalhos de Loja e Configurações; apresentação discreta de um cubo giratório ao fundo.

**Loja:** três cards alinhados com nome, descrição numérica, nível 0–3, custo do próximo nível e indicação de máximo. Exibir saldo antes e depois; compras exigem confirmação somente se teste indicar clique acidental frequente, com botão desativado quando insuficiente.

**Resumo da run:** resultado, onda alcançada, cubos resolvidos, ganho de moedas, melhor combo, tempo e sugestões de evolução. Reiniciar não deve comprar upgrades sozinho.

## 8. Acessibilidade e UX

- Interface legível em 720p; tamanho de texto configurável ou no mínimo confortável.
- Paleta para daltônicos: símbolos/texturas pequenas nos adesivos como opção, e status por ícone + texto.
- Desativar tremor, reduzir partículas, alternar pós-processamento.
- Volume separado para música, UI e efeitos.
- Pausa real; evitar contagem regressiva enquanto uma janela modal está ativa.
- Clique/segurar em vez de exigir frenéticas sacudidas do mouse.
- Opções de câmera sensíveis a movimento (menos inclinação, sem zoom animado agressivo).
- Confirmar saída de run, explicar que moedas já ganhas são preservadas.
- Foco de teclado visível nas telas de menu, mesmo que mouse seja principal no combate.

## 9. Pipeline de arte e áudio

- Preferir meshes e materiais reutilizáveis; importação .glb/.gltf; efeitos simples de partículas Godot.
- Uma única paleta e design token central para fontes, espaçamentos, tons e ícones.
- Objetos 3D devem ter LOD ou pooling se contagem crescer; no MVP limite 4 cubos ativos reduz pressão.
- SFX: giro 2–3 variações, solução, moeda, level-up, expiração, erro, UI e conclusão; música em loop tranquila com camada mais intensa na elite.
- Assets próprios ou com licença apropriada (documentar autor, origem, permissão e atribuição).

## 10. Checklist visual de aceite

- Usuário diferencia visualmente aprendiz, reforçado e elite sem ler texto.
- Em cada solução há ao menos um giro de camada fisicamente convincente.
- Mão não cobre integralmente o cubo.
- Todos os valores relevantes permanecem legíveis com muitos efeitos.
- Nunca reaproveitar modelos, gráficos, sons, screenshots ou logotipos de King of Pickaxe.

## 11. Microinterações obrigatórias

Cada giro tem gesto da mão, rotação **válida de camada**, snap e som de plástico; solução revela faces uniformes antes da recompensa em moedas/XP separadas. As oito habilidades sinalizam efeitos sem esconder cores dos cubos. O roteiro visual, auditivo e de câmera está em [12 — Gamefeel](12-gamefeel-eventos-visuais-e-detalhamento.md).
