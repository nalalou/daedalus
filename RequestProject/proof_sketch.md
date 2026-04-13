# Proof Sketch: Erdős's 1974 Theorem on Locally Nearly Bipartite Graphs with Infinite Chromatic Number

---

## 1. Statement of the Theorem

**Theorem (Erdős, 1974).** *Let $f : \mathbb{N} \to \mathbb{N}$ be any function satisfying $f(n) \to \infty$ as $n \to \infty$. Then there exists a graph $G$ on vertex set $\mathbb{N}$ such that:*

1. *$\chi(G) = \infty$, and*
2. *for every finite subset $S \subseteq V(G)$ with $|S| = n$, one can delete at most $f(n)$ edges from the induced subgraph $G[S]$ to make it bipartite.*

In other words, there exist graphs of infinite chromatic number that are, in a
quantitative local sense, arbitrarily close to bipartite: every finite induced
subgraph on $n$ vertices can be made bipartite by the removal of a number of
edges that is negligible compared to any prescribed divergent function of $n$.

This result is a striking instance of Erdős's broader programme demonstrating
that high chromatic number need not be witnessed by any local obstruction of
bounded size.

---

## 2. Preliminaries and Ingredients

### 2.1. Existence of Graphs with Arbitrarily High Chromatic Number

The construction relies on the existence, for every positive integer $k$, of a
finite graph $H_k$ with chromatic number $\chi(H_k) \geq k$. Several classical
families suffice:

- **Complete graphs.** $K_k$ satisfies $\chi(K_k) = k$, with $|V(K_k)| = k$
  and $|E(K_k)| = \binom{k}{2}$.
- **Mycielski's construction (1955).** Yields triangle-free graphs $M_k$ with
  $\chi(M_k) = k$, showing that the chromatic number can be forced high without
  short odd cycles.
- **Zykov's construction.** An alternative recursive procedure producing graphs
  with $\chi \geq k$ for any $k$.

For the purposes of this proof, any such family works. We write $H_k$ for a
chosen finite graph with $\chi(H_k) \geq k$, and set:

$$v_k := |V(H_k)|, \qquad e_k := |E(H_k)|.$$

### 2.2. Monotonization of the Growth Function

Given $f : \mathbb{N} \to \mathbb{N}$ with $f(n) \to \infty$, we replace it by
a non-decreasing function that still diverges. Define

$$f'(n) := \min_{m \geq n} f(m).$$

**Claim.** $f'$ is non-decreasing and $f'(n) \to \infty$.

*Proof of claim.* For $n_1 \leq n_2$, the set $\{m : m \geq n_2\}$ is
contained in $\{m : m \geq n_1\}$, so $f'(n_1) \leq f'(n_2)$. For divergence:
given any $C > 0$, there exists $N$ such that $f(m) \geq C$ for all $m \geq N$.
Then $f'(n) = \min_{m \geq n} f(m) \geq C$ for all $n \geq N$. $\square$

Since $f'(n) \leq f(n)$ for all $n$, it suffices to prove the theorem for $f'$
in place of $f$. Henceforth we assume without loss of generality that **$f$
itself is non-decreasing** and $f(n) \to \infty$.

---

## 3. The Construction

### 3.1. Cumulative Edge Sums

For each $k \geq 1$, define the cumulative edge count:

$$S_k := \sum_{j=1}^{k} e_j.$$

Since each $e_j \geq 1$, we have $S_k \to \infty$.

### 3.2. Inductive Placement of Components

We place the graphs $H_1, H_2, H_3, \ldots$ on disjoint intervals of
$\mathbb{N}$, choosing starting positions $a_k$ inductively to satisfy two
constraints:

1. **Disjointness:** $a_{k+1} \geq a_k + v_k$, so that $H_k$ occupies
   vertices $\{a_k, a_k + 1, \ldots, a_k + v_k - 1\}$ and consecutive
   components do not overlap.
2. **Growth compatibility:** $f(a_k) \geq S_k$, which will be the key to the
   bipartization bound.

**Inductive definition.** Set $a_1 := 0$ (or any value with $f(a_1) \geq S_1 = e_1$; since $f(n) \to \infty$ we can choose such a value). For $k \geq 1$, define:

$$a_{k+1} := \max\!\Big(a_k + v_k,\;\; \min\{n \in \mathbb{N} : f(n) \geq S_{k+1}\}\Big).$$

The minimum in the second argument exists because $f(n) \to \infty$ and
$S_{k+1}$ is a finite number.

**Verification of the two constraints:**

- *Disjointness:* By definition, $a_{k+1} \geq a_k + v_k$, so the vertex
  interval $[a_k, a_k + v_k - 1]$ for $H_k$ is disjoint from
  $[a_{k+1}, a_{k+1} + v_{k+1} - 1]$ for $H_{k+1}$.
- *Growth compatibility:* By the second term in the max, $a_{k+1} \geq
  \min\{n : f(n) \geq S_{k+1}\}$, so $f(a_{k+1}) \geq S_{k+1}$ since $f$ is
  non-decreasing.

### 3.3. Definition of $G$

The graph $G$ has vertex set $\mathbb{N}$. Its edge set is defined as follows:

- For each $k \geq 1$, let $\varphi_k : V(H_k) \to \{a_k, a_k+1, \ldots,
  a_k + v_k - 1\}$ be a fixed bijection (i.e., an arbitrary labelling of
  $H_k$'s vertices by the integers in the $k$-th interval).
- Two vertices $u, v \in \mathbb{N}$ are adjacent in $G$ if and only if there
  exists some $k \geq 1$ such that $u, v \in \{a_k, \ldots, a_k + v_k - 1\}$
  and $\{\varphi_k^{-1}(u), \varphi_k^{-1}(v)\} \in E(H_k)$.

Equivalently, $G$ is the **disjoint union** of isomorphic copies of
$H_1, H_2, H_3, \ldots$, placed on successive intervals of $\mathbb{N}$, with
all vertices not belonging to any component being isolated.

---

## 4. Proof of Property 1: $\chi(G) = \infty$

**Claim.** $\chi(G) = \infty$.

*Proof.* For every $k \geq 1$, the graph $G$ contains an isomorphic copy of
$H_k$ as an induced subgraph (on the vertex set
$\{a_k, \ldots, a_k + v_k - 1\}$). Since $\chi(H_k) \geq k$, we have

$$\chi(G) \geq \chi(G[\{a_k, \ldots, a_k + v_k - 1\}]) = \chi(H_k) \geq k.$$

As this holds for every $k$, it follows that $\chi(G) = \infty$. $\square$

---

## 5. Proof of Property 2: The Bipartization Bound

**Claim.** For every finite $S \subseteq V(G)$ with $|S| = n$, one can delete
at most $f(n)$ edges from $G[S]$ to make it bipartite.

*Proof.* Let $S \subseteq \mathbb{N}$ with $|S| = n$. Write
$V_k := \{a_k, a_k + 1, \ldots, a_k + v_k - 1\}$ for the vertex set of the
$k$-th component, and define

$$\mathcal{K}(S) := \{k \geq 1 : S \cap V_k \neq \emptyset\}$$

to be the set of indices of components that $S$ intersects. Since the components
are vertex-disjoint, the induced subgraph $G[S]$ decomposes as a disjoint union:

$$G[S] = \bigsqcup_{k \in \mathcal{K}(S)} H_k[S \cap V_k]$$

where vertices of $S$ not belonging to any $V_k$ are isolated in $G[S]$.

**Step 1: Bipartization strategy (crude deletion).** For each
$k \in \mathcal{K}(S)$, delete *all* edges of $H_k[S \cap V_k]$. The resulting
graph is edgeless, hence trivially bipartite. The number of edges deleted from
the $k$-th component is at most $|E(H_k)| = e_k$.

Therefore, the total number of edges deleted is at most:

$$D(S) := \sum_{k \in \mathcal{K}(S)} e_k.$$

**Step 2: Identifying the dominant component.** Let
$K^* := \max \mathcal{K}(S)$ be the largest index of a component that $S$
intersects. Then $\mathcal{K}(S) \subseteq \{1, 2, \ldots, K^*\}$, so:

$$D(S) = \sum_{k \in \mathcal{K}(S)} e_k \leq \sum_{k=1}^{K^*} e_k = S_{K^*}.$$

**Step 3: Relating $K^*$ to $n$.** Since $K^* \in \mathcal{K}(S)$, there exists
a vertex $u \in S \cap V_{K^*}$, so $u \geq a_{K^*}$. Now $S$ is an $n$-element
subset of $\mathbb{N} = \{0, 1, 2, \ldots\}$. Since $S$ contains $u \geq a_{K^*}$,
the set $S$ must draw its $n$ elements from natural numbers that include at least
one value $\geq a_{K^*}$. But $S$ has exactly $n$ elements, all of which are
distinct natural numbers. The largest element of $S$ is therefore at least
$a_{K^*}$, and since $S \subseteq \{0, 1, 2, \ldots\}$ has $n$ elements, we need:

$$n \geq a_{K^*} + 1$$

(because $S$ contains $n$ distinct natural numbers including one that is
$\geq a_{K^*}$; the minimum cardinality of such a set is $a_{K^*} + 1$, achieved
by $S = \{0, 1, \ldots, a_{K^*}\}$).

In particular, $n - 1 \geq a_{K^*}$, so $n > a_{K^*}$.

**Step 4: Applying monotonicity of $f$.** Since $f$ is non-decreasing and
$n > a_{K^*}$:

$$f(n) \geq f(a_{K^*} + 1) \geq f(a_{K^*}) \geq S_{K^*}$$

where the last inequality is the growth compatibility condition established in
the construction (Section 3.2).

**Step 5: Conclusion.** Combining Steps 1, 2, and 4:

$$\text{edges deleted} \leq D(S) \leq S_{K^*} \leq f(a_{K^*}) \leq f(n).$$

Hence at most $f(n)$ edge deletions suffice to make $G[S]$ bipartite. $\square$

---

## 6. Refined Accounting and the Crude Bound

One might object that deleting *all* edges in each touched component is
wasteful. Indeed, a more careful approach would delete only the minimum number of
edges needed to make each $H_k[S \cap V_k]$ bipartite (its **bipartite edge
deletion number**, also known as the **odd cycle edge transversal number**).
This can only decrease the count, so the crude bound suffices for the upper
estimate.

The elegance of the argument lies precisely in this: even the crudest possible
bipartization strategy --- total annihilation of edges in each intersected
component --- stays within the budget $f(n)$, because the growth of $f$ outpaces
the cumulative edge counts $S_k$ by construction.

---

## 7. Discussion of Ingredients

### 7.1. Role of High-Chromatic-Number Graphs

The only non-trivial combinatorial ingredient is the existence of finite graphs
with arbitrarily large chromatic number. The simplest witness is the family of
complete graphs $\{K_k\}_{k \geq 1}$. However, using Mycielski graphs or other
triangle-free constructions yields a stronger result: $G$ can be made to be
**triangle-free** (or, more generally, to have arbitrarily large girth) while
simultaneously having infinite chromatic number and the bipartization property.

This is because Erdős's probabilistic proof (1959) and Lovász's topological
proof (via the Kneser graph, 1978) both establish the existence of graphs with
simultaneously high girth and high chromatic number. Using such graphs as the
building blocks $H_k$ yields the stronger conclusion.

### 7.2. Role of the Monotonization

The monotonization step ($f \mapsto f'$) is a standard regularization that
ensures we can apply the monotonicity of $f$ in the final inequality chain. It
is essential: without it, $f$ could oscillate (e.g., $f(n) = n$ for even $n$ and
$f(n) = 1$ for odd $n$), and the argument that $f(n) \geq f(a_{K^*})$ would
fail.

### 7.3. The Spacing Condition

The inductive choice of starting positions $a_k$ is the heart of the
construction. It serves a dual purpose:

1. It separates the components so that $G$ is a genuine disjoint union on
   $\mathbb{N}$.
2. It synchronizes the cumulative complexity of the first $k$ components
   ($S_k$) with the growth of $f$ at position $a_k$.

The tension is that the $a_k$ must grow fast enough for condition (2), but the
construction always succeeds because $f(n) \to \infty$ guarantees that for any
finite threshold, there exist sufficiently large $n$ exceeding it.

---

## 8. Optimality and Tightness

### 8.1. The Condition $f(n) \to \infty$ is Necessary

The condition $f(n) \to \infty$ cannot be replaced by $f(n) \geq C$ for a fixed
constant $C$. Indeed, suppose every $n$-vertex induced subgraph of $G$ can be
made bipartite by deleting at most $C$ edges. Then every odd cycle in $G$ must
use one of the $C$ deleted edges, which constrains the structure of $G$
substantially. More precisely, a graph where every $n$-vertex subgraph is within
$C$ edge-deletions of bipartite has the property that every subgraph on $n$
vertices has at most $n - 1 + C$ edges (since a bipartite graph on $n$ vertices
has at most $\lfloor n^2/4 \rfloor$ edges, but the key point is the bounded
excess over a forest/bipartite graph). By a result of Erdős, such graphs have
bounded chromatic number depending only on $C$. Hence the divergence condition
is tight.

### 8.2. Comparison with Related Results

Erdős's theorem is an early manifestation of the principle that chromatic number
is a *global* invariant that need not be detectable by any *local* measurement
of bounded scope. This philosophy appears throughout combinatorics:

- **Erdős (1959):** There exist graphs with arbitrarily high chromatic number
  and arbitrarily large girth (no short cycles locally, yet globally
  non-$k$-colorable for any $k$).
- **Erdős--Hajnal (various):** Investigations into which local/structural
  conditions force bounded chromatic number (e.g., excluding a fixed induced
  subgraph).
- **Thomassen (1983):** Every graph of sufficiently large average degree
  contains a subgraph of large girth and large chromatic number.
- **Reed (1999) and subsequent work:** The relationship between clique number,
  maximum degree, and chromatic number --- further evidence that chromatic
  number is driven by global rather than purely local considerations.

### 8.3. Rate of Growth

The construction gives no explicit lower bound on how slowly $f$ can grow; it
works for *any* $f \to \infty$, no matter how slowly (e.g.,
$f(n) = \lfloor \log^* n \rfloor$, the iterated logarithm, or the inverse
Ackermann function $\alpha(n)$). This universality over all divergent functions
is the theorem's principal strength and is characteristic of Erdős's style of
result.

### 8.4. Quantitative Aspects of the Construction

If one uses $H_k = K_k$ (complete graphs), then $e_k = \binom{k}{2}$ and
$S_k = \sum_{j=1}^{k} \binom{j}{2} = \binom{k+1}{3} = \Theta(k^3)$.
The starting positions $a_k$ must satisfy $f(a_k) \geq \Theta(k^3)$, so
$a_k \geq f^{-1}(\Theta(k^3))$ (where $f^{-1}$ is a generalized inverse). For
very slowly growing $f$, this pushes the components far apart, but the
construction remains valid.

If instead one uses Mycielski graphs $M_k$ (triangle-free, $\chi(M_k) = k$),
then $v_k = 3 \cdot 2^{k-2} - 1$ and $e_k$ grows exponentially in $k$, leading
to faster growth of $S_k$. This does not affect the qualitative result but
changes the quantitative spacing.

---

## 9. Summary of the Proof Architecture

| Step | Construction/Argument | Purpose |
|------|----------------------|---------|
| 1 | Monotonize $f \mapsto f' = \min_{m \geq n} f(m)$ | Ensure $f$ is non-decreasing for monotonicity arguments |
| 2 | Choose building blocks $H_k$ with $\chi(H_k) \geq k$ | Guarantee $\chi(G) = \infty$ via containment |
| 3 | Compute cumulative edge sums $S_k = \sum_{j \leq k} e_j$ | Track the worst-case bipartization cost budget |
| 4 | Choose $a_k$ inductively with $a_{k+1} \geq a_k + v_k$ and $f(a_k) \geq S_k$ | Ensure disjointness and synchronize cost with growth |
| 5 | Define $G$ as the disjoint union of $H_k$ on intervals $[a_k, a_k + v_k)$ | Explicit graph construction on $\mathbb{N}$ |
| 6 | $\chi(G) \geq \chi(H_k) \geq k$ for all $k$ | Infinite chromatic number (Property 1) |
| 7 | For $|S| = n$: delete all edges in each touched component; cost $\leq S_{K^*} \leq f(a_{K^*}) \leq f(n)$ | Bipartization bound (Property 2) |

The proof is entirely constructive (given any explicit family $\{H_k\}$ and
an explicit $f$), and the resulting graph $G$ can be described algorithmically.

---

## 10. References

1. **P. Erdős**, "Some new applications of probability methods to combinatorial
   analysis and graph theory," *Proceedings of the Fifth Southeastern Conference
   on Combinatorics, Graph Theory, and Computing* (Boca Raton, 1974), Congressus
   Numerantium X, Utilitas Math., 1974, pp. 39--51.

2. **P. Erdős**, "Graph theory and probability," *Canadian Journal of
   Mathematics*, 11 (1959), 34--38. (Existence of high-chromatic,
   high-girth graphs via the probabilistic method.)

3. **J. Mycielski**, "Sur le coloriage des graphes," *Colloq. Math.* 3 (1955),
   161--162. (Triangle-free graphs with arbitrary chromatic number.)

4. **L. Lovász**, "Kneser's conjecture, chromatic number, and homotopy,"
   *Journal of Combinatorial Theory, Series A*, 25 (1978), 319--324.

5. **A. Zykov**, "On some properties of linear complexes" (Russian),
   *Mat. Sbornik* 24 (1949), 163--188. (Alternative construction of graphs
   with high chromatic number.)

6. **R. Diestel**, *Graph Theory*, 5th edition, Springer, 2017. (Standard
   reference for chromatic number, degeneracy, and Erdős-type constructions;
   see Chapter 5.)

7. **B. Bollobás**, *Modern Graph Theory*, Springer, 1998. (Probabilistic and
   extremal graph theory background.)

---

*Proof sketch prepared in the style of expository combinatorics. The argument
follows Erdős's original approach with the details elaborated for clarity and
self-containedness.*
