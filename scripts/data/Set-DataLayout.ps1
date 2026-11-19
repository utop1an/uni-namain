param([Parameter(Mandatory)][ValidateSet('Domains','Research')][string]$Layout)
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../..')).Path
$active = Join-Path $repo 'data'
$storage = Join-Path $repo 'archive/research-data-v1'
$legacy = Join-Path $storage 'data'
$domains = Join-Path $storage 'domains'
if ((Get-Item -LiteralPath $storage).Attributes -band [IO.FileAttributes]::ReparsePoint) {
    throw 'The layout storage must be an ordinary directory in this checkout.'
}
$currentDomains = Test-Path -LiteralPath (Join-Path $active 'groups.csv')
$currentResearch = Test-Path -LiteralPath (Join-Path $active 'validation/official_unidomain_table234_inputs_2026_11_09_v1/input_registry.json')
if ($currentDomains -eq $currentResearch) { throw 'Unrecognized or mixed active data layout.' }
if (($Layout -eq 'Domains') -eq $currentDomains) { Write-Output "Already in $Layout layout."; return }
if ($currentDomains) { $park = $domains; $take = $legacy } else { $park = $legacy; $take = $domains }
if (Test-Path -LiteralPath $park) { throw "Refusing to overwrite $park" }
foreach ($directory in @($active,$take,$storage)) {
    $item = Get-Item -LiteralPath $directory
    if (-not $item.PSIsContainer -or ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -or
        -not $item.FullName.StartsWith(($repo + [IO.Path]::DirectorySeparatorChar), [StringComparison]::OrdinalIgnoreCase)) {
        throw "Unexpected directory: $directory"
    }
}
if ($Layout -eq 'Research' -and -not (Test-Path -LiteralPath (Join-Path $take 'validation'))) { throw 'Missing research data.' }
if ($Layout -eq 'Domains' -and -not (Test-Path -LiteralPath (Join-Path $take 'groups.csv'))) { throw 'Missing domain catalog.' }
try {
    [IO.Directory]::Move($active,$park)
} catch [IO.IOException] {
    if ((Test-Path -LiteralPath $park) -or -not (Test-Path -LiteralPath $active)) { throw }
    # Windows may keep handles to the empty shells of an aborted historical run.
    # Move its unlocked children and keep the directory handle valid. A locked
    # file or any other busy run aborts the switch and rolls back earlier moves.
    $journal = [Collections.Generic.List[object]]::new()
    $shells = @('validation','validation/priority1_union_full_initialization_lowmem_2026_11_08_v1')
    function Move-LayoutChild($item, [string]$to, [string]$relative) {
        $src = $item.FullName
        $dst = [IO.Path]::GetFullPath((Join-Path $to $item.Name))
        if (-not $src.StartsWith(($repo + '\'),[StringComparison]::OrdinalIgnoreCase) -or
            [IO.Path]::GetDirectoryName($dst) -ne $to -or
            -not $dst.StartsWith(($repo + '\'),[StringComparison]::OrdinalIgnoreCase) -or
            ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) { throw "Unexpected child: $src" }
        if (-not (Test-Path -LiteralPath $dst)) {
            try {
                if ($item.PSIsContainer) { [IO.Directory]::Move($src,$dst) } else { [IO.File]::Move($src,$dst) }
                $journal.Add(@('move',$src,$dst,$item.PSIsContainer))
                return
            } catch {
                $why = $_.Exception.GetBaseException()
                if (-not $item.PSIsContainer -or $relative -notin $shells -or ($why.HResult -band 65535) -ne 32) {
                    throw "Cannot move ${src}: $($why.Message)"
                }
                [IO.Directory]::CreateDirectory($dst) | Out-Null
                $journal.Add(@('created',$dst))
            }
        } elseif ($relative -notin $shells -or -not $item.PSIsContainer -or
            -not [IO.Directory]::Exists($dst) -or ((Get-Item -LiteralPath $dst).Attributes -band [IO.FileAttributes]::ReparsePoint)) {
            throw "Refusing to overwrite $dst"
        }
        foreach ($child in @(Get-ChildItem -Force -LiteralPath $src)) {
            Move-LayoutChild $child $dst ($relative + '/' + $child.Name)
        }
        $left = @(Get-ChildItem -Force -LiteralPath $src)
        if ($left.Count) {
            foreach ($entry in $left) {
                if (-not $entry.PSIsContainer -or ($relative + '/' + $entry.Name) -notin $shells -or
                    @(Get-ChildItem -Force -LiteralPath $entry.FullName).Count) { throw "Directory changed during switch: $src" }
            }
            return
        }
        try {
            [IO.Directory]::Delete($src,$false)
            $journal.Add(@('removed',$src))
        } catch {
            if (($_.Exception.GetBaseException().HResult -band 65535) -ne 32) { throw }
        }
    }
    [IO.Directory]::CreateDirectory($park) | Out-Null
    try {
        foreach ($pair in @(@($active,$park),@($take,$active))) {
            $from,$to = $pair
            foreach ($item in @(Get-ChildItem -Force -LiteralPath $from)) {
                Move-LayoutChild $item $to $item.Name
            }
        }
        [IO.Directory]::Delete($take,$false)
    } catch {
        for ($i=$journal.Count-1; $i -ge 0; $i--) {
            $kind,$src,$dst,$isDirectory=$journal[$i]
            switch ($kind) {
                'created' { [IO.Directory]::Delete($src,$false) }
                'removed' { [IO.Directory]::CreateDirectory($src) | Out-Null }
                'move' {
                    if ($isDirectory) { [IO.Directory]::Move($dst,$src) } else { [IO.File]::Move($dst,$src) }
                }
            }
        }
        [IO.Directory]::Delete($park,$false)
        throw
    }
    Write-Output "Active data layout: $Layout"
    return
}
try {
    [IO.Directory]::Move($take,$active)
} catch {
    [IO.Directory]::Move($park,$active)
    throw
}
Write-Output "Active data layout: $Layout"
