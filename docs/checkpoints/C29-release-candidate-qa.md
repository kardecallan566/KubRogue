# C29 — Release Candidate e QA final

**Estado:** planejado; nenhum código C29 existe. **Base:** C28 aprovado. **Branch sugerida:** `release/1.0.0-rc` ou branch de checkpoint definida no momento.

## Objetivo

Congelar funcionalidades e provar que a experiência integrada é estável. C29 é principalmente correção, validação e documentação; feature nova volta ao backlog.

## Matriz funcional

- Campanha Normal, Desafio Diário, Desafio Semanal e Laboratório.
- Todas as espécies, biomas, chefe e sinergias.
- Bestiário, maestrias, conquistas, contratos, Oficina, rotas, Fever, medalhas e carreira.
- Acessibilidade, dois idiomas, mouse/teclado e gamepad.
- Saves novos, saves de versões anteriores, backup, arquivo corrompido, versão desconhecida e falha de gravação.
- Pausa, alt-tab, foco perdido, desligamento durante transação e retorno à hub.
- Resoluções 1280×720, 1920×1080, 16:10 e 21:9.

## Protocolo de QA

1. Definir build SHA e hardware de teste.
2. Rodar suíte headless e exportação limpa.
3. Executar pelo menos 20 runs com seeds registradas: vitórias, derrotas, Diário e Semanal.
4. Testar cinco jogadores sem instrução verbal; registrar entendimento, tempo até primeira solução, abandono e problemas de leitura.
5. Corrigir bugs P0/P1; classificar P2/P3 e decidir explicitamente se podem ser adiados.
6. Repetir a matriz após correções. Não aceitar teste em editor como substituto de build exportada.
7. Congelar assets, traduções e dados após assinatura do RC.

## Implementação por arquivo

- `tests/qa/`: roteiros automatizáveis de save, modos, cena e seed.
- `docs/qa/rc-checklist.md`: checklist assinado com build SHA, hardware, resultados e issues.
- Atualizações pontuais em `tests/integration/` e workflows somente para cobrir falhas reproduzíveis.
- Não criar sistema de analytics novo; usar exportação C18 se o usuário habilitou.

## Critérios de bloqueio

Bloquear RC por crash, save perdido/corrompido sem recuperação, recompensa duplicada, puzzle impossível, softlock, modo inacessível, controle principal quebrado, erro de localização que impeça ação ou desempenho muito abaixo do alvo sem plano.

## Aceitação

- CI, importação limpa e export Windows aprovados no mesmo SHA.
- Executável testado fora do editor.
- 20 runs sem defeito crítico e com resultados reproduzíveis.
- Cinco testes humanos concluídos e achados tratados.
- Licenças, créditos, versão e instruções de instalação revisados.
- Usuário aprova visual/jogabilidade e autoriza declarar RC.

**Fora do escopo:** adicionar conteúdo, balancear por gosto sem dados ou publicar.
