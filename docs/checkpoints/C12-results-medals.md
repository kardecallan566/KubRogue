# C12 — Salão de Medalhas e histórico de partidas

**Branch:** `dev/checkpoint-12-results-medals` · **Godot:** 4.7.2 Compatibility · **PR:** aguarda aprovação do usuário.

## Objetivo

Dar ao jogador uma conclusão memorável da run e incentivo para rejogar, sem inflar moedas, sem uma quinta ação na hub e sem alterar a resolução real dos cubos, os contratos, a Oficina, as Rotas ou o Fever.

## Medals: regras transparentes, sem sorte

As medalhas são **cosméticas**, calculadas apenas quando a run termina por vitória. Derrota termina com `SEM MEDALHA`. Uma vitória tem Bronze; passa a Prata com pelo menos **35 de estabilidade**; atinge Ouro quando termina com **70 de estabilidade**, **2 contratos concluídos** e **combo máximo de 4** ou mais. Não há novos pagamentos nem desbloqueios permanentes associados a essa classificação. Os valores podem ser ajustados por feedback do usuário.

## Tela de conclusão

Ao vencer/perder a quinta ou outra onda por regras já existentes, o resumo padrão apresenta um banner colorido com medalha e métricas da partida: cubos resolvidos, moedas **ganhas** (antes de compras), maior sequência de combo, contratos, ativações de Fever e cartas de habilidade escolhidas. A navegação original `Voltar à hub` permanece. Resumos intermediários exibem as mesmas informações que antes, sem medalha e sem criar histórico.

## Salão de Medalhas

A hub mantém **quatro botões**. No **Bestiário**, um botão **HISTÓRICO DE PARTIDAS** abre uma galeria com dois cards por linha, contendo medalha, modo/dia, onda atingida, cubos, moedas, XP, combo, Fever, contratos e identificação da partida. O histórico é **local/offline** e limitado às 12 últimas partidas concluídas; recordes globais antigos de C4 e do modo diário C6 continuam preservados.

## Persistência e compatibilidade

O arquivo novo é `user://kubrogue_history_v1.json`, por `SaveStore`, **separado** dos saves C4/C6/C8. Registros incluem `run_id` que é o número persistente da run em C4: salvar duas vezes o mesmo resultado não duplica medalhas. Nenhum conteúdo é migrado do histórico de moedas ou dos recordes antigos (faltam informações de run). O serviço protege JSON ilegível e futuras versões incompatíveis; registra erro em vez de sobrescrever os dados. Quando um salvamento falha temporariamente, o resultado fica pendente em memória e a hub tenta novamente quando o usuário abre o histórico. Isso não garante recuperação após encerrar o jogo sem salvar; os outros saves permanecem independentes e intactos.

## Testes

- Cold boot antes do cache de classes do Godot.
- Unitário: todos os quatro níveis de medalha, run IDs inválidos, idempotência, 12 registros, reload, arquivo principal corrompido com backup, versão futura protegida.
- Integração: vitória da onda 5 confirmada pelo diretor real, medalha Ouro, snapshot coerente de Fever/contratos, Bestiário com botão de histórico sem alterar a hub, recuperação após reinício.
- Toda a suíte anterior C0–C10 + auditoria C11 e build Windows obrigatórias.

## Checklist manual

- [ ] Abrir `godot .` sem erros em cópia limpa.
- [ ] Vencer uma partida de 5 ondas e ler a medalha no resumo final.
- [ ] Perder uma partida e confirmar ausência de medalha de vitória.
- [ ] Conferir que contratos, Fever e moedas mostradas refletem a run concluída; não houve crédito adicional.
- [ ] Abrir `Bestiário → Histórico de Partidas`; os cards devem ter datas, rótulos e medalhas legíveis.
- [ ] Reiniciar o jogo, voltar ao Salão e confirmar as conquistas anteriores.
- [ ] Histórico vazio mostra ajuda clara; com 12+ partidas guarda apenas as 12 últimas.
- [ ] Confirmar menu principal com apenas Jogar/Bestiário/Configurações/Sair.
- [ ] Conferir layout em 1280×720 e 1920×1080 e executar quatro ondas com Rotas e Oficina.
- [ ] Não sobrescrever os arquivos reais para testar corrupção; usar cópias.

**Critério de merge:** CI e Windows verdes, mais teste visual e aprovação do jogador.
