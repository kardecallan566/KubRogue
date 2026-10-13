# 09 — Qualidade, riscos, direitos e validação

## 1. Matriz de riscos

| Risco | Impacto | Probabilidade inicial | Mitigação |
|---|---|---|---|
| Mão resolver vira apenas “clicar HP” | Crítico | Alta | Rotação de camada real e teste C1 com usuários |
| Modelo 3D é malha única / licença incerta | Alto | Média | Auditoria C0; fallback procedural |
| 3x3 render e estado divergem | Alto | Média | Modelo de grade discreta + snap + seeds |
| Complexidade de solver livre explode escopo | Alto | Alta | Somente plano inverso de embaralhamento |
| Recompensa duplicada ao pausar/sair | Alto | Média | Estado SOLVED único, IDs de transação, testes |
| Run monótona com alvos fáceis | Alto | Média | Diferentes profundidades, elite, 8 cartas e pacing |
| Sem tempo para resolver 3x3 no fim | Médio | Média | Aferir movimentos, quota e timer no playtest |
| HUD e mão cobrem cubos | Médio | Alta | Safe zones e testes 720p/1080p |
| Performance despenca com cubinhos/partículas | Médio | Média | Limite de 4 atores, profiler e pooling se necessário |
| Referência fica parecida demais visualmente | Alto | Média | Design, nomenclatura, ícones, sons e recursos originais |

Probabilidades são **estimativas de projeto**, não medições.

## 2. Testes de puzzle: unitários

- Dado um estado resolvido, aplicar embaralhamento de comprimento N e seu inverso retorna a estado resolvido.
- Girar qualquer face 4 vezes em 90° retorna o estado original.
- Girar camada 180° duas vezes retorna o estado original.
- Rotação de camadas nunca elimina/duplica cubinhos ou adesivos.
- Todas as cores permanecem presentes na contagem esperada; cada peça conserva seus adesivos.
- Repetir seed e parâmetros gera mesmo estado embaralhado.
- Conferir solução real pelo estado, não apenas esgotamento do array de comandos.
- Gerar 1000 seeds por categoria de cubo e realizar solução completa, sem falso estado solúvel.

## 3. Testes de gameplay: integração

- Mouse fora da arena não altera cubos nem dinheiro.
- Input durante pausa não gira.
- Input em cubo durante fim de onda não concede moedas duas vezes.
- Segurar clique inicia uma sequência regulada por cooldown, não pelo FPS; comparar a 30, 60 e 144 FPS.
- Ao sumir um cubo, ponteiro deixa de selecioná-lo.
- Resumo de onda distingue spawns **não apresentados** (sem penalidade) de cubos **spawnados não resolvidos** (com penalidade), evitando punição injusta.
- Carta com giro duplo nunca avança para cubo já resolvido.
- Loja rejeita compra sem saldo ou acima do nível máximo.
- Save preserva saldo, configurações e nível de meta ao reiniciar.
- XP de run não sobrevive e moeda sobrevivente não diminui ao perder.
- Clicar em botão de menu sobre a arena não atravessa a interface.

## 4. Testes de estabilidade e performance

Simular 20 sequências de runs (variar RNG e upgrades), reiniciar cena repetidamente e monitorar objetos ativos, memoria e FPS. Submeter puzzle a animações encadeadas e ESC no meio da transição. Confirmar que timers pausados não continuam via processamento independente não intencional.

Teste formal de export: abrir projeto sem warnings críticos, exportar Windows, executar build sem editor instalado, resolver cubo, perder e vencer, verificar save gerado em user://.

## 5. Testes com jogadores

Aplicar cenário sem tutorial verbal com ao menos cinco pessoas:
- Em que momento entenderam que o cubo deve ser resolvido, não destruído?
- Conseguiram distinguir moeda e XP?
- Sentiram que clique e rotação tinham relação clara?
- A elite 3x3 parece desafiadora ou cansativa?
- Qual carta parece interessante? Alguma opção parece sem efeito?
- Queriam jogar outra vez? Em caso negativo, por quê?

Registrar tempo até primeira resolução, erros comuns, taxa de sucesso, tempo da run e feedback qualitativo. Priorizar eliminar frustração antes de adicionar conteúdo.

## 6. Licenciamento e identidade original

King of Pickaxe é referência de **padrão de experiência** (mouse + ondas + cartas), não pacote de assets. Não copiar os personagens, pedras, imagens da Steam, interface, músicas, sons, textos, animações, código, identidade de marca ou layouts únicos.

Uma mecânica abstrata isolada não deve ser tratada como licença para replicar a expressão artística específica de outro jogo. Manter design próprio: resolver formas geométricas, rotação correta de camadas, estética de oficina de puzzles e mão como protagonista.

O modelo 3D citado pelo desenvolvedor deve ter direitos de uso, modificação e distribuição comercial verificados. Registrar arquivos LICENSE/ATTRIBUTION ou equivalente quando aplicável. Evitar usar logotipos/marcas de cubo comerciais em ícones e publicidade sem autorização; usar nomenclatura genérica (cubo de cores, 2x2, 3x3).

## 7. Segurança e dados

MVP é offline; não coleta contas nem dados pessoais. Salvar somente progresso, saldo e opções localmente. Um save editável não é vulnerabilidade de rede, mas deve ser validado para impedir crashes/inteiros inválidos. Proteger o jogo contra arquivos enormes, chaves inesperadas e versões antigas do esquema. Não adicionar telemetria externa ou SDK de propaganda só para medir primeiro playtest — usar anotações e métricas locais autorizadas.

## 8. Definition of Done técnica

Concluir uma tarefa só quando: regra escrita -> caso de teste -> implementação -> execução real -> revisão visual -> log/evidência -> sem regressões óbvias. Se faltar arquivo/asset, marcar bloqueado. Não afirmar que o MVP está pronto enquanto nenhum executável do Godot tiver sido testado.

## 9. Testes adicionais de mapa e oferta

- O gramado cobre a câmera toda, sem bordas, muros, texturas de terceiros ou chão quadriculado; 720p/1080p/16:10.
- O cursor projetado por câmera fixa coincide com a mão sem deriva, inclusive quando o mouse permanece parado.
- 4 cubos não se sobrepõem a outras hitboxes ou HUD; decorativos não interceptam raycast.
- Na onda 5, três cubos comuns podem estar ativos e a elite **ainda assim** aparece até o segundo 20.
- Na expiração com spawns pendentes, somente cubos realmente apresentados retiram 25 de estabilidade cada.
- Cartas oferecem 1/3 opções ao atingir XP 5/12/21/32/45 **antes** do estado terminal; nenhuma carta aparece em victory/defeat.
- Transação de moeda é durável antes da HUD confirmar pagamento, inclusive em caso de encerramento no mesmo frame.
- Material 3D real é auditado quando enviado (licença, peças, pivôs, giro). Não presumir que já está no GitHub.

Plano original completo em [11](11-mapa-campo-aberto-e-camera.md), [12](12-gamefeel-eventos-visuais-e-detalhamento.md) e [13](13-auditoria-de-consistencia.md).
