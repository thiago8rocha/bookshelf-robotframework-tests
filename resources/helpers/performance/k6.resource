*** Settings ***
Library    Process
Library    OperatingSystem
Library    Collections
Library    String
Library    json


*** Variables ***
${K6_BINARY}          k6
${K6_RESULTS_DIR}     ${EXECDIR}/results/performance
${K6_TIMEOUT}         300s
${API_URL}            %{API_URL=http://localhost:3000}


*** Keywords ***
Setup Performance Suite
    [Documentation]    Configura o ambiente para os testes de performance
    Create Directory    ${K6_RESULTS_DIR}
    ${rc}=    Run And Return Rc    ${K6_BINARY} version
    Should Be Equal As Integers    ${rc}    0
    ...    msg=K6 não está disponível. Verifique a instalação.

Run K6 Test
    [Documentation]    Executa um script K6 e retorna o resultado
    ...
    ...                Argumentos:
    ...                - script: caminho do script K6 relativo à raiz do projeto
    ...                - output: nome base para os arquivos de resultado (sem extensão)
    ...
    ...                Retorna dicionário com:
    ...                - rc: return code (0 = passou, 1 = falhou nos thresholds)
    ...                - summary_path: caminho para o JSON de summary
    ...                - script: caminho do script executado
    [Arguments]    ${script}    ${output}
    ${summary_path}=    Set Variable    ${K6_RESULTS_DIR}/${output}_summary.json
    ${raw_path}=        Set Variable    ${K6_RESULTS_DIR}/${output}_raw.json
    Log    Executando K6: ${script}
    Log    API_URL: ${API_URL}
    ${cmd}=    Set Variable
    ...    ${K6_BINARY} run --env API_URL=${API_URL} --summary-export ${summary_path} --out json=${raw_path} ${script}
    ${result}=    Run Process
    ...    ${cmd}
    ...    shell=True
    ...    timeout=${K6_TIMEOUT}
    ...    stdout=PIPE
    ...    stderr=STDOUT
    Log    K6 finalizado com rc=${result.rc}
    ${run_result}=    Create Dictionary
    ...    rc=${result.rc}
    ...    summary_path=${summary_path}
    ...    script=${script}
    RETURN    ${run_result}

K6 Should Pass
    [Documentation]    Valida que o K6 passou em todos os thresholds
    ...                Falha o teste Robot se o K6 retornou exit code diferente de 0
    [Arguments]    ${result}
    IF    ${result}[rc] != 0
        Log    ❌ K6 falhou nos thresholds    WARN
        Log    Script: ${result}[script]    WARN
        Log    Return code: ${result}[rc]    WARN
        Fail    K6 falhou nos thresholds para o script: ${result}[script]
    END
    Log    ✅ K6 passou em todos os thresholds

K6 Get Metric Value
    [Documentation]    Extrai o valor de uma métrica específica do summary JSON
    ...
    ...                Argumentos:
    ...                - result: dicionário retornado por Run K6 Test
    ...                - metric: nome da métrica (ex: login_duration)
    ...                - field: campo da métrica (ex: p(95), avg, min, max)
    ...
    ...                Retorna o valor numérico da métrica
    [Arguments]    ${result}    ${metric}    ${field}
    ${summary_path}=    Set Variable    ${result}[summary_path]
    File Should Exist    ${summary_path}
    ...    msg=Summary JSON não encontrado: ${summary_path}
    ${content}=    Get File    ${summary_path}
    ${data}=    Evaluate    __import__('json').loads('''${content}''')
    ${metrics}=    Set Variable    ${data}[metrics]
    Dictionary Should Contain Key    ${metrics}    ${metric}
    ...    msg=Métrica '${metric}' não encontrada no summary
    ${metric_data}=    Set Variable    ${metrics}[${metric}]
    Dictionary Should Contain Key    ${metric_data}    ${field}
    ...    msg=Campo '${field}' não encontrado na métrica '${metric}'
    ${value}=    Set Variable    ${metric_data}[${field}]
    RETURN    ${value}

K6 Threshold Should Not Be Violated
    [Documentation]    Verifica se um threshold específico não foi violado
    ...                No K6 summary, 'false' = não violado (passou), 'true' = violado (falhou)
    ...
    ...                Argumentos:
    ...                - result: dicionário retornado por Run K6 Test
    ...                - metric: nome da métrica
    ...                - threshold: expressão do threshold (ex: p(95)<1500)
    [Arguments]    ${result}    ${metric}    ${threshold}
    ${summary_path}=    Set Variable    ${result}[summary_path]
    File Should Exist    ${summary_path}
    ${content}=    Get File    ${summary_path}
    ${data}=    Evaluate    __import__('json').loads('''${content}''')
    ${metrics}=    Set Variable    ${data}[metrics]
    ${metric_data}=    Set Variable    ${metrics}[${metric}]
    ${thresholds}=    Set Variable    ${metric_data}[thresholds]
    ${violated}=    Set Variable    ${thresholds}[${threshold}]
    IF    ${violated}
        Fail    Threshold violado: ${metric} - ${threshold}
    END
    Log    ✅ Threshold OK: ${metric} - ${threshold}

Teardown Performance Suite
    [Documentation]    Limpeza pós-suite de performance
    Log    ✅ Suite de performance finalizada
