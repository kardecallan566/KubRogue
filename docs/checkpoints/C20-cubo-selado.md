# C20 — Nova espécie: Cubo Selado

**Estado:** planejado; nenhum código C20 existe. **Base:** C19 aprovado. **Branch sugerida:** `dev/checkpoint-20-sealed-cube`.

## Objetivo

Introduzir uma restrição temporária, visual e justa: uma face aparece com um selo e fica indisponível durante os dois primeiros movimentos válidos. Depois disso, o selo se rompe e todas as faces ficam liberadas.

## Lógica e prevenção de softlock

1. A seed escolhe a face selada entre F/R/U/L/D/B.
2. O gerador produz um embaralhamento legal e calcula o plano inverso.
3. Antes de aceitar o estado, verificar se os dois primeiros passos do plano não dependem da face selada.
4. Se a condição falhar, tentar nova sequência usando a mesma seed base mais um contador determinístico.
5. Limitar a geração a 64 tentativas. Se não houver plano válido, usar fallback sem selo e registrar o motivo em debug.
6. `SealedFaceRule.can_execute(step)` rejeita apenas a face selada enquanto `accepted_moves < 2`; `register_move(step)` incrementa uma vez após movimento confirmado.
7. Ao completar dois movimentos válidos, remover o selo com efeito visual e atualizar HUD. A partir daí, a sequência inteira fica disponível.
8. O selo não altera a orientação, a posição ou a cor matemática de nenhum cubie.

## Implementação por arquivo

- `scripts/c20/sealed_face_rule.gd`: estado puro `sealed_face`, `accepted_moves`, `can_execute`, `register_move`, `is_unlocked`.
- `scripts/c20/scramble_validator.gd`: geração/rejeição determinística e fallback.
- `scripts/c20/sealed_visuals.gd`: cadeado/anel na face e animação de quebra.
- `scripts/c20/special_director.gd`: adicionar espécie `sealed`, ondas, profundidade e recompensa provisória.
- `scripts/c20/game_stage.gd`: interceptar o passo antes da rotação e liberar input após confirmação.
- Atualizar `KubeJournal.CATALOG` e o catálogo de maestria/conquistas mantendo IDs antigos.
- `tests/unit/test_c20_sealed_rule.gd`, `tests/unit/test_c20_scramble_validator.gd`, `tests/integration/test_c20_sealed_game.gd`.

## Contratos

- A regra recebe o passo que o diretor realmente pretende executar; não deduz a face pela posição do mouse.
- Um movimento só conta depois da animação terminar e do estado lógico ser confirmado.
- A tentativa de movimento bloqueado não gasta cooldown, timer, moeda nem contagem de movimentos.
- A cena deve mostrar claramente qual face está selada e quantos movimentos faltam.
- Não aplicar a regra no Laboratório C16; o modo livre continua com todas as faces.

## Testes e aceitação

- 1.000 seeds de teste não produzem sequência impossível nem softlock.
- O mesmo seed e versão de algoritmo reproduzem a mesma face e sequência.
- Os dois primeiros movimentos permitidos funcionam; face selada é bloqueada; após o segundo movimento todas liberam.
- Input bloqueado não altera puzzle, timer, cooldown ou carteira.
- Fallback sem selo é funcional e visível apenas em debug.
- Bestiário, conquistas, maestria e pagamento são registrados uma única vez.

**Fora do escopo:** bloqueio permanente, sequência secreta ou comandos que não existam no tutorial.
