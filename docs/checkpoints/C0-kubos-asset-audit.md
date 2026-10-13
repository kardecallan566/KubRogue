# C0 — Auditoria e adaptação do cubo 3×3×3 do Kubos

## Situação

**Implementação em branch de checkpoint**, destinada à revisão e teste antes de integração na `main`. O conteúdo implementa uma **cena técnica de inspeção**, não o jogo jogável do C1.

## Origem e rastreabilidade

- Repositório-fonte de propriedade do mesmo titular GitHub: [kardecallan566/Kubos](https://github.com/kardecallan566/Kubos) (privado).
- Ref consultada: `main`, commit `75cfcba4b9ab0d199b4bda8197fad2845377c9fe`.
- Fonte principal de geometria: `scripts/presentation/kubo_model.gd`; peças construídas procedimentalmente, **não é um arquivo .glb/.fbx/.blend**.
- Núcleo independente: `scripts/domain/cube_state.gd`.
- Gerador de malha arredondada: `scripts/presentation/rounded_box_mesh.gd`.
- Testes de domínio: `tests/unit/test_cube_state.gd`.
- Arquivos do modelo e domínio em KubRogue são **cópias adaptadas dos scripts do mesmo proprietário**; os componentes de economia, celular, menus, skins comerciais e acessórios do Kubos não foram migrados.
- O Kubos não apresenta um arquivo LICENSE na árvore consultada. Como ambos pertencem ao mesmo proprietário, a adaptação foi solicitada diretamente pelo titular. **Não pressupõe licenciamento de assets externos ou de terceiros.** Em caso de incorporar conteúdo de terceiros, verificar autorização antes de distribuir.

## Descobertas

1. Cubo 3×3×3 real: 26 cubinhos externos (centros, cantos e arestas), 54 plaquinhas coloridas; malhas compartilhadas para corpos e adesivos.
2. Medidas da fonte: tamanho do corpo `0.327`, distância de centros `0.338`, adesivo `0.283×0.283×0.014`, raio do chanfro `0.023`.
3. Estado lógico inteiro baseado em posição e orientação, com giro de face `U D R L F B`; histórico reversível de embaralhamento.
4. Animação de face por `TemporaryLayerPivot`, seguida de snap do estado discreto; não depende de rig humano nem de arquivo externo.
5. A implementação de fonte já possui teste de domínio e teste de integração; **os testes do Kubos não substituem rodar os novos testes no KubRogue**.

## O que foi implementado no C0

- Projeto Godot autônomo com cena principal `scenes/c0/cube_inspection.tscn`.
- Reaproveitamento de `CubeState` e `RoundedBox`.
- Adapter `KubRogueCube3D`: recria 26 cubinhos, 54 placas, seis cores e giro real de camada, com restauro de estado e plano reversível.
- Cena técnica com campo gramado aberto, Camera3D ortográfica fixa, iluminação e painel de inspeção (embaralhar / passo / resolver / reiniciar).
- Testes de domínio e de integração e workflow para Godot 4.7.2.
- Não existe mão interativa, ondas, moedas, XP nem vitória/derrota: pertencem a C1–C4.

## Limitações / gates restantes

- Não foi realizada validação visual em janela gráfica por este agente; a integração visual 720p/1080p, sombras, stickers e comportamento do mouse precisa ser observada **no Godot instalado pelo usuário**.
- A execução CI é a evidência automatizada prevista; conferir execução do Actions após push.
- Verificar se a silhueta, chanfros e espessura de adesivos atendem ao padrão da arte final. Inspecionar rotação 90° e 180° em todas as faces U/D/R/L/F/B.
- **O 2×2 ainda não existe:** o domínio e o modelo de origem são exclusivos para 3×3. Generalizar grid e faces será um trabalho de C1/C2 sem copiar o mesmo 3×3 reduzido artificialmente.
- O is_solved() herdado exige retorno à pose canônica de peças, orientação e cores; é compatível com o caminho de solução inversa do C0, mas é mais estrito que simplesmente identificar faces uniformes de um cubo físico. Planejar refinamento da condição de vitória para o MVP.
- Cuidado ao girar cubo em outras animações: pose visual de personagem não pode entrar na lógica discreta.
- Antes de produção pública comercial, conferir direitos sobre qualquer recurso futuro não procedural.

## Executar localmente

1. Baixar esta branch do [KubRogue](https://github.com/kardecallan566/KubRogue), com Godot 4.7.2.
2. Abrir `project.godot`, depois executar a cena principal F6/F5.
3. O painel permite embaralhar um 3×3, resolver uma face por vez e executar todas as rotações de volta ao estado inicial.
4. Para testes headless:
   - `godot --headless --editor --path . --import --quit`
   - `godot --headless --path . --script res://tests/unit/test_cube_state.gd`
   - `godot --headless --path . --script res://tests/integration/test_c0_cube.gd`

## Critérios para fechar C0

- [x] Modelo concreto localizado, arquitetura analisada e origem registrada.
- [x] Estrutura e scripts 3×3 adaptados para repositório separado.
- [x] Testes de domínio e de integração adicionados.
- [x] Campo aberto/câmera fixa de inspeção implementados como cena Godot.
- [ ] Execução automatizada CI verde na branch (não marcar antes de comprovar).
- [ ] Captura e revisão visual real no Godot (não marcar sem evidência).
- [ ] Aprovação do modelo para uso como base em C1.

**C0 entregue para inspeção**, não declarado visualmente concluído.
