# 10 — Parâmetros de balanceamento v0 (HIPÓTESES)

**ATENÇÃO:** valores de partida para desenvolvimento. Ajustar depois de medir o protótipo C1–C3. Não declarar estes números como resultados confirmados.

## 1. Dados base

| Parâmetro | Base proposta |
|---|---|
| Janela do jogo | 1280x720 (escalar para 1080p) |
| FPS alvo | 60 no PC de desenvolvimento |
| Quantidade de ondas | 5 |
| Cubos ativos simultâneos | máximo 4 |
| Estabilidade inicial | 100 |
| Estabilidade perdida por cubo não resolvido | 25 |
| Intervalo de uma ação de mão | 0,34 s |
| Cooldown mínimo com upgrades | 0,16 s |
| Duração visual de giro de 90° | 0,22–0,30 s (não ultrapassar cooldown) |
| Expiração do combo sem solução | 12 s |
| Raio de foco da mão | Escala ajustada visualmente ao cubo, sem atravessar UI |
| Duração pretendida de run vencedora | 6–8 min, incluindo cartas e transições |

## 2. Tabela das ondas

| Onda | Duração limite | Aprendizes 2x2 | Reforçados 2x2 | Elite 3x3 | Total |
|---|---:|---:|---:|---:|---:|
| 1 | 45 s | 5 | 0 | 0 | 5 |
| 2 | 55 s | 6 | 2 | 0 | 8 |
| 3 | 65 s | 6 | 3 | 0 | 9 |
| 4 | 70 s | 6 | 5 | 0 | 11 |
| 5 | 90 s | 5 | 4 | 1 | 10 |
| **Total** | **325 s** | **28** | **14** | **1** | **43** |

Uma onda termina antecipadamente quando **todos os cubos previstos para ela** foram resolvidos (ou expirados), e não simplesmente porque a arena está vazia antes de concluir a programação de spawns.

Spawns: preferencialmente sequenciais com intervalo variável, até 4 ativos. Não postergar cubos restantes além do limite sem contabilizá-los como perdidos. A elite da onda 5 deve aparecer com janela suficiente para resolvê-la; hipótese: após aproximadamente 30 s ou quando 5 dos cubos anteriores tiverem sido concluídos, o que acontecer primeiro. A ordem não deve tornar vitória impossível em seeds rápidas ou lentas.

## 3. Tipos de cubo

| Tipo | Embaralhamento | Moeda base | XP base | Padrão |
|---|---|---:|---:|---|
| Aprendiz 2x2 | 2–4 giros legais | 10 | 1 | Movimento/oscilações suaves |
| Reforçado 2x2 | 5–8 giros legais | 18 | 2 | Deslocamento lento, material distinto |
| Elite 3x3 | 6–12 giros legais | 80 | 6 | Introdução especial, 1 por run |

**Dificuldade:** a profundidade escolhida é o comprimento do embaralhamento gerado, não medida exata de menor solução. Descartar sequências triviais; detectar resolução antecipada e encerrar. A elite deve terminar com face uniforme legítima, não após “12 HP”.

Total teórico sem bônus de uma run que resolve todos os cubos:
- **Moedas:** 28×10 + 14×18 + 1×80 = **612**.
- **XP:** 28×1 + 14×2 + 1×6 = **62**.
- A run pode pagar menos por cubos não resolvidos ou mais com bônus.
- Os limiares de XP 5/12/21/32 garantem, na run limpa, ofertas após as primeiras quatro ondas, mas os gatilhos podem variar se cubos expirarem.

## 4. Ações e limites

Com cubos médios a ~3 giros aprendiz, ~6,5 reforçado e ~9 elite, a run limpa precisa de ~184 ações (estimativa 28×3 +14×6,5 +9). A 0,34 s, são ~63 s de cooldown puro **sem contar deslocamento, animação, decisões e spawns**; portanto pacing depende principalmente dos spawns e da tensão criada pelo cronômetro, não de exigir centenas de cliques por segundo.

A mão deve ser confortável para jogar segurando o botão, sem automação ociosa: exige cursor sobre alvo.

## 5. Upgrades permanentes

| Item | Preço níveis 1/2/3 | Ganho por nível |
|---|---|---|
| Treino da mão | 200 / 500 / 1200 | -4% cooldown-base |
| Bolso do cubista | 250 / 650 / 1300 | +5% moedas |
| Arena estável | 300 / 800 / 1600 | +5 estabilidade inicial/máxima |

Preços são por nível a comprar, não acumulados. Compra após run; saldo salvo no momento da solução, independentemente da derrota.

## 6. Cartas e metas de variedade

Oito cartas com até três níveis cada, oferta de 3 distintas, cartas max excluídas. A carta Olhar de cubista reduz apenas movimentos de cubos reforçados futuros; mínimo 2 giros. Os modificadores precisam ser quantificados no HUD e limitados para prevenir builds infinitas.

## 7. Playtests e decisões de ajuste

**Se o jogo parecer lento:** primeiro encurtar intervalos de spawn/animação e melhorar responsividade da mão, **não** inflar dinheiro para mascarar. **Se parecer automático demais:** adicionar decisões de priorização e comportamento de cubos, não exigir resolução manual sem redesign. **Se 3x3 ficar cansativo:** reduzir movimentos e melhorar indicação de giro antes de criar upgrade obrigatório. **Se jogadores perderem cedo:** baixar penalidade ou número de spawns, mantendo valor das escolhas.

Registrar por onda: duração real, cubos aparecidos/resolvidos/expirados, giros por cubo, moedas/minuto, ofertas recebidas, estabilidade restante, frame-time e motivos de frustração. Ajustar uma variável relevante por rodada de teste e anotar decisão.

## 8. Condições de vitória e derrota (fonte canônica)

- Vitória: ao encerrar a onda 5 com **elite resolvida e estabilidade maior que zero**.
- Derrota: estabilidade chega a zero em qualquer onda; ou na onda 5 a elite não está resolvida quando tempo encerra.
- Estabilidade reduzida ao fim da onda pelos cubos previstos que não foram resolvidos, inclusive spawns pendentes.
- Cubos completados **antes** do encerramento confirmado creditam moedas/XP, mesmo se a run for derrotada.
- Transições devem aguardar ações visuais já confirmadas, evitando perder um cubo que concluiu no limite.
