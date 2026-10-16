# C15 — Desafio Semanal offline

**Branch:** `dev/checkpoint-15-weekly-challenge` (derivada do C14 em validação) · **Godot:** 4.7.2 · **Gate:** CI, Windows e teste manual, sem merge automático.

## Objetivo

Implementar a hipótese pós-MVP de desafios semanais com seed fixa, sem nova ação no menu principal e sem impactar as cinco ondas, moedas, habilidades, Fever, Oficina, Rotas e contratos.

## Mecânica

- Na tela **Escolha seu modo**, três cards: Normal, Desafio Diário e **Desafio Semanal**. Menu principal segue com quatro botões.
- Semana definida por **segunda-feira a domingo em UTC**, identificada pela data ISO da segunda. O modo captura essa chave na seleção; a mudança da semana durante uma partida não troca o desafio.
- Seed semanal determinística e multiplataforma, diferente da fórmula usada no Diário. Ofertas, Rotas e os cubos continuam usando a seed capturada.
- O Diário continua com seu arquivo `user://kubrogue_daily_v1.json`; os recordes semanais ficam **separados** em `user://kubrogue_weekly_v1.json`, versão 1, limitados a 52 semanas e protegidos por SaveStore contra corrupção e versões futuras.
- Registra tentativas, vitórias, melhor onda e melhor número de cubos uma vez por partida. Mesma semana permite novas tentativas e mantém melhores resultados.
- O resultado C12 usa o mesmo arquivo de histórico versão 1, mas agora preserva `mode=weekly` e o identificador da semana; sem duplicar conquistas e sem alterar medalhas.
- No Histórico C13, o filtro **Semanal** mostra apenas runs semanais; o filtro Todas inclui os três modos. O Bestiário e as conquistas permanentes C14 continuam intactos.
- Nenhum backend, ranking remoto, recompensa monetária extra ou novo botão na hub.

## Verificações

1. Unitário: semana em segunda/domingo/virada de ano, data inválida, seed constante, idempotência, melhores marcas, reload, proteção contra esquema incompatível, isolação do Diário.
2. Integração: três cards da seleção, menu com quatro ações, seed semanal real no diretor, vitória na onda 5, registro de resultado semanal, Histórico com modo correto e abas intactas.
3. Cold start: execução sem cache de importação; suíte C0–C15 e build Windows.
4. Manual: 1280×720 e 1920×1080, conferir três cards sem cortes, C14 Bestiário e Histórico, normal/dia/semana, reinício com recordes e nenhuma moeda extra.

**Observação:** o C15 é empilhado sobre o C14. Após aprovação do C14, ajustar base do PR C15 para `main` e revalidar; nada deve chegar à `main` antes de passar por esse gate.
