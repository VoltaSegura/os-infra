# os-infra — entrega da disciplina Operating Systems (VoltaSegura)

> 🗂 **Ficha da CitizenTech** — resumo do produto **VoltaSegura** (ex-"CitizenTech"; renomeado em 10/11/2026):
> cidade São Paulo; cidadão = estudante universitário do período noturno;
> problema = falta de visão integrada das condições urbanas que influenciam a percepção de segurança no deslocamento;
> como funciona = comparação de alternativas de ida/volta com exposição estimada e confiança dos dados;
> ODS = 11 e 10. Ficha completa: monorepo **https://github.com/VoltaSegura/voltasegura**.
> ⚠️ O produto não garante segurança e não classifica bairros — comunicar apenas exposição estimada e confiança dos dados (=`docs`/04).

**Monorepo central (fonte da verdade)**: https://github.com/VoltaSegura/voltasegura

# VoltaSegura — Infraestrutura Linux (Operating Systems)

Provisionamento automatizado (Shell Script) de um ambiente Linux que hospeda a aplicação web do VoltaSegura: rede, DNS, hostname, dependências, monitoramento (CPU/disco/memória com alertas), logs de auditoria e teste de falha.

> ⚠️ Em construção. Ver percurso e rubrica em [`docs/02_entregas_disciplinas.md`](../../docs/02_entregas_disciplinas.md). Vídeo de até 7 min demonstrando o provisionamento automático dentro da VM.

## Entregáveis

- Scripts Bash de provisionamento de infra e da aplicação;
- Monitoramento como serviço tolerante a falhas;
- Logs de auditoria;
- Teste de falha;
- Vídeo (até 7 min).
