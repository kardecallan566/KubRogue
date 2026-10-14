# C6 — Desafio do Dia e variedade roguelite

**Branch:** `dev/checkpoint-06-daily-challenge`  
**Engine:** Godot 4.7.2, Compatibility / Windows.  
**Estado:** implementação para testes, **ainda não aprovada para merge**.

## Escopo e experiência

1. Na hub, o jogador escolhe **JOGAR · MODO NORMAL** ou **DESAFIO DO DIA**. Ambas continuam com cinco ondas, cubos verdadeiros e elite 3×3 na última onda.
2. Desafio do Dia usa `YYYY-MM-DD` **UTC** do sistema quando o modo é selecionado. Seed = `(AAAAMMDD × 97 + 607) % 2147483647`. A seed serve ao embaralhamento dos cubos e à ordem inicial das ofertas; está visível na HUD. O cronômetro e a habilidade do jogador permanecem variáveis naturais, não é replay dos inputs.
3. Desafio diário é **repetível** quantas vezes quiser e persiste tentativas, vitórias, melhor onda e recorde pessoal de cubos; não há ranking online.
4. No modo Normal, o sorteio usa uma nova seed a cada run (ao contrário da constante 2026 do C5). A seed aparece na partida para facilitar testes futuros.
5. Durante uma oferta de habilidade, há um botão **TROCAR AS 3 CARTAS**. Uma troca por partida, somente quando há pelo menos uma opção nova; novos IDs não duplicam, respeito a habilidades nível 3. Trocar não consome a oferta nem XP; escolher continua obrigatório.
6. Carteira, dinheiro por resolução, loja, salva/vitória, cursor e VFX seguem funcionando como no C5. As melhorias permanentes funcionam também no desafio diário; por isso, **recordes são pessoais e não equivalentes a competição global**.
7. O save original `user://kubrogue_progress_v1.json` não é modificado. Recordes de desafio têm arquivo próprio `user://kubrogue_daily_v1.json` com escrita transacional e backup; guarda até 120 dias. Se o save diário falhar, não afeta a carteira.

## Checklist Windows

- [ ] Abre com `godot .` após clone, sem erros de preload de imagens.
- [ ] Dois modos visíveis, tutorial funcional em ambos, retorno à hub C6.
- [ ] Desafio do Dia exibe data UTC, seed e recordes de tentativas/onda.
- [ ] Duas tentativas no mesmo dia mostram a mesma seed e o mesmo scramble inicial.
- [ ] Reabrir o aplicativo mantém tentativas, vitórias e melhor onda/cubos do dia.
- [ ] Escolha de três cartas continua legível; reroll altera opções sem perder XP e só pode ser usado uma vez por run.
- [ ] Recomeçar a run restaura direito ao reroll e redefine XP/cartas.
- [ ] Moedas e upgrades antigos permanecem intocados; pagamentos não duplicam após reinício.
- [ ] Modo Normal usa seed distinta entre tentativas, sem alterar cinco ondas.
- [ ] Cenas C0–C5 e testes antigos continuam passando.
- [ ] CI e export Windows x86_64 atualizada aprovados; ZIP aberto no Windows e save persistido.

## Limites

Ainda não há ranking online, desafios semanais, recompensas exclusivas, condições de jogo especiais ou sincronização entre dispositivos. O horário UTC é escolhido para que todos recebam a mesma seed por dia, mesmo em fusos diferentes. A seed não promete reproduzir uma partida inteira, apenas conteúdo gerado a partir dela. O C6 precisa da sua validação visual antes de integrar à main.
