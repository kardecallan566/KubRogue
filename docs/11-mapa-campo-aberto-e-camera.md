# 11 — Mapa principal: campo aberto, câmera e composição de combate

> **Especificação de cenário v1 — obrigatória para o MVP.** Este documento prevalece sobre descrições anteriores de palco circular, bordas de plataforma ou diorama fechado. O campo é uma interpretação ORIGINAL do princípio espacial visto em King of Pickaxe: visão superior, superfície simples, muito espaço livre e protagonistas destacados. Não replicar texturas, composição exata, padrões de grama nem sprites do jogo de referência.

## 1. O que a referência realmente inspira

Nas capturas de gameplay de **King of Pickaxe** observa-se um campo visualmente contínuo, grama verde-clara com tufos e manchas esparsas, visão superior, inimigos agrupados no plano de ação e interface compacta nas bordas. O cenário não disputa a atenção com a jogabilidade. A Steam confirma o controle de cursor em visão superior, mas **não especifica tecnicamente** tamanho de mapa, câmera, geração de terreno nem algoritmo de spawn; esses elementos do KubRogue são decisões nossas.

Referências de leitura visual:
- Steam: https://store.steampowered.com/app/4264240/King_of_Pickaxe/
- Captura de gameplay da página oficial no itch.io: https://enter-the-game.itch.io/king-of-pickaxe
- Galeria com capturas de gameplay: https://www.4gamer.net/games/998/G099807/screenshot.html

**O que manter como ideia:** campo aberto, cores agradáveis, detalhes baixos no solo, ausência de corredores, combate concentrado nos personagens, HUD periférica.

**O que transformar para o KubRogue:** campo tridimensional baixo, cubos 3D com sombras e giro verdadeiro das faces, cursor de mão 2D sobreposto, folhas e formas geométricas originais, uma fantasia de jardim/oficina de enigmas.

## 2. Bioma inicial: Jardim dos Cubos

**Nome de produção:** Jardim dos Cubos. **Sensação:** tarde clara em um gramado encantado onde cubos de cores vivas aparecem para serem organizados. O chão é verde-menta/verde-lima suave, com superfícies majoritariamente planas e formas arredondadas, sem excessos.

### Camadas visuais, do fundo para frente

1. **Terreno base:** plano 3D suficientemente grande para ultrapassar as bordas da câmera em todas as resoluções; material fosco com variação quase imperceptível de verde. Não colocar uma borda de plataforma visível.
2. **Manchas do gramado:** elipses irregulares e difusas, 1–2 tons mais claros/escuros, distribuição por seed visual; sem padrões quadriculados aparentes.
3. **Tufos e brotos:** grupos muito pequenos de 2–4 hastes arredondadas, achatados ou em leve relevo, bem espaçados; não criar florestas, árvores ou paredes nas áreas de interação.
4. **Flores geométricas pontuais:** raras e discretas nas regiões com menos densidade de gameplay; silhuetas próprias em triângulos/círculos com baixa saturação. Jamais confundir com um cubo selecionável.
5. **Sombras de contato:** pequenas sombras circulares suaves sob cada cubo e sob a mão; deslocam-se junto com os atores e dão volume aos modelos 3D.
6. **Atores principais:** cubos 2x2 e 3x3 de alto contraste, contorno sutil, destaque de foco e o cursor de mão 2D desenhado acima dos cubos.
7. **Efeitos e HUD:** efeitos de solução breves e interface legível, desenhada por cima sem depender da cor do terreno.

**Regra de composição:** pelo menos 75% do piso visto em uma captura deve parecer limpo; cobertura decorativa discreta, sem objetos altos dentro da área de interação. Os cubos devem ser os pontos de maior contraste.

## 3. Geometria e câmera do MVP

- Eixo do jogo: **plano XZ**, Y é altura. A mão e os cubos se movem no XZ.
- Câmera: **Camera3D ortográfica**, perto da visão superior, com direção aproximadamente 15–25° afastada da vertical (inclinação a validar com cubo 3x3). Isso mostra topo e laterais sem distorção de perspectiva.
- Câmera do MVP: **fixa**, com pequena animação opcional de entrada e sem rotação durante o combate. A mão acompanha a posição do cursor projetada sobre o plano XZ por raycast. Fixar câmera evita feedback de controle instável quando mundo e cursor tentam seguir um ao outro.
- Área de ação: retângulo lógico invisível contido na região de visão útil. A mão é limitada a esse retângulo para não sair da tela; cubos surgem nas faixas externas sem bloquear a HUD.
- **Terreno maior que a área jogável**, de modo que nenhum limite, parede ou borda de plataforma seja visível. É um campo **visualmente contínuo**; o MVP não promete exploração procedural infinita.
- Câmera segue o jogador / mapa com rolagem: **pós-MVP**, apenas após redesenho de entrada. Se adotado, usar deslocamento relativo independente ou dead zone com alvo em coordenadas estáveis; não usar câmera seguindo diretamente posição derivada do cursor em câmera móvel (loop de deriva).
- Escala de mundo de partida (hipótese): área útil de aproximadamente 18 × 10 unidades; dimensões finais são escolhidas pelo enquadramento em 16:9 e testes 16:10/21:9, **não** assumidas como fixas.

## 4. Zonas do mapa — sem paredes

1. **Zona central de leitura:** área de melhor visibilidade onde a mão começa e o tutorial apresenta o primeiro 2x2.
2. **Anel de entrada:** faixa lógica próxima às bordas da câmera, dentro da área visível segura, de onde aparecem cubos com pequena animação de aterrissagem.
3. **Zona de circulação:** área entre entrada e centro; cubos podem oscilar e caminhar lentamente sem atravessar elementos de HUD.
4. **Zonas mortas da HUD:** retângulos definidos pelos painéis de interface. Não iniciar spawn nem aceitar giro através deles.
5. **Área de efeito da elite:** destaque temporário no piso, como linhas luminosas geométricas concentricas, mas **sem bloquear movimentos** ou trocar o cenário.

Não criar grid de tiles, plataformas elevadas, corredores, labirintos, obstáculos bloqueantes, cercas, penhascos ou cenário fechado no MVP.

## 5. Spawns e movimento no campo

- Alocar locais pelo anel de entrada, em ângulos/posições distribuídos; garantir distância mínima entre centros, distância segura da mão, da HUD e da elite.
- Spawn visível e anunciado com 0,25–0,45 s de pulso suave no chão, seguido de subida da peça; tempo de spawn não conta como cubo resolvido.
- Máximo de **4 atores**; antes de a elite da onda 5 aparecer, reservar capacidade para ela (limite 3 cubos comuns, quarto lugar dedicado à elite).
- Aprendiz: deslocamento muito lento ao redor de um ponto-alvo, com pausas; não fugir para fora da área de ação.
- Reforçado: flutuação com pequenas mudanças de rumo, em velocidade baixa; se aproximar da zona central de modo previsível, sem atravessar outros cubos.
- Elite: aparece com vinheta de 1 s, em uma região claramente visível; evita cobrir a mão e mantém o corpo relativamente estável durante a resolução.
- **Nenhum inimigo persegue ou causa dano de contato no MVP.** A tensão vem dos alvos em movimento, do relógio e da estabilidade; vida/dodge são experimentos posteriores, não afirmações sobre este protótipo.
- Os cubos devem ser identificáveis pela localização e não pelo padrão de gramado. Raycast encontra o ator, não as plantas.

## 6. Atmosfera por onda mantendo o mesmo mapa

| Onda | Mudança ambiental sutil | Objetivo |
|---|---|---|
| 1 | Gramado claro e iluminação de manhã | Ensinar leitura e interação |
| 2 | Mais partículas de pólen geométrico bem esparsas | Sugerir progressão |
| 3 | Sombra das nuvens atravessa lentamente o solo, sem mudar seleção | Variedade visual |
| 4 | Pequenos pulsos de cor nos spawns, ênfase musical | Criar expectativa |
| 5 | Céu/luz levemente mais quente, marca geométrica de entrada da elite | Clímax sem mudar bioma |

Não trocar para lava, neve, pedra ou outra arena no MVP. Os efeitos de atmosfera não podem afetar cor correta das faces nem esconder movimentos.

## 7. Elementos de cenário para a cena Godot

Sugestão de nós:
- WorldRoot (Node3D)
  - FieldGround (MeshInstance3D, mesh plano)
  - GrassScatter (MultiMeshInstance3D para tufos/folhas, quando necessário)
  - SoftPatches (meshes/decal simples ou shader com variação)
  - AmbientLight (WorldEnvironment + DirectionalLight3D)
  - SpawnRing (Node3D com pontos de amostragem, invisível em runtime)
  - CameraRig (Node3D com Camera3D fixa)
  - CubeContainer / FXRoot (HandCursor2D em CanvasLayer separado)
- OverlayHUD (CanvasLayer; ponteiro em HUD impede interações na arena)

**Otimização:** prefira MultiMesh para decoração repetida, sem CollisionShape3D em tufos e manchas; fogos e objetos 3D devem ser simples. Evitar sombras individuais em centenas de brotos. Não gerar plantas aleatórias a cada frame: criar uma vez por seed e reutilizar.

## 8. Paleta e legibilidade (hipóteses)

- Piso: verdes suaves com luminância média; não copiar amostras exatas da referência.
- Cubos: seis adesivos contrastantes, material plástico, contorno independente do piso.
- Mão: tom de luva diferente do verde do solo e dos adesivos mais comuns; sombra suave própria.
- UI: texto claro em placa neutra/escura semi-opaca, outline leve; nunca texto diretamente sobre grama sem contraste.
- **Evitar grama vermelha, azul, laranja intensa ou mosaicos multicoloridos** que confundam com adesivos dos cubos.

## 9. Critérios de aceite do mapa

- [ ] Uma captura sem cubos lembra um gramado aberto e leve, **sem palco circular, muros ou pisos quadriculados**.
- [ ] Em resolução 1280x720 e 1920x1080, 3 a 4 cubos continuam visualmente separados da decoração.
- [ ] A câmera permite ver giros 90° dos cubos 2x2 e 3x3 sem esconder faces importantes.
- [ ] Spawns nunca nascem sob menus, fora da câmera, em cima da mão nem sobrepostos.
- [ ] O cursor encontra cubos por raycast sem interferência de folhagem.
- [ ] O cenário parece contínuo mesmo nas bordas, sem chão terminando.
- [ ] Nenhuma onda troca o bioma; só há evolução sutil de atmosfera.
- [ ] Frame time da decoração é estável em runs longas, e a grama não pisca ao mover câmera na abertura.
- [ ] Sombras, vegetação e ambientação são **originais**; capturas da referência servem apenas a análise, não são assets.

## 10. Futuro — não implementar agora

Após aprovação do MVP, prototipar mapa com **rolagem de câmera e terreno em chunks**, diferentes épocas do mesmo jardim, trilhas sem colisão, flores reativas, eventos de chuva e encontros especiais. Essas opções não devem alterar o fluxo C1–C5 nem inviabilizar a versão inicial.
