param(
    [string]$OutputDirectory = (Join-Path $PSScriptRoot ('../.tmp/icaps2027_' + (Get-Date -Format 'yyyyMMdd_HHmmss')))
)

$ErrorActionPreference = 'Stop'
$taskOutput = [System.IO.Path]::GetFullPath($OutputDirectory)
if (Test-Path -LiteralPath $taskOutput) {
    throw 'Choose a fresh output directory to preserve earlier PDF builds.'
}
New-Item -ItemType Directory -Path $taskOutput | Out-Null
$taskOldTex = $env:TEXINPUTS
$taskOldBib = $env:BIBINPUTS
$taskOldBst = $env:BSTINPUTS
try {
    # Trailing separator retains the TeX installation's default search paths.
    $env:TEXINPUTS = "$PSScriptRoot;"
    $env:BIBINPUTS = "$PSScriptRoot;"
    $env:BSTINPUTS = "$PSScriptRoot;"
    Push-Location -LiteralPath $taskOutput
    try {
        foreach ($taskDocument in @('icaps2027_method_draft', 'icaps2027_supplement')) {
            $taskSource = Join-Path $PSScriptRoot "$taskDocument.tex"
            & pdflatex -interaction=nonstopmode -halt-on-error $taskSource *> "$taskDocument.pass1.txt"
            if ($LASTEXITCODE -ne 0) { throw "Initial PDF build failed: $taskDocument" }
            & bibtex $taskDocument *> "$taskDocument.bibtex.txt"
            if ($LASTEXITCODE -ne 0) { throw "Bibliography build failed: $taskDocument" }
            foreach ($taskPass in @(2, 3)) {
                & pdflatex -interaction=nonstopmode -halt-on-error $taskSource *> "$taskDocument.pass$taskPass.txt"
                if ($LASTEXITCODE -ne 0) { throw "PDF build failed: $taskDocument, pass $taskPass" }
            }
            $taskLog = Get-Content -LiteralPath "$taskDocument.log" -Raw
            if ($taskLog -match 'Overfull \\[hv]box|There were undefined|multiply defined') {
                throw "Inspect layout or references in $taskDocument.log before delivery."
            }
            Get-Item -LiteralPath "$taskDocument.pdf" | Select-Object FullName, Length
        }
    } finally {
        Pop-Location
    }
} finally {
    $env:TEXINPUTS = $taskOldTex
    $env:BIBINPUTS = $taskOldBib
    $env:BSTINPUTS = $taskOldBst
}
