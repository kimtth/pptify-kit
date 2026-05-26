param(
    [string]$Version = "1.0.0",
    [string]$PluginId = "pptify",
    [string]$Repository = "https://github.com/github/awesome-copilot",
    [string]$AuthorName = "PPTify maintainers"
)

$ErrorActionPreference = "Stop"

$scriptPath = $PSCommandPath
if (-not $scriptPath) {
    $scriptPath = $MyInvocation.MyCommand.Path
}

$deployRoot = Split-Path -Parent $scriptPath
$repoRoot = Split-Path -Parent $deployRoot
$awesomeRoot = Join-Path $deployRoot "awesome-copilot"
$pluginRoot = Join-Path $awesomeRoot "plugins\$PluginId"
$pluginMetadataDir = Join-Path $pluginRoot ".github\plugin"
$skillsRoot = Join-Path $awesomeRoot "skills"
$manifestPath = Join-Path $deployRoot "manifest.json"

function ConvertTo-PrettyJsonFile {
    param(
        [Parameter(Mandatory = $true)] [object]$InputObject,
        [Parameter(Mandatory = $true)] [string]$Path,
        [int]$Depth = 10
    )

    $json = $InputObject | ConvertTo-Json -Depth $Depth
    Write-Utf8NoBom -Path $Path -Value $json
}

function Write-Utf8NoBom {
    param(
        [Parameter(Mandatory = $true)] [string]$Path,
        [Parameter(Mandatory = $true)] [string]$Value
    )

    $encoding = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($Path, $Value, $encoding)
}

function Get-RelativeDeployPath {
    param([Parameter(Mandatory = $true)] [string]$Path)

    $fullPath = [System.IO.Path]::GetFullPath($Path)
    $basePath = [System.IO.Path]::GetFullPath($repoRoot)
    if (-not $basePath.EndsWith("\")) {
        $basePath = "$basePath\"
    }
    if ($fullPath.StartsWith($basePath, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $fullPath.Substring($basePath.Length).Replace("/", "\")
    }
    return $fullPath.Replace("/", "\")
}

Push-Location -LiteralPath $repoRoot
try {
    if (Test-Path -LiteralPath $awesomeRoot) {
        Remove-Item -LiteralPath $awesomeRoot -Recurse -Force
    }
    New-Item -ItemType Directory -Path $pluginMetadataDir -Force | Out-Null
    New-Item -ItemType Directory -Path $skillsRoot -Force | Out-Null

    $sourceSkillsRoot = Join-Path $repoRoot "pptify-core\skills"
    if (-not (Test-Path -LiteralPath $sourceSkillsRoot)) {
        throw "Source skills directory not found: $sourceSkillsRoot"
    }

    $skills = Get-ChildItem -LiteralPath $sourceSkillsRoot -Directory |
        Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName "SKILL.md") } |
        Sort-Object Name

    foreach ($skill in $skills) {
        $destDir = Join-Path $skillsRoot $skill.Name
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        Copy-Item -Path (Join-Path $skill.FullName "*") `
                  -Destination $destDir -Recurse -Force
    }

    $pluginJson = [ordered]@{
        name = $PluginId
        description = "Generate production-ready PowerPoint decks with pptify skills, source ingestion, design-context selection, coordinate-explicit slide specs, visual assets, runtime tooling, and audit-driven quality gates."
        version = $Version
        author = [ordered]@{
            name = $AuthorName
        }
        repository = $Repository
        license = "MIT"
        keywords = @(
            "pptify",
            "powerpoint",
            "pptx",
            "presentations",
            "deck-generation",
            "slides",
            "design-context",
            "visual-assets",
            "quality-gates"
        )
        skills = @($skills | ForEach-Object { "./skills/$($_.Name)/" })
    }
    ConvertTo-PrettyJsonFile -InputObject $pluginJson -Path (Join-Path $pluginMetadataDir "plugin.json")

    $readme = @'
# PPTify Plugin

Generate production-ready PowerPoint decks with pptify skills, source ingestion, design context, coordinate-explicit slide specs, visual assets, runtime tooling, and audit-driven quality gates.

## Installation

```bash
copilot plugin install pptify@awesome-copilot
```

## What's Included

### Skills

| Skill | Description |
| --- | --- |
| `pptify-context-prep` | Prepare source material and design context before authoring a pptify deck spec. |
| `pptify-deck-generation` | Generate PPTX decks end to end from prompts, source material, reference PPTX analysis, coordinate-explicit layout trees, or pptify JSON specs. |
| `pptify-quality-gates` | Validate and repair PPTX artifacts by checking specs, PPTX packages, audits, layout trees, collisions, text overflows, warnings, visual hierarchy, asset layering, and reference deck alignment. |
| `pptify-slide-spec` | Author or repair coordinate-explicit pptify JSON deck specs with layout tree groups, objects, bounding boxes, tables, images, lines, shapes, type scale, and collision-safe content. |
| `pptify-tooling` | Look up pptify install commands, plugin script syntax, and workspace reality checks. |
| `pptify-visual-assets` | Find, generate, and place icons, images, SVGs, raster conversions, infographics, image placeholders, and asset-backed slide objects. |

## Optional Toolkit

The bundled skills include reference material for design profile selection and manual quality checks. To run helper scripts for source prep, design context, visual assets, extraction, or audits, users can optionally install the PPTify toolkit from its source repository. The current external toolkit does not provide an importable `pptify` renderer module.

Do not clone or install the external toolkit automatically. Install it only when the user explicitly asks to use helper scripts:

```powershell
git clone https://github.com/kimtth/agent-pptify-kit
cd agent-pptify-kit
uv sync                   # base project
uv sync --extra plugins   # add source ingestion and image helpers
```

## Usage

Ask Copilot to create or repair a deck and mention `pptify`. The plugin guides the agent to collect required deck inputs, prepare source and reference context, select a design profile, author a coordinate-explicit JSON spec, build through the available PowerPoint path, and repair audit findings before reporting artifact paths.

## Source

Plugin skills are sourced from [kimtth/agent-pptify-kit](https://github.com/kimtth/agent-pptify-kit) for submission to [Awesome Copilot](https://github.com/github/awesome-copilot).

## License

MIT
'@
    Write-Utf8NoBom -Path (Join-Path $pluginRoot "README.md") -Value $readme

    $manifest = [ordered]@{
        name = "pptify-awesome-copilot-deploy"
        targetRepository = "https://github.com/github/awesome-copilot"
        pluginId = $PluginId
        version = $Version
        description = "Awesome Copilot PR artifacts for PPTify plugin with skills at top-level."
        generatedWith = [ordered]@{
            command = "deploy\create-artifacts.ps1 - copies skill folders from pptify-core\skills\"
        }
        copyRoot = "deploy\awesome-copilot"
        generator = "deploy\create-artifacts.ps1"
        artifacts = @(
            "deploy\awesome-copilot\plugins\$PluginId\.github\plugin\plugin.json",
            "deploy\awesome-copilot\plugins\$PluginId\README.md",
            "deploy\awesome-copilot\skills"
        )
        validationCommands = @(
            "npm install",
            "npm run plugin:validate",
            "npm run build"
        )
    }
    ConvertTo-PrettyJsonFile -InputObject $manifest -Path $manifestPath

    $requiredPaths = @(
        (Join-Path $pluginMetadataDir "plugin.json"),
        (Join-Path $pluginRoot "README.md")
    )
    foreach ($skill in $skills) {
        $sourceFiles = Get-ChildItem -LiteralPath $skill.FullName -Recurse -File
        foreach ($sourceFile in $sourceFiles) {
            $relativePath = $sourceFile.FullName.Substring($skill.FullName.Length).TrimStart("\", "/")
            $requiredPaths += Join-Path (Join-Path $skillsRoot $skill.Name) $relativePath
        }
    }
    foreach ($path in $requiredPaths) {
        if (-not (Test-Path -LiteralPath $path)) {
            throw "Required artifact missing: $(Get-RelativeDeployPath -Path $path)"
        }
    }

    $fileCount = (Get-ChildItem -LiteralPath $deployRoot -Recurse -File | Measure-Object).Count
    $sizeBytes = (Get-ChildItem -LiteralPath $deployRoot -Recurse -File | Measure-Object Length -Sum).Sum

    Write-Host "Created deploy artifacts for '$PluginId'."
    Write-Host "Skills root: $(Get-RelativeDeployPath -Path $skillsRoot)"
    Write-Host "Skills copied: $($skills.Count)"
    Write-Host ("Deploy tree: {0} files, {1:N2} MB" -f $fileCount, ($sizeBytes / 1MB))
}
finally {
    Pop-Location
}
