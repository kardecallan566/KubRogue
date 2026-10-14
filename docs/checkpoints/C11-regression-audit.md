# Auditoria transversal pós-C10 — Correções e lacunas verificadas

**Revisão inicial:** 14/10/2026. **Branch:** `dev/checkpoint-11-regression-audit`. **Base aprovada:** main após PR #11 (`f199873`). **Status:** aguardando CI e teste de usuário; sem merge automático.

## Metodologia

Revisei a árvore completa do repositório, a origem dos scripts por checkpoint, os serviços de persistência, as regras de cubos, a rota de crédito de moeda e o workflow que executa os testes existentes. Os testes de todos os checkpoints C0–C10 continuam rodando. Foram adicionados quatro testes transversais com arquivos de save reais no `user://`: corrupção sucessiva, desconhecimento de versão, datas gregorianas e proteção independente de Bestiário/Desafio Diário.

**Importante:** a existência dos testes automatizados **não comprova desempenho gráfico e usabilidade no Windows**. O teste manual de compatibilidade e fluidez ainda é obrigatório.

## Matriz de conferência por checkpoint

| Etapa | Escopo verificado no código | Proteção / teste |
|---|---|---|
| C0 | Cubo 3×3 e geometria original, scripts de inspeção | Estados válidos, giros físicos e geometria |
| C1 | 2×2, mão 2D/fluxo de resolução | Solução real e controle |
| C2 | Ondas, temporizadores, spawn e carteira de partida | Moeda idempotente, não cobrar não-spawnado |
| C3 | Cinco ondas, chefe 3×3, XP e oito habilidades | Elite obrigatória, escolhas e limites de carta |
| C4 | Hub, tutorial, moedas e upgrades permanentes | **Correção de recuperação de save e bloqueio de schema** |
| C5 | Cursor PNG aberto/fechado, sintetizador de áudio, HUD | Abertura em clone limpo e testes áudio/UI |
| C6 | Desafio Diário UTC, seeds e reroll | **Calendário gregoriano válido, salvamento protegido** |
| C7 | Cubos Dourado, Blindado, 4×4, 5×5, giros internos | Reversão matemática, saldo e animações reais |
| C8 | Bestiário, contratos, ícones e Oficina | **Proteção de arquivo de coleção, débito transacional** |
| C9 | Duas rotas determinísticas com risco/benefício | Contratos de uma onda, reinício, chefe preservado |
| C10 | Combo Fever e bônus temporários | 4 resoluções, caps, pausa de timer e crédito único |

## Problemas encontrados e correções

### A11-01 — Backup substituído por JSON corrompido (alta prioridade)

**Antes:** `SaveStore.write_json()` fazia backup do arquivo principal **mesmo se ele estivesse quebrado**. Ao abrir o jogo, recuperar `.bak` e jogar, um salvamento posterior podia sobrescrever o último backup bom pelo arquivo corrompido, perdendo a segunda chance de recuperação.

**Agora:** há leitura/validação de JSON dentro do adaptador. O backup é renovado **somente quando o arquivo principal é um documento JSON válido e não vazio**. Se o principal estiver ilegível, a versão boa `.bak` permanece intacta quando o jogo salva novamente. Teste: corromper → recuperar → gravar → corromper outra vez → recuperar.

### A11-02 — Saves futuros ou ilegíveis sobrescritos silenciosamente (alta prioridade)

**Antes:** o serviço de carteira podia apresentar valores zerados quando a versão do arquivo não era reconhecida. A mensagem de incompatibilidade era apagada no final do carregamento e um novo crédito de moedas poderia escrever os valores padrão por cima do arquivo. Desafio Diário e Bestiário tinham risco similar quando o JSON era inválido/estava numa versão nova.

**Agora:** as três fontes entram em **modo de gravação bloqueada** quando encontram arquivos legíveis mas de versões incompatíveis, ou arquivos presentes e ilegíveis, e preservam os bytes originais. A hub mostra o alerta. Somente arquivos novos ou versões antigas compatíveis continuam graváveis. Isso não converte dados entre versões; exige **cópia de segurança e recuperação manual** do arquivo incompatível.

### A11-03 — Datas inexistentes aceitas no Desafio Diário (prioridade média)

**Antes:** a validação exigia apenas mês 1–12 e dia 1–31, permitindo datas como 2026-02-30, 2026-04-31 ou 2100-02-29.

**Agora:** a validação segue os dias reais de cada mês e a regra de anos bissextos gregorianos, preservando a fórmula de seed e os recordes para datas válidas. Testes incluem 2028/2400 (bissextos) e 2100 (não bissexto).

## Pontos que ainda precisam de avaliação fora do CI

- **FPS e consumo de memória** com vários cubos 4×4/5×5 presentes no Godot Compatibility em uma GPU real.
- **Layout e legibilidade** da hub, cartas, Bestiário, Oficina, Rotas e barra Fever em 1280×720, 1920×1080 e janela redimensionada.
- **Ritmo/balanceamento**: preços da Oficina, valor das rotas, tempo suficiente para resolver 5×5 e som do Fever.
- **Testes exploratórios de desligamento** durante uma compra/solução e ao tentar reabrir um save de versão futura. Os testes automatizados verificam bytes de arquivos simulados, mas não substituem uma queda real de energia.
- **Histórico do Bestiário**: eventos de descoberta são mantidos nos 512 IDs recentes; observações pendentes apenas em memória ainda podem ser perdidas se o usuário encerrar o jogo enquanto o armazenamento está indisponível. A carteira permanece independente.

## Como validar

```powershell
git fetch origin
git switch dev/checkpoint-11-regression-audit
git pull origin dev/checkpoint-11-regression-audit
godot .
```

Confira os fluxos da campanha até a onda 5, entre no Bestiário, compre na Oficina e ative o Fever. Os testes automatizados da branch cobrem C0–C10 e cenários de integridade de save. **Não fazer merge antes do CI completo e aprovação no Windows.**
