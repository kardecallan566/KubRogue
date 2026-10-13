# C0 — Checklist de teste manual (Godot 4.7.2)

## Instalação e abertura

- [ ] Abre `project.godot` sem falhas de parse.
- [ ] Exibe a cena de inspeção do cubo 3×3 no centro de campo gramado aberto.
- [ ] Nenhum asset do Kubos precisa de caminho fora de `res://`.

## Geometria e animação

- [ ] Contagem estruturada: 26 corpos, 54 adesivos; nenhum cubinho preto ou ausente.
- [ ] Inspecionar faces branca, amarela, vermelha, laranja, verde e azul.
- [ ] A rotação de camada não leva cubinhos vizinhos e não cria folga ou deslocamento residual.
- [ ] Um embaralhamento de 9 giros visivelmente mistura cores.
- [ ] Resolver passo a passo exibe rotações corretas das camadas e diminui o contador.
- [ ] Resolver todos termina com faces uniformes e texto "RESOLVIDO".
- [ ] Reset restaura estado canônico sem reaparecimento de peças no lugar errado.
- [ ] Repetir pelo menos 5 ciclos embaralhar -> resolver, incluindo dois giros de 180° por teste unitário/integração.

## Cena e ergonomia

- [ ] Campo de grama verde claro sem palco circular nem limites do chão.
- [ ] Câmera quase superior demonstra 3D real e mantém cubo no enquadramento.
- [ ] Painel não cobre a demonstração em 1280×720 e 1920×1080.
- [ ] Revisar contrastes entre adesivos, mão futura e piso verde.
- [ ] Registrar screenshot real da janela Godot no checkpoint.

## Para o próximo checkpoint C1

- [ ] Criar 2×2 real com coordenadas discretas próprias.
- [ ] Implementar mão 3D responsiva e seleção do cubo em campo aberto.
- [ ] Separar objeto de puzzle da cena de inspeção e conectar sinais de solução ao jogo.
- [ ] Definir teste de resolução arcade com seed e transações idempotentes futuras.
