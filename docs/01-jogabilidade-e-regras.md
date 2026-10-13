# 01 — Jogabilidade, regras e fluxo da partida

## 1. Loop principal (segundo a segundo)

1. Cubos embaralhados surgem em posições seguras da arena com aviso visual breve.
2. Jogador move o mouse; a mão 3D segue a posição projetada sobre o plano da arena.
3. Ao pairar sobre um cubo, surge realce de alvo, indicação curta de movimentos faltantes e sua recompensa.
4. Clique esquerdo realiza **uma ação de resolução**; segurar repete no intervalo de cooldown da mão. Uma ação resolve exatamente um movimento lógico legal, salvo efeitos explicitamente sinalizados.
5. Uma face/camada gira 90° ou 180° conforme o movimento registrado. Nenhum progresso é registrado antes de a transição ser concluída.
6. Quando o estado final for resolvido, toca uma animação de conclusão: todas as faces corretas, partículas, pop-up de moedas e experiência, combo e retirada do cubo.
7. O jogador alterna alvos, aumenta a eficiência por upgrades e tenta cumprir as ondas sem perder estabilidade.

O jogador **não precisa aprender algoritmos de cubo mágico** para concluir o MVP. A mão escolhe o próximo movimento válido a partir de um caminho de solução previamente gerado.

## 2. Controle MVP

| Entrada | Ação |
|---|---|
| Movimento do mouse | Posicionar a mão, com interpolação suave curta |
| Botão esquerdo (clique) | Um movimento de solução no alvo sob a mão |
| Botão esquerdo (segurar) | Repetir movimentos após o cooldown; sem autoclique fora do alvo |
| Esc | Pausar/despausar, exibir configurações e sair com confirmação |
| Movimento sobre HUD | Não girar cubos atrás da interface |
| Sem alvo | Mão repousa e não gasta ação nem altera moedas |

Evitar exigir movimentos bruscos do mouse ou repetição muito rápida. Clique e segurar têm a mesma lógica de precisão e cooldown; o movimento da mão não gera automaticamente soluções sem intenção.

## 3. Direção e sensação de movimento

- Arena em plano XZ, câmera fixa com projeção ortográfica e inclinação suave; cenas 3D em uma composição 2.5D.
- Mouse em tela é convertido por raycast/plano da arena em coordenadas de mundo; posição da mão suavizada com limite para não gerar atraso incômodo.
- Mão flutua levemente acima dos cubos, mostra pose de apontar ao selecionar e gesto de girar ao executar.
- Concluir giro no alvo ativo antes de aceitar um novo comando; fila máxima de **uma ação antecipada**, cancelada ao sair do alvo.
- Feedback de input em até um frame visual; nenhuma ação pode iniciar em mais de um cubo simultaneamente.
- Botão direito reservado para recurso futuro (modo manual/inspeção), sem função obrigatória no MVP.

## 4. Regras de uma run

- O jogador inicia na hub com carteira persistente; pressionar **Jogar** inicia partida do zero.
- Meta: superar **cinco ondas** no mesmo cenário.
- Cada onda possui uma lista determinada de cubos a aparecer e um limite de tempo (parâmetros no doc. 10).
- Máximo de cubos simultâneos ativos: **4** no MVP; novos spawns aguardam vaga. Se o relógio chegar a zero, os cubos ativos e os ainda previstos que não apareceram contam como não resolvidos — importante para impedir exploração por bloquear spawns.
- **Estabilidade da arena:** começa em 100; cada cubo não resolvido ao fim de uma onda reduz 25. A derrota ocorre se estabilidade <= 0; um timer esgotado não encerra automaticamente a run se ainda houver estabilidade.
- Entre ondas, o jogador recebe tela breve com resultados, cartas pendentes, e botão de continuar; a pausa congela timers e física relevante.
- Vitória: concluir a onda 5 e resolver a elite 3x3 antes do encerramento da run. Se o tempo da onda 5 expirar sem concluir a elite, a run é considerada derrota mesmo que reste estabilidade.
- Recompensa em moedas é concedida **no instante em que um cubo é resolvido**, incluída na carteira persistente. Nunca remover moedas já ganhas por morrer; prevenir pagamento duplicado.
- Pontuação/recorde pode contar cubos, velocidade e estabilidade, mas não substitui a moeda.

## 5. Pacing e surgimento

- Spawn gradual, em locais dentro da área jogável, sem sobreposição, longe da mão na criação e sem invadir HUD.
- Cubos comuns se movimentam muito lentamente ou oscilam em sua posição, sem física caótica.
- Reforçados se deslocam um pouco mais e precisam de mais movimentos.
- Elite 3x3 aparece apenas na onda final, com introdução marcante e mais tempo para a resolução.
- Aviso de proximidade do fim do tempo em 10 s, visual e sonoro discreto.
- Cubos em animação final não devem ser contabilizados como não resolvidos; concluir a transição antes de avançar de onda.

## 6. Falha, risco e priorização

A tensão do MVP é **qual cubo resolver primeiro**. Cubos fáceis liberam rapidamente espaço e geram experiência/moedas. Cubos difíceis prendem a mão por mais ações mas pagam mais. O tempo e a estabilidade punem a incapacidade de limpar a arena.

Não adicionar dano de contato, projéteis ou corações nesta primeira versão: isso mudaria o foco e complicaria o teste central. Efeitos de perigo e esquiva entram somente após o MVP se o loop básico justificar.

## 7. Fluxo de telas

**Inicialização -> Menu principal/hub -> Tutorial contextual na primeira run -> Arena -> Resumo de onda -> Seleção de habilidade (quando XP atingir limiar) -> Próxima onda -> Vitória/Derrota -> Resumo da run -> Hub/Loja.**

- Hub: Jogar, Melhorias permanentes, Configurações, Sair, total de moedas e recorde.
- Arena: mão, cubos, ondas, relógio, estabilidade, moedas obtidas na run, XP/nível e indicador do alvo.
- Resumo: resolvidos, perdidos, dinheiro/XP, próxima onda.
- Cartas: três alternativas legíveis, uma escolha obrigatória ou escolha padrão explícita se houver comando de pular.
- Fim: vitória/derrota, dinheiro recebido, cubos resolvidos, melhor combo, botão Jogar novamente e Retornar à hub.

## 8. Tutorial inicial (< 60–90 s)

1. Mostrar mão e um 2x2 com embaralhamento curto; mensagem “Mova a mão até o cubo”.
2. Ao pairar, mensagem “Clique ou segure para girar as camadas”; primeiro comando produz giro visível.
3. Na conclusão, mostrar dinheiro e experiência em dois locais separados.
4. Introduzir o relógio e a estabilidade em uma onda curta.
5. Apresentar escolha de habilidade quando ocorrer a primeira oferta; permitir revisitar a ajuda na hub.

Mensagens podem ser dispensadas, mas ações tutorializadas devem funcionar de verdade. Ao perder a primeira run, dica breve sobre priorização.

## 9. Casos-limite obrigatórios

- Nenhum pagamento por animação parcial ou toque sem solução.
- Clique sobre dois cubos sobrepostos deve atingir só o selecionado.
- Não girar enquanto seleção de cartas, pausa ou tela de transição estiver ativa.
- Ao sair durante a animação, salvar somente moedas já confirmadas, sem reaplicar recompensa.
- Cooldown não deve variar por FPS; update com delta.
- Nunca gerar cubo inicialmente resolvido por acidente (ou contar como resolvido gratuitamente).
- Se terminar a onda com cubos no spawn pendente, contabilizar pendências conforme regra.
- Se um buff altera cooldown durante animação, aplicar ao próximo comando.
- Em PC sem modelo 3D disponível, usar placeholder honesto; não declarar integração completa.
