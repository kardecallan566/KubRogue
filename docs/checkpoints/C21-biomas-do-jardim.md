# C21 — Biomas do Jardim

**Estado:** planejado; nenhum código C21 existe. **Base:** C20 aprovado. **Branch sugerida:** `dev/checkpoint-21-garden-biomes`.

## Objetivo

Dar variedade visual às runs sem reconstruir o sistema de combate. A primeira versão contém três biomas com o mesmo layout, câmera, hitboxes, spawns e regras.

## Catálogo inicial

- `classic_garden` — Jardim Clássico: paleta verde atual.
- `golden_glade` — Clareira Dourada: luz quente, folhas douradas e partículas leves.
- `misty_orchard` — Pomar Nebuloso: tons frios, vegetação diferente e névoa de fundo sem cobrir cubos/UI.

A escolha deve ser determinística por seed da run e identificador da rota/onda. A mesma seed e versão do catálogo selecionam o mesmo bioma.

## Implementação por arquivo

- `scripts/c21/biome_definition.gd`: Resource com `id`, paleta, ambiente, materiais, lista de props e parâmetros visuais limitados.
- `scripts/c21/biome_catalog.gd`: whitelist de IDs, validação e seleção determinística.
- `scripts/c21/biome_applier.gd`: aplica paleta, WorldEnvironment, materiais, MultiMesh e partículas à cena de campo.
- `scripts/c21/game_stage.gd`: herdar do estágio aprovado e aplicar bioma antes do primeiro spawn.
- `scenes/c21/biomes/`: subcenas somente se os elementos precisarem de composição própria; preferir recursos reutilizáveis.
- `tests/unit/test_c21_biome_selection.gd` e `tests/integration/test_c21_biome_scene.gd`.

## Contratos técnicos

- Não duplicar toda a cena de gameplay para cada bioma.
- Não mover câmera nem pontos de spawn; cubos devem manter as mesmas posições/hitboxes.
- Manter GL Compatibility, sem shader exclusivo de Forward+.
- Na primeira entrega, biomas são **cosméticos**. Não alterar tempo, estabilidade, moedas, XP ou chance de spawn.
- Evitar chuva/neblina com transparência pesada; preferir partículas reduzidas, materiais opacos e MultiMesh.
- Respeitar C17: símbolos, contraste e movimento reduzido.
- Respeitar C18: medir frame-time com quatro cubos e efeitos ligados.

## Testes e aceitação

- Cada bioma tem screenshot/manual review em 1280×720 e 1920×1080.
- Mesma seed reproduz o mesmo bioma; seeds diferentes distribuem os três sem viés óbvio.
- Nenhuma decoração intercepta raycast ou cobre cubos/HUD.
- Com partículas reduzidas, a leitura do campo continua completa.
- Comparar desempenho com Jardim Clássico; não aceitar regressão relevante sem justificativa.

**Fora do escopo:** arenas com regras próprias, novos mapas de colisão ou modificadores econômicos.
