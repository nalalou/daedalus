# Lemma Decomposition for Erdős Problem 74

## Status

- **Open conjecture** — Erdős prize $500
- Google DeepMind has the statement formalized in `formal-conjectures` repo
- Our formalization: `Solution.lean` in this directory

---

## Layer 0: Mathlib Prerequisites

### Available in Mathlib

| API | Module | Notes |
|-----|--------|-------|
| `SimpleGraph V` | `SimpleGraph.Basic` | Base type |
| `SimpleGraph.Adj` | `SimpleGraph.Basic` | Adjacency relation |
| `SimpleGraph.edgeSet` | `SimpleGraph.Basic` | Set of edges as `Set (Sym2 V)` |
| `SimpleGraph.edgeFinset` | `SimpleGraph.Basic` | Finset of edges |
| `SimpleGraph.Coloring α` | `SimpleGraph.Coloring` | Proper vertex coloring |
| `SimpleGraph.Colorable n` | `SimpleGraph.Coloring` | Existence of n-coloring |
| `SimpleGraph.chromaticNumber` | `SimpleGraph.Coloring` | Returns `ENat`, `⊤` if not finitely colorable |
| `SimpleGraph.IsBipartite` | `SimpleGraph.Bipartite` | Abbreviation for `Colorable 2` |
| `SimpleGraph.deleteEdges G s` | `SimpleGraph.DeleteEdges` | Remove edges in `s : Set (Sym2 V)` |
| `SimpleGraph.induce S` | `SimpleGraph.Subgraph` | Induced subgraph on vertex set `S` |
| `Filter.Tendsto` | `Order.Filter.Basic` | For `f(n) → ∞` |
| `SimpleGraph.girth` | `SimpleGraph.Girth` | Length of shortest cycle |

### Missing from Mathlib

| Concept | Status | Impact |
|---------|--------|--------|
| Mycielski construction | Not formalized | Need for `exists_finite_graph_high_chromatic` |
| Erdős 1959 (high girth + high χ) | Not formalized | Alternative to Mycielski |
| Szemerédi regularity lemma | Not formalized | Needed for Rödl's result |
| Odd cycle characterization of bipartiteness | Partial | `Walk`/`Circuit` API exists but connection to `Colorable 2` not proved |
| Subgraph deletion on `Subgraph` type | Not in Mathlib | DeepMind defines their own |

---

## Layer 1: Custom Definitions

### 1.1 Bipartizing Sets

```lean
def bipartizingSets (G : SimpleGraph V) [Fintype V] [DecidableRel G.Adj] :
    Set (Finset (Sym2 V)) :=
  { s | (G.deleteEdges ↑s).Colorable 2 }
```

**Difficulty:** Trivial (just a definition)
**Dependencies:** `SimpleGraph.deleteEdges`, `Colorable`

### 1.2 Bipartization Number

```lean
noncomputable def bipartizationNumber (G : SimpleGraph V)
    [Fintype V] [DecidableRel G.Adj] [DecidableEq V] : ℕ :=
  sInf { s.card | s ∈ bipartizingSets G }
```

**Difficulty:** Easy (definition + well-foundedness)
**Dependencies:** `bipartizingSets`

### 1.3 Max Subgraph Bipartization

```lean
noncomputable def maxSubgraphEdgeDistToBipartite
    (G : SimpleGraph ℕ) (n : ℕ) : ℕ :=
  sSup { bipartizationNumber (G.induce ↑S) | S : Finset ℕ // S.card = n }
```

**Difficulty:** Medium (need to show the supremum is finite/attained)
**Dependencies:** `bipartizationNumber`, `SimpleGraph.induce`

---

## Layer 2: Structural Lemmas

### 2.1 `bot_isBipartite`

```lean
theorem bot_isBipartite (V : Type*) : (⊥ : SimpleGraph V).Colorable 2
```

**Difficulty:** Trivial
**Dependencies:** None
**Strategy:** Constant coloring function; no adjacent vertices in ⊥.
**Status:** ✅ Proved in Solution.lean

### 2.2 `deleteEdges_univ_isBipartite`

```lean
theorem deleteEdges_univ_isBipartite (G : SimpleGraph V) :
    (G.deleteEdges G.edgeSet).Colorable 2
```

**Difficulty:** Easy
**Dependencies:** `bot_isBipartite`
**Strategy:** Show `G.deleteEdges G.edgeSet = ⊥`, then apply 2.1.
**Status:** ✅ Proved in Solution.lean

### 2.3 `colorable_deleteEdges_of_colorable`

```lean
theorem colorable_deleteEdges_of_colorable {G : SimpleGraph V} {n : ℕ}
    (h : G.Colorable n) (s : Set (Sym2 V)) :
    (G.deleteEdges s).Colorable n
```

**Difficulty:** Easy
**Dependencies:** None (structural)
**Strategy:** A coloring of G restricts to a coloring of the subgraph.
**Status:** ✅ Proved in Solution.lean

### 2.4 `bipartizingSets_nonempty`

```lean
theorem bipartizingSets_nonempty (G : SimpleGraph V) :
    (bipartizingSets G).Nonempty
```

**Difficulty:** Easy
**Dependencies:** `deleteEdges_univ_isBipartite`
**Strategy:** `G.edgeFinset` is always a bipartizing set.
**Status:** ✅ Proved in Solution.lean

### 2.5 `bipartizationNumber_le_card_edgeFinset`

```lean
theorem bipartizationNumber_le_card_edgeFinset (G : SimpleGraph V)
    [Fintype V] [DecidableRel G.Adj] [DecidableEq V] :
    bipartizationNumber G ≤ G.edgeFinset.card
```

**Difficulty:** Easy
**Dependencies:** `bipartizingSets_nonempty`
**Strategy:** The edge finset is a bipartizing set; sInf ≤ any element.
**Status:** ❌ Not yet proved (sorry)

### 2.6 `bipartizationNumber_zero_iff`

```lean
theorem bipartizationNumber_zero_iff (G : SimpleGraph V) :
    bipartizationNumber G = 0 ↔ G.Colorable 2
```

**Difficulty:** Medium
**Dependencies:** `bipartizationNumber`, `bipartizingSets`
**Strategy:** Forward: if min is 0, empty deletion works. Backward: empty set is bipartizing.

### 2.7 `bipartizationNumber_antitone`

```lean
theorem bipartizationNumber_antitone {G H : SimpleGraph V}
    (h : H ≤ G) :
    bipartizationNumber H ≤ bipartizationNumber G
```

**Difficulty:** Medium
**Dependencies:** `bipartizationNumber`
**Strategy:** Any bipartizing set for G is also bipartizing for H (since H has fewer edges).
**Note:** Actually this goes the wrong way — fewer edges means easier to bipartize. Need: `bipartizationNumber_mono`: more edges → larger bipartization.

### 2.8 `chromaticNumber_ge_of_subgraph`

```lean
theorem chromaticNumber_ge_of_subgraph {G H : SimpleGraph V}
    (hsub : H ≤ G) (k : ℕ) (hH : ¬ H.Colorable k) :
    ¬ G.Colorable k
```

**Difficulty:** Easy
**Dependencies:** `Colorable` monotonicity
**Strategy:** A k-coloring of G restricts to a k-coloring of H.
**Status:** ❌ sorry (should be straightforward but needs Mathlib API)

---

## Layer 3: Known Partial Results (Formalization Targets)

### 3.1 Existence of Finite High-Chromatic Graphs

```lean
theorem exists_finite_graph_high_chromatic (k : ℕ) :
    ∃ (n : ℕ) (G : SimpleGraph (Fin n)), ¬ G.Colorable k
```

**Difficulty:** Very Hard (axiomatize for now)
**Dependencies:** None (external)
**Options:**
  - **Mycielski construction:** Inductive, triangle-free, χ grows. Feasible to formalize but significant effort.
  - **Complete graphs:** `K_k` requires k colors. Trivial but doesn't give triangle-free.
  - **Kneser graphs:** `KG(2k+1, k)` has χ = k+1 by Lovász. Very hard to formalize.
  - **Probabilistic method (Erdős 1959):** High girth + high χ. Extremely hard to formalize.

**Recommendation:** For complete graphs, this is easy: `K_{k+1}` is not k-colorable. This suffices for the disjoint union construction (we don't need triangle-free). For the full conjecture, we'd want high-girth graphs, which requires much more.

### 3.2 Rödl's Linear Case

```lean
theorem rodl_linear_bipartization (ε : ℝ) (hε : 0 < ε) :
    ∃ G : SimpleGraph ℕ, G.chromaticNumber = ⊤ ∧ ...
```

**Difficulty:** Open research problem to formalize (requires regularity lemma)
**Dependencies:** Szemerédi regularity lemma (not in Mathlib)

### 3.3 Weak Version (Disjoint Union)

```lean
theorem weak_erdos_74 (f : ℕ → ℕ) (hf : Tendsto f atTop atTop) :
    ∃ G : SimpleGraph ℕ, (∀ k, ¬ G.Colorable k) ∧ ...
```

**Difficulty:** Hard (but provable in principle)
**Dependencies:** 3.1, placement construction, bipartization bounds

---

## Layer 4: Possible Attack Strategies for the Full Conjecture

### 4.1 Probabilistic Method

- Construct random graphs with high chromatic number
- Control bipartization via Lovász Local Lemma or second moment method
- **Obstacle:** Controlling max over *all* induced subgraphs is exponentially harder than controlling the expected bipartization

### 4.2 Algebraic Constructions

- Shift graphs, Kneser graphs, Schrijver graphs
- **Advantage:** Explicit, structured
- **Obstacle:** Bipartization of induced subgraphs not well studied

### 4.3 Regularity + Ramsey

- Extends Rödl's approach below linear
- **Obstacle:** Regularity lemma gives bounds of tower-type, hard to push to sublinear

### 4.4 Topological Methods

- Borsuk-Ulam based (à la Lovász for Kneser)
- **Obstacle:** Connects chromatic number to topology, but bipartization is a metric property

---

## Layer 5: What Would Complete the Proof

A resolution would require:

1. **A new construction** of graphs with infinite chromatic number where odd cycles are extremely "spread out" — formally, any n vertices induce a graph whose odd-cycle edge transversal has size o(n) or even ≤ f(n).

2. **OR a new impossibility argument** showing that such spread-out odd cycles cannot coexist with infinite chromatic number for some specific f.

3. **Key missing ingredient:** A way to simultaneously control:
   - Global chromatic number (lower bound on coloring complexity)
   - Local bipartization (upper bound on odd-cycle density in every induced subgraph)

This tension between global and local properties is what makes the problem fundamentally difficult.

---

## Dependency Graph (ASCII)

```
erdos_problem_74  (OPEN)
    │
    ├── maxSubgraphEdgeDistToBipartite (def)
    │       └── bipartizationNumber (def)
    │               └── bipartizingSets (def)
    │                       └── SimpleGraph.deleteEdges (Mathlib)
    │                       └── SimpleGraph.Colorable 2 (Mathlib)
    │
    ├── chromaticNumber = ⊤
    │       └── ∀ k, ¬ Colorable k
    │               └── chromaticNumber_ge_of_subgraph [sorry]
    │
    └── [NO KNOWN PROOF]

weak_erdos_74  (PROVABLE)
    │
    ├── exists_finite_graph_high_chromatic [sorry - use K_n]
    ├── placement construction (needs: Tendsto, Finset arithmetic)
    ├── bipartizingSets_nonempty [✅]
    ├── deleteEdges_univ_isBipartite [✅]
    └── bipartizationNumber_le_card_edgeFinset [sorry - easy]
```
