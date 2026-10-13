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
8. **Windows:** `export_presets.cfg` define preset `Windows Desktop` x86_64. O workflow separado `windows-export.yml` é executado ao atualizar a branch C5 e também pode ser acionado manualmente em Actions/Run workflow para baixar o template oficial 4.7.2 e criar arquivo ZIP com `KubRogue.exe` e `KubRogue.pck`. É um pacote de teste, não instalador, não assinado, sem Steamworks e sem certificação Steam.

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

## Revisão solicitada — UI arcade e música mais alegre

A referência visual fornecida mostra a construção gradual de botões arcade: traço, cor, sombra, luz e highlight. A implementação interpreta **essa técnica**, mas gera a textura original proceduralmente a cada variante/estado, sem incorporar a arte enviada nem fonte de terceiros. O desenho tem moldura marrom profunda, face colorida arredondada, listras suaves, brilho superior e texto branco com contraste forte.

- **Hub/loja/tutoriais/ajustes:** botões mais espessos, variações dourada (ação), verde (compras), azul (configuração/pausa) e vermelha (voltar/sair), estados ativo/hover/pressed/desabilitado. Painéis claros com bordas e sombra, sem transparências ilegíveis.
- **Gameplay:** barras de progresso da onda, tempo e estabilidade, com valores originais sincronizados à lógica. A área retangular da HUD é considerada no posicionamento dos cubos para impedir alvos cobertos.
- **Áudio:** a progressão original C–F–Am–G em oito compassos, 132 BPM, usando lead sincopado, baixo de notas curtas, arpejo de acordes e percussão procedural. Loop ~14,55 segundos; redução de clique na junção; volumes permanecem persistentes e aplicados em tempo real.

**Testes adicionados:** textura de botão e estados hover/pressed, duração real do PCM da música e presença das três barras da HUD, além da suíte anterior. Validação gráfica/sonora no Windows é obrigatória antes do merge.

## Refinamento C5.2 — Revisão de experiência após screenshots

As capturas do Windows mostraram botões desproporcionalmente largos, informações de combate excessivas e três habilidades apresentadas como barras horizontais de texto sem hierarquia. A implementação foi refeita mantendo a identidade do campo aberto/cubos.

- `ui_skin.gd` usa botões nativos com profundidade moderada e cantos arredondados; eliminadas texturas gigantes e o contorno excessivo do texto. As cores identificam função, mas o conteúdo é legível independentemente da cor.
- `hub_stage.gd` separa título, moeda, recorde, ações primárias e secundárias. A loja passou a oferecer cartões individuais sem interferir no estado de compra do C4.
- `game_stage.gd` mostra status em um painel compacto à esquerda com três barras discretas; dinheiro e XP em linhas específicas; botões de ação menores e recuperação do salvamento visível **somente quando necessária**.
- `skill_card.gd` fornece opções sem truncamento: categoria, nome, nível, bônus, explicação e botão. Três cartões lado a lado em janelas largas; coluna única rolável em janelas pequenas. Não muda as probabilidades de escolha ou os efeitos de C3.
- **Testar em 1280×720 e 1920×1080**, inclusive oferta de habilidades, três cartões distintos, clique e teclado, navegação de volta à hub, compras e pausa durante escolha.

O C5 continua em rascunho até aprovação do usuário; não substituir o save C4 e não fazer merge automaticamente.
