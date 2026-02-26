*** Settings ***
Library    Process
Library    OperatingSystem
Library    Collections
Library    String
Library    json
Library    ${EXECDIR}/resources/helpers/performance/AllurePerformance.py


*** Variables ***
${K6_BINARY}          /usr/bin/k6
${K6_RESULTS_DIR}     ${EXECDIR}/results/performance
${K6_TIMEOUT}         300s
${API_URL}            %{API_URL=http://localhost:3000}


*** Keywords ***
Setup Performance Suite
    [Documentation]    Verifica pré-requisitos e cria diretório de resultados
    Create Directory    ${K6_RESULTS_DIR}
    ${rc}=    Run And Return Rc    ${K6_BINARY} version
    Should Be Equal As Integers    ${rc}    0
    ...    msg=K6 não está disponível. Verifique a instalação.

Teardown Performance Suite
    [Documentation]    Limpeza pós-suite de performance
    Log    ✅ Suite de performance finalizada

Run K6 Test
    [Documentation]    Executa um script K6 e retorna o resultado.
    ...
    ...    Argumentos:
    ...    - script:    caminho do script K6
    ...    - output:    nome base para os arquivos de resultado (sem extensão)
    ...    - test_type: load | spike | soak | stress  (padrão: load)
    [Arguments]    ${script}    ${output}    ${test_type}=load
    ${summary_path}=    Set Variable    ${K6_RESULTS_DIR}/${output}_summary.json
    ${cmd}=    Catenate
    ...    ${K6_BINARY} run
    ...    --env API_URL=${API_URL}
    ...    --summary-export ${summary_path}
    ...    ${script}
    ${result}=    Run Process    ${cmd}
    ...    shell=True
    ...    timeout=${K6_TIMEOUT}
    ...    stdout=PIPE
    ...    stderr=STDOUT
    Log    K6 rc=${result.rc} | script=${script}
    Log    ${result.stdout}
    ${run_result}=    Create Dictionary
    ...    rc=${result.rc}
    ...    summary_path=${summary_path}
    ...    script=${script}
    ...    test_type=${test_type}
    RETURN    ${run_result}

K6 Should Pass
    [Documentation]    Falha o teste se o K6 retornou exit code != 0
    [Arguments]    ${result}
    IF    ${result}[rc] != 0
        Log    ❌ K6 falhou | rc=${result}[rc] | script=${result}[script]    WARN
        Fail    K6 falhou nos thresholds para o script: ${result}[script]
    END
    Log    ✅ K6 passou em todos os thresholds

Attach Performance Results To Allure
    [Documentation]    Gera attachment HTML + JSON no relatório Allure.
    [Arguments]    ${result}    ${test_name}
    ${summary_path}=    Set Variable    ${result}[summary_path]
    ${test_type}=       Set Variable    ${result}[test_type]
    ${exists}=    Run Keyword And Return Status    File Should Exist    ${summary_path}
    IF    not ${exists}
        Log    Summary não encontrado — attachment Allure pulado    WARN
        RETURN
    END
    Attach K6 Results To Allure    ${summary_path}    ${test_name}    ${test_type}
    Log    📊 Attachment gerado: ${test_name}

K6 Get Metric Value
    [Documentation]    Extrai o valor de uma métrica do summary JSON.
    [Arguments]    ${result}    ${metric}    ${field}
    ${content}=    Get File    ${result}[summary_path]
    ${data}=       Evaluate    __import__('json').loads('''${content}''')
    ${value}=      Set Variable    ${data}[metrics][${metric}][${field}]
    RETURN    ${value}

K6 Threshold Should Not Be Violated
    [Documentation]    Verifica se um threshold não foi violado.
    ...                No K6 summary, false = passou, true = violado.
    [Arguments]    ${result}    ${metric}    ${threshold}
    ${content}=    Get File    ${result}[summary_path]
    ${data}=       Evaluate    __import__('json').loads('''${content}''')
    ${violated}=   Set Variable    ${data}[metrics][${metric}][thresholds][${threshold}]
    IF    ${violated}
        Fail    Threshold violado: ${metric} — ${threshold}
    END
    Log    ✅ Threshold OK: ${metric} — ${threshold}
