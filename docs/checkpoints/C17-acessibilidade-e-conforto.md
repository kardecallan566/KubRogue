# C17 — Acessibilidade visual e conforto

**Estado:** planejado; nenhum código C17 existe. **Base:** C16 aprovado e integrado. **Branch sugerida:** `dev/checkpoint-17-accessibility`.

## Objetivo

Garantir que nenhuma face seja identificada somente pela cor e oferecer opções simples de conforto visual. Não alterar as regras de rotação, o estado do puzzle, os pagamentos ou a dificuldade.

## Regras e fluxo lógico

1. Criar um catálogo imutável de marcadores por cor/face: símbolo geométrico + contorno + padrão simples.
2. O perfil padrão preserva o visual atual. O perfil Símbolos adiciona marcadores a todas as faces; Alto Contraste aumenta contraste e espessura de bordas.
3. A escala da UI usa níveis discretos (100%, 110%, 125%) para evitar valores que quebrem o layout.
4. Movimento reduzido diminui duração de transições decorativas, tremor e partículas; nunca encurta a janela lógica de input nem altera o resultado de movimentos.
5. Configurações são aplicadas imediatamente e persistidas por KubeSession. Saves antigos recebem defaults; nenhuma migração destrutiva.
6. O modo de acessibilidade também se aplica ao Laboratório C16 e aos cards de Bestiário/contratos.

## Implementação por arquivo

- `scripts/c17/accessibility_profile.gd`: classe pura com IDs `default`, `symbols`, `high_contrast`; função `marker_for_face(face_id, profile_id)` e `normalize_settings(raw)`.
- `scripts/c17/accessibility_controller.gd`: aplica perfil, escala e movimento reduzido a uma raiz Control; expõe `apply_to(root)` e sinal `profile_changed`.
- `scripts/c17/hub_stage.gd`: herdar da hub C16 aprovada e acrescentar seção Acessibilidade em Configurações.
- `scripts/c17/game_stage.gd`: herdar da cena C16 aprovada; aplicar perfil aos cubos criados e ao HUD.
- `scripts/visual/face_marker_overlay.gd`: desenhar marcador/símbolo sem modificar stickers ou estado lógico.
- `tests/unit/test_c17_accessibility.gd`: mapeamento, normalização e limites.
- `tests/integration/test_c17_accessibility_ui.gd`: save antigo, hub, combate e laboratório.

### Contrato proposto

- Novas chaves em `KubeSession.data.settings`: `face_profile`, `ui_scale`, `reduced_motion`.
- Defaults: `default`, 1.0 e false. Validar valores com whitelist; não aceitar escala arbitrária.
- Funções propostas no controlador: `set_face_profile(id)`, `set_ui_scale(value)`, `set_reduced_motion(enabled)`.
- IDs de faces e espécies permanecem invariáveis; só o desenho e o texto visível mudam.

## Testes e aceitação

- Verificar as seis cores em cada perfil e confirmar que símbolos não se confundem em 720p.
- Confirmar que a lógica do cubo gera snapshots idênticos antes/depois de trocar perfil.
- Carregar save C4/C14 antigo sem chaves novas e confirmar que o jogo inicia e não sobrescreve dados.
- Verificar 1280×720, 1920×1080, 16:10 e 21:9; nenhum marcador pode cobrir a hitbox ou a HUD.
- Movimento reduzido não pode alterar quantidade de giros, cooldown de gameplay, tempo de onda ou pagamentos.
- Validar contraste, foco de teclado e leitura no Bestiário e Laboratório.

**Fora do escopo:** remapeamento de controle (C26), novas cores obrigatórias, alteração da economia ou reformulação completa de arte.
