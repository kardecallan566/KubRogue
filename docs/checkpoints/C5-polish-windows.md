# C5 — Polimento visual, som, acessibilidade e build de teste Windows

**Branch:** `dev/checkpoint-05-polish-windows`  
**Godot:** 4.7.2 (Compatibility, OpenGL 3.3)  
**Gate:** executar testes automáticos, exportar Windows, verificar em janela real no Windows e receber aprovação do usuário **antes de fazer merge**.

## Alterações do C5

1. **Cena principal:** hub refinada em tons verde pastel, cards claros, botões com hover/pressed e modal com rolagem. Menu da loja passa a acomodar mais conteúdo em 720p. Os botões originais e a navegação permanecem.
2. **Áudio original procedural:** `KubeAudio` sintetiza efeitos curtos e melodia instrumental simples sem arquivos baixados. Categorias: toque, giro, solução, moeda, surgimento, nível, transição de onda, elite, erro e vitória; máximo seis canais de efeitos ao mesmo tempo, música em loop. **Não afirmar qualidade sonora profissional sem ouvi-la**.
3. **Volumes reais:** `music_volume` e `effects_volume` continuam persistentes pelo C4, agora alterando os players, inclusive opção volume zero (silêncio).
4. **Feedback visual:** pulsos circulares, partículas efêmeras e números flutuantes em `CanvasLayer` quando um giro é realizado ou um cubo é resolvido. Não intercepta clique, usa limite de 22 pulsos, desativa processamento quando não há animações. `reduced_particles` substitui confetes por um aro simples; texto da recompensa permanece visível.
5. **Conforto:** camera shake apenas se `screen_shake` estiver ativado e apenas ao perder estabilidade; default OFF. Animação pequena, sem telas piscando.
6. **Cenário:** o Jardim dos Cubos permanece um gramado plano contínuo, sem bordas ou plataforma. Tufos não têm colisão; no C5 66 tufos são instâncias do mesmo mesh por MultiMesh em vez de nós independentes.
7. **Arquitetura:** C4 não foi sobrescrito. Novas cenas em `scenes/c5/`, scripts em `scripts/c5/`; as cenas C0–C4 continuam abrindo diretamente.
8. **Windows:** `export_presets.cfg` define preset `Windows Desktop` x86_64. O workflow separado `windows-export.yml` pode ser acionado em Actions/Run workflow para baixar o template oficial 4.7.2 e criar arquivo ZIP com `KubRogue.exe` e `KubRogue.pck`. É um pacote de teste, não instalador, não assinado, sem Steamworks e sem certificação Steam.

## Testar no Windows

```powershell
git fetch origin
git switch dev/checkpoint-05-polish-windows
git pull origin dev/checkpoint-05-polish-windows
godot .
```

A cena inicial é a nova hub; para comparar com a versão aprovada C4, abra `scenes/c4/hub_stage.tscn` com F6. O save permanece em `user://kubrogue_progress_v1.json`. **Não apague esse arquivo para testar.**

## Testes obrigatórios

- [ ] Abertura limpa com `godot .` antes de criar `.godot/`; sem dependência de tipo global.
- [ ] Jogar → resolver 2×2 → receber moeda persistente → voltar à hub; sem dupla recompensa.
- [ ] A elite 3×3 aparece na onda cinco, e as cartas/XP funcionam sem interrupção indevida.
- [ ] A hub e os modais cabem em 1280×720 e 1920×1080; loja rola e botões podem ser clicados.
- [ ] Sons de giro, solução, moeda, nível, surgimento, elite e vitória tocam quando esperado.
- [ ] Música está em loop e seus controles alteram volume em tempo real; volume zero silencia música ou efeitos separadamente.
- [ ] "Reduzir partículas" diminui partículas sem apagar números de recompensa ou o aro; não bloqueia interação.
- [ ] "Tremor de câmera" é opcional, desligado por padrão e só age na perda de estabilidade.
- [ ] FPS confortável com 4 cubos, 3×3 elite, UI e VFX; sem vazamento de labels/partículas após várias soluções.
- [ ] Cenas antigas C0–C4 continuam funcionando e testes C0–C5 passam.
- [ ] Instalar templates oficiais Godot 4.7.2; exportar Windows e conferir existência de `.exe` + `.pck` e abertura real por duplo clique.
- [ ] ZIP de Windows no Actions (workflow manual) só é considerado entregue após execução **bem-sucedida** e verificação.
- [ ] Reabrir a versão exportada preserva progresso na pasta de dados do usuário.

## Limites

O C5 é preparação para um primeiro **teste distribuível**, não publicação final na Steam/Google Play, e não inclui assinaturas digitais, integração Steamworks, conquistas online, multiplayer ou verificação anticheat. Os sons e cores são originais e ainda devem passar por revisão humana de estética e conforto.
