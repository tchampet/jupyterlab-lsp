*** Settings ***
Suite Setup       Setup Suite For Screenshots    notebook
Test Setup        Try to Close All Tabs
Resource          Keywords.robot

*** Test Cases ***
Python
    [Setup]    Setup Notebook    Python    Python.ipynb
    ${diagnostic} =    Set Variable    W291 trailing whitespace (pycodestyle)
    Wait Until Page Contains Element    css:.cm-lsp-diagnostic[title="${diagnostic}"]    timeout=35s
    Capture Page Screenshot    01-python.png
    [Teardown]    Clean Up After Working With File    Python.ipynb

Conversion Of Cell Types
    [Setup]    Setup Notebook    Python    Python.ipynb
    ${lsp_entry} =    Set Variable    Show diagnostics panel
    # initial (code) cell
    Open Context Menu Over Cell Editor    1
    Capture Page Screenshot    01-initial-code-cell.png
    Context Menu Should Contain    ${lsp_entry}
    Close Context Menu
    # raw cell
    Lab Command    Change to Raw Cell Type
    Open Context Menu Over Cell Editor    1
    Capture Page Screenshot    02-as-raw-cell.png
    Context Menu Should Not Contain    ${lsp_entry}
    Close Context Menu
    # code cell again
    Lab Command    Change to Code Cell Type
    Open Context Menu Over Cell Editor    1
    Capture Page Screenshot    03-as-code-cell-again.png
    Context Menu Should Contain    ${lsp_entry}
    Close Context Menu
    [Teardown]    Clean Up After Working With File    Python.ipynb

Moving Cells Around
    [Setup]    Setup Notebook    Python    Python.ipynb
    ${diagnostic} =    Set Variable    undefined name 'test' (pyflakes)
    Enter Cell Editor    1
    Lab Command    Move Cells Down
    Wait Until Page Contains Element    css:.cm-lsp-diagnostic[title="${diagnostic}"]    timeout=35s
    Enter Cell Editor    1
    Lab Command    Move Cells Down
    Wait Until Page Does Not Contain Element    css:.cm-lsp-diagnostic[title="${diagnostic}"]    timeout=35s
    [Teardown]    Clean Up After Working With File    Python.ipynb

Foreign Extractors
    ${file} =    Set Variable    Foreign extractors.ipynb
    Configure JupyterLab Plugin
    ...    {"language_servers": {"texlab": {"serverSettings": {"latex.lint.onChange": true}}, "bash-langauge-server": {"bashIde.highlightParsingErrors": true}}}
    Capture Page Screenshot    10-configured.png
    Reset Application State
    Setup Notebook    Python    ${file}
    @{diagnostics} =    Create List
    ...    Failed to parse expression    # bash, configured by spec.env
    ...    ame 'valid'    # python, mypy and pyflakes will fight over `(N|n)ame 'valid'`, just hope for the best
    ...    Trailing whitespace is superfluous.    # r
    ...    `frob` is misspelt    # markdown
    ...    Command terminated with space    # latex
    FOR    ${diagnostic}    IN    @{diagnostics}
        Wait Until Page Contains Element    css:.cm-lsp-diagnostic[title*\="${diagnostic}"]    timeout=35s
    END
    Capture Page Screenshot    11-extracted.png
    [Teardown]    Clean Up After Working with File and Settings    ${file}

Code Overrides
    ${file} =    Set Variable    Code overrides.ipynb
    Setup Notebook    Python    ${file}
    ${virtual_path} =    Set Variable    ${VIRTUALDOCS DIR}${/}Code overrides.ipynb
    Wait Until Created    ${virtual_path}
    ${document} =    Get File    ${virtual_path}
    Should Be Equal    ${document}    get_ipython().run_line_magic("ls", "")\n\n\nget_ipython().run_line_magic("pip", " freeze")\n
