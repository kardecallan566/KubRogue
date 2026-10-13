# 00 — Visão do KubRogue

## 1. Pitch

**KubRogue** é um roguelite arcade sobre uma mão que corre contra ondas de cubos embaralhados. Em vez de acertar ou quebrar inimigos, o jogador os **organiza** num campo gramado aberto visto de cima: toca cubos, aciona rotações fisicamente reconhecíveis de suas camadas e recebe uma recompensa quando suas faces voltam ao estado uniforme. As moedas alimentam uma pequena loja permanente; a experiência libera escolhas de poderes exclusivos da partida.

**Fantasia principal:** começar resolvendo cubos simples e terminar uma partida com a mão mais rápida, efeitos de combo e capacidade de lidar com vários cubos sob pressão — sempre visualizando as peças se alinharem.

## 2. Pilares obrigatórios

1. **Prazer tátil de resolver.** Uma resolução deve sempre exibir um movimento correto das peças, clique visual/sonoro, progresso e conclusão reconhecível.
2. **Uma mão, uma interface intuitiva.** O mouse guia a mão na arena e clique/segurar aplica ações, sem exigir conhecer notação de cubo mágico.
3. **Dificuldade progressiva perceptível.** Mais movimentos, mais cubos simultâneos, variantes e pressão de tempo; não só números maiores.
4. **Escolhas roguelite reais.** O jogador seleciona uma habilidade entre três alternativas e combina efeitos ao longo da partida.
5. **Recompensa clara.** Dinheiro só entra quando o cubo está realmente resolvido. O ganho deve ser legível, com contagem, sons e feedback de combo.
6. **3D legível e otimizado.** Cada cubo parece brinquedo com adesivos coloridos, sombra, rotações reais e silhueta clara; a grama ao fundo é simples e leve.
7. **Produção controlável.** Construir uma versão simples e completa antes de multiplicar tipos de cubo, cenários e sistemas.

## 3. Público e experiência

- Pessoas que gostam de jogos casuais de mouse, sensação de upgrade e runs curtas; jogadores de cubo mágico podem apreciar a fantasia, mas não é preciso saber resolver o quebra-cabeça.
- Plataforma MVP: Windows PC; proporção-base 16:9 com escala adaptável, mouse principal; sem dependência de internet.
- Sessão-alvo inicial: **6–8 minutos** para uma run bem-sucedida, sujeita a teste.
- Idioma MVP: português brasileiro; textos centralizados para facilitar posterior tradução.
- Experiência: fofa, luminosa, satisfatória, acelerada progressivamente, evitando violência e destruição.

## 4. O que KubRogue é — e não é

**É:** ação de precisão acessível em arena, apresentação 3D de cubos, progressão roguelite, gerenciamento de alvos e resolução arcade baseada em movimentos legais.

**Não é no MVP:** simulador completo de cubo mágico com solução livre do usuário, jogo totalmente idle, clone de interfaces/arte de King of Pickaxe, plataforma multiplayer, loja com dinheiro real ou ambiente 3D de exploração.

A palavra **resolver** tem definição verificável: o estado lógico do cubo termina com todas as faces uniformes, e o jogador assistiu às rotações que levaram a esse estado. No MVP, a própria mão escolhe o próximo movimento correto; o desafio está na priorização, agilidade e construção de habilidades, não em encontrar o algoritmo.

## 5. Diferenciação em relação à inspiração

A referência fornece inspiração para **ritmo, ação por cursor, ondas e escolha de habilidades**. KubRogue deve inovar com:
- Cubos tridimensionais manipuláveis, sem pedras ou picaretas;
- Animações reais de giros de camadas, com posições/cores coerentes;
- Progressão por complexidade do embaralhamento e variantes comportamentais;
- Mão protagonista com melhorias visuais e de eficiência;
- Recompensa pelo retorno à ordem em vez de destruição.

Evitar copiar nomes de upgrades, interface, sonoplastia, design de inimigos, layout idêntico ou arquivos extraídos da referência.

## 6. Jornada emocional

**Início:** curiosidade e domínio instantâneo. **Meio:** percepção de domínio por sinergias, moedas e combos. **Final:** pressão diante de uma elite 3x3, com vitória por uma última rotação bem apresentada. **Entre runs:** usar moedas acumuladas e tentar uma combinação nova.

## 7. Promessa de produto no MVP

Ao abrir o jogo, qualquer pessoa deve entender em menos de um minuto:
1. o mouse controla a mão;
2. clicar/segurar próximo de um cubo gira uma camada em direção à solução;
3. cubos completos dão moedas e XP;
4. cubos não atendidos prejudicam a estabilidade;
5. habilidades temporárias facilitam a próxima onda.

O projeto deve ser demonstrável sem explicação verbal do desenvolvedor.

## 8. Questões já decididas e hipóteses

**Decidido para o planejamento:** cursor como controle principal, resolução arcade assistida, cinco ondas, moeda persistente e habilidades temporárias.

**Hipóteses que exigem playtest:** tamanho da área útil invisível do gramado, duração das ondas, contagem de movimentos, ritmo dos cliques, proporção 2x2/3x3, preços e qualidade da câmera. Consulte o documento 10; números não são promessas imutáveis.

**Dependências de material não recebido:** geometria, rig, formato, permissão de uso e capacidade de girar camadas do modelo 3D já existente. Não presumir compatibilidade nem importar dados inexistentes.

## 9. Visão espacial obrigatória

**Jardim dos Cubos:** campo aberto verde suave, solo sem bordas visíveis, tufos pequenos e manchas discretas. A câmera ortográfica fica quase de cima e **fixa no MVP**, enquanto a mão acompanha o cursor. Terreno grande dá sensação de continuidade, porém a área jogável tem limites lógicos invisíveis, sem mapa infinito procedural. Sem plataforma circular, muro ou grid de pisos. Inspiração no princípio de espaço livre de King of Pickaxe, com texturas e arte originais. Ver [11](11-mapa-campo-aberto-e-camera.md).

## 10. Nota de implementação C0

O modelo 3×3×3 do [Kubos](https://github.com/kardecallan566/Kubos) foi localizado no repositório do mesmo proprietário e adaptado em uma **cena técnica de inspeção** separada, com 26 cubinhos e 54 adesivos. O 2×2, a mão e o loop jogável permanecem futuros. Veja [auditoria C0](checkpoints/C0-kubos-asset-audit.md).
