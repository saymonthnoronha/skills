# GLYPHER - Sanitization Presets

This document details the five sanitization presets available in GLYPHER, their use cases, and character-level behavior.

---

## Preset Overview

| Preset | Security Level | Preserves | Best For |
|--------|----------------|-----------|----------|
| `strict` | Maximum | ASCII only | High-security environments |
| `moderate` | Balanced | Multilingual, emoji | General use |
| `light` | Minimal | Most content | Low-risk scenarios |
| `rag_hardened` | AI-optimized | Clean semantics | LLM/RAG pipelines |
| `preserve_pua` | Custom | PUA markers | Specialized systems |

---

## Preset: strict

### Description

Maximum security sanitization that removes ALL non-ASCII characters.

### Behavior

```
Removes:
├── All Unicode characters above U+007F
├── All control characters
├── All combining marks
├── All invisibles
├── All emoji
└── All non-Latin scripts

Preserves:
├── ASCII letters (a-z, A-Z)
├── ASCII digits (0-9)
├── Basic punctuation (!@#$%^&*...)
├── Space, tab, newline
└── Nothing else
```

### Use Cases

- Usernames and identifiers
- URL validation
- Legacy system integration
- Maximum attack surface reduction

### Example

```python
Input:  "Hëllo Wörld! 你好 🌍"
Output: "Hllo Wrld! "

Input:  "admin​istrator"  # Contains ZWSP
Output: "administrator"

Input:  "раssword"  # Cyrillic 'р' and 'а'
Output: "ssword"
```

### Implementation

```python
def sanitize_strict(text: str) -> str:
    """Remove everything except ASCII printable + whitespace."""
    result = []
    for char in text:
        code = ord(char)
        # ASCII printable (32-126) plus common whitespace
        if 32 <= code <= 126 or char in '\n\t\r':
            result.append(char)
    return ''.join(result)
```

### Warnings

- **Data loss**: Removes legitimate multilingual content
- **User experience**: May frustrate international users
- **Not suitable for**: Content that requires Unicode support

---

## Preset: moderate

### Description

Balanced sanitization that removes invisible threats while preserving legitimate multilingual content and emoji.

### Behavior

```
Removes:
├── Zero-width characters (U+200B-200F, U+2060-2064)
├── BIDI controls (U+202A-202E, U+2066-2069)
├── Tag characters (U+E0000-E007F)
├── VS Extended (U+E0100-E01EF)
├── Interlinear annotation (U+FFF9-FFFB)
└── Other format characters (category Cf)

Preserves:
├── All visible scripts (Latin, Cyrillic, CJK, Arabic, etc.)
├── Emoji and symbols
├── Standard whitespace
├── Combining marks (accents, diacritics)
├── Basic variation selectors (for emoji)
└── Mathematical symbols
```

### Use Cases

- General web content
- User-generated content
- International applications
- Default recommendation

### Example

```python
Input:  "Hëllo Wörld! 你好 🌍"
Output: "Hëllo Wörld! 你好 🌍"  # Preserved

Input:  "admin​istrator"  # Contains ZWSP
Output: "administrator"  # ZWSP removed

Input:  "⁦malicious⁩ code"  # Contains LRI/PDI
Output: "malicious code"  # BIDI removed

Input:  "Hello󠁨󠁩󠁤󠁤󠁥󠁮"  # Contains tags
Output: "Hello"  # Tags removed
```

### Implementation

```python
def sanitize_moderate(text: str) -> str:
    """Remove invisibles, keep multilingual content."""
    INVISIBLE_RANGES = [
        (0x200B, 0x200F),  # Zero-width + directional
        (0x202A, 0x202E),  # BIDI overrides
        (0x2060, 0x2064),  # Word joiner + math invisible
        (0x2066, 0x2069),  # BIDI isolates
        (0xE0000, 0xE007F),  # Tags
        (0xE0100, 0xE01EF),  # VS Extended
        (0xFFF9, 0xFFFB),  # Interlinear
    ]

    def is_invisible(code):
        return any(start <= code <= end for start, end in INVISIBLE_RANGES)

    result = []
    for char in text:
        code = ord(char)
        if not is_invisible(code):
            # Also check category
            if unicodedata.category(char) != 'Cf' or char in ' \t\n\r':
                result.append(char)

    return ''.join(result)
```

---

## Preset: light

### Description

Minimal sanitization that only removes the most dangerous characters (BIDI controls and tag sequences).

### Behavior

```
Removes:
├── BIDI controls (Trojan Source prevention)
├── Tag characters (Ghost Plane)
└── Nothing else

Preserves:
├── Zero-width characters
├── VS Extended
├── Homoglyphs
├── All visible content
├── All invisibles except tags/BIDI
└── Everything else
```

### Use Cases

- When you need to detect but not destroy
- Logging and forensics
- When false positives are costly
- Development and testing

### Example

```python
Input:  "admin​istrator"  # Contains ZWSP
Output: "admin​istrator"  # ZWSP preserved

Input:  "⁦malicious⁩ code"  # Contains LRI/PDI
Output: "malicious code"  # BIDI removed

Input:  "a\U000E0100b"  # Contains VS17
Output: "a\U000E0100b"  # VS preserved

Input:  "a󠁨b"  # Contains tag
Output: "ab"  # Tag removed
```

### Implementation

```python
def sanitize_light(text: str) -> str:
    """Remove only critical threats."""
    BIDI_CONTROLS = [
        0x202A, 0x202B, 0x202C, 0x202D, 0x202E,
        0x2066, 0x2067, 0x2068, 0x2069
    ]

    result = []
    for char in text:
        code = ord(char)

        # Block BIDI controls
        if code in BIDI_CONTROLS:
            continue

        # Block tag characters
        if 0xE0000 <= code <= 0xE007F:
            continue

        result.append(char)

    return ''.join(result)
```

---

## Preset: rag_hardened

### Description

Specialized sanitization optimized for LLM and RAG pipeline ingestion. Normalizes homoglyphs and removes all content that could cause tokenization anomalies.

### Behavior

```
Removes:
├── All invisible characters
├── All BIDI controls
├── All tag characters
├── All VS Extended
├── Combining mark stacking (limit to 3)
└── Unusual whitespace variants

Transforms:
├── Homoglyphs → ASCII equivalents
├── Fullwidth → Regular width
├── Fancy Unicode → Plain equivalent
└── Multiple spaces → Single space

Preserves:
├── Core multilingual content (post-normalization)
├── Standard punctuation
├── Standard whitespace
└── Standard emoji (base forms)
```

### Use Cases

- RAG document ingestion
- LLM prompt preprocessing
- Embedding generation
- Token-sensitive applications

### Example

```python
Input:  "Неllo"  # Cyrillic 'Н' and 'е'
Output: "Hello"  # Normalized to Latin

Input:  "ＨＥＬＬＯ"  # Fullwidth
Output: "HELLO"  # Regular width

Input:  "he​llo wo​rld"  # ZWSPs
Output: "hello world"  # Cleaned

Input:  "H̷̢̛̛̖e̸̡̛l̵̢̛l̷̡̛o"  # Zalgo
Output: "Hello"  # Combining marks removed
```

### Implementation

```python
def sanitize_rag_hardened(text: str) -> str:
    """Optimize for LLM/RAG ingestion."""
    import unicodedata

    # Normalize to NFKC (compatibility decomposition)
    text = unicodedata.normalize('NFKC', text)

    # Homoglyph mapping
    CONFUSABLES = {
        'а': 'a', 'е': 'e', 'о': 'o', 'р': 'p', 'с': 'c',
        'х': 'x', 'у': 'y', 'Н': 'H', 'В': 'B', 'Е': 'E',
        # ... full mapping
    }

    result = []
    combining_count = 0

    for char in text:
        code = ord(char)
        category = unicodedata.category(char)

        # Skip format characters
        if category == 'Cf':
            continue

        # Skip tag and VS extended
        if 0xE0000 <= code <= 0xE01EF:
            continue

        # Limit combining marks
        if category.startswith('M'):
            combining_count += 1
            if combining_count > 3:
                continue
        else:
            combining_count = 0

        # Normalize homoglyphs
        if char in CONFUSABLES:
            result.append(CONFUSABLES[char])
        else:
            result.append(char)

    # Collapse multiple spaces
    output = ''.join(result)
    output = re.sub(r'[ \t]+', ' ', output)
    output = re.sub(r'\n{3,}', '\n\n', output)

    return output.strip()
```

### Configuration Options

```python
RAG_CONFIG = {
    'max_combining_marks': 3,
    'normalize_form': 'NFKC',
    'collapse_whitespace': True,
    'strip_emoji': False,
    'preserve_structure': True,
    'max_line_length': None
}
```

---

## Preset: preserve_pua

### Description

Sanitization that preserves Private Use Area (PUA) characters while removing standard threats. Used for systems that encode custom semantics in PUA ranges.

### Behavior

```
Preserves:
├── BMP PUA (U+E000-F8FF)
├── Plane 15 PUA (U+F0000-FFFFD)
├── Plane 16 PUA (U+100000-10FFFD)
└── All standard visible content

Removes:
├── BIDI controls
├── Tag characters (U+E0000-E007F) - not in PUA
├── Standard invisibles (outside PUA)
└── VS Extended (not in standard PUA)
```

### Use Cases

- Custom annotation systems
- Proprietary markup
- Legacy systems using PUA
- NORmAI-style semantic markers

### Example

```python
# NORmAI PUA markers example
Input:  "Hello\uE000World\uE001"  # Custom markers
Output: "Hello\uE000World\uE001"  # Preserved

Input:  "Hello󠁨World"  # Tag character
Output: "HelloWorld"  # Tag removed

Input:  "\uE000⁦text⁩\uE001"  # PUA + BIDI
Output: "\uE000text\uE001"  # PUA kept, BIDI removed
```

### Implementation

```python
def sanitize_preserve_pua(text: str) -> str:
    """Keep PUA markers, remove other threats."""
    PUA_RANGES = [
        (0xE000, 0xF8FF),      # BMP PUA
        (0xF0000, 0xFFFFD),    # Plane 15
        (0x100000, 0x10FFFD),  # Plane 16
    ]

    BIDI_CONTROLS = [
        0x202A, 0x202B, 0x202C, 0x202D, 0x202E,
        0x2066, 0x2067, 0x2068, 0x2069
    ]

    def is_pua(code):
        return any(start <= code <= end for start, end in PUA_RANGES)

    result = []
    for char in text:
        code = ord(char)

        # Always preserve PUA
        if is_pua(code):
            result.append(char)
            continue

        # Block BIDI controls
        if code in BIDI_CONTROLS:
            continue

        # Block tag characters (NOT in PUA despite Plane 14)
        if 0xE0000 <= code <= 0xE007F:
            continue

        # Keep everything else
        result.append(char)

    return ''.join(result)
```

---

## Preset Comparison Matrix

### Character Handling

| Character Type | strict | moderate | light | rag_hardened | preserve_pua |
|----------------|--------|----------|-------|--------------|--------------|
| ASCII letters | ✅ | ✅ | ✅ | ✅ | ✅ |
| ASCII digits | ✅ | ✅ | ✅ | ✅ | ✅ |
| ASCII punct | ✅ | ✅ | ✅ | ✅ | ✅ |
| Latin extended | ❌ | ✅ | ✅ | ✅ | ✅ |
| Cyrillic | ❌ | ✅ | ✅ | → Latin | ✅ |
| CJK | ❌ | ✅ | ✅ | ✅ | ✅ |
| Arabic | ❌ | ✅ | ✅ | ✅ | ✅ |
| Emoji | ❌ | ✅ | ✅ | ✅ | ✅ |
| ZWSP/ZWJ | ❌ | ❌ | ✅ | ❌ | ❌* |
| BIDI controls | ❌ | ❌ | ❌ | ❌ | ❌ |
| Ghost Tags | ❌ | ❌ | ❌ | ❌ | ❌ |
| VS Extended | ❌ | ❌ | ✅ | ❌ | ❌ |
| PUA | ❌ | ❌* | ✅ | ❌ | ✅ |
| Combining marks | ❌ | ✅ | ✅ | ≤3 | ✅ |

*Depends on specific implementation

---

## Selection Guide

### Decision Tree

```
START
  │
  ├─► Is ASCII sufficient?
  │   ├─► YES → Use "strict"
  │   └─► NO ↓
  │
  ├─► Is this for LLM/RAG?
  │   ├─► YES → Use "rag_hardened"
  │   └─► NO ↓
  │
  ├─► Do you use PUA markers?
  │   ├─► YES → Use "preserve_pua"
  │   └─► NO ↓
  │
  ├─► Is minimal intervention needed?
  │   ├─► YES → Use "light"
  │   └─► NO ↓
  │
  └─► DEFAULT → Use "moderate"
```

### Use Case Mapping

| Scenario | Recommended Preset |
|----------|-------------------|
| Username validation | strict |
| URL/domain checking | strict |
| Email body processing | moderate |
| Social media content | moderate |
| Code review | light |
| Forensic analysis | light |
| RAG document ingestion | rag_hardened |
| LLM prompt cleaning | rag_hardened |
| NORmAI integration | preserve_pua |
| Custom annotation system | preserve_pua |

---

## Custom Preset Creation

```python
def create_custom_preset(
    remove_invisibles: bool = True,
    remove_bidi: bool = True,
    remove_tags: bool = True,
    remove_vs_extended: bool = False,
    normalize_homoglyphs: bool = False,
    preserve_pua: bool = False,
    max_combining: int = 10,
    allowed_scripts: list = None
) -> callable:
    """
    Create a custom sanitization preset.

    Returns a sanitization function configured with
    the specified parameters.
    """
    def sanitize(text: str) -> str:
        result = []
        combining_count = 0

        for char in text:
            code = ord(char)
            category = unicodedata.category(char)

            # Check PUA preservation
            if preserve_pua and is_pua(code):
                result.append(char)
                continue

            # Check invisibles
            if remove_invisibles and category == 'Cf':
                continue

            # Check BIDI
            if remove_bidi and code in BIDI_CONTROLS:
                continue

            # Check tags
            if remove_tags and 0xE0000 <= code <= 0xE007F:
                continue

            # Check VS Extended
            if remove_vs_extended and 0xE0100 <= code <= 0xE01EF:
                continue

            # Check combining marks
            if category.startswith('M'):
                combining_count += 1
                if combining_count > max_combining:
                    continue
            else:
                combining_count = 0

            # Check allowed scripts
            if allowed_scripts:
                script = get_script(char)
                if script not in allowed_scripts and char.isalpha():
                    continue

            # Normalize homoglyphs
            if normalize_homoglyphs and char in CONFUSABLES:
                result.append(CONFUSABLES[char])
            else:
                result.append(char)

        return ''.join(result)

    return sanitize
```
