# pptify Architecture

This workspace snapshot is a PPTX plugin toolkit plus Copilot prompt assets. It does not currently contain an importable `pptify/` core renderer package or a `python -m pptify` command; lifecycle commands run through the `pptify-cli` directory entry point.

## Current Components

- `pptify-plugin/documents`: document-to-markdown and markdown-to-RAPTOR helpers.
- `pptify-plugin/design`: source-backed design context catalog loader for `pptify-design`.
- `pptify-plugin/images`: web image search, Iconify search, raster-to-SVG conversion, and OpenAI/Azure OpenAI infographic generation.
- `pptify-plugin/audit`: standalone content-region collision audit for layout-tree JSON specs.
- `pptify-plugin/extraction`: importable PPTX extraction and style-master analysis helpers.
- `pptify-core`: Agent Skills and workflow prompts used by Copilot or any generic coding agent when planning decks.
- `pptify-cli`: Lifecycle commands for installing and uninstalling the pptify skill set into a local coding-agent home (`./.agent` by default).
- `pptify-design`: local source-backed design context packs and attribution metadata.

## Execution Model

Plugin scripts are called directly by file path and write JSON to stdout:

```powershell
uv run python pptify-plugin/design/design_context_catalog.py --list --pretty
uv run python pptify-plugin/images/text_prompt_to_infographic.py --provider auto --prompt "Cloud governance roadmap" --output-path infographic.png --pretty
uv run python pptify-plugin/audit/audit.py deck-spec.json --json
```

Extraction helpers are import APIs. Because `pptify-plugin` contains a dash, load those modules with `importlib.util.spec_from_file_location(...)`.

## Data Contracts

The prompt assets still use the agent-coordinate contract for generated deck specs:

- Each generated slide should have explicit slide size, groups, object IDs, bboxes, roles, styles, and z-order.
- Text-bearing objects should carry explicit font size and color.
- Lines should carry explicit endpoints and line style.
- Shapes should carry explicit shape, fill, and line style.
- Image-model attempts must record provider, model or deployment, prompt path, output path, status, and error details when generation fails.

In this snapshot, that contract is planning/audit context. There is no local renderer package that consumes the full layout tree and writes a PPTX from `python -m pptify`; use `uv run python pptify-cli ...` only for install/help lifecycle commands.

## Image Generation Boundary

`pptify-plugin/images/text_prompt_to_infographic.py` supports `openai`, `azure-openai`, and `auto` provider selection. It deliberately has no local fallback image provider. If credentials or provider configuration are missing, or the provider returns an error, the caller should persist the failure manifest and avoid describing substitute artwork as model-generated.

Provider configuration and credentials are loaded from `.env`. Create `.env` from `.env.template` when image generation is needed, fill the required values locally, and keep `.env` out of git.

## Optional Assets

The MiniLM ONNX model and tokenizer are downloaded on demand and ignored by git:

- `pptify-plugin/external/all-MiniLM-L6-v2/*`

Restore with:

```powershell
.\pptify-plugin\download-external-assets.ps1
```

`document_to_raptor_tree.py` currently uses deterministic local embeddings and does not require the MiniLM external assets.

## Quality Gates

For generated artifacts, use the standalone audit plugin and PPTX package inspection scripts/helpers to confirm slide count, hidden-slide metadata, media counts, and collision status.

## Known Gaps

- Prompt assets may still mention restored-renderer paths conditionally; treat them as unavailable unless a core renderer package is restored.
