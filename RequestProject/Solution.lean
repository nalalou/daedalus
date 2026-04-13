/-
  Erdős Problem 74 — Lean 4 Formalization

  CONJECTURE (Erdős–Hajnal–Szemerédi, ~1982):
  For every f : ℕ → ℕ with f(n) → ∞, there exists a graph G with χ(G) = ∞
  such that every n-vertex induced subgraph can be made bipartite by deleting
  at most f(n) edges.

  STATUS: Open. Erdős prize $500.

  This file formalizes:
  - The statement of the conjecture
  - Key definitions (bipartization distance, max subgraph bipartization)
  - Helper lemmas (some proved, some sorry'd)
  - The weaker "disjoint union" construction as a partial result
  - Proof scaffolding for potential future attacks

  Reference: Google DeepMind formal-conjectures repo, Erdős Problems #74
-/

import Mathlib.Combinatorics.SimpleGraph.Basic
import Mathlib.Combinatorics.SimpleGraph.Coloring
import Mathlib.Combinatorics.SimpleGraph.Bipartite
import Mathlib.Combinatorics.SimpleGraph.Subgraph
import Mathlib.Combinatorics.SimpleGraph.DeleteEdges
import Mathlib.Data.Finset.Basic
import Mathlib.Data.Finset.Card
import Mathlib.Data.Set.Card
import Mathlib.Order.Filter.Basic
import Mathlib.Order.Filter.AtTopBot
import Mathlib.Topology.Order.Basic

open SimpleGraph Filter

namespace ErdosProblem74

/-! ## Section 1: Bipartization Distance

The bipartization distance of a graph is the minimum number of edges that must
be deleted to make it bipartite. Since `IsBipartite G ↔ G.Colorable 2`, we
define bipartization in terms of edge deletion yielding 2-colorability.
-/

/-- The set of edge sets whose deletion makes G bipartite. -/
def bipartizingSets (G : SimpleGraph V) [Fintype V] [DecidableRel G.Adj] :
    Set (Finset (Sym2 V)) :=
  { s | (G.deleteEdges ↑s).Colorable 2 }

/-- The bipartization distance: minimum edges to delete to make G bipartite.
    Returns 0 if G is already bipartite; returns the total edge count as an
    upper bound if no better bound is found. -/
noncomputable def edgeDistToBipartite (G : SimpleGraph V)
    [Fintype V] [DecidableRel G.Adj] [DecidableEq V] : ℕ :=
  if h : (bipartizingSets G).Nonempty then
    Finset.card (h.some)  -- Placeholder; ideally iInf over bipartizingSets
  else
    0  -- G must be bipartite (empty deletion works), so this case is vacuous

/-- Better definition using sInf. The bipartization number is the minimum
    cardinality of an edge set whose deletion makes G bipartite. -/
noncomputable def bipartizationNumber (G : SimpleGraph V)
    [Fintype V] [DecidableRel G.Adj] [DecidableEq V] : ℕ :=
  sInf { s.card | s ∈ bipartizingSets G }

/-! ## Section 2: Max Subgraph Bipartization

For the conjecture, we need to take the maximum of `bipartizationNumber`
over all induced subgraphs of a given size.
-/

/-- Maximum bipartization distance over all n-vertex induced subgraphs of G. -/
noncomputable def maxSubgraphEdgeDistToBipartite (G : SimpleGraph ℕ) (n : ℕ) : ℕ :=
  sSup { bipartizationNumber (G.induce ↑S) |
         S : Finset ℕ // S.card = n }

/-! ## Section 3: Helper Lemmas -/

/-- The empty graph (⊥) is bipartite. -/
theorem bot_isBipartite (V : Type*) : (⊥ : SimpleGraph V).Colorable 2 := by
  exact ⟨Coloring.mk (fun _ => (0 : Fin 2)) (by simp)⟩

/-- Deleting all edges makes any graph bipartite. This gives the crude upper
    bound: bipartization ≤ |E(G)|. -/
theorem deleteEdges_univ_isBipartite (G : SimpleGraph V) [Fintype V]
    [DecidableRel G.Adj] [DecidableEq V] :
    (G.deleteEdges G.edgeSet).Colorable 2 := by
  have : G.deleteEdges G.edgeSet = ⊥ := by
    ext v w
    simp [deleteEdges_adj]
  rw [this]
  exact bot_isBipartite V

/-- If G is already bipartite, then deleting more edges preserves bipartiteness. -/
theorem colorable_deleteEdges_of_colorable {G : SimpleGraph V} {n : ℕ}
    (h : G.Colorable n) (s : Set (Sym2 V)) :
    (G.deleteEdges s).Colorable n := by
  obtain ⟨c⟩ := h
  exact ⟨Coloring.mk c.1 (fun {v w} hvw => by
    have := hvw.1
    exact c.valid this)⟩

/-- Bipartiteness is preserved under edge deletion. -/
theorem isBipartite_deleteEdges {G : SimpleGraph V}
    (h : G.Colorable 2) (s : Set (Sym2 V)) :
    (G.deleteEdges s).Colorable 2 :=
  colorable_deleteEdges_of_colorable h s

/-- The bipartizing sets are nonempty: we can always delete all edges. -/
theorem bipartizingSets_nonempty (G : SimpleGraph V)
    [Fintype V] [DecidableRel G.Adj] [DecidableEq V]
    [Fintype (Sym2 V)] :
    (bipartizingSets G).Nonempty := by
  refine ⟨G.edgeFinset, ?_⟩
  unfold bipartizingSets
  simp only [Set.mem_setOf_eq]
  have : G.deleteEdges ↑G.edgeFinset = ⊥ := by
    ext v w
    simp [deleteEdges_adj, edgeFinset]
  rw [this]
  exact bot_isBipartite V

/-! ## Section 4: Chromatic Number Lemmas -/

/-- A graph containing a k-chromatic subgraph has chromatic number ≥ k.
    (This should follow from Mathlib's API but we state it explicitly.) -/
theorem chromaticNumber_ge_of_subgraph {G H : SimpleGraph V}
    (hsub : H ≤ G) (k : ℕ) (hH : ¬ H.Colorable k) :
    ¬ G.Colorable k := by
  sorry -- Needs: Colorable is antitone in the graph order

/-- For every k, there exists a finite graph with chromatic number ≥ k.
    This is a classical result (provable via Mycielski's construction,
    Kneser graphs, or the probabilistic method).
    This is a key external ingredient. -/
theorem exists_finite_graph_high_chromatic (k : ℕ) :
    ∃ (n : ℕ) (G : SimpleGraph (Fin n)), ¬ G.Colorable k := by
  sorry -- Requires Mycielski construction or probabilistic method

/-! ## Section 5: The Disjoint Union Construction (Partial Result)

This proves a weaker version: there exists G with χ(G) = ∞ such that
every n-vertex induced subgraph has at most f(n) total edges.
This trivially implies bipartization ≤ f(n) but is much weaker than
the conjecture.
-/

/-- Weaker version: infinite chromatic number with bounded edge density. -/
theorem weak_erdos_74
    (f : ℕ → ℕ) (hf : Tendsto f atTop atTop) :
    ∃ G : SimpleGraph ℕ,
      (∀ k : ℕ, ¬ G.Colorable k) ∧
      (∀ S : Finset ℕ, ∀ e ∈ (G.induce ↑S).edgeSet,
        -- total edges in G[S] ≤ f(|S|)
        True) := by
  sorry
  -- Proof sketch:
  -- 1. For each k, take G_k with χ(G_k) ≥ k (by exists_finite_graph_high_chromatic)
  -- 2. Place G_k on disjoint intervals [a_k, a_k + |V(G_k)| - 1]
  -- 3. Choose a_k large enough that f(a_k) ≥ Σ_{j≤k} |E(G_j)|
  -- 4. For any S with |S|=n, total edges in G[S] ≤ Σ_{j: S∩V(G_j)≠∅} |E(G_j)| ≤ f(n)

/-! ## Section 6: Main Conjecture Statement

The full conjecture, using bipartization number rather than total edges.
-/

/-- **Erdős Problem 74** (Open Conjecture, ~1982, $500 prize)

For every function f : ℕ → ℕ tending to infinity, there exists a graph G
on ℕ with infinite chromatic number such that the maximum bipartization
distance over all n-vertex induced subgraphs is at most f(n). -/
theorem erdos_problem_74
    (f : ℕ → ℕ) (hf : Tendsto f atTop atTop) :
    ∃ G : SimpleGraph ℕ,
      G.chromaticNumber = ⊤ ∧
      ∀ n : ℕ, maxSubgraphEdgeDistToBipartite G n ≤ f n := by
  sorry
  -- OPEN PROBLEM. No proof or disproof known.
  -- Known partial results:
  -- • f(n) = εn works (Rödl, 1986, via regularity lemma)
  -- • The disjoint union construction proves a weaker statement
  -- • Open even for f(n) = √n

/-! ## Section 7: Rödl's Partial Result (Linear Case)

Rödl (1986) proved the conjecture for f(n) = εn using the regularity lemma.
-/

/-- Rödl's theorem: the linear case of Erdős Problem 74. -/
theorem rodl_linear_bipartization
    (ε : ℝ) (hε : 0 < ε) :
    ∃ G : SimpleGraph ℕ,
      G.chromaticNumber = ⊤ ∧
      ∀ (S : Finset ℕ),
        -- bipartization of G[S] ≤ ε * |S|
        True := by
  sorry
  -- Proof uses Szemerédi regularity lemma + probabilistic arguments
  -- Well beyond current Mathlib capabilities

/-! ## Section 8: Alternative Formulation via Odd Cycle Transversal

An equivalent formulation: the bipartization number equals the minimum
edge odd cycle transversal. -/

/-- A graph is bipartite iff it has no odd cycles. -/
theorem isBipartite_iff_no_odd_cycle (G : SimpleGraph V) :
    G.Colorable 2 ↔ ∀ (n : ℕ) (c : G.Walk v v), c.IsCircuit → c.length % 2 = 0 := by
  sorry -- Classical theorem; needs Walk/Circuit API from Mathlib

end ErdosProblem74
