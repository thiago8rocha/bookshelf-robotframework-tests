"""
AllurePerformance
-----------------
Library Robot Framework para anexar resultados K6 ao relatório Allure.

Gera dois tipos de attachment por teste:
  1. Tabela HTML com as métricas principais (visível direto no Allure)
  2. JSON completo do summary (para download/análise detalhada)
"""

import json
import os
from datetime import datetime


class AllurePerformance:
    """Integra resultados de performance K6 ao relatório Allure."""

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    # Métricas que queremos destacar na tabela HTML, por tipo de teste
    _METRIC_LABELS = {
        "login_duration":       "Login (ms)",
        "register_duration":    "Register (ms)",
        "list_books_duration":  "List Books (ms)",
        "create_book_duration": "Create Book (ms)",
        "update_book_duration": "Update Book (ms)",
        "delete_book_duration": "Delete Book (ms)",
        "http_req_duration":    "HTTP Req Duration (ms)",
        "iteration_duration":   "Iteration Duration (ms)",
    }

    def attach_k6_results_to_allure(
        self, summary_path: str, test_name: str, test_type: str
    ) -> None:
        """
        Lê o summary JSON do K6 e gera attachments no Allure.

        Argumentos:
        - summary_path: caminho absoluto para o *_summary.json gerado pelo K6
        - test_name:    nome legível do teste (ex: 'Auth - Spike Test')
        - test_type:    tipo do teste: 'load', 'spike', 'soak' ou 'stress'
        """
        try:
            from allure_robotframework import attach
            import allure_commons
        except ImportError:
            print("allure-robotframework não instalado — pulando attachment")
            return

        if not os.path.exists(summary_path):
            print(f"Summary não encontrado: {summary_path}")
            return

        with open(summary_path, encoding="utf-8") as f:
            data = json.load(f)

        metrics = data.get("metrics", {})
        checks  = data.get("root_group", {}).get("checks", {})

        # --- Attachment 1: tabela HTML ---
        html = self._build_html_report(test_name, test_type, metrics, checks)
        attach(
            body=html.encode("utf-8"),
            name=f"📊 {test_name} — Métricas",
            attachment_type="text/html",
        )

        # --- Attachment 2: JSON bruto ---
        attach(
            body=json.dumps(data, indent=2, ensure_ascii=False).encode("utf-8"),
            name=f"📄 {test_name} — Summary JSON",
            attachment_type="application/json",
        )

    # ------------------------------------------------------------------
    # Helpers privados
    # ------------------------------------------------------------------

    def _build_html_report(
        self, test_name: str, test_type: str, metrics: dict, checks: dict
    ) -> str:
        type_meta = {
            "load":   ("🔵", "Load Test",   "Carga normal sustentada"),
            "spike":  ("🟡", "Spike Test",  "Pico súbito de usuários"),
            "soak":   ("🟣", "Soak Test",   "Carga prolongada — detecta degradação"),
            "stress": ("🔴", "Stress Test", "Escalonamento até o ponto de ruptura"),
        }
        icon, label, description = type_meta.get(
            test_type.lower(), ("⚪", test_type, "")
        )

        generated_at = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

        # Seção de checks
        checks_rows = ""
        for name, c in checks.items():
            total  = c.get("passes", 0) + c.get("fails", 0)
            passes = c.get("passes", 0)
            rate   = (passes / total * 100) if total > 0 else 0
            status = "✅" if c.get("fails", 0) == 0 else "❌"
            checks_rows += f"""
            <tr>
              <td>{status} {name}</td>
              <td class="num">{passes}</td>
              <td class="num">{c.get('fails', 0)}</td>
              <td class="num">{rate:.1f}%</td>
            </tr>"""

        # Seção de métricas de duração
        metrics_rows = ""
        for key, label_metric in self._METRIC_LABELS.items():
            if key not in metrics:
                continue
            m   = metrics[key]
            avg = m.get("avg", 0)
            p90 = m.get("p(90)", 0)
            p95 = m.get("p(95)", 0)
            p99 = m.get("p(99)", m.get("max", 0))
            mn  = m.get("min", 0)
            mx  = m.get("max", 0)

            # Classifica p95 por cor
            if p95 < 500:
                p95_class = "green"
            elif p95 < 2000:
                p95_class = "yellow"
            else:
                p95_class = "red"

            # Thresholds violados
            violated = []
            for expr, v in m.get("thresholds", {}).items():
                if v:  # true = violado no K6
                    violated.append(f"⚠️ {expr}")
            threshold_html = (
                "<br>".join(violated)
                if violated
                else '<span class="ok">✅ OK</span>'
            )

            metrics_rows += f"""
            <tr>
              <td><strong>{label_metric}</strong></td>
              <td class="num">{mn:.1f}</td>
              <td class="num">{avg:.1f}</td>
              <td class="num">{p90:.1f}</td>
              <td class="num {p95_class}">{p95:.1f}</td>
              <td class="num">{p99:.1f}</td>
              <td class="num">{mx:.1f}</td>
              <td>{threshold_html}</td>
            </tr>"""

        # Métricas gerais
        reqs    = metrics.get("http_reqs", {})
        vus     = metrics.get("vus", {})
        iters   = metrics.get("iterations", {})
        err_m   = metrics.get("http_req_failed", {})
        err_val = err_m.get("value", 0)
        err_cls = "green" if err_val < 0.02 else ("yellow" if err_val < 0.10 else "red")

        return f"""<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<style>
  body       {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
                margin: 0; padding: 20px; background: #f8f9fa; color: #212529; }}
  .card      {{ background: #fff; border-radius: 8px; padding: 24px;
                box-shadow: 0 1px 4px rgba(0,0,0,.12); margin-bottom: 20px; }}
  h1         {{ margin: 0 0 4px; font-size: 1.4rem; }}
  .badge     {{ display: inline-block; padding: 3px 10px; border-radius: 12px;
                font-size: .8rem; font-weight: 600; margin-left: 8px; }}
  .load      {{ background: #cfe2ff; color: #084298; }}
  .spike     {{ background: #fff3cd; color: #664d03; }}
  .soak      {{ background: #e9d5ff; color: #5b21b6; }}
  .stress    {{ background: #f8d7da; color: #842029; }}
  .subtitle  {{ color: #6c757d; font-size: .9rem; margin-bottom: 20px; }}
  table      {{ width: 100%; border-collapse: collapse; font-size: .88rem; }}
  th         {{ background: #f1f3f5; text-align: left; padding: 8px 12px;
                border-bottom: 2px solid #dee2e6; white-space: nowrap; }}
  td         {{ padding: 7px 12px; border-bottom: 1px solid #e9ecef; }}
  tr:hover   {{ background: #f8f9fa; }}
  .num       {{ text-align: right; font-family: monospace; }}
  .green     {{ color: #198754; font-weight: 700; }}
  .yellow    {{ color: #fd7e14; font-weight: 700; }}
  .red       {{ color: #dc3545; font-weight: 700; }}
  .ok        {{ color: #198754; }}
  .summary-grid {{ display: grid; grid-template-columns: repeat(4, 1fr); gap: 12px; }}
  .metric-box   {{ background: #f8f9fa; border-radius: 6px; padding: 12px 16px;
                   border-left: 4px solid #0d6efd; }}
  .metric-box .val {{ font-size: 1.5rem; font-weight: 700; color: #0d6efd; }}
  .metric-box .lbl {{ font-size: .78rem; color: #6c757d; margin-top: 2px; }}
  .metric-box.err  {{ border-left-color: #dc3545; }}
  .metric-box.err .val {{ color: #dc3545; }}
  h2         {{ font-size: 1rem; margin: 0 0 12px; color: #495057; }}
  .ts        {{ font-size: .75rem; color: #adb5bd; text-align: right; margin-top: 8px; }}
</style>
</head>
<body>
  <div class="card">
    <h1>{icon} {test_name} <span class="badge {test_type.lower()}">{label}</span></h1>
    <div class="subtitle">{description} &nbsp;·&nbsp; Gerado em {generated_at}</div>

    <div class="summary-grid">
      <div class="metric-box">
        <div class="val">{int(reqs.get('count', 0))}</div>
        <div class="lbl">Total de Requisições</div>
      </div>
      <div class="metric-box">
        <div class="val">{reqs.get('rate', 0):.1f}/s</div>
        <div class="lbl">Taxa (req/s)</div>
      </div>
      <div class="metric-box">
        <div class="val">{int(iters.get('count', 0))}</div>
        <div class="lbl">Iterações</div>
      </div>
      <div class="metric-box err">
        <div class="val {err_cls}">{err_val * 100:.1f}%</div>
        <div class="lbl">Taxa de Erro</div>
      </div>
    </div>
  </div>

  <div class="card">
    <h2>⏱ Latência por Operação (ms)</h2>
    <table>
      <thead>
        <tr>
          <th>Operação</th>
          <th>Min</th>
          <th>Avg</th>
          <th>p90</th>
          <th>p95</th>
          <th>p99</th>
          <th>Max</th>
          <th>Thresholds</th>
        </tr>
      </thead>
      <tbody>{metrics_rows}</tbody>
    </table>
  </div>

  {"" if not checks_rows else f'''
  <div class="card">
    <h2>✔ Checks</h2>
    <table>
      <thead>
        <tr><th>Check</th><th>Passed</th><th>Failed</th><th>Taxa</th></tr>
      </thead>
      <tbody>{checks_rows}</tbody>
    </table>
  </div>'''}

  <div class="ts">K6 Performance Report · bookshelf-robotframework-tests</div>
</body>
</html>"""
