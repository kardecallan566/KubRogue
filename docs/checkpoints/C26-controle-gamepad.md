# C26 — Controle por gamepad

**Estado:** planejado; nenhum código C26 existe. **Base:** C25 aprovado. **Branch sugerida:** `dev/checkpoint-26-gamepad`.

## Objetivo

Permitir jogar menus, Laboratório e combate com controle sem remover o mouse. Mouse continua sendo o caminho padrão e o jogo deve continuar funcionando quando um controle é desconectado.

## Mapeamento inicial

- Analógico esquerdo: mover a mão virtual no plano da arena.
- A / botão inferior: interagir com o cubo focado ou confirmar botão selecionado.
- B / botão direito: voltar/cancelar.
- Start/Menu: pausar/abrir menu.
- D-pad: navegar foco de UI e, no Laboratório, selecionar face.
- LB/RB: alternar camada no Laboratório.
- Analógico direito não é necessário na primeira versão; evitar controles redundantes.

## Arquitetura

- Criar ações semânticas no InputMap: `move_cursor_left/right/up/down`, `interact`, `cancel`, `pause`, `face_prev/next`, `layer_prev/next`.
- `InputRouter` normaliza mouse, teclado e gamepad para comandos do jogo; a cena não deve consultar botões específicos do fabricante.
- A mão virtual é convertida para coordenadas de mundo por projeção de câmera/raio no plano do campo; respeitar safe area e não atravessar UI.
- A navegação de UI usa foco explícito e ordem previsível. Ao conectar/desconectar controle, alternar prompt visual sem reiniciar a partida.
- Deadzone configurável e histerese para evitar drift; o mouse recupera prioridade quando houver movimento real.

## Implementação por arquivo

- `scripts/c26/input_router.gd`: mapeamento de eventos para comandos semânticos.
- `scripts/c26/virtual_hand_cursor.gd`: posição, deadzone, limites e ray-plane.
- `scripts/c26/controller_prompts.gd`: ícones de botões e troca de prompt.
- `scripts/c26/hub_stage.gd`, `game_stage.gd`, `lab_stage.gd`: conectar ações sem copiar cenas inteiras.
- Atualizar `project.godot` InputMap com defaults; não sobrescrever mapeamentos personalizados existentes.
- `tests/unit/test_c26_input_router.gd` e `tests/integration/test_c26_gamepad_navigation.gd`.

## Testes e aceitação

- Testar ao menos um controle XInput e um controle genérico reconhecido pelo Godot.
- Menu, diálogos, cartas, Oficina e Laboratório funcionam sem mouse.
- A mão virtual alcança todos os cubos sem deriva e sem clicar através de HUD.
- Desconectar controle durante run não pausa nem trava o jogo; mouse continua funcional.
- Deadzone elimina drift e é configurável.
- Mouse, teclado e gamepad podem ser alternados sem duplicar ações ou recompensas.

**Fora do escopo:** mobile, touch, remapeamento avançado por perfil ou suporte a volante/joystick especializado.
