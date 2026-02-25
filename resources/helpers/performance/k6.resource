*** Settings ***
Documentation    Keywords para orquestração do K6 via Robot Framework
...              Executa scripts K6, captura resultados e valida thresholds

Library    OperatingSystem
Library    Process
Library    Collections
Library    String

Resource    ../../../environment.resource

*** Variables ***
${K6_BINARY}         k6
${K6_RESULTS_DIR}    results/performance
${K6_TIMEOUT}        300s    # 5 minutos de timeout por teste

*** Keywords ***

Setup Performance Suite
    [Documentation]    Prepara ambiente para testes de performance
    Create Directory    ${K6_RESULTS_DIR}
    Verify K6 Is Available

Teardown Performance Suite
    [Documentation]    Limpeza após testes de performance
    Log    Testes de performance finalizados

Verify K6 Is Available
    [Documentation]    Verifica se o K6 está instalado e acessível
    ${result}=    Run Process
    ...    ${K6_BINARY}    version
    ...    timeout=10s    stdout=PIPE    stderr=PIPE
    Should Be Equal As Integers    ${result.rc}    0
    ...    msg=K6 não encontrado. Verifique se está instalado no container.
    Log    K6 disponível: ${result.stdout}

Run K6 Test
    [Documentation]    Executa um script K6 e retorna o resultado
    ...
    ...                Argumentos:
    ...                - script: caminho do script K6 relativo à raiz do projeto
    ...                - output: nome base para os arquivos de resultado (sem extensão)
    ...
    ...                Retorna dicionário com:
    ...                - rc: return code (0 = passou, 1 = falhou nos thresholds)
    ...                - stdout: saída do K6
    ...                - stderr: erros do K6
    ...                - summary_path: caminho para o JSON de summary
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
    ...    timeout=${K6_TIMEOUT}    stdout=PIPE    stderr=PIPE

    Log    K6 finalizado com exit code: ${result.rc}
    Log    K6 stdout:\n${result.stdout}
    Run Keyword If    '${result.stderr}' != ''    Log    K6 stderr:\n${result.stderr}    WARN

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

K6 Get Metric Value
    [Documentation]    Extrai o valor de uma métrica do summary JSON do K6
    ...
    ...                Uso:
    ...                ${p95}=    K6 Get Metric Value
    ...                ...    summary_path=${result}[summary_path]
    ...                ...    metric=http_req_duration
    ...                ...    aggregation=p(95)
    [Arguments]    ${summary_path}    ${metric}    ${aggregation}=avg

    ${file_exists}=    Run Keyword And Return Status
    ...    File Should Exist    ${summary_path}

    Return From Keyword If    not ${file_exists}    ${None}

    ${content}=    Get File    ${summary_path}
    ${json}=       Evaluate    __import__('json').loads(open('${summary_path}').read())

    ${metrics}=    Get From Dictionary    ${json}    metrics    default=${None}
    Return From Keyword If    '${metrics}' == 'None'    ${None}

    ${metric_data}=    Get From Dictionary    ${metrics}    ${metric}    default=${None}
    Return From Keyword If    '${metric_data}' == 'None'    ${None}

    ${values}=    Get From Dictionary    ${metric_data}    values    default=${None}
    Return From Keyword If    '${values}' == 'None'    ${None}

    ${value}=    Get From Dictionary    ${values}    ${aggregation}    default=${None}
    RETURN    ${value}
