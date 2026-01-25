# ENGINE Protocol - Segment Applications

This document details how ENGINE manifests across different industry segments, addressing specific problems with tailored solutions while maintaining consistent core principles.

---

## Legal Segment

### Problems

| Problem | Description |
|---------|-------------|
| **Disconnected Theses** | Legal arguments not linked to precedents |
| **Unsustainable Arguments** | Claims that don't hold up under scrutiny |
| **Lost "Why"** | Reasoning behind defense lines disappears |
| **AI-Generated Risk** | AI producing dangerous legal documents without proper grounding |

### ENGINE Solution

**Identity and Linking:**
- Assign IDs to theses, facts, and arguments
- Link precedents, norms, and interpretations
- Separate fact, interpretation, and rhetoric

**Structural Guarantees:**
```
Thesis-001
├── Fact-023 (observed event)
│   └── Source: Document-456, Page 12
├── Precedent-089 (prior ruling)
│   └── Court: STJ, Date: 2023-05-15
└── Norm-012 (applicable law)
    └── Article 5, Constitution
```

**Objective:** The argument sustains itself even without the lawyer present.

### Example Application

```yaml
legal_thesis:
  id: THESIS-2024-0342
  type: defense_argument
  claim: "Contract termination was justified under force majeure"

  supporting_facts:
    - fact_id: FACT-2024-0891
      content: "Pandemic declared March 11, 2020"
      source: WHO Official Declaration

    - fact_id: FACT-2024-0892
      content: "Operations suspended March 15, 2020"
      source: Internal Memo IM-2020-034

  precedents:
    - precedent_id: PREC-STJ-2021-456
      court: STJ
      ruling: "Force majeure applies to unforeseeable events"
      relevance: "Establishes pandemic as force majeure"

  legal_basis:
    - norm_id: NORM-CC-393
      content: "Article 393, Civil Code"
      interpretation: "Debtor not liable for fortuitous case"
```

---

## Marketing Segment

### Problems

| Problem | Description |
|---------|-------------|
| **Isolated Metrics** | Numbers without context or connection |
| **Success Narratives** | Stories shaped to appear successful regardless of reality |
| **Dashboards Without Causality** | Visualizations that don't explain why |
| **AI-Generated Persuasion** | Convincing text without strategic truth |

### ENGINE Solution

**Layer Separation:**
- **Data**: Reach, conversion, engagement numbers
- **Fact**: Campaign results as observed
- **Knowledge**: Why it worked (or didn't)

**Strategy Identity:**
- Strategies get IDs
- Learnings accumulate by real usage
- Attribution becomes traceable

### Example Application

```yaml
marketing_campaign:
  id: CAMP-2024-Q4-001
  name: "Black Friday Launch"

  data_layer:
    - metric_id: DATA-REACH-001
      value: 2_500_000
      unit: impressions
      period: "2024-11-20 to 2024-11-30"

    - metric_id: DATA-CONV-001
      value: 3.2
      unit: percent
      period: "2024-11-20 to 2024-11-30"

  fact_layer:
    - fact_id: FACT-CAMP-001
      content: "Campaign achieved 2.5M impressions with 3.2% conversion"
      derived_from: [DATA-REACH-001, DATA-CONV-001]

    - fact_id: FACT-CAMP-002
      content: "Peak engagement occurred on November 25"
      derived_from: [DATA-ENG-001]

  interpretation_layer:
    - interpretation_id: INT-CAMP-001
      content: "Strong performance attributed to early launch timing"
      supports: [FACT-CAMP-001]
      confidence: 0.75
      analyst: "marketing_team"

  knowledge_layer:
    - knowledge_id: KNOW-MKT-042
      content: "Black Friday campaigns starting 5+ days early achieve 30% higher conversion"
      validated_by: [CAMP-2024-Q4-001, CAMP-2023-Q4-001, CAMP-2022-Q4-001]
      version: 3
      last_updated: "2024-12-15"
```

---

## Journalism Segment

### Problems

| Problem | Description |
|---------|-------------|
| **Fact/Opinion Mixing** | Unclear boundaries between reporting and analysis |
| **Lost Context** | Background information not preserved |
| **Artificial Narratives** | Difficulty distinguishing honest reporting from constructed stories |

### ENGINE Solution

**Clear Distinctions:**
- Facts with IDs and explicit origins
- Opinions with interpretation IDs
- Narratives showing what was observed, inferred, or contextualized

### Example Application

```yaml
news_article:
  id: ART-2024-12-001
  headline: "Tech Company Announces Major Layoffs"

  facts:
    - fact_id: FACT-NEWS-001
      content: "Company X announced 10,000 job cuts"
      source: "Official press release, December 10, 2024"
      type: primary_source

    - fact_id: FACT-NEWS-002
      content: "Stock price dropped 8% following announcement"
      source: "NYSE trading data, December 10, 2024"
      type: observed_data

    - fact_id: FACT-NEWS-003
      content: "CEO cited 'market conditions' as reason"
      source: "Press conference transcript, 14:30 EST"
      type: direct_quote

  interpretations:
    - interpretation_id: INT-NEWS-001
      content: "Layoffs appear larger than industry average"
      basis: "Comparison with FACT-CONTEXT-001"
      type: analysis
      author: "Editorial team"

  context:
    - context_id: FACT-CONTEXT-001
      content: "Industry average layoffs in 2024: 5,000 per major company"
      source: "Industry report, Q3 2024"

  narrative_structure:
    - observed: [FACT-NEWS-001, FACT-NEWS-002, FACT-NEWS-003]
    - inferred: [INT-NEWS-001]
    - contextualized: [FACT-CONTEXT-001]
```

---

## Financial/Patrimonial Segment

### Problems

| Problem | Description |
|---------|-------------|
| **Correct-Looking Reports** | Documents that appear valid but lack substance |
| **Disconnected Charts** | Visualizations without decision connection |
| **External Explanations** | Verbal explanations outside the document |

### ENGINE Solution

**Complete Documentation:**
- Numbers with origin, comparison, and documented interpretation
- Separation between fact, performance, and narrative
- Versioned and reusable financial knowledge

### Example Application

```yaml
financial_report:
  id: FIN-REP-2024-Q4
  period: "Q4 2024"

  metrics:
    - metric_id: FIN-REV-001
      name: "Revenue"
      value: 45_000_000
      currency: USD
      source: "ERP System, Export 2024-12-31"

    - metric_id: FIN-REV-002
      name: "YoY Growth"
      value: 12.5
      unit: percent
      calculation: "(FIN-REV-001 - FIN-REV-2023-Q4) / FIN-REV-2023-Q4"

  facts:
    - fact_id: FACT-FIN-001
      content: "Q4 revenue reached $45M, 12.5% YoY growth"
      derived_from: [FIN-REV-001, FIN-REV-002]

  interpretations:
    - interpretation_id: INT-FIN-001
      content: "Growth driven primarily by new product line"
      supports: [FACT-FIN-001]
      evidence: [FIN-PROD-001, FIN-PROD-002]
      analyst: "CFO"
      date: "2025-01-05"

  knowledge:
    - knowledge_id: KNOW-FIN-012
      content: "Product launches in Q4 historically yield 15-20% revenue boost"
      version: 4
      validated_by: [FIN-REP-2024-Q4, FIN-REP-2023-Q4, FIN-REP-2022-Q4]
      confidence: 0.85
```

---

## Technology/Engineering Segment

### Problems

| Problem | Description |
|---------|-------------|
| **Code Without "Why"** | Implementation without rationale |
| **Undocumented Decisions** | Technical choices not recorded |
| **Refactoring Erasure** | Logic lost during code updates |

### ENGINE Solution

**Decision Architecture:**
- IDs for architectural decisions
- Code blocks and formulas identified
- Explicit evolution history
- Referenced logic, not rewritten

### Example Application

```yaml
architectural_decision:
  id: ADR-2024-042
  title: "Use Event Sourcing for Order Management"
  status: accepted
  date: "2024-08-15"

  context:
    - context_id: CTX-ADR-001
      content: "Current system loses order state history"
      evidence: "Support tickets ST-2024-100 through ST-2024-150"

    - context_id: CTX-ADR-002
      content: "Audit requirements mandate full state reconstruction"
      evidence: "Compliance requirement COMP-2024-003"

  decision:
    content: "Implement event sourcing pattern for order aggregate"
    rationale: "Enables complete audit trail and state reconstruction"

  consequences:
    positive:
      - "Full audit capability"
      - "Time-travel debugging"
      - "Event replay for testing"
    negative:
      - "Increased storage requirements"
      - "Learning curve for team"

  related_code:
    - block_id: CODE-ORD-001
      file: "src/orders/OrderAggregate.ts"
      lines: "45-120"
      implements: ADR-2024-042

  evolution:
    - version: 1
      date: "2024-08-15"
      change: "Initial decision"
    - version: 2
      date: "2024-10-01"
      change: "Added snapshot strategy for performance"
      reason: "Event replay too slow for large aggregates"
```

---

## Patents/Innovation Segment

### Problems

| Problem | Description |
|---------|-------------|
| **Fragile Delimitation** | Ideas not clearly bounded |
| **Originality Proof** | Difficulty demonstrating novelty |
| **Unclear Evolution** | Innovation progression not documented |
| **Authorship Disputes** | Contribution unclear |

### ENGINE Solution

**Innovation Tracking:**
- IDs for ideas
- Versioning of variations
- Usage trail
- Explicit contribution

### Example Application

```yaml
innovation_record:
  id: INV-2024-089
  title: "Adaptive Context Compression Algorithm"
  status: patent_pending

  idea_core:
    id: IDEA-CORE-089
    description: "Algorithm that dynamically compresses context based on semantic density"
    original_date: "2024-03-15"

  variations:
    - variation_id: VAR-089-001
      description: "Application to legal document processing"
      date: "2024-04-20"
      contributor: "researcher_a"

    - variation_id: VAR-089-002
      description: "Extension to multi-language support"
      date: "2024-06-10"
      contributor: "researcher_b"

  prior_art:
    - prior_id: PRIOR-001
      reference: "Smith et al., 2022, Context Compression Methods"
      differentiation: "Our approach is adaptive; prior art uses fixed compression"

  contributions:
    - contributor: "researcher_a"
      role: "Core algorithm design"
      percentage: 60
      evidence: [COMMIT-001, COMMIT-002, DOC-001]

    - contributor: "researcher_b"
      role: "Multi-language extension"
      percentage: 40
      evidence: [COMMIT-003, COMMIT-004]

  usage_trail:
    - usage_id: USE-001
      date: "2024-09-01"
      context: "Implemented in ENGINE Protocol v2.0"
      reference: "RELEASE-2024-09"
```

---

## Common Pattern Across Segments

### The Four Guarantees Applied

| Guarantee | Legal | Marketing | Journalism | Financial | Technology | Patents |
|-----------|-------|-----------|------------|-----------|------------|---------|
| **Nothing without function** | Every argument serves the case | Every metric ties to strategy | Every fact supports the story | Every number informs decision | Every code block has purpose | Every claim supports novelty |
| **Nothing without support** | Precedents backing claims | Data backing insights | Sources backing facts | Calculations backing figures | Tests backing implementations | Prior art backing differentiation |
| **Nothing without history** | Case evolution tracked | Campaign learning preserved | Story development documented | Financial trends versioned | Code decisions recorded | Idea evolution traced |
| **Nothing without relation** | Thesis-fact-precedent links | Metric-strategy-outcome links | Fact-context-interpretation links | Number-source-decision links | Code-decision-requirement links | Idea-variation-contribution links |

---

## Implementation Checklist by Segment

### Legal
- [ ] All theses have IDs
- [ ] All facts linked to sources
- [ ] All precedents catalogued
- [ ] Fact/interpretation/rhetoric separated
- [ ] Reasoning chains documented

### Marketing
- [ ] All metrics have data IDs
- [ ] Campaign results as facts (not interpretations)
- [ ] Strategy IDs assigned
- [ ] Learnings versioned
- [ ] Attribution traceable

### Journalism
- [ ] All facts have origin IDs
- [ ] Opinions clearly marked as interpretations
- [ ] Context preserved and linked
- [ ] Narrative structure explicit

### Financial
- [ ] All numbers have source IDs
- [ ] Calculations documented
- [ ] Interpretations separated from facts
- [ ] Knowledge versioned

### Technology
- [ ] All decisions have ADR IDs
- [ ] Code blocks linked to decisions
- [ ] Evolution history maintained
- [ ] Rationale preserved

### Patents
- [ ] All ideas have IDs
- [ ] Variations versioned
- [ ] Contributions explicit
- [ ] Prior art differentiated
