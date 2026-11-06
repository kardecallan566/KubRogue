# C25 — Localização Português do Brasil e Inglês

**Estado:** planejado; nenhum código C25 existe. **Base:** C24 aprovado. **Branch sugerida:** `dev/checkpoint-25-localization`.

## Objetivo

Oferecer Português do Brasil e Inglês com troca pela tela de Configurações. Português do Brasil continua como padrão para saves novos e instalações sem preferência definida.

## Arquitetura

- Usar o sistema nativo de tradução do Godot (`TranslationServer`) e arquivos CSV/Translation importados pelo projeto.
- Criar arquivos `data/i18n/pt_BR.csv` e `data/i18n/en.csv`, com chave estável na primeira coluna.
- Converter strings de interface para `tr("UI_...")`; manter IDs internos, enums, nomes de arquivo, logs técnicos e chaves de save em inglês estável.
- Persistir `language` em KubeSession.settings; validar contra `pt_BR` e `en`.
- Aplicar locale ao iniciar e imediatamente após mudança nas Configurações.
- Formatar datas e números por locale sem alterar chaves UTC de Diário/Semanal.

## Implementação por arquivo

- `data/i18n/pt_BR.csv` e `data/i18n/en.csv`: catálogo completo de strings visíveis.
- `scripts/c25/localization_service.gd`: `set_locale`, `current_locale`, `validate_key_coverage`.
- `scripts/c25/hub_stage.gd`: seletor de idioma.
- `scripts/c25/game_stage.gd`: textos de HUD, cartas, resultados, contratos e modos.
- `scripts/c25/lab_stage.gd`: faces, camadas, dicas e mensagens do Laboratório.
- `tests/unit/test_c25_localization.gd`: cobertura de chaves e fallback.
- `tests/integration/test_c25_locale_switch.gd`: troca em runtime, reinício e save.

A migração de strings deve ser feita por áreas, mantendo uma chave por mensagem e placeholders tipados. Não concatenar frases para montar tradução; traduzir a frase completa.

## Testes e aceitação

- Nenhuma label visível pode mostrar chave crua `UI_...` ou tradução vazia.
- Todos os botões, tooltips, modais, cards, Bestiário, contratos, Diário/Semanal, Laboratório e resultados existem nos dois idiomas.
- Inglês não pode cortar textos; revisar 1280×720 e 1920×1080.
- Trocar idioma não reinicia run nem altera seed, save, carteira ou histórico.
- Saves anteriores sem idioma usam pt_BR.
- Datas de desafio continuam calculadas em UTC; só a apresentação muda.

**Fora do escopo:** tradução automática em runtime, novos idiomas ou alteração de conteúdo narrativo.
