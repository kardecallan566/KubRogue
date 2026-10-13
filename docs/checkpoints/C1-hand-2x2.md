# C1 — Primeira fatia jogável: cursor de mão 2D e resolução compacta de 2×2

**Branch:** `dev/checkpoint-01-hand-2x2`, baseada na main após merge de C0.
**Status:** implementação + testes automatizados; validação gráfica/manual exigida antes de merge.

## Entregas incluídas

1. Cubo 2×2 genuíno com **8 cubinhos de canto, 24 adesivos**, cores consistentes, chanfros e pivôs; não é textura falsa.
2. Motor lógico 2×2 com giros de faces legais, testes de inversão, seed reproduzível e condição canônica solucionada.
3. Reaproveitamento do modelo 3×3 procedural do Kubos no projeto, preservando a cena e testes antigos do C0.
4. Mão desenhada em **2D** diretamente numa CanvasLayer, com contorno original e ponta alinhada ao mouse; a seleção de cubo ainda usa posição 3D calculada no campo XZ.
5. **Clique esquerdo ou botão pressionado** para executar giros na região do alvo; cooldown definido por segundos e bloqueio durante uma animação em curso.
6. Anel luminoso quando existe seleção, texto de movimentos restantes, seed, quantidade de cubos resolvidos, moedas e XP **de demonstração**.
7. Após um cubo realmente resolvido, somar **+10 moedas e +1 XP apenas em memória**, marcar recompensa única e chamar novo scramble. Não somar ao tocar enquanto ainda embaralhado.
8. Gramado estilizado de campo aberto, câmera ortográfica fixa, manchas de baixo relevo, iluminação e HUD mínima.
9. CI estendido para testar 2×2 e loop de recompensa sem retirar os testes do C0.

## Limites intencionais

- Não há **carteira persistente**; ao reiniciar o jogo zera a recompensa de teste.
- Não há ondas, timers, estabilidade, cartas, upgrade ou loja; entram em C2–C4.
- Sem free-form solver: ações consomem **uma solução válida inversa do embaralhamento**; o jogador prioriza controle/tempo no futuro.
- Mão 2D é um cursor estilizado procedural, não um sprite externo nem uma malha 3D. Seu desenho poderá ser polido sem mudar o gameplay.
- Existe exatamente **um cubo alvo** em tela, para validar sensação antes de multiplicar a arena.
- O C0 mantém seu 3×3 e não usa o 2×2 por padrão.

## Jogar no Windows

```powershell
git clone -b dev/checkpoint-01-hand-2x2 https://github.com/kardecallan566/KubRogue.git
cd KubRogue
```

Abra `project.godot` no Godot **4.7.2** e pressione **F5**. Mova cursor sobre o cubo até aparecer o anel de foco, clique ou segure o botão esquerdo. Use o botão "Novo cubo" para trocar de seed. Para a cena anterior C0, abra `scenes/c0/cube_inspection.tscn` diretamente e pressione F6.

## Critérios de aceite manual

- [ ] Gramado claro ocupa toda a tela, sem bordas, plataforma ou grid.
- [ ] Mão **2D** acompanha o cursor pixel a pixel e não cobre completamente as faces; na HUD volta o ponteiro normal.
- [ ] Próximo ao cubo aparece o anel; longe ou sobre a HUD não é possível girar.
- [ ] Um clique = um giro legal, segurar executa giros sequenciais regulados por cooldown.
- [ ] Rotações de 90° e 180° não deformam cubinhos nem soltam stickers.
- [ ] 10 cubos consecutivos completam, com um crédito provisório por cubo.
- [ ] Sem recompensa ao passar o mouse, clicar longe ou apertar em botão.
- [ ] Repetir nova seed não concede dinheiro; ESC/fechar não corrompe cenas.
- [ ] Janela 1280×720 e 1920×1080 com mão, alvo e HUD legíveis.
- [ ] Rodar novamente cena C0 para garantir 3×3 sem regressões.
- [ ] Godot CI verde para branch; testar também graficamente com Windows.

## Próximo marco: C2

Implementar campo com spawn até 4 alvos, reforçado 2×2, timer, estabilidade, ondas, economia de run centralizada e HUD mais completo. **Não fazer C2 antes de validar a experiência manual do C1.**

## Correção pós-teste: 2×2 compacto e mão 2D

A captura do primeiro teste expôs **vãos exagerados**: no domínio 2×2 os cantos têm coordenadas ±1; o visual 3×3 aplica `root.position=Vector3(p)*STEP`, criando distância entre centros de `2*STEP=0.676` para cubinhos de tamanho `CELL=0.327`. Assim, o vão por eixo era `0.676-0.327=0.349` unidade, parecendo quatro pilares.

**Correção:** manter todas as peças matematicamente corretas mas aplicar `root.position=Vector3(p)*(STEP/2)` no 2×2, usando um hook `_grid_step()` sobrescrito no modelo 2×2. O passo físico passa a `0.338` e a junta visível para `0.011` unidade, inclusive depois de cada giro e snap. O 3×3 do C0 fica inalterado. O 2×2 é exibido um pouco maior e repousa sobre o gramado.

**Mão:** remover a malha de mão 3D e substituí-la por `scripts/visual/hand_cursor_2d.gd`, Control que desenha uma mão vetorial original na CanvasLayer, com hotspot na ponta e `MOUSE_FILTER_IGNORE`. O mouse nativo reaparece na HUD e após sair da cena, evitando cursor duplicado. **Campo:** material gramado unshaded para manter verde pastel sem ser lavado pela iluminação.

**Testes de regressão adicionados:** distâncias entre cubinhos adjacentes em X/Y/Z antes e após giros, 24 adesivos e animação de solução; mão ser Control na CanvasLayer, não interceptar input e seguir hotspot. Repetir teste gráfico no Windows; CI automatizado não substitui a revisão visual.
