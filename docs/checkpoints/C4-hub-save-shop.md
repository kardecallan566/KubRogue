# C4 — Hub, loja permanente, salvamento e tutorial

**Branch:** `dev/checkpoint-04-hub-save-shop`  
**Godot:** 4.7.2  
**Status:** código em validação CI/manual; PR draft até aprovação visual no Windows.

## O que há nesta versão

1. **Hub original em gramado pastel**, entrada do jogo (F5): Jogar, Loja, Como jogar, Configurações e Sair; saldo e recordes sempre visíveis.
2. **Tutorial de primeira run** (em PT-BR), persistido em `user://`. Volta a abrir pelo botão Como jogar.
3. **Loja de três linhas e três níveis por item:** Treino da mão (200/500/1200; -4% cooldown por nível), Bolso do cubista (250/650/1300; +5% moedas por nível) e Arena estável (300/800/1600; +5 estabilidade máxima/inicial por nível). O preço é da próxima compra, não acumulado. Botões desabilitados sem saldo/no máximo.
4. **Carreira local** versionada: saldo de moedas, níveis meta, records de onda/cubos/combo, configurações, tutorial e IDs de recompensa confirmados. Nenhum login e nenhuma conta necessária.
5. **Arena de cinco ondas do C3 mantida**, com mão 2D e puzzles 2×2/3×3. O bônus de moedas soma ao da carta, respeitando o teto +150%; cooldown tem piso 0,16 s; Arena estável eleva o máximo até 115.
6. **Economia durável:** solução lógica paga uma vez por ID. Persistência de moeda ocorre **antes** do texto confirmando o pagamento. Se a gravação falhar, a run pausa e mostra Tentar salvar. Se não resolver, bloqueia novo início de run no mesmo estado.
7. **Resultado e retorno:** após conclusão das ondas, botão Voltar à hub permite gastar moedas. No meio da partida, botão Voltar à hub abre confirmação; sair conserva todos os créditos já registrados.
8. **Recordes:** melhor onda, mais cubos resolvidos e melhor combo são atualizados na saída e/ou ao finalizar onda. XP e cartas não persistem, por decisão do game design.
9. **Settings:** preferências de música, efeitos, redução de partículas e tremor já persistem. O catálogo de sons e VFX definitivo pertence ao C5.
10. **Cenas históricas:** C0/C1/C2/C3 permanecem acessíveis e testáveis no Godot via F6.

## Testar no Windows

```powershell
git fetch origin
git switch dev/checkpoint-04-hub-save-shop
git pull origin dev/checkpoint-04-hub-save-shop
```

Abra `project.godot` no Godot 4.7.2 e pressione **F5**. Para ler o save: no editor, Projeto → Abrir Pasta de Dados do Usuário, ou verifique o caminho absoluto indicado por `ProjectSettings.globalize_path("user://kubrogue_progress_v1.json")`.

## Checklist para aprovação C4

- [ ] Hub legível em 1280×720 e 1920×1080, sem clipping; Jogar em destaque.
- [ ] Tutorial aparece somente na primeira entrada, com instruções compreensíveis; Como jogar o reabre sempre.
- [ ] Resolver um cubo concede valor permanente equivalente ao popup e ao saldo da hub.
- [ ] Fechar e reabrir o jogo mantém moedas; perder uma run **não** apaga moedas anteriores.
- [ ] Loja permite comprar cada upgrade e debita o custo correto **uma vez**; compra persiste após reinício.
- [ ] Aumento de estabilidade inicial/máxima aparece no HUD (105/110/115).
- [ ] Bolso do cubista e Treino da mão afetam valores/tempo efetivamente.
- [ ] Saldo insuficiente não permite compra; nível 3 mostra máximo.
- [ ] Pausa e retorno à hub não causam duplicação nem avanço indevido do timer.
- [ ] Jogar de novo cria um novo escopo de IDs, mantendo moedas e níveis meta anteriores.
- [ ] Não há cartas pendentes após derrota/vitória; XP de run reinicia.
- [ ] Preferências e recordes sobrevivem ao encerramento do aplicativo.
- [ ] Os testes de backup/corrupção e os testes de regressão C0–C3 passam.
- [ ] Nenhum login, publicidade ou rede é utilizado.

## Limitações conhecidas

- Save local não é criptografado/anticheat; deve ser validado, não tratar como dado de servidor.
- Os volumes só adquirem efeito prático quando o catálogo de áudio do C5 estiver implementado.
- As configurações de partículas e tremor ficam persistidas, mas só serão exercitadas pelos VFX do C5.
- C4 não inclui Steamworks, export comercial, efeitos finais, 4×4 ou monetização.
- O checkpoint **não deve ser integrado à main até a validação gráfica pelo usuário**.

## Correção de inicialização limpa (Godot CLI — 2026-10-13)

O comando `godot .` em um clone sem cache podia informar `Could not find type "KubRogueProgress" in the current scope`, pois a hub e a arena tipavam uma classe global definida no próprio script de autoload, antes de o índice de classes de `.godot/` estar disponível. O C4 agora usa `const ProgressScript = preload("res://scripts/c4/progress_service.gd")` nos dois consumidores, com tipos `ProgressScript`, sem depender da descoberta global por `class_name`. O autoload `KubeSession` permanece inalterado. A suíte CI passa a iniciar o projeto **antes da importação no editor e sem pasta `.godot/`**, replicando uma primeira execução de `godot .`. Não é necessário apagar os saves de `user://`.

Para atualizar seu checkout: `git pull origin dev/checkpoint-04-hub-save-shop` e executar `godot .`.
