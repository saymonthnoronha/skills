# CLAUDE.md - AI Assistant Guide for Skills Repository

This document provides guidance for AI assistants working with the Anthropic Skills repository.

## Repository Overview

This repository contains **example skills** that demonstrate Claude's skills system. Skills are folders of instructions, scripts, and resources that Claude loads dynamically to perform better at specialized tasks. They act as "onboarding guides" for specific domains, transforming Claude from a general-purpose agent into a specialized one.

**License**: Example skills are Apache 2.0. Document skills in `document-skills/` are source-available (proprietary).

## Directory Structure

```
skills/
├── CLAUDE.md                    # This file
├── README.md                    # User-facing documentation
├── agent_skills_spec.md         # Official Agent Skills specification
├── THIRD_PARTY_NOTICES.md       # Third-party license attributions
├── .gitignore
├── .claude-plugin/              # Claude Code plugin marketplace configuration
│   └── marketplace.json
│
├── document-skills/             # Production document processing skills (proprietary)
│   ├── docx/                    # Word document processing
│   ├── pdf/                     # PDF manipulation toolkit
│   ├── pptx/                    # PowerPoint processing
│   └── xlsx/                    # Excel spreadsheet processing
│
└── [example-skills]/            # Open source example skills (Apache 2.0)
    ├── algorithmic-art/         # Generative art with p5.js
    ├── artifacts-builder/       # React/Tailwind HTML artifacts
    ├── brand-guidelines/        # Anthropic brand colors/typography
    ├── canvas-design/           # Visual art in PNG/PDF formats
    ├── internal-comms/          # Internal communications writing
    ├── mcp-builder/             # MCP server development guide
    ├── skill-creator/           # Guide for creating new skills
    ├── slack-gif-creator/       # Animated GIFs for Slack
    ├── template-skill/          # Minimal skill template
    ├── theme-factory/           # Professional theme styling
    └── webapp-testing/          # Playwright web app testing
```

## Skill Structure

Every skill must follow the Agent Skills Spec (`agent_skills_spec.md`):

### Minimum Required Structure

```
skill-name/
└── SKILL.md                     # Required entrypoint
```

### Complete Structure with Resources

```
skill-name/
├── SKILL.md                     # Required: Instructions and metadata
├── LICENSE.txt                  # Recommended: License terms
├── scripts/                     # Optional: Executable code (Python/Bash)
├── references/                  # Optional: Documentation loaded as needed
└── assets/                      # Optional: Templates, fonts, images for output
```

### SKILL.md Format

Every SKILL.md must begin with YAML frontmatter:

```yaml
---
name: skill-name                 # Required: hyphen-case, must match directory name
description: Description text    # Required: What it does and when to use it
license: LICENSE.txt             # Optional: License reference
allowed-tools:                   # Optional: Pre-approved tools (Claude Code only)
  - tool-name
metadata:                        # Optional: Client-specific key-value pairs
  key: value
---

# Markdown Body

Instructions, examples, and guidelines follow here.
```

### Frontmatter Conventions

- **name**: Lowercase alphanumeric + hyphens only. Must match the containing directory name.
- **description**: Use third-person ("This skill should be used when..."). Be specific about capabilities and trigger conditions.
- **license**: Keep short (license name or filename reference).

## Writing Style for Skills

When creating or editing skills, follow these conventions:

1. **Use imperative/infinitive form** (verb-first instructions):
   - Good: "To accomplish X, do Y"
   - Avoid: "You should do X" or "If you need to do X"

2. **Keep SKILL.md lean**: Move detailed reference material to `references/` files.

3. **Avoid duplication**: Information should live in SKILL.md OR reference files, not both.

4. **For large references** (>10k words): Include grep search patterns in SKILL.md.

## Resource Directories

### scripts/
- Executable code for deterministic, repeated tasks
- Example: `scripts/rotate_pdf.py` for PDF rotation
- Benefits: Token efficient, can execute without loading into context

### references/
- Documentation loaded into context as needed
- Examples: API docs, schemas, company policies, workflow guides
- Use when Claude should reference material while working

### assets/
- Files used in output (not loaded into context)
- Examples: Templates, logos, fonts, boilerplate code
- Use for resources that get copied or modified in final output

## Creating New Skills

Use the skill-creator skill's initialization script:

```bash
python skill-creator/scripts/init_skill.py <skill-name> --path <output-directory>
```

This creates a properly structured skill directory with SKILL.md template and example resource directories.

### Validation and Packaging

```bash
# Validate and package a skill
python skill-creator/scripts/package_skill.py <path/to/skill-folder>

# Quick validation only
python skill-creator/scripts/quick_validate.py <path/to/skill-folder>
```

## Claude Code Plugin System

This repository is configured as a **Claude Code plugin marketplace**, allowing users to install skills directly into Claude Code.

### Marketplace Configuration

The plugin marketplace is defined in `.claude-plugin/marketplace.json`:

```json
{
  "name": "anthropic-agent-skills",
  "owner": {
    "name": "Keith Lazuka",
    "email": "klazuka@anthropic.com"
  },
  "metadata": {
    "description": "Anthropic example skills",
    "version": "1.0.0"
  },
  "plugins": [
    {
      "name": "document-skills",
      "description": "Collection of document processing suite...",
      "source": "./",
      "strict": false,
      "skills": [
        "./document-skills/xlsx",
        "./document-skills/docx",
        "./document-skills/pptx",
        "./document-skills/pdf"
      ]
    },
    {
      "name": "example-skills",
      "description": "Collection of example skills...",
      "source": "./",
      "strict": false,
      "skills": [
        "./skill-creator",
        "./mcp-builder",
        "./canvas-design",
        // ... additional skills
      ]
    }
  ]
}
```

### Available Plugin Collections

| Plugin Name | Description | Skills Included |
|-------------|-------------|-----------------|
| **document-skills** | Document processing suite | xlsx, docx, pptx, pdf |
| **example-skills** | Example skills collection | skill-creator, mcp-builder, canvas-design, algorithmic-art, internal-comms, webapp-testing, artifacts-builder, slack-gif-creator, theme-factory, brand-guidelines |

### Installation Commands

**Register the marketplace:**
```
/plugin marketplace add anthropics/skills
```

**Browse and install interactively:**
1. Select `Browse and install plugins`
2. Select `anthropic-agent-skills`
3. Select `document-skills` or `example-skills`
4. Select `Install now`

**Direct installation:**
```
/plugin install document-skills@anthropic-agent-skills
/plugin install example-skills@anthropic-agent-skills
```

### Using Installed Plugins

After installation, reference skills by mentioning them in prompts:
- "Use the PDF skill to extract form fields from path/to/file.pdf"
- "Use the canvas-design skill to create a poster"
- "Use the mcp-builder skill to create an MCP server"

### Plugin Configuration Fields

When creating a marketplace.json:

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Marketplace identifier |
| `owner.name` | Yes | Maintainer name |
| `owner.email` | Yes | Maintainer contact |
| `metadata.description` | Yes | Marketplace description |
| `metadata.version` | Yes | Version string |
| `plugins[].name` | Yes | Plugin name |
| `plugins[].description` | Yes | Plugin description |
| `plugins[].source` | Yes | Base path for skills |
| `plugins[].strict` | No | Strict mode flag |
| `plugins[].skills` | Yes | Array of skill paths |

## Key Files Reference

| File | Purpose |
|------|---------|
| `agent_skills_spec.md` | Official specification for skill structure |
| `skill-creator/SKILL.md` | Comprehensive guide for creating skills |
| `template-skill/SKILL.md` | Minimal starting template |
| `README.md` | User documentation and skill catalog |

## Development Guidelines

### When Modifying Skills

1. Maintain the exact frontmatter format (name + description required)
2. Ensure skill name matches directory name
3. Keep instructions concise but complete
4. Test with real use cases before finalizing

### When Adding New Skills

1. Use `init_skill.py` to create proper structure
2. Follow the skill-creator guide in `skill-creator/SKILL.md`
3. Delete unused example directories (scripts/, references/, assets/)
4. Package with `package_skill.py` to validate before distribution

### Documentation Standards

- Skills are for Claude to follow, not for human reading
- Focus on procedural knowledge that Claude wouldn't inherently know
- Include examples of when to use AND when not to use the skill
- Reference bundled resources explicitly so Claude knows they exist

## Common Patterns in This Repository

### Progressive Disclosure
Skills use three-level loading:
1. Metadata (always in context): ~100 words
2. SKILL.md body (when triggered): <5k words
3. Bundled resources (as needed): unlimited

### Templates and Assets
Many skills include templates:
- `algorithmic-art/templates/viewer.html` - Interactive art viewer template
- `artifacts-builder/scripts/` - Artifact initialization scripts
- `document-skills/*/scripts/` - Document processing utilities

### External Documentation Fetching
Some skills reference external docs:
- MCP skills fetch from `modelcontextprotocol.io`
- Skills may use WebFetch for current SDK documentation

## Summary

This repository demonstrates skill patterns ranging from simple (template-skill) to complex (document processing skills with scripts, schemas, and multiple reference files). When working with this codebase:

1. Follow the Agent Skills Spec strictly
2. Use imperative writing style
3. Keep SKILL.md focused; move details to references/
4. Test skills thoroughly with real use cases
5. Use provided scripts for initialization and validation
