# pptify-kit

Agent-driven PPTX toolkit. Coding agents use the installed skill set, plugin tools, and predefined design context to plan and generate coordinate-explicit PowerPoint decks.

> **Sample** (densed and overcomplicated layout for stress testing): [pptify-kit-stress-demo.pptx](https://view.officeapps.live.com/op/view.aspx?src=https%3A%2F%2Fraw.githubusercontent.com%2Fkimtth%2Fpptify-kit%2Fmain%2Fdocs%2Fpptify-kit-stress-demo.pptx)


| Package | Purpose |
| --- | --- |
| [pptify-plugin](pptify-plugin) | Source ingestion, design context, image/SVG helpers, PPTX extraction, collision audit |
| [pptify-core](pptify-core) | Agent Skills and workflow prompts |
| [pptify-design](pptify-design) | Predefined design profiles and template context |
| [pptify-cli](pptify-cli) | Installs the above into `./.agent/` |

See [ARCHITECTURE.md](ARCHITECTURE.md) for details.

## Setup

```powershell
uv sync                    # base dependencies
uv sync --extra plugins    # add source conversion, image search, vector tracing
```

## Agent Install

```powershell
uv run python pptify-cli install                              # → ./.agent/
uv run python pptify-cli install --home ~                     # → ~/.agent/
uv run python pptify-cli install --home temp\pptify-install-test  # → temp\pptify-install-test\.agent\
```

See [pptify-cli/README.md](pptify-cli/README.md) for `uninstall`, `help`, and `--dry-run`.

## Image Provider Credentials

When OpenAI or Azure OpenAI image generation is needed, create a local `.env` from `.env.template` and fill the required provider values there. The image helper loads `.env` automatically; `.env` is git-ignored and must not be committed.

```powershell
Copy-Item .env.template .env
```

## Common Plugin Commands

```powershell
uv run python pptify-plugin/design/design_context_catalog.py --list --pretty
uv run python pptify-plugin/audit/audit.py deck-spec.json --json
uv run python pptify-plugin/images/iconfy_search.py --query governance --collection fluent --color 0078D4 --pretty
uv run python pptify-plugin/images/text_prompt_to_infographic.py --provider azure-openai --azure-endpoint "<endpoint>" --model "gpt-image-2" --prompt "..." --output-path out.png --pretty
```

Extraction helpers (`extraction/pptx_extractor.py`, `extraction/pptx_style_master.py`) are import APIs — load them with `importlib.util.spec_from_file_location(...)`.

## External Assets

The MiniLM ONNX model and tokenizer are not committed. Restore from the repository root:

```powershell
.\pptify-plugin\download-external-assets.ps1
```
