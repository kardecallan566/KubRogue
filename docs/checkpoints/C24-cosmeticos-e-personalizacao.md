# C24 — Cosméticos e personalização

**Estado:** planejado; nenhum código C24 existe. **Base:** C23 aprovado. **Branch sugerida:** `dev/checkpoint-24-cosmetics`.

## Objetivo

Permitir personalizar a mão e a aparência dos cubos sem vantagem competitiva. Todos os cosméticos iniciais são obtidos jogando; não há compras com dinheiro real.

## Conteúdo inicial

- Três temas de adesivos: Clássico, Jardim e Neon Suave.
- Três aparências de mão: Padrão, Luva de Jardinagem e Mão Cristalina.
- Uma prévia 3D/2D na Oficina; o jogador pode selecionar somente itens desbloqueados.
- Desbloqueios por marcos já existentes (maestria, conquistas, desafios), sem criar grind ou moeda nova.

## Persistência e lógica

- Catálogo com IDs imutáveis, categoria, requisitos de desbloqueio e dados visuais.
- `CosmeticService.is_unlocked(id)` deriva ou lê desbloqueios; `equip(category, id)` valida o catálogo e persiste a seleção.
- Preferir derivar desbloqueios de conquistas/maestrias para evitar duplicar contadores. Se houver save próprio, guardar apenas seleção e flags de unlock que não possam ser derivadas.
- Save independente sugerido: `user://kubrogue_cosmetics_v1.json`, com versão, tamanho limitado e SaveStore.
- Tema padrão sempre disponível como fallback; save inválido não pode impedir a partida.
- Não modificar cor/símbolo de acessibilidade C17; cosmético deve preservar contraste mínimo e marcadores.

## Implementação por arquivo

- `scripts/c24/cosmetic_catalog.gd`: catálogo e requisitos.
- `scripts/c24/cosmetic_service.gd`: seleção, validação e persistência.
- `scripts/c24/cosmetic_preview.gd`: prévia sem instanciar campanha.
- `scripts/c24/cosmetic_card.gd`: UI de seleção.
- `scripts/c24/hub_stage.gd`: entrada na Oficina/Personalização sem adicionar botão principal.
- `scripts/c24/game_stage.gd`: aplicar tema ao spawn do cubo e à mão.
- `tests/unit/test_c24_cosmetics.gd` e `tests/integration/test_c24_cosmetics_save.gd`.

## Testes e aceitação

- IDs desconhecidos e itens bloqueados não podem ser equipados.
- Save novo/antigo/corrompido usa tema padrão e preserva backups.
- Trocar cosmético não altera snapshot lógico, hitbox, cooldown, recompensa ou dificuldade.
- Perfil C17 mantém contraste e símbolos em todos os temas.
- Laboratório e campanha mostram o mesmo item equipado, sem conceder progresso.
- Nenhuma compra de dinheiro real ou moeda paga.

**Fora do escopo:** marketplace, itens aleatórios pagos, skins que escondem faces ou bônus de atributos.
