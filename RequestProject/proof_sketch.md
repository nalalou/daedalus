# Erdős Problem 74: Infinite Chromatic Number with Bounded Bipartization

## Status

**Open conjecture.** Originally posed by Erdős, Hajnal, and Szemerédi (~1982).
Erdős offered **$500** for a proof or disproof.

## Statement

**Conjecture.** For every function $f : \mathbb{N} \to \mathbb{N}$ with
$f(n) \to \infty$, there exists a graph $G$ with $\chi(G) = \infty$ such that
for every finite $S \subseteq V(G)$ with $|S| = n$, the induced subgraph $G[S]$
can be made bipartite by deleting at most $f(n)$ edges.

Equivalently: for every such $f$, there exists a graph $G$ with infinite
chromatic number such that

$$\max_{S \subseteq V(G),\, |S|=n} \operatorname{bip}(G[S]) \le f(n)$$

where $\operatorname{bip}(H)$ denotes the minimum number of edges whose removal
makes $H$ bipartite (the **bipartization number** or **odd cycle transversal
edge number**).

## Known Partial Results

### 1. Linear bipartization (Rödl, 1986)

For every $\varepsilon > 0$, there exists a graph $G$ with $\chi(G) = \infty$
such that every $n$-vertex induced subgraph can be made bipartite by deleting
at most $\varepsilon n$ edges. This is the case $f(n) = \varepsilon n$.

**Proof idea:** Use the Szemerédi regularity lemma. A graph whose regularity
partition has mostly "nearly bipartite" pairs can be shown to have low
bipartization number, while a suitable probabilistic or Ramsey-theoretic
construction ensures infinite chromatic number.

### 2. Triangle-free graphs with high chromatic number

By Erdős (1959), for every $k$ there exist triangle-free graphs with
$\chi \ge k$. More generally, for every $k, g$ there exist graphs with
$\chi \ge k$ and girth $\ge g$.

For triangle-free graphs, bipartization is related to odd cycle structure.
High-girth graphs have large bipartization in the worst case, but controlling
the *maximum over all induced subgraphs* is the hard part.

### 3. Specific growth rates

The conjecture is open even for $f(n) = \sqrt{n}$, which would already be a
major breakthrough.

## The "Disjoint Union" Construction (Weaker Result)

The following construction proves a **weaker** statement: there exists a graph
with infinite chromatic number where the *total edge count* of induced subgraphs
grows slowly. This does NOT resolve Problem 74 because it bounds total edges,
not bipartization number.

### Construction

Given $f : \mathbb{N} \to \mathbb{N}$ with $f(n) \to \infty$:

1. **Monotonize:** WLOG assume $f$ is non-decreasing (replace $f(n)$ with
   $\min_{m \ge n} f(m)$).

2. **Build components:** For each $k \ge 1$, choose a finite graph $G_k$ with
   $\chi(G_k) \ge k$. Let $B_k = |E(G_k)|$ and $S_k = \sum_{j \le k} B_j$.

3. **Place carefully:** Set $a_k$ inductively:
   - $a_1 = 0$
   - $a_{k+1} = \max(a_k + |V(G_k)|, \min\{n : f(n) \ge S_{k+1}\})$

4. **Define $G$:** Place each $G_k$ on vertices
   $\{a_k, a_k + 1, \ldots, a_k + |V(G_k)| - 1\}$.

### Why $\chi(G) = \infty$

$G$ contains $G_k$ as a subgraph for all $k$, so $\chi(G) \ge k$ for all $k$.

### Why bipartization is bounded (sketch)

For $S \subseteq V(G)$ with $|S| = n$: let $K$ be the largest index such that
$S$ intersects $V(G_K)$. Then $n \ge a_K$, so $f(n) \ge f(a_K) \ge S_K$.
The total edges in $G[S]$ is at most $S_K \le f(n)$, so deleting all of them
(at most $f(n)$) makes $G[S]$ bipartite.

### Why this is weaker than Problem 74

This proves: "edges in $G[S]$ $\le f(n)$", which trivially implies
"bipartization $\le f(n)$". But it's wasteful — we're bounding total edges,
not just the minimum edges needed for bipartiteness. The conjecture asks for
much denser graphs where most edges are "useful" (in bipartite components)
but only a few "odd cycle" edges need removal.

## Why Problem 74 is Hard

The core difficulty: we need a graph that is simultaneously:

1. **Globally non-bipartite in a strong sense** — infinite chromatic number,
   meaning lots of odd cycles that can't all be killed by finitely many colors.

2. **Locally nearly bipartite** — every finite piece is "close to bipartite"
   in the edge-deletion metric.

These two requirements are in tension. High chromatic number usually comes from
dense odd-cycle structure, but we need odd cycles to be sparse and
well-distributed so that any finite sample contains few of them relative to
its size.

### Key obstacles

- **Probabilistic method:** Random graphs can achieve high chromatic number
  with high girth, but controlling bipartization of *all* induced subgraphs
  (not just the whole graph) requires more delicate analysis.

- **Regularity lemma approaches:** Give the linear case ($f(n) = \varepsilon n$)
  but seem unable to push below linear growth.

- **Algebraic constructions:** Kneser graphs, Schrijver graphs have high
  chromatic number but their bipartization properties for induced subgraphs
  are not well understood.

## References

1. P. Erdős, "Problems and results in graph theory and combinatorial analysis,"
   *Proceedings of the Fifth British Combinatorial Conference*, 1975.

2. P. Erdős, A. Hajnal, E. Szemerédi, "On almost bipartite large chromatic
   graphs," *Annals of Discrete Mathematics* 12 (1982), 117–123.

3. V. Rödl, "On the chromatic number of subgraphs of a given graph,"
   *Proceedings of the AMS* 64 (1977), 370–371.

4. P. Erdős, "Graph theory and probability," *Canadian Journal of Mathematics*
   11 (1959), 34–38.

5. Google DeepMind, "Formal Conjectures: Erdős Problem 74,"
   `formal-conjectures/FormalConjectures/ErdosProblems/74.lean`.

6. https://www.erdosproblems.com/74
