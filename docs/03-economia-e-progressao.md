# 03 — Economia, progressão e persistência

## 1. Três marcadores, três funções distintas

| Recurso | Obtenção | Gasto/uso | Persiste após run? |
|---|---|---|---|
| **Moedas** | Apenas quando um cubo é resolvido | Loja de melhorias permanentes na hub | **Sim**, saldo imediato |
| **XP da run** | Ao completar cubos | Subir nível e abrir escolhas de habilidade | **Não**, zera ao iniciar nova run |
| **Estabilidade** | Inicia em 100; sem regeneração padrão | Cai quando cubos permanecem sem solução ao final da onda | **Não**, reinicia em 100 + bônus meta |

**Moedas não são XP**, não gastam na seleção de cartas, e não desaparecem na derrota. O jogador deve compreender isso em poucos segundos pelo HUD.

## 2. Pagamento por solução

Regra-base:
- Cubo aprendiz 2x2: **10 moedas** e **1 XP**;
- Cubo reforçado 2x2: **18 moedas** e **2 XP**;
- Elite 3x3: **80 moedas** e **6 XP**.

Fórmula de moedas pagas: arredondar_para_baixo(base × (1 + bonus_permanente + bonus_habilidade + bonus_combo)), com bônus aditivos e limite para evitar crescimento descontrolado (MVP: teto combinado de +150%). Nunca multiplicar repetidamente pelo número de cliques.

**Momento de crédito:** evento único de SOLVED, antes do efeito visual de saída. O valor exibido em tela deve bater com o saldo. Um identificador único de instância impede pagamento em duplicidade.

## 3. XP e escolha de cartas

Limiar de XP acumulado dentro de uma run, **proposta inicial**:
- Nível 2: 5 XP
- Nível 3: 12 XP
- Nível 4: 21 XP
- Nível 5: 32 XP
- Nível 6+: fora do escopo obrigatório ou limiar adicional de 45 XP, conforme observação em playtest.

Quando cruzar limiar:
1. registrar level-up pendente;
2. **não interromper uma rotação em andamento**;
3. mostrar oferta de 3 cartas na próxima transição segura entre ondas;
4. selecionar uma, aplicar ao inventário da run e limpar pendência;
5. se múltiplos níveis forem acumulados, enfileirar as ofertas sem duplicar pagamento.

XP reinicia na partida seguinte. Cartas escolhidas pertencem apenas à run, não são consumíveis nem itens comprados.

## 4. Loja permanente (MVP: exatamente 3 linhas)

| Linha | Nível inicial | 1º / 2º / 3º nível | Efeito por nível |
|---|---|---|---|
| **Treino da mão** | 0/3 | 200 / 500 / 1200 moedas | -4% no cooldown-base por nível (total -12%) |
| **Bolso do cubista** | 0/3 | 250 / 650 / 1300 moedas | +5% na recompensa por nível (total +15%) |
| **Arena estável** | 0/3 | 300 / 800 / 1600 moedas | +5 de estabilidade máxima/inicial por nível (máximo 115) |

A compra só pode ocorrer na hub, fora de uma run. Validar saldo, nível máximo e existência da chave no catálogo antes de debitar. O custo é descontado **uma única vez** e a mudança salva imediatamente.

**Não incluir no MVP:** moedas premium, anúncios, compras reais, roletas, múltiplas moedas ou economia online.

## 5. Exemplo de primeira experiência

- Jogador resolve 5 cubos comuns: +50 moedas e +5 XP; no fim da onda, escolhe a primeira carta.
- Mais tarde resolve um reforçado: +18 moedas e +2 XP.
- Ao finalizar ou perder a partida, mantém o saldo acumulado por cada cubo concluído.
- Depois de algumas runs, pode comprar Treino da mão I por 200 moedas e sentir melhora desde o início seguinte.

Exemplo didático: números reais da run variam com suas ondas, bônus e sucesso.

## 6. Curva desejada

- Primeira run: mesmo sem upgrade meta, todas as cinco ondas devem **ser possíveis**, ainda que não triviais.
- Primeira melhoria permanente: alcançável em cerca de 1–2 runs medianas (validar por telemetria de playtest).
- Melhorias permanentes devem aliviar erros e dar motivação, nunca ser exigência para passar o desafio.
- Dificuldade da elite deve vir de priorização e mais movimentos, não de um “paywall” de grind.
- Uma run precisa de progressão expressiva de cartas mesmo quando o jogador não compra nada.

## 7. Dados salvos

Salvar localmente: versão de esquema, saldo de moedas, níveis meta, melhor onda, maior número de cubos resolvidos, recorde de combo, configurações e flag de tutorial.

Uma run **não** precisa ser retomável no MVP. Ao fechar durante a arena, manter moedas já creditadas e melhorias meta; limpar estado transitório da run. Salvar créditos de modo atômico e com checkpoint frequente (por evento ou pequeno debounce que não permita perder moedas legitimamente concedidas). Arquivo temporário + renomeação validada é recomendável para reduzir corrupção.

Não confiar em saldo exibido pela UI: centralizar transações no gerenciador da economia. Número inteiro não negativo; ao carregar valores inválidos, recuperar com fallback seguro. Evitar que um save anterior seja sobrescrito por formato incompatível.

## 8. Critérios de equilíbrio

Comparar: moedas por minuto, upgrades comprados nas 3 primeiras runs, taxa de vitória sem meta, impacto de cada carta e variação entre runs. Ajustar custo e recompensa **apenas** depois do protótipo completar o fluxo. Tabelas propostas estão consolidadas no [documento 10](10-balanceamento-inicial.md).
