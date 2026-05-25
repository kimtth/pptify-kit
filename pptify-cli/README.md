# pptify-cli

Production install surface for the pptify generic coding-agent skill extension.

`pptify-cli` copies the pptify skill set from `pptify-core/skills/` into the
local agent home (`./.agent/`), copies the predefined design context, plugin
tool set, and `.env.template`, seeds a default developer-protection policy, and
provides explicit lifecycle commands.

Runtime dependencies: `pptify-core`, `pptify-design`, `pptify-plugin`.

## Commands

```powershell
pptify install              # copy skills, workflows, plugin/design assets, policy into ./.agent/
pptify install --dry-run    # preview without writing files
pptify install --home <dir> # install into <dir>/.agent (e.g. temp/pptify-install-test/.agent)

pptify uninstall            # remove installed pptify assets from ./.agent/
pptify uninstall --dry-run  # preview without removing files
pptify uninstall --home <dir> # uninstall from <dir>/.agent

pptify help                 # list available design profiles and plugins
pptify help --designs       # design profiles only
pptify help --plugins       # plugin scripts only
pptify help --profile <id>  # print full JSON for one design profile
```

## Installed Artifacts

| Artifact | Destination |
| --- | --- |
| `pptify-core/skills/pptify-*/SKILL.md` | `./.agent/skills/pptify-*/SKILL.md` |
| `pptify-core/workflows/*.md` | `./.agent/workflows/*.md` |
| `pptify-plugin/` | `./.agent/pptify-plugin/` |
| `pptify-design/` | `./.agent/pptify-design/` |
| `.env.template` | `./.agent/.env.template` |
| Developer-protection policy | `./.agent/pptify-policy.md` |
| Generic agent instruction | `./.agent/copilot-instruction.md` |

## Running Without Installation

Call `pptify-cli` directly by directory when running from this checkout:

```powershell
uv run python pptify-cli install
uv run python pptify-cli help
```

## Developer-Protection Policy

`pptify install` seeds `./.agent/pptify-policy.md` with constraints that
govern safe, production-quality deck generation:

- **Secrets**: API keys and tokens must never appear in specs, prompts, audits,
  manifests, or commit history.
- **Coordinate contract**: All generated slides must use explicit `layout_tree`
  with final bboxes, font sizes, colors, and z-order. Obsolete shorthand keys
  (`pattern`, `layout`, `sections`, `bullets`, `theme`, etc.) are prohibited.
- **Quality gates**: Zero content collisions, zero text overflows, no
  `classification: "content"` font size below 9 pt.
- **Asset boundaries**: No external fonts, icons, or images without explicit
  license metadata and source attribution.

Run `pptify install` to refresh the policy after upgrading `pptify-cli`.

The repository also includes [`copilot-instruction.md`](../copilot-instruction.md),
which tells generic coding agents to use `./.agent` as the installed pptify
home instead of a Copilot-only directory.

## Available Skills

| Skill | Description |
| --- | --- |
| `pptify-context-prep` | Prepare source material and design context before authoring a deck spec |
| `pptify-deck-generation` | End-to-end PPTX generation workflow |
| `pptify-quality-gates` | Audit validation and repair |
| `pptify-slide-spec` | Coordinate-explicit JSON deck spec authoring and repair |
| `pptify-tooling` | Plugin and CLI tool selection |
| `pptify-visual-assets` | Icons, images, SVGs, and infographics |

## Available Design Profiles

List profiles:

```powershell
pptify help --designs
```

Or load profile context directly:

```powershell
uv run python pptify-plugin/design/design_context_catalog.py --list --pretty
uv run python pptify-plugin/design/design_context_catalog.py --profile primer-primitives --include-context --pretty
```

| Profile | Best for |
| --- | --- |
| `primer-primitives` | GitHub, developer, and token-driven engineering decks |
| `fluent-ui-design-tokens` | Microsoft, M365, Teams, and enterprise-aligned decks |
| `awesome-copilot-design-agents` | Agent prompt context for design review and UX discovery |
| `corazzon-pptx-design-styles` | Modern 30-style PPTX template catalog |
