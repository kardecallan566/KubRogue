# 04 — Cartas, upgrades e sinergias

## 1. Princípio

O jogador deve sentir que a mão se transforma durante uma run. Ao cruzar um limiar de XP numa run ativa, oferece-se **1 entre 3 cartas sorteadas**, assim que o giro terminar e a simulação puder pausar. Cada carta altera um sistema real, tem descrição numérica visível, ícone distinto e resultado testável. Não copiar nomes, textos, arte ou efeitos exatos de King of Pickaxe; a inspiração se limita a sistema de escolhas e combinações.

## 2. Catálogo inicial — oito habilidades

| Carta | Efeito por nível (até 3) | Identidade | Nota técnica |
|---|---|---|---|
| **Pulso ágil** | -8% cooldown da mão por nível | Velocidade de giro | Respeita cooldown mínimo global |
| **Dedo certeiro** | A cada 7/6/5 ações válidas, executar um giro correto adicional no mesmo alvo | Duplo giro | Exibir 2 giros separados e validar solução após cada |
| **Luva magnética** | +12% raio de seleção por nível | Acesso a alvos | Seleciona um único alvo mais próximo |
| **Bolsa encantada** | +15% moedas de cubos resolvidos por nível | Economia da run | Sujeita ao teto de bonificação |
| **Ritmo de mestre** | Após 3 cubos consecutivos resolvidos sem perder combo, +10/15/20% moedas enquanto combo ativo | Combo | Explicitar reset e duração |
| **Fôlego extra** | +8/12/16 segundos de tempo nas ondas seguintes | Controle de tempo | Bônus aplicado uma vez por onda |
| **Olhar de cubista** | Alvo reforçado passa a nascer com 1/2/3 movimentos a menos (mínimo 2) | Anti-dificuldade | Valer só para spawns futuros |
| **Mão paciente** | Cada onda concluída recupera 5/8/12 de estabilidade, sem ultrapassar máximo | Sobrevivência | Aplicar apenas após a penalidade da onda |

**Todos os valores são propostas para playtest**, não implementação.

## 3. Regras de aplicação

- Oferecer 3 cartas **distintas** por oferta; no máximo cinco ofertas por run (XP 5/12/21/32/45).
- Cartas no nível máximo não entram nas próximas ofertas.
- Pool de ofertas e aleatoriedade precisam de seed, garantindo repetibilidade em depuração.
- Se restarem menos de 3 elegíveis, ofertar o que existir e uma opção alternativa claramente definida (ex.: moedas de bônus pequenas) — nunca inventar uma carta vazia.
- Não interromper animação ativa; cartas são oferecidas **durante a run após uma resolução segura**, não apenas entre ondas; nunca após o fim.
- Ao escolher uma carta já adquirida, aumentar nível até 3 e atualizar descrição do próximo nível.
- Exibir lista de habilidades ativas, nível e efeitos no HUD via painel expandível.
- Ao iniciar nova run, todas as cartas voltam ao nível zero.

## 4. Exemplos de sinergias

**Velocidade + precisão:** Pulso ágil permite mais ações; Dedo certeiro gera um giro extra periodicamente. Resulta em mais cubos resolvidos por minuto.

**Risco + riqueza:** Bolsa encantada e Ritmo de mestre recompensam limpar a arena sem deixar o combo cair, estimulando escolher alvos simples primeiro.

**Controle + resistência:** Fôlego extra dá tempo adicional; Mão paciente recupera estabilidade quando a onda termina. Útil para elite e novos jogadores.

**Elite eficiente:** Olhar de cubista reduz movimentos exigidos em reforçados, liberando espaço para alcançar outros alvos enquanto Luva magnética facilita a aquisição.

## 5. Combo

- Cada cubo resolvido incrementa contador; combo mantém-se até a próxima oportunidade de solução.
- Proposta: combo expira após 12 s sem resolver outro cubo. Ao fim da onda, combo é preservado apenas até a transição, não durante a tela de cartas; próxima onda começa sem combo, evitando exploração de pausa.
- Se houver expiração de um cubo ao fechar uma onda, zerar combo.
- Exibir x2/x3 etc. como **sequência**, não multiplicador de dinheiro. A carta Ritmo de mestre usa limiar de 3 soluções; definir recompensa por carta e não por contador infinito.
- Resolver cubos mais difíceis não concede “kills”; usar vocabulário de resolução (resolvidos, combo, organização).

## 6. Limites e balanceamento

- Cooldown mínimo absoluto sugerido: 0,16 s por movimento, independentemente das cartas.
- Aplicar modificadores de cooldown por uma fórmula única. Proposta: cooldown final = max(0,16, cooldown_base × (1 - bonus_meta - bonus_cartas)).
- bônus máximo somado em moedas: +150%, inclusive efeitos temporários e permanentes.
- Bônus de tempo nunca pode entrar repetidamente por reabrir resumo de onda.
- Movimentos extras de Dedo certeiro nunca são disparados sobre cubo já resolvido ou expirado; não transportá-los arbitrariamente a outro alvo.
- Variantes que reduzem movimentos de spawn devem respeitar a geração de puzzles solucionáveis.
- Cada upgrade precisa de testes de efeito isolado e combinação extrema de nível 3.

## 7. UX da oferta

Três cartas com: nome, ícone, nível atual -> próximo, número concreto (“-8% tempo entre giros”), tag simples (Velocidade, Dinheiro, Precisão, Controle) e botão selecionar. Cor ou raridade estética não deve implicar chance secreta no MVP. Pausar jogo enquanto escolhe; suporte a mouse e teclado opcional (1/2/3) é recomendado.

## 8. Fora do MVP

Relíquias permanentes equipáveis, mãos elementais, sinergias ocultas complexas, dezenas de raridades, árvores de talentos, rerolls pagos, evolução visual procedural complexa e leaderboard. Tais ideias entram após demonstrar que oito cartas já dão decisões interessantes.

## 9. Feedback exclusivo das habilidades

Pulso ágil: rastro de gesto; Dedo certeiro: dois giros reais identificáveis; Luva magnética: anel de foco maior; Bolsa encantada: brilho de pagamento; Ritmo de mestre: contador de combo; Fôlego extra: relógio aumenta uma vez por onda; Olhar de cubista: menos giros nos reforçados futuros; Mão paciente: estabilidade restaurada após penalização. Nenhuma habilidade deve confundir adesivos ou esconder o gramado. Exibição de carta pausa ondas e spawn. Ver [12](12-gamefeel-eventos-visuais-e-detalhamento.md).
