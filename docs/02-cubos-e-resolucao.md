# 02 — Cubos 3D, estado lógico e resolução assistida

## 1. Objetivo técnico

Cubos são **quebra-cabeças tridimensionais de verdade**: faces coloridas e camadas rotacionáveis, não blocos com HP que apenas explodem. A mão executa movimentos legais em uma sequência de solução preparada pelo jogo. O jogador escolhe *onde* e *quando* agir, enquanto o jogo decide *qual movimento* aplicar. Essa divisão é central para a identidade arcade.

## 2. Conjunto MVP

| Tipo | Estrutura | Dificuldade | Comportamento | Recompensa |
|---|---|---|---|---|
| Cubo aprendiz | 2x2 | 2–4 movimentos | Quase parado, tamanho confortável | Base |
| Cubo reforçado | 2x2 | 5–8 movimentos | Oscila/desloca devagar, realce distinto | Maior |
| Cubo elite | 3x3 | 6–12 movimentos | Introdução na onda 5; maior área de alvo | Alta |

**Não incluir no MVP:** 4x4, 5x5, 6x6, speedcubing manual, estados aleatórios difíceis sem caminho conhecido, cubos com regras exóticas, física peça-a-peça e solver externo.

## 3. Fonte da verdade: estado vs render

Separar duas camadas:
- **CubePuzzleModel (dados):** tipo, N, adesivos/peças, orientação, estado resolvido, lista de movimentos de embaralhamento, plano inverso, índice de progresso e seed.
- **CubeView3D (apresentação):** meshes das peças, pivôs temporários de camada, sombras, interpolação de animação, material, áudio e realce.
- **CubeActor (jogo):** spawn, seleção, timing, valor em moedas/XP, estado ativo/resolvendo/concluído/expirado.

**Regra:** só o modelo lógico altera o estado real; a aparência obedece ao modelo. Usar rotação de malhas soltas sem estado não é suficiente para garantir solução correta.

## 4. Representação de peças

Para NxN, construir cubinhos visíveis e adesivos coloridos nas faces externas. Referências:
- 2x2: 8 peças de canto.
- 3x3: 26 cubinhos visíveis (6 centros, 12 arestas, 8 cantos). Peça interior não precisa de mesh.
- Cada peça tem posição discreta (coordenada de grade), orientação e quais adesivos estão expostos.
- As seis cores devem permanecer em orientação consistente entre todas as faces e giros. Definir paleta acessível e apoio opcional por símbolo, não apenas cor.

Ao girar face/camada:
1. Validar movimento no modelo;
2. Identificar cubinhos da camada (eixo, índice, direção, quartos-de-volta);
3. Conectá-los temporariamente a pivô central da camada;
4. Animar 90° ou 180° com easing curto, sem deformar malhas;
5. Atualizar posições/orientações discretas, reparentar e normalizar transformações;
6. Confirmar fim da animação e testar estado resolvido.

Evitar erros cumulativos de ponto flutuante: **snap** no grid e ângulos de múltiplos exatos de 90° após cada giro.

## 5. Algoritmo sem solver geral

**Método MVP: embaralhamento reversível conhecido.**
1. Partir de um estado solucionado.
2. Usar gerador pseudoaleatório com seed persistida dentro da run para compor uma sequência de movimentos legais.
3. Registrar a sequência completa e aplicá-la ao estado, sem disparar efeitos de vitória.
4. Evitar sequências triviais (por exemplo, cancelar imediatamente o movimento anterior ou misturar a mesma face em sequência de forma redundante).
5. A sequência de solução é a sequência de embaralhamento invertida, com direções inversas.
6. Cada comando da mão consome um item do plano após a animação efetiva.
7. Se a última ação levou todas as faces a estado uniforme, emitir evento único de conclusão.

**Limitação declarada:** reverter a sequência de embaralhamento dá **uma solução válida**, não necessariamente a solução com menor número de giros. Pode haver estados resolvidos antes do fim do plano; nesse caso a conclusão é imediata e os giros excedentes não acontecem. O contador de movimentos deve refletir giros que restam no plano atual (não distância matemática mínima).

Caso futuramente se permita girar camadas livremente, o estado poderá deixar de corresponder ao plano inverso; será necessário um mecanismo de resolução recalculada ou um solver adequado. Não oferecer controle manual livre dentro do MVP.

## 6. O papel da mão

- Cursor com forma de mão 3D, pose neutra e animação de gesto de giro quando comanda uma camada.
- Retículo discreto mostra qual cubo está em foco. Click/hold aplica próximo movimento do plano de resolução.
- Cada toque bem-sucedido produz som mecânico, giro de uma camada, pequenos highlights de cor e atualização do contador.
- Habilidades podem reduzir intervalo entre comandos ou aplicar giro adicional, **mas cada giro deve continuar válido e visível**.
- Animações rápidas podem ser enfileiradas de modo limitado; nunca sobrepor duas rotações conflitantes na mesma instância de cubo.

## 7. Estados e transições

**SPAWNING -> ACTIVE -> ROTATING -> ACTIVE ou SOLVED -> EXITING**; também ACTIVE -> EXPIRED. Evento SOLVED deve ocorrer no máximo uma vez. EXPIRADO não aceita input. Qualquer transição para SOLVED cancela expiração e conta como resolvido.

Uma animação de morte/partículas pode ocorrer após a solução confirmada. Pagamento único é vinculado ao identificador único do cubo na run; sinal de animação visual não credita dinheiro.

## 8. Integração do modelo 3D existente

Ainda **não há arquivo disponibilizado no repositório**. Na futura implementação, antes de editar:
- Solicitar/importar o modelo e verificar formato (.glb/.gltf preferencial), licença, número de cubinhos, orientação de eixos, texturas, pivôs, materiais e animações existentes.
- Se vier como malha monolítica, avaliar separação por peças sem perder as cores. Um modelo com uma única textura fixa pode não permitir girar camadas de forma convincente.
- **Fallback legítimo:** gerar cubinhos e seis materiais no Godot até conseguir adaptar o asset real.
- Testar 2x2 e 3x3 com solução reproduzível, sem cracks visuais; escala e pivôs configuráveis por recurso, jamais valores globais arbitrários.

A documentação técnica oficial confirma glTF 2.0 e .glb como formatos de importação apropriados para Godot 4: https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_3d_scenes/

## 9. Testes fundamentais do puzzle

- Toda sequência embaralhada e depois invertida termina resolvida.
- Após centenas de rotações e várias instâncias, cores e posições continuam coerentes.
- Repetir a mesma seed dá o mesmo embaralhamento, independentemente de FPS.
- Rotação 180° mantém estado e render sincronizados.
- Jamais entregar duas recompensas pelo mesmo cubo, inclusive em pause/quit.
- Transições entre cenas não deixam cubinhos órfãos ou girando sem dono.
- Contador chega a zero **quando** os adesivos confirmam o estado resolvido, sem falso positivo.
- O cubo 3x3 de elite realmente usa camadas 3x3; não basta trocar o tamanho de um 2x2.
