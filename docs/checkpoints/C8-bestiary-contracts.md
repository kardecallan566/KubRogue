# C8 — Bestiário do Jardim e Contratos de Partida

**Branch:** `dev/checkpoint-08-bestiary-contracts`. **Godot:** 4.7.2, renderer Compatibility. **Estado:** validação antes do merge. **Base:** C7 aprovado, PR #8 integrado na main.

## O que o jogador vê

A hub recebe **BESTIÁRIO DO JARDIM**, acessível sem conexão. Ao abrir, mostra sete entradas: Aprendiz 2×2, Reforçado 2×2, Dourado 2×2, Blindado 2×2, Elite 3×3, Mestre 4×4 e Titã 5×5. Cada cubo resolvido e pago desbloqueia seus detalhes e aumenta o contador acumulado de resoluções. A tela usa os cartões, painéis e paleta arcade do C5; espécies desconhecidas aparecem bloqueadas.

Há também **três contratos disponíveis em toda partida**. Eles não gastam moeda, não substituem cartas e não alteram as cinco ondas:
- **Primeiros passos:** resolver 4 cubos; **+20 moedas** na quarta solução.
- **Caçador de raros:** resolver 2 cubos especiais (Dourado, Blindado, Elite, Mestre ou Titã); **+35 moedas** na segunda solução.
- **Mestre das camadas:** resolver 1 cubo 4×4 ou 5×5; **+60 moedas** na primeira solução.

O painel da partida exibe progresso e número de contratos completos. Cada bônus é incorporado na **mesma transação C4 `credit_cube`** que paga o cubo que completou o contrato, impedindo cobrança ou crédito independentes. Máximo possível **+115 moedas por run**, sem aumentar o XP base dos cubos. Em uma nova partida os contratos reiniciam.

## Persistência e segurança

A coleção é armazenada em `user://kubrogue_journal_v1.json` (adaptador `SaveStore`, arquivo temporário e backup) e não interfere com `kubrogue_progress_v1.json` nem com `kubrogue_daily_v1.json`. Contadores e IDs de evento são validados, e os últimos 512 pagamentos registrados impedem descoberta duplicada após reinício. Se a escrita do bestiário falhar, o dinheiro continua salvo pelo C4 e o registro permanece pendente **em memória** para nova tentativa na sessão; ao fechar o jogo antes de salvar, uma observação pendente pode ser perdida, sem perda de moedas. Não existe servidor, conta, leaderboard ou coleta de dados.

## Checklist do Windows

- [ ] `godot .` a partir de um clone sem cache `.godot`; sem erro de preload PNG ou class_name.
- [ ] Hub 720p/1080p com BESTIÁRIO visível, sem cortes ou botões sobrepostos.
- [ ] Bestiário inicialmente tem 7 cartões bloqueados; uma espécie resolvida desbloqueia o cartão correspondente.
- [ ] Reabrir o jogo preserva as descobertas e quantidades.
- [ ] Quatro Aprendizes 2×2 pagam 40 moedas base + 20 do contrato, sem segunda transação.
- [ ] Duas espécies especiais resolvidas dão 35 moedas extras na segunda.
- [ ] Resolver um 4×4 ou 5×5 dá +60 moedas extras na primeira vez por run, além do próprio pagamento.
- [ ] Reiniciar partida permite cumprir contratos outra vez, sem apagar a coleção permanente.
- [ ] Falhar ao salvar dinheiro mantém recuperação com TENTAR SALVAR; bônus não são pagos duas vezes.
- [ ] Permanecem os 2×2, 3×3, 4×4, 5×5, cinco ondas, Boss, desafios diários, habilidades/reroll, som e cursor 2D.
- [ ] CI C0–C8 e build Windows ZIP aprovados. Testar desempenho no Windows antes do merge.

**Fora do C8:** colecionáveis compráveis, conquistas Steam, placar online, monetização e alterações ao formato dos saves anteriores.
