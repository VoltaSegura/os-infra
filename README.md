> 🗂 **Ficha da CitizenTech** — produto **VoltaSegura** (ex-"CitizenTech"); estudantes universitários noturnos; São Paulo;
> problema: apps de mobilidade não expõem condições urbanas que influenciam a percepção de segurança;
> como funciona: compara alternativas de ida/volta com exposição estimada + confiança dos dados;
> ODS: 11 (cidades sustentáveis) e 10 (desigualdades). Detalhes completos no README do monorepo
> **VoltaSegura/voltasegura** (single source of truth).

## voltasegura-os-infra — espelho de entrega da disciplina

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
