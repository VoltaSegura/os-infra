'use strict';
const config = window.VOLTA_CONFIG;
const $ = id => document.getElementById(id);
let routes = [];
const now = new Date();
$('partida').value = new Date(now.getTime() - now.getTimezoneOffset() * 60000).toISOString().slice(0, 16);
$('modo').textContent = config.mode === 'demo'
  ? 'Demonstração: locais e trajetos fictícios. Sem consulta à API, geolocalização ou dados oficiais.'
  : 'Modo API: integração experimental. Consulte a origem e as limitações dos dados em cada resultado.';
$('tema').addEventListener('click', () => document.body.classList.toggle('light'));
$('sobre').addEventListener('click', () => $('dados').showModal());
function demoRoutes() {
  return [
    {id:'exemplo-a',label:'Menor tempo',durationMinutes:32,walkingMeters:1200,transfers:1,exposureStatus:'insufficient_data',dataConfidence:'not_evaluated',steps:['Caminhar até a parada de exemplo.','Embarcar no ônibus ilustrativo.','Fazer conexão com o metrô ilustrativo.','Caminhar até o destino de exemplo.']},
    {id:'exemplo-b',label:'Menos caminhada',durationMinutes:38,walkingMeters:600,transfers:2,exposureStatus:'insufficient_data',dataConfidence:'not_evaluated',steps:['Caminhar até a estação de exemplo.','Embarcar no metrô ilustrativo.','Fazer duas conexões ilustrativas.','Caminhar até o destino de exemplo.']}
  ];
}
function validateResponse(data) {
  if (!data || !Array.isArray(data.routes) || data.routes.length > 20) throw new Error('Resposta da API fora do contrato proposto.');
  for (const r of data.routes) {
    if (typeof r.id !== 'string' || typeof r.label !== 'string' || !Array.isArray(r.steps) ||
      !r.steps.every(s => typeof s === 'string') ||
      ![r.durationMinutes,r.walkingMeters,r.transfers].every(v => Number.isFinite(v) && v >= 0) ||
      r.exposureStatus !== 'insufficient_data' || r.dataConfidence !== 'not_evaluated') {
      throw new Error('Resultado incompatível: este adaptador inicial aceita apenas exposição insuficiente e confiança não avaliada.');
    }
  }
  return data.routes;
}
function element(tag, text, className) { const el = document.createElement(tag); el.textContent = text; if (className) el.className = className; return el; }
function render(selectedId) {
  $('rotas').replaceChildren();
  for (const route of routes) {
    const card = element('article', '', 'route' + (route.id === selectedId ? ' selected' : ''));
    const top = element('div', '', 'route-top');
    top.append(element('strong',route.label), element('span',`${route.durationMinutes} min`,'duration'));
    card.append(top,element('p',`${route.walkingMeters} m a pé · ${route.transfers} troca(s)`),element('p','Exposição estimada: dados insuficientes.','data'),element('p','Confiança dos dados: não avaliada.','data'));
    const button = element('button', route.id === selectedId ? 'Rota selecionada · ver detalhes' : 'Selecionar e ver detalhes');
    button.type = 'button'; button.setAttribute('aria-pressed', String(route.id === selectedId));
    button.addEventListener('click', () => showDetails(route));
    card.append(button); $('rotas').append(card);
  }
}
function showDetails(route) {
  render(route.id);
  const details = $('detalhes'); details.replaceChildren(element('h3',`${route.label} · passo a passo`));
  const list = element('ol',''); route.steps.forEach(step => list.append(element('li',step))); details.append(list);
  details.append(element('p','Tempos e etapas de exemplo no modo demonstração. O esquema acima não muda com a seleção e não representa uma rota geográfica.','muted'));
  details.hidden = false; details.focus();
}
$('busca').addEventListener('submit', async event => {
  event.preventDefault(); $('erro').textContent = ''; $('detalhes').hidden = true;
  $('rotas').replaceChildren(); routes = [];
  if ($('origem').value === $('destino').value) { $('erro').textContent = 'Escolha origem e destino diferentes.'; $('estado').textContent = 'Revise a viagem.'; return; }
  const departure = new Date($('partida').value);
  if (Number.isNaN(departure.getTime())) { $('erro').textContent = 'Informe uma data e um horário válidos.'; return; }
  $('comparar').disabled = true; $('estado').textContent = 'Buscando alternativas…';
  try {
    if (config.mode === 'demo') routes = demoRoutes();
    else if (config.mode === 'api') {
      const response = await fetch(`${config.apiBase}/routes/compare`,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({originId:$('origem').value,destinationId:$('destino').value,departureAt:departure.toISOString(),direction:document.querySelector('input[name=sentido]:checked').value}),signal:AbortSignal.timeout(config.timeoutMs)});
      if (!response.ok) throw new Error(`API indisponível ou solicitação recusada (HTTP ${response.status}).`);
      routes = validateResponse(await response.json());
    } else throw new Error('Modo de execução inválido.');
    $('estado').textContent = routes.length ? `${routes.length} alternativas. ${config.mode === 'demo' ? 'Cenário fixo: o horário e o sentido não recalculam os exemplos.' : 'Resposta recebida da API.'}` : 'Nenhuma alternativa disponível para esta consulta.';
    render();
  } catch (error) { $('erro').textContent = error.name === 'TimeoutError' ? 'A API demorou para responder. Tente novamente.' : error.message; $('estado').textContent = 'Não foi possível comparar. Nenhum dado de exemplo foi usado como substituição.'; }
  finally { $('comparar').disabled = false; }
});
