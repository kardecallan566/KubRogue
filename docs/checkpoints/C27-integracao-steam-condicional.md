# C27 — Integração Steam (condicional)

**Estado:** planejado e bloqueado por decisão de produto; nenhum código C27 existe. **Base:** C26 aprovado. **Branch sugerida:** `dev/checkpoint-27-steam-platform`.

## Gate obrigatório antes de começar

Só implementar se o usuário confirmar Steam como destino de distribuição e escolher SDK/plugin compatível com Godot 4.7.2. Antes do código, revisar licença, manutenção, versão, requisitos de publicação e suporte a GL Compatibility. Sem essa decisão, C27 fica em espera e a build offline continua sendo a referência.

## Arquitetura

- Criar interface `PlatformService` com métodos `initialize`, `is_available`, `unlock_achievement(id)`, `sync_cloud()` e `shutdown`.
- Implementação `NullPlatformService` é padrão e não depende de Steam; todos os modos offline funcionam sem plataforma.
- `SteamPlatformService` é adaptador opcional, isolado atrás de verificação de disponibilidade e configuração de export.
- IDs de conquistas da plataforma mapeiam para IDs locais C14; sincronizar somente depois de a conquista local ter sido gravada duravelmente.
- Falha de Steam nunca bloqueia jogo, run, save local ou tela de resultados.

## Cloud save e conflitos

- Não sincronizar arquivos temporários, backups ou métricas locais.
- Definir lista explícita de arquivos e schema antes de habilitar Cloud.
- Não mesclar saldos/moedas por soma: isso pode duplicar progresso. Em conflito, preservar cópia local e remota, apresentar escolha ou usar política de snapshot versionado aprovada.
- Nunca sobrescrever automaticamente uma versão mais nova/desconhecida.
- Testar modo offline, login ausente, Steam indisponível, conflito de dois dispositivos e restauração de backup.

## Implementação por arquivo

- `scripts/c27/platform_service.gd`: contrato/base.
- `scripts/c27/null_platform_service.gd`: implementação offline.
- `scripts/c27/steam_platform_service.gd`: wrapper do SDK aprovado, sem chamadas espalhadas pela gameplay.
- `scripts/c27/cloud_save_manifest.gd`: allowlist, versões e política de conflito.
- `tests/unit/test_c27_platform_adapter.gd` e testes manuais com Steam sandbox.

## Aceitação

- Executável sem Steam instalado continua abrindo e jogável.
- Conquista local continua desbloqueada se Steam falhar.
- Nenhuma chamada de plataforma ocorre antes da inicialização validada.
- Cloud preserva cópias em conflito e nunca soma carteiras.
- Nenhum SDK não licenciado ou binário não reproduzível entra no repositório.

**Fora do escopo:** multiplayer, matchmaking, leaderboard online ou dependência obrigatória de login.
