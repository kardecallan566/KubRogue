# C30 — Preparação de lançamento 1.0

**Estado:** planejado; nenhum código C30 existe. **Base:** C29 aprovado. **Branch sugerida:** `release/1.0.0`.

## Objetivo

Gerar uma entrega reproduzível e documentada para Windows. Preparar a distribuição não significa publicar automaticamente em loja; qualquer publicação depende de autorização explícita do usuário.

## Entregáveis

- Versão semântica `1.0.0` e changelog com C0–C30 efetivamente entregues.
- Build Release Windows x86_64 com executável e arquivos necessários juntos.
- ZIP de distribuição ou instalador, conforme decisão de produto; não chamar um ZIP de instalador.
- Checksums SHA-256, tamanho, data, commit SHA e versão do Godot registrados.
- README de instalação, requisitos, solução de problemas, localização, controles e localização dos saves.
- Créditos/licenças de modelos, fontes, áudio, plugins e bibliotecas; nenhum asset sem procedência.
- Backup dos arquivos de save e instruções de recuperação/rollback.
- Metadados e capturas da loja somente se houver decisão de distribuição (Steam ou outra).

## Implementação por arquivo

- Atualizar versão em `project.godot` e metadados de build em arquivo único (por exemplo `release/version.json`).
- `docs/release/CHANGELOG-1.0.0.md`.
- `docs/release/INSTALL-WINDOWS.md`.
- `docs/release/THIRD-PARTY-NOTICES.md`.
- `.github/workflows/release-windows.yml`: workflow manual/tagged que importa templates oficiais, exporta Release, valida arquivos, gera ZIP e checksum.
- `scripts/c30/release_manifest.gd` somente se o projeto precisar gerar manifesto dentro do jogo; não criar código runtime desnecessário.

## Pipeline

1. Criar tag candidata a partir do SHA aprovado.
2. Executar importação limpa, testes headless e export Release.
3. Verificar assinatura/hash, abrir em Windows sem editor, iniciar campanha, resolver cubo, salvar, reiniciar e carregar.
4. Conferir arquivos obrigatórios, créditos e licenças.
5. Gerar ZIP/instalador, checksum e changelog.
6. Guardar artefatos e anotar o SHA exato.
7. Criar tag final `v1.0.0` somente após aprovação.

## Aceitação

- Instalação/extração em pasta limpa funciona sem Godot Editor.
- Build não depende de arquivos fora do pacote.
- Save de versão anterior carrega ou apresenta migração/backup clara.
- Teste de fumaça completo em Windows real.
- Artefato, checksum, changelog, créditos e instruções correspondem ao mesmo SHA.
- Nenhuma publicação, anúncio ou upload em loja ocorre sem autorização do usuário.

**Fora do escopo:** lançamento automático, anúncios, telemetria, login ou multiplayer.
