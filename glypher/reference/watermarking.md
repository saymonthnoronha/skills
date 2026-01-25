# GLYPHER - Forensic Watermarking

This document details the invisible watermarking capabilities of GLYPHER, including techniques, capacity, persistence, and verification methods.

---

## Overview

GLYPHER provides forensic watermarking using Unicode's Variation Selectors Extended range (U+E0100-E01EF), enabling:

- **Invisible marking** - Watermarks don't affect visual appearance
- **Copy/paste persistence** - Survives most text transformations
- **High capacity** - 240 slots providing 1,920+ bits
- **Cryptographic verification** - HMAC-SHA256 integrity checking
- **Attribution tracking** - Document lineage and leak detection

---

## Technical Foundation

### Variation Selectors Extended

```
Unicode Range: U+E0100 - U+E01EF
Count: 240 characters (VS17 through VS256)
Properties:
├── Category: Mn (Mark, Nonspacing)
├── Rendering: Invisible (no glyph)
├── Behavior: Attach to preceding base character
└── Survival: Most copy/paste operations preserve them
```

### Why VS Extended?

| Method | Visibility | Persistence | Capacity | Detection Risk |
|--------|------------|-------------|----------|----------------|
| Zero-Width | Invisible | Medium | Low | High |
| Tags | Invisible | Low | High | High |
| **VS Extended** | **Invisible** | **High** | **High** | **Low** |
| Homoglyphs | Visible diff | High | Low | Medium |

VS Extended offers the best balance of invisibility, persistence, and low detection risk.

---

## Watermark Structure

### Payload Format

```
┌─────────────────────────────────────────────────────────────────────┐
│                    WATERMARK PAYLOAD STRUCTURE                      │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ HEADER (8 bytes)                                            │   │
│  │ ├── Magic: "GW" (2 bytes)                                   │   │
│  │ ├── Version: 0x41 (1 byte) = v4.1                          │   │
│  │ ├── Flags: 0x00 (1 byte)                                    │   │
│  │ └── Length: uint32 (4 bytes)                                │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ METADATA (variable)                                         │   │
│  │ ├── Document ID (up to 64 bytes)                           │   │
│  │ ├── Timestamp (8 bytes, Unix epoch)                        │   │
│  │ ├── Author hash (16 bytes, MD5)                            │   │
│  │ └── Custom fields (JSON, variable)                         │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ SIGNATURE (16 bytes)                                        │   │
│  │ └── HMAC-SHA256 truncated (128 bits)                        │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Encoding Scheme

```python
def encode_byte_to_vs(byte: int) -> str:
    """
    Encode a byte (0-255) using VS Extended.

    Since we have 240 selectors, we use a base-240 encoding:
    - Values 0-239: Direct mapping to VS17-VS256
    - Values 240-255: Escape sequence (VS256 + VS17-VS32)
    """
    VS_BASE = 0xE0100

    if byte < 240:
        return chr(VS_BASE + byte)
    else:
        # Escape for values >= 240
        return chr(VS_BASE + 239) + chr(VS_BASE + (byte - 240))
```

---

## Embedding Process

### Algorithm

```
1. Serialize metadata to JSON
2. Compute HMAC-SHA256 signature
3. Construct payload: header + metadata + signature
4. Encode payload using VS Extended
5. Distribute VS characters across carrier text
6. Return watermarked text
```

### Implementation

```python
import json
import hmac
import hashlib
from datetime import datetime

def embed_watermark(
    text: str,
    document_id: str,
    author: str = None,
    custom_data: dict = None,
    secret_key: bytes = None
) -> tuple[str, dict]:
    """
    Embed invisible watermark into text.

    Args:
        text: Carrier text
        document_id: Unique document identifier
        author: Optional author identifier
        custom_data: Optional custom metadata
        secret_key: HMAC key (default: internal key)

    Returns:
        tuple: (watermarked_text, metadata_dict)
    """
    if secret_key is None:
        secret_key = b"glypher-default-key-change-in-production"

    # Build metadata
    metadata = {
        "id": document_id,
        "ts": int(datetime.now().timestamp()),
        "v": "4.1"
    }

    if author:
        metadata["author"] = hashlib.md5(author.encode()).hexdigest()[:16]

    if custom_data:
        metadata["custom"] = custom_data

    # Serialize
    payload = json.dumps(metadata, separators=(',', ':')).encode('utf-8')

    # Sign
    signature = hmac.new(secret_key, payload, hashlib.sha256).digest()[:16]

    # Combine
    full_payload = payload + b"|" + signature

    # Encode to VS Extended
    vs_encoded = encode_payload_to_vs(full_payload)

    # Distribute across text
    watermarked = distribute_watermark(text, vs_encoded)

    return watermarked, metadata


def encode_payload_to_vs(payload: bytes) -> str:
    """Encode bytes to VS Extended characters."""
    VS_BASE = 0xE0100
    result = []

    for byte in payload:
        if byte < 240:
            result.append(chr(VS_BASE + byte))
        else:
            result.append(chr(VS_BASE + 239))
            result.append(chr(VS_BASE + (byte - 240)))

    return ''.join(result)


def distribute_watermark(text: str, watermark: str) -> str:
    """
    Distribute watermark characters throughout text.

    Strategy: Insert VS after every N-th base character,
    where N = len(text) / len(watermark)
    """
    if not text:
        return watermark

    interval = max(1, len(text) // (len(watermark) + 1))

    result = []
    wm_index = 0
    char_count = 0

    for char in text:
        result.append(char)
        char_count += 1

        # Don't attach VS to whitespace or control chars
        if wm_index < len(watermark) and char_count % interval == 0:
            if char not in ' \t\n\r':
                result.append(watermark[wm_index])
                wm_index += 1

    # Append remaining watermark at end
    if wm_index < len(watermark):
        result.extend(watermark[wm_index:])

    return ''.join(result)
```

---

## Extraction Process

### Algorithm

```
1. Scan text for VS Extended characters
2. Extract and decode VS sequence
3. Separate payload from signature
4. Verify HMAC signature
5. Parse metadata JSON
6. Return clean text + metadata
```

### Implementation

```python
def extract_watermark(
    text: str,
    secret_key: bytes = None,
    verify: bool = True
) -> dict:
    """
    Extract watermark from text.

    Args:
        text: Potentially watermarked text
        secret_key: HMAC key for verification
        verify: Whether to verify signature

    Returns:
        dict: {
            'found': bool,
            'verified': bool,
            'metadata': dict or None,
            'clean_text': str
        }
    """
    if secret_key is None:
        secret_key = b"glypher-default-key-change-in-production"

    VS_BASE = 0xE0100
    VS_END = 0xE01EF

    # Extract VS characters
    vs_chars = []
    clean_chars = []

    for char in text:
        code = ord(char)
        if VS_BASE <= code <= VS_END:
            vs_chars.append(code - VS_BASE)
        else:
            clean_chars.append(char)

    clean_text = ''.join(clean_chars)

    if not vs_chars:
        return {
            'found': False,
            'verified': False,
            'metadata': None,
            'clean_text': clean_text
        }

    # Decode VS to bytes
    payload_bytes = decode_vs_to_bytes(vs_chars)

    try:
        # Split payload and signature
        payload_str = payload_bytes.decode('utf-8', errors='ignore')

        if '|' not in payload_str:
            return {
                'found': True,
                'verified': False,
                'metadata': {'raw': payload_str},
                'clean_text': clean_text,
                'error': 'Invalid watermark format'
            }

        payload_part, sig_part = payload_str.rsplit('|', 1)

        # Verify signature
        if verify:
            expected_sig = hmac.new(
                secret_key,
                payload_part.encode('utf-8'),
                hashlib.sha256
            ).digest()[:16]

            # Compare (sig_part is hex or bytes)
            verified = hmac.compare_digest(
                expected_sig,
                sig_part.encode('latin-1')
            )
        else:
            verified = None

        # Parse metadata
        metadata = json.loads(payload_part)

        return {
            'found': True,
            'verified': verified,
            'metadata': metadata,
            'clean_text': clean_text
        }

    except Exception as e:
        return {
            'found': True,
            'verified': False,
            'metadata': None,
            'clean_text': clean_text,
            'error': str(e)
        }


def decode_vs_to_bytes(vs_values: list) -> bytes:
    """Decode VS Extended values back to bytes."""
    result = []
    i = 0

    while i < len(vs_values):
        val = vs_values[i]

        if val == 239 and i + 1 < len(vs_values):
            # Escape sequence for values >= 240
            result.append(240 + vs_values[i + 1])
            i += 2
        else:
            result.append(val)
            i += 1

    return bytes(result)
```

---

## Capacity Analysis

### Theoretical Maximum

```
VS Extended range: 240 characters
Encoding efficiency: ~7.9 bits per VS character
Maximum VS per document: ~1000 (practical limit)

Theoretical capacity: 1000 × 7.9 = 7,900 bits ≈ 987 bytes
```

### Practical Capacity

```
Recommended limits:
├── Document ID: 64 bytes
├── Timestamp: 8 bytes
├── Author hash: 16 bytes
├── Signature: 16 bytes
├── Header: 8 bytes
├── Overhead: ~20 bytes
└── Total base: ~132 bytes

Custom data budget: ~855 bytes remaining
```

### Capacity Calculator

```python
def calculate_watermark_capacity(
    text_length: int,
    density: float = 0.01
) -> dict:
    """
    Calculate watermark capacity for given text.

    Args:
        text_length: Length of carrier text
        density: VS per character ratio (0.01 = 1%)

    Returns:
        dict: Capacity metrics
    """
    max_vs_chars = int(text_length * density)
    max_bytes = int(max_vs_chars * 0.95)  # Account for escapes

    return {
        'text_length': text_length,
        'max_vs_characters': max_vs_chars,
        'max_payload_bytes': max_bytes,
        'recommended_metadata_bytes': min(max_bytes - 50, 200),
        'density': density
    }
```

---

## Persistence Testing

### Survival Matrix

| Transformation | VS Preserved | Notes |
|----------------|--------------|-------|
| Copy/paste (same app) | ✅ 100% | All VS survive |
| Copy/paste (cross-app) | ✅ 95% | Most survive |
| Plain text email | ✅ 90% | Some clients strip |
| Rich text / HTML | ✅ 85% | Depends on renderer |
| PDF generation | ⚠️ 70% | Font-dependent |
| OCR | ❌ 0% | Not preserved |
| Screenshot | ❌ 0% | Not preserved |
| Normalization (NFC) | ✅ 100% | VS not affected |
| Normalization (NFKC) | ⚠️ 80% | Some VS removed |

### Resilience Strategies

```python
def create_resilient_watermark(
    text: str,
    metadata: dict,
    redundancy: int = 3
) -> str:
    """
    Create watermark with redundancy for resilience.

    Embeds the same watermark multiple times at different
    positions to survive partial text loss.
    """
    # Create base watermark
    watermark = encode_metadata_to_vs(metadata)

    # Calculate segment positions
    segment_size = len(text) // (redundancy + 1)

    result = list(text)

    for i in range(redundancy):
        position = segment_size * (i + 1)
        # Insert complete watermark at each position
        for j, vs_char in enumerate(watermark):
            insert_pos = min(position + j, len(result))
            result.insert(insert_pos, vs_char)

    return ''.join(result)
```

---

## Security Considerations

### Threat Model

```
Threats:
├── Detection: Adversary discovers watermark exists
├── Removal: Adversary strips watermark
├── Forgery: Adversary creates fake watermark
└── Analysis: Adversary extracts payload without key

Mitigations:
├── Detection → Sparse distribution, plausible deniability
├── Removal → Redundancy, integrity checking
├── Forgery → HMAC signature verification
└── Analysis → Optional payload encryption
```

### Key Management

```python
# Production key management
class WatermarkKeyManager:
    def __init__(self, master_key: bytes):
        self.master_key = master_key

    def derive_document_key(self, document_id: str) -> bytes:
        """Derive unique key per document."""
        return hmac.new(
            self.master_key,
            document_id.encode(),
            hashlib.sha256
        ).digest()

    def derive_author_key(self, author_id: str) -> bytes:
        """Derive unique key per author."""
        return hmac.new(
            self.master_key,
            f"author:{author_id}".encode(),
            hashlib.sha256
        ).digest()
```

### Optional Encryption

```python
from cryptography.fernet import Fernet
import base64

def encrypt_payload(payload: bytes, key: bytes) -> bytes:
    """Encrypt watermark payload for confidentiality."""
    # Derive Fernet key from HMAC key
    fernet_key = base64.urlsafe_b64encode(
        hashlib.sha256(key).digest()
    )
    f = Fernet(fernet_key)
    return f.encrypt(payload)

def decrypt_payload(encrypted: bytes, key: bytes) -> bytes:
    """Decrypt watermark payload."""
    fernet_key = base64.urlsafe_b64encode(
        hashlib.sha256(key).digest()
    )
    f = Fernet(fernet_key)
    return f.decrypt(encrypted)
```

---

## Use Cases

### Document Tracking

```python
# Track document distribution
def track_document(content: str, recipient: str) -> str:
    """Create tracked copy for specific recipient."""
    watermarked, metadata = embed_watermark(
        text=content,
        document_id=f"DOC-{generate_id()}",
        author="legal-dept",
        custom_data={
            "recipient": recipient,
            "classification": "confidential",
            "expires": "2025-12-31"
        }
    )

    # Log distribution
    log_distribution(metadata, recipient)

    return watermarked
```

### Leak Detection

```python
# Detect leaked documents
def investigate_leak(leaked_content: str) -> dict:
    """Investigate leaked document for attribution."""
    result = extract_watermark(leaked_content)

    if result['found'] and result['verified']:
        metadata = result['metadata']

        return {
            'leak_confirmed': True,
            'original_document': metadata.get('id'),
            'original_recipient': metadata.get('custom', {}).get('recipient'),
            'distribution_date': metadata.get('ts'),
            'confidence': 'high' if result['verified'] else 'medium'
        }

    return {
        'leak_confirmed': False,
        'watermark_found': result['found'],
        'notes': 'Watermark may have been stripped or document not from tracked source'
    }
```

### Version Control

```python
# Track document versions
def watermark_version(
    content: str,
    doc_id: str,
    version: int,
    changes: list
) -> str:
    """Watermark specific version with change tracking."""
    return embed_watermark(
        text=content,
        document_id=f"{doc_id}-v{version}",
        custom_data={
            "version": version,
            "changes": changes[:5],  # First 5 changes
            "parent_version": version - 1 if version > 1 else None
        }
    )[0]
```

---

## API Reference

### glypher_watermark

```python
@mcp.tool()
def glypher_watermark(
    text: str,
    mode: Literal["embed", "extract"] = "embed",
    document_id: str = None
) -> str:
    """
    Forensic watermarking using Variation Selectors Extended.

    Parameters:
        text: Input text (carrier for embed, source for extract)
        mode: "embed" to add watermark, "extract" to retrieve
        document_id: Unique identifier (auto-generated if not provided)

    Returns:
        JSON with:
        - embed: {status, document_id, watermarked_text, watermark_length}
        - extract: {status, watermark, signature, verified, clean_text}
    """
```

### Usage Examples

```python
# Embed watermark
result = glypher_watermark(
    text="Confidential report content...",
    mode="embed",
    document_id="REPORT-2024-001"
)

# Extract watermark
result = glypher_watermark(
    text=watermarked_content,
    mode="extract"
)
```
