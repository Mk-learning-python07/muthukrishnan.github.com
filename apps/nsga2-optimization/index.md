---
layout: default
title: NSGA-II Optimization Reference
description: A personal technical reference on multi-objective optimization, compiled from hands-on exposure with pymoo.
permalink: /apps/nsga2-optimization/
---

<div class="callout">
  <strong>Use at your own discretion.</strong> This is a personal reference compiled from hands-on exposure with pymoo's NSGA-II implementation for multi-objective optimization - the kind of Purity-vs-Recovery, Recovery-vs-Productivity trade-offs that come up directly in PVSA cycle design. It's shared as an open resource, not a validated or maintained package. Defaults, examples, and recommendations below reflect the library's documentation and my own usage - verify against your own problem before relying on them.
</div>


> **pymoo version:** 0.6.1.6  
> **Module:** `pymoo.algorithms.moo.nsga2`  
> **Reference:** Deb et al. (2002) — *"A Fast and Elitist Multiobjective Genetic Algorithm: NSGA-II"*

---

## Table of Contents

1. [Overview](#overview)
2. [Algorithm Summary](#algorithm-summary)
3. [Full Signature](#full-signature)
4. [Core Parameters (kwargs)](#core-parameters-kwargs)
   - [pop_size](#pop_size)
   - [sampling](#sampling)
   - [selection](#selection)
   - [crossover](#crossover)
   - [mutation](#mutation)
   - [survival](#survival)
   - [output](#output)
   - [n_offsprings](#n_offsprings)
   - [eliminate_duplicates](#eliminate_duplicates)
   - [repair](#repair)
   - [mating](#mating)
5. [Operator Sub-Parameters](#operator-sub-parameters)
   - [SBX Crossover Parameters](#sbx-crossover-parameters)
   - [Polynomial Mutation Parameters](#polynomial-mutation-parameters)
   - [Tournament Selection Parameters](#tournament-selection-parameters)
   - [RankAndCrowding Survival Parameters](#rankandcrowding-survival-parameters)
6. [Inherited kwargs (Algorithm Base Class)](#inherited-kwargs)
7. [minimize() Function Parameters](#minimize-function-parameters)
8. [DefaultMultiObjectiveTermination](#defaultmultiobjectivetermination)
9. [Result Object — Complete Field Reference](#result-object)
10. [Verbose Output — Column Meanings](#verbose-output)
11. [Sampling Options Reference](#sampling-options-reference)
12. [Crossover Options Reference](#crossover-options-reference)
13. [Mutation Options Reference](#mutation-options-reference)
14. [Performance Indicators](#performance-indicators)
15. [Parallelization](#parallelization)
16. [When NOT to Use NSGA-II](#when-not-to-use-nsga-ii)
17. [Full Configuration Examples](#full-configuration-examples)

---

## Overview

NSGA-II (Non-dominated Sorting Genetic Algorithm II) is a fast, elitist, multi-objective evolutionary algorithm. It is the go-to baseline algorithm for solving problems with 2-3 objectives in pymoo. Its key features are:

- **Non-dominated sorting** to rank solutions into Pareto fronts
- **Crowding distance** for diversity preservation within a front
- **Binary tournament selection** for selection pressure
- **Elitism** — the best individuals always survive to the next generation

---

## Algorithm Summary

| Phase | Mechanism |
|---|---|
| Initialization | Random sampling (or user-supplied population / array) |
| Parent Selection | Binary tournament (rank then crowding distance) |
| Recombination | Simulated Binary Crossover (SBX) |
| Mutation | Polynomial Mutation (PM) |
| Survival | Rank-and-Crowding (non-dominated sort + crowding distance) |
| Termination | n_gen, n_eval, time, tolerance-based, or custom |

---

## Full Signature

```python
from pymoo.algorithms.moo.nsga2 import NSGA2

NSGA2(
    pop_size=100,
    sampling=FloatRandomSampling(),
    selection=TournamentSelection(func_comp=binary_tournament),
    crossover=SBX(prob=0.9, eta=15),
    mutation=PM(prob=None, eta=20),
    survival=RankAndCrowding(),
    output=MultiObjectiveOutput(),
    eliminate_duplicates=True,
    n_offsprings=None,
    repair=None,
    mating=None,
    # --- Inherited from Algorithm base ---
    termination=None,
    seed=None,
    verbose=False,
    callback=None,
    save_history=False,
    return_least_infeasible=False,
    display=None,
    evaluator=None,
    archive=None,
    **kwargs
)
```

---

## Core Parameters (kwargs)

### `pop_size`

| | |
|---|---|
| **Type** | `int` |
| **Default** | `100` |

The number of individuals maintained in the population each generation. This is one of the most impactful hyperparameters:

- **Larger values** (e.g., 200-500) improve diversity and exploration but significantly increase runtime per generation.
- **Smaller values** (e.g., 20-50) run faster but risk premature convergence, especially in complex or high-dimensional search spaces.
- A common rule of thumb is to set `pop_size` to at least 10x the number of decision variables.
- For problems with many constraints, a larger population helps maintain enough feasible individuals.

```python
algorithm = NSGA2(pop_size=200)
```

---

### `sampling`

| | |
|---|---|
| **Type** | `Sampling` object, `Population` object, or `numpy.ndarray` |
| **Default** | `FloatRandomSampling()` |

Defines how the **initial population** is generated. Three input formats are accepted:

1. **A `Sampling` implementation** - a class that generates random initial solutions within the problem's bounds.
2. **A `Population` object** - pass pre-built individuals, optionally already evaluated (set `F` values in this case).
3. **A 2D `numpy.ndarray`** - shape `(n_individuals, n_var)` with variable values, used for warm-starting the search from a known region.

```python
import numpy as np
from pymoo.operators.sampling.rnd import FloatRandomSampling, BinaryRandomSampling
from pymoo.operators.sampling.lhs import LHS

# Option 1: Random float sampling (default)
NSGA2(sampling=FloatRandomSampling())

# Option 2: Latin Hypercube Sampling for better initial coverage
NSGA2(sampling=LHS())

# Option 3: Binary sampling (for binary variable problems)
NSGA2(sampling=BinaryRandomSampling())

# Option 4: Warm-start with a custom numpy array
X_init = np.random.rand(100, 10)  # 100 individuals, 10 variables
NSGA2(sampling=X_init)
```

---

### `selection`

| | |
|---|---|
| **Type** | `Selection` object |
| **Default** | `TournamentSelection(func_comp=binary_tournament)` |

Determines how **parent individuals** are chosen from the current population for mating. The default binary tournament selection compares two randomly chosen individuals and selects the better one based on:

1. **Pareto rank** (lower is better - closer to the Pareto front)
2. **Crowding distance** (higher is better - less crowded regions preferred)

```python
from pymoo.operators.selection.tournament import TournamentSelection
from pymoo.operators.selection.rnd import RandomSelection
from pymoo.algorithms.moo.nsga2 import binary_tournament

# Default: binary tournament
NSGA2(selection=TournamentSelection(func_comp=binary_tournament))

# Alternative: purely random selection (removes selection pressure)
NSGA2(selection=RandomSelection())
```

---

### `crossover`

| | |
|---|---|
| **Type** | `Crossover` object |
| **Default** | `SBX(prob=0.9, eta=15)` |

The **recombination operator** that combines two parent solutions to create offspring. The default is Simulated Binary Crossover (SBX), which mimics single-point crossover from binary-coded GAs but works in the real-valued (continuous) space.

```python
from pymoo.operators.crossover.sbx import SBX
from pymoo.operators.crossover.pntx import TwoPointCrossover, SinglePointCrossover
from pymoo.operators.crossover.ux import UniformCrossover

# Default: SBX for continuous variables
NSGA2(crossover=SBX(prob=0.9, eta=15))

# Two-point crossover (for binary problems)
NSGA2(crossover=TwoPointCrossover())

# Uniform crossover
NSGA2(crossover=UniformCrossover(prob=0.5))
```

See [SBX Crossover Parameters](#sbx-crossover-parameters) for full sub-parameter details.

---

### `mutation`

| | |
|---|---|
| **Type** | `Mutation` object |
| **Default** | `PM(prob=None, eta=20)` |

The **mutation operator** randomly alters offspring variables to maintain genetic diversity and enable exploration beyond what crossover alone can reach. The default is Polynomial Mutation (PM) for real-valued variables.

When `prob=None`, pymoo automatically sets the per-variable mutation probability to `1/n_var`, meaning on average one variable is mutated per individual - the standard recommendation.

```python
from pymoo.operators.mutation.pm import PM
from pymoo.operators.mutation.bitflip import BitflipMutation

# Default: polynomial mutation for real variables
NSGA2(mutation=PM(prob=None, eta=20))

# Bit-flip mutation for binary variables
NSGA2(mutation=BitflipMutation())
```

See [Polynomial Mutation Parameters](#polynomial-mutation-parameters) for full sub-parameter details.

---

### `survival`

| | |
|---|---|
| **Type** | `Survival` object |
| **Default** | `RankAndCrowding()` |

The **survival selection** strategy that decides which individuals move on to the next generation. NSGA-II's defining feature is its `RankAndCrowding` survival, which works as follows:

1. Merge parent and offspring populations into a combined pool of size `2N` (or `pop_size + n_offsprings`).
2. Sort all individuals by **non-dominated rank** (Pareto front 1, 2, 3...).
3. Fill the next generation **front-by-front** until adding another full front would exceed `pop_size`.
4. In the splitting front, select individuals with the **highest crowding distance** to maintain diversity.

```python
from pymoo.operators.survival.rank_and_crowding import RankAndCrowding

NSGA2(survival=RankAndCrowding())
```

See [RankAndCrowding Survival Parameters](#rankandcrowding-survival-parameters) for crowding metric variants.

---

### `output`

| | |
|---|---|
| **Type** | `Output` object |
| **Default** | `MultiObjectiveOutput()` |

Controls what information is **printed to the console** during optimization when `verbose=True`. The default multi-objective output shows generation number, evaluations, constraint violations, non-dominated solution count, and convergence indicators.

```python
from pymoo.util.display.multi import MultiObjectiveOutput

NSGA2(output=MultiObjectiveOutput())
```

See [Verbose Output - Column Meanings](#verbose-output) for a detailed explanation of each printed column.

---

### `n_offsprings`

| | |
|---|---|
| **Type** | `int` or `None` |
| **Default** | `None` |

The number of offspring to generate **per generation**. When `None`, defaults to `pop_size`, implementing the standard `(mu + lambda)` strategy where the combined pool each generation has size `2 x pop_size`.

Setting `n_offsprings < pop_size` creates a **steady-state** variant where only a fraction of the population is replaced per generation - useful for reducing the number of function evaluations per iteration at the cost of slower convergence per generation.

```python
# Default: generate pop_size offspring each generation (full generational)
NSGA2(pop_size=100, n_offsprings=None)

# Steady-state: generate 10 offspring per generation
NSGA2(pop_size=100, n_offsprings=10)
```

> **Note:** Using a small `n_offsprings` (like 10-20% of `pop_size`) on simple problems often leads to faster wall-clock convergence. On complex multimodal problems, full generational replacement (`n_offsprings=None`) is usually better.

---

### `eliminate_duplicates`

| | |
|---|---|
| **Type** | `bool` or `ElementwiseDuplicateElimination` object |
| **Default** | `True` |

Whether to **remove duplicate solutions** from the offspring pool before survival selection. Duplicates are detected in the **variable space** (`X`), not the objective space.

- `True` - use default duplicate detection (compares variable arrays element-wise within a small floating-point tolerance).
- `False` - disable duplicate elimination entirely (faster, but may harm diversity).
- A custom `DuplicateElimination` object - define your own equality logic (useful for permutation, mixed, or custom variable types).

```python
from pymoo.core.duplicate import ElementwiseDuplicateElimination
import numpy as np

# Default: eliminate duplicates
NSGA2(eliminate_duplicates=True)

# Disable
NSGA2(eliminate_duplicates=False)

# Custom: consider two solutions equal if within 1e-4
class MyDuplicateElimination(ElementwiseDuplicateElimination):
    def is_equal(self, a, b):
        return np.allclose(a.X, b.X, atol=1e-4)

NSGA2(eliminate_duplicates=MyDuplicateElimination())
```

---

### `repair`

| | |
|---|---|
| **Type** | `Repair` object or `None` |
| **Default** | `None` |

An optional **repair operator** applied to offspring *after* mutation and *before* evaluation. Its purpose is to fix infeasible or structurally invalid solutions that violate problem-specific constraints that the standard bounds-based operators cannot handle automatically.

Common use cases include:
- Ensuring the sum of variables equals a fixed value (e.g., portfolio weights summing to 1).
- Enforcing ordering constraints in scheduling problems.
- Clamping or projecting solutions onto a feasible manifold.

```python
from pymoo.core.repair import Repair
import numpy as np

class NormalizeRepair(Repair):
    """Repair operator that ensures all variables sum to 1.0."""
    def _do(self, problem, X, **kwargs):
        # X shape: (n_individuals, n_var)
        row_sums = X.sum(axis=1, keepdims=True)
        row_sums[row_sums == 0] = 1.0
        return X / row_sums

algorithm = NSGA2(
    pop_size=100,
    repair=NormalizeRepair()
)
```

> **Note:** The `repair` operator runs inside the mating loop on the batch of generated offspring. It does **not** run on the initial population - if you need to repair the initial population too, use a custom `Sampling` class that generates valid solutions directly.

---

### `mating`

| | |
|---|---|
| **Type** | `Mating` object or `None` |
| **Default** | `None` |

An optional **mating object** that bundles `selection`, `crossover`, `mutation`, and `repair` into a single configurable pipeline. When `None`, NSGA-II constructs its own default `Mating` object internally from the individual operator kwargs.

Providing a custom `Mating` object is an advanced option that allows you to override the entire offspring-generation pipeline in one step, rather than supplying operators one by one.

```python
from pymoo.core.mating import Mating
from pymoo.operators.crossover.sbx import SBX
from pymoo.operators.mutation.pm import PM
from pymoo.operators.selection.tournament import TournamentSelection
from pymoo.algorithms.moo.nsga2 import binary_tournament

custom_mating = Mating(
    selection=TournamentSelection(func_comp=binary_tournament),
    crossover=SBX(prob=0.9, eta=15),
    mutation=PM(prob=None, eta=20),
    repair=None,
    eliminate_duplicates=True,
    n_max_iterations=100   # max tries to fill offspring pool without duplicates
)

algorithm = NSGA2(pop_size=100, mating=custom_mating)
```

> **Warning:** When `mating` is explicitly provided, the individual `selection`, `crossover`, `mutation`, and `repair` kwargs at the `NSGA2(...)` level are **ignored**. The mating object takes full precedence. Use one approach or the other, not both.

---

## Operator Sub-Parameters

### SBX Crossover Parameters

**Class:** `pymoo.operators.crossover.sbx.SBX`

Simulated Binary Crossover (SBX) creates offspring that statistically mimic binary crossover behavior in real-valued search spaces, preserving the mean of parents while controlling spread via the distribution index `eta`.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `prob` | `float` | `0.9` | Probability that crossover is applied to a given mating pair. `0.9` means 90% of pairs undergo recombination; the remaining 10% are copied to the offspring pool unchanged. |
| `eta` | `float` | `15` | Distribution index. Controls how closely offspring resemble their parents. **Low `eta`** (e.g., 2-5) -> offspring spread far from parents (exploration). **High `eta`** (e.g., 20-30) -> offspring stay close to parents (exploitation). |
| `prob_var` | `float` | `0.5` | Per-variable crossover probability. Only applies when the pair-level `prob` is triggered. Each variable is independently recombined with this probability. Setting to `1.0` means all variables are always crossed. |
| `vtype` | `type` | `float` | Variable type (`float` for continuous, `int` for integer-encoded variables). |

```python
from pymoo.operators.crossover.sbx import SBX

# High exploration (eta=5)
crossover = SBX(prob=0.9, eta=5)

# Conservative exploitation (eta=30), lower crossover rate
crossover = SBX(prob=0.7, eta=30)

# Cross every variable each time (prob_var=1.0)
crossover = SBX(prob=0.9, eta=15, prob_var=1.0)
```

**Choosing `eta`:**

| `eta` Value | Offspring Distribution | Use Case |
|---|---|---|
| 2 - 5 | Widely spread (exploratory) | Early stages, multimodal problems, diverse Pareto fronts |
| 10 - 15 | Moderate spread | General purpose - good starting point for most problems |
| 20 - 30 | Tightly clustered | Fine-tuning, convergence refinement, smooth Pareto fronts |

---

### Polynomial Mutation Parameters

**Class:** `pymoo.operators.mutation.pm.PM`

Polynomial Mutation perturbs individual variables by a small amount drawn from a polynomial probability distribution, always staying within the variable's defined lower and upper bounds.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `prob` | `float` or `None` | `None` | Probability of mutating any given variable. `None` auto-sets this to `1/n_var`, which ensures on average one variable per individual is mutated - the standard recommendation. |
| `eta` | `float` | `20` | Distribution index for mutation. **Low `eta`** -> large perturbations (exploration, escaping local optima). **High `eta`** -> small perturbations (refinement near the current solution). |
| `prob_var` | `float` or `None` | `None` | Alternative way to set the per-variable mutation probability (equivalent to `prob`). |

```python
from pymoo.operators.mutation.pm import PM

# Default: auto probability, eta=20
mutation = PM(prob=None, eta=20)

# Explicit mutation rate with higher spread
mutation = PM(prob=0.1, eta=10)

# Conservative mutation (very small perturbations)
mutation = PM(prob=0.05, eta=30)
```

**Choosing `eta`:**

| `eta` Value | Perturbation Size | Use Case |
|---|---|---|
| 5 - 10 | Large jumps | Escaping local optima, rugged search spaces |
| 15 - 20 | Moderate (default) | General purpose |
| 25 - 40 | Very small steps | Fine local search, smooth objective landscapes |

---

### Tournament Selection Parameters

**Class:** `pymoo.operators.selection.tournament.TournamentSelection`

| Parameter | Type | Default | Description |
|---|---|---|---|
| `func_comp` | `callable` | `binary_tournament` | The comparison function used to determine the tournament winner. The default `binary_tournament` ranks by Pareto front first, then crowding distance as a tiebreaker. Supply a custom callable to implement different selection pressures. |
| `pressure` | `int` | `2` | Tournament size - how many individuals compete per tournament. `pressure=2` is binary tournament (one comparison). Higher values increase selection pressure toward high-rank solutions, reducing diversity. |

```python
from pymoo.operators.selection.tournament import TournamentSelection
from pymoo.algorithms.moo.nsga2 import binary_tournament

# Default
selection = TournamentSelection(func_comp=binary_tournament, pressure=2)

# Stronger selection pressure (3-way tournament)
selection = TournamentSelection(func_comp=binary_tournament, pressure=3)
```

---

### RankAndCrowding Survival Parameters

**Class:** `pymoo.operators.survival.rank_and_crowding.classes.RankAndCrowding`

| Parameter | Type | Default | Description |
|---|---|---|---|
| `nds` | `NonDominatedSorting` or `None` | `None` | The non-dominated sorting implementation. `None` uses the default fast non-dominated sort. Can be replaced with a custom NDS method. |
| `crowding_func` | `str` or `callable` | `'cd'` | The crowding metric used to distinguish solutions within the same Pareto front. See options below. |

**`crowding_func` Options:**

| Value | Full Name | Description |
|---|---|---|
| `'cd'` | Crowding Distance | **Standard NSGA-II** crowding distance - Manhattan distance in normalized objective space. Boundary solutions get infinite distance (always preserved). Proposed by Deb et al. (2002). |
| `'pcd'` | Pruning Crowding Distance | Recursively recalculates crowding distance as individuals are removed from the selection pool. Better diversity maintenance than standard CD. Proposed by Kukkonen & Deb (2006). |
| `'ce'` | Crowding Entropy | Entropy-based diversity measure. More robust in higher dimensions (3+ objectives). Proposed by Wang et al. (2009). |
| `'mnn'` | M-Nearest Neighbors | Distance to the M nearest neighbors in objective space, where M = number of objectives. Proposed by Kukkonen & Deb (2006). |
| `'2nn'` | 2-Nearest Neighbors | Simplified nearest-neighbor variant using only the 2 closest solutions. Computationally lighter than M-NN. |

```python
from pymoo.operators.survival.rank_and_crowding import RankAndCrowding

# Default NSGA-II crowding distance
NSGA2(survival=RankAndCrowding(crowding_func='cd'))

# Pruning crowding distance (generally better in practice)
NSGA2(survival=RankAndCrowding(crowding_func='pcd'))

# Entropy-based (useful for 3-objective problems)
NSGA2(survival=RankAndCrowding(crowding_func='ce'))
```

---

## Inherited kwargs

NSGA-II inherits from `GeneticAlgorithm`, which inherits from `Algorithm`. The following are all recognized `**kwargs` passed through to the base `Algorithm` class:

| Parameter | Type | Default | Description |
|---|---|---|---|
| `termination` | `Termination` or `None` | `None` | Termination criterion object. When `None`, the algorithm uses `DefaultMultiObjectiveTermination` internally. Can also be specified in `minimize()`. See [DefaultMultiObjectiveTermination](#defaultmultiobjectivetermination). |
| `seed` | `int` or `None` | `None` | Random seed for reproducibility. When `None`, a random integer seed is chosen and stored in `res.seed`. If set in both the algorithm and `minimize()`, `minimize()` takes precedence. |
| `verbose` | `bool` | `False` | Print generation-by-generation output to stdout. See [Verbose Output - Column Meanings](#verbose-output). |
| `callback` | `Callback` or `None` | `None` | A `Callback` object whose `notify(algorithm)` method is called after every generation. Used to log metrics, save checkpoints, inspect or modify the algorithm mid-run. |
| `display` | `Display` or `None` | `None` | Custom display object controlling what is printed when `verbose=True`. Overrides `output`. |
| `save_history` | `bool` | `False` | If `True`, a deep snapshot of the algorithm state is stored after every generation into `res.history`. Essential for convergence analysis but increases memory usage linearly with `n_gen`. |
| `return_least_infeasible` | `bool` | `False` | If `True` and no feasible solution exists at termination, return the individual(s) with the smallest constraint violation instead of `None`. |
| `evaluator` | `Evaluator` or `None` | `None` | Custom evaluator object. Allows intercepting and wrapping the problem's `_evaluate` call - useful for adding evaluation caches, logging, or custom parallelization strategies. |
| `archive` | `Archive` or `None` | `None` | An optional external archive maintained alongside the population. Not used by default NSGA-II but can be attached for external elitism or solution archiving. |

```python
from pymoo.core.callback import Callback

class ConvergenceLogger(Callback):
    def __init__(self):
        super().__init__()
        self.data["n_nds"] = []
        self.data["n_evals"] = []

    def notify(self, algorithm):
        self.data["n_nds"].append(len(algorithm.opt))
        self.data["n_evals"].append(algorithm.evaluator.n_eval)

algorithm = NSGA2(
    pop_size=100,
    seed=42,
    verbose=True,
    save_history=True,
    callback=ConvergenceLogger()
)
```

---

## minimize() Function Parameters

The `minimize()` function drives the optimization run. It accepts its own set of parameters and also passes unrecognized `**kwargs` through to the algorithm.

```python
from pymoo.optimize import minimize

res = minimize(
    problem,
    algorithm,
    termination=None,
    seed=None,
    verbose=False,
    display=None,
    callback=None,
    return_least_infeasible=False,
    save_history=False,
    copy_algorithm=True,
    copy_termination=True,
)
```

| Parameter | Type | Default | Description |
|---|---|---|---|
| `problem` | `Problem` | *(required)* | The problem instance to optimize. |
| `algorithm` | `Algorithm` | *(required)* | The configured `NSGA2` (or any other algorithm) object. |
| `termination` | `tuple` or `Termination` or `None` | `None` | When to stop. Short tuples like `('n_gen', 200)`, `('n_eval', 10000)`, or `('time', '00:01:00')` are accepted. When `None`, `DefaultMultiObjectiveTermination` is used. |
| `seed` | `int` or `None` | `None` | Random seed for the run. Overrides any seed set on the algorithm object itself. |
| `verbose` | `bool` | `False` | Print generation-by-generation progress. Overrides the `verbose` flag on the algorithm. |
| `display` | `Display` or `None` | `None` | Custom display object for controlling printed output. |
| `callback` | `Callback` or `None` | `None` | Callback invoked each generation. Overrides any callback set on the algorithm. |
| `return_least_infeasible` | `bool` | `False` | Return the least constraint-violating solution if no feasible one is found at termination. |
| `save_history` | `bool` | `False` | Save per-generation algorithm snapshots into `res.history`. |
| `copy_algorithm` | `bool` | `True` | Deep-copy the algorithm object before running. Ensures two runs with the same algorithm object and same seed produce identical, independent results. |
| `copy_termination` | `bool` | `True` | Deep-copy the termination criterion before running. Prevents state leakage if the same termination object is reused across runs. |

**Termination shortcut tuples:**

| Tuple | Meaning |
|---|---|
| `('n_gen', 200)` | Stop after 200 generations |
| `('n_eval', 50000)` | Stop after 50,000 function evaluations |
| `('time', '00:30:00')` | Stop after 30 minutes (HH:MM:SS format) |
| `('xtol', 1e-8)` | Stop when design-space change drops below 1e-8 |
| `('ftol', 0.0025)` | Stop when objective-space change drops below 0.0025 |

---

## DefaultMultiObjectiveTermination

When no termination criterion is provided to `minimize()`, NSGA-II uses `DefaultMultiObjectiveTermination` internally. Understanding its parameters is critical for tuning automatic stopping behavior.

**Class:** `pymoo.termination.default.DefaultMultiObjectiveTermination`

```python
from pymoo.termination.default import DefaultMultiObjectiveTermination

termination = DefaultMultiObjectiveTermination(
    xtol=0.0005,
    cvtol=1e-8,
    ftol=0.005,
    n_skip=5,
    period=50,
    n_max_gen=1000,
    n_max_evals=100000,
)
```

| Parameter | Type | Default | Description |
|---|---|---|---|
| `xtol` | `float` | `0.0005` | **Design space tolerance.** The algorithm stops when the maximum absolute change in decision variables across the sliding window is below this value. Measures stagnation in `X`. |
| `cvtol` | `float` | `1e-8` | **Constraint violation tolerance.** Stops (on the CV criterion) when constraint violation falls below this threshold. For unconstrained problems this criterion is always satisfied and does not trigger premature termination. |
| `ftol` | `float` | `0.005` | **Objective space tolerance.** Stops when the relative change in the normalized Pareto front (measured via changes in the ideal point, nadir point, and front spread) falls below this value across the sliding window. |
| `n_skip` | `int` | `5` | How often (in generations) the termination criterion is evaluated. `1` evaluates every generation (most responsive). Higher values reduce computational overhead for the convergence check. |
| `period` | `int` | `50` | **Sliding window size.** The number of past generations considered when computing tolerances. The **maximum** change over this window is used (worst-case), not just the last generation. Larger values make termination more conservative. |
| `n_max_gen` | `int` | `1000` | **Fallback maximum generations.** An upper bound to prevent infinite runs if tolerance criteria are never met. Acts as a safety net. |
| `n_max_evals` | `int` | `100000` | **Fallback maximum evaluations.** An upper bound on total function evaluations. Whichever of `n_max_gen` or `n_max_evals` is hit first triggers termination. |

**How termination is decided:** The algorithm stops when **all three** conditions are satisfied within the sliding window (xtol AND cvtol AND ftol), OR when the fallback `n_max_gen` or `n_max_evals` is reached.

```python
from pymoo.termination.default import DefaultMultiObjectiveTermination
from pymoo.optimize import minimize

# Stricter convergence, larger window, higher fallback
termination = DefaultMultiObjectiveTermination(
    xtol=1e-8,
    cvtol=1e-8,
    ftol=1e-6,
    period=100,
    n_skip=5,
    n_max_gen=5000,
    n_max_evals=500000,
)

res = minimize(problem, algorithm, termination, seed=1, verbose=True)

# Effectively disable ftol (rely only on xtol and n_max_gen):
termination = DefaultMultiObjectiveTermination(
    ftol=1.0,       # Very large value, never triggered
    n_max_gen=500,  # Rely on generation cap instead
)
```

---

## Result Object

The `Result` object returned by `minimize()` contains all output from the optimization run.

**Full attribute reference:**

| Attribute | Type | Description |
|---|---|---|
| `res.X` | `ndarray` shape `(n_nds, n_var)` | Decision variable values of the final non-dominated (Pareto-optimal) solutions. `None` if no feasible solution was found. |
| `res.F` | `ndarray` shape `(n_nds, n_obj)` | Objective values of the final Pareto front solutions, in the same order as `res.X`. |
| `res.G` | `ndarray` shape `(n_nds, n_constr)` or `None` | Inequality constraint values for the Pareto solutions. `None` if the problem is unconstrained. |
| `res.H` | `ndarray` or `None` | Equality constraint values for the Pareto solutions. `None` if no equality constraints exist. |
| `res.CV` | `ndarray` shape `(n_nds, 1)` | Constraint violation values. Always `0` for unconstrained problems. |
| `res.opt` | `Population` | The full `Population` object representing the final non-dominated set. Use `.get("X", "F", "rank", "crowding")` to extract specific attributes. |
| `res.pop` | `Population` | The **entire** final population (both dominated and non-dominated). Useful for post-hoc analysis. |
| `res.algorithm` | `Algorithm` | The algorithm object after optimization has completed. Contains the full final state. |
| `res.problem` | `Problem` | The problem instance that was solved. |
| `res.history` | `list[Algorithm]` | List of per-generation algorithm snapshots. Only populated if `save_history=True`. Length equals the number of generations run. |
| `res.exec_time` | `float` | Total wall-clock runtime in seconds. |
| `res.start_time` | `float` | Unix timestamp of when the run started. |
| `res.end_time` | `float` | Unix timestamp of when the run ended. |
| `res.seed` | `int` | The random seed actually used (useful when seed was auto-assigned from `None`). |
| `res.success` | `bool` | Whether the algorithm terminated successfully. |
| `res.message` | `str` or `None` | An optional termination message. |
| `res.pf` | `ndarray` or `None` | The true Pareto front, if known (provided by the problem). `None` for unknown fronts. |
| `res.archive` | `Archive` or `None` | External archive contents if an archive was attached to the algorithm. |
| `res.data` | `dict` | Data stored within the algorithm object during the run (e.g., from custom callbacks). |

```python
res = minimize(problem, algorithm, ('n_gen', 200), seed=1, save_history=True)

# Pareto front results
print(res.X)          # shape (n_nds, n_var)
print(res.F)          # shape (n_nds, n_obj)
print(res.CV)         # shape (n_nds, 1)

# Full population attributes
X_all   = res.pop.get("X")        # all individuals' variables
F_all   = res.pop.get("F")        # all individuals' objectives
ranks   = res.pop.get("rank")     # Pareto rank (0 = first front)
cd      = res.pop.get("crowding") # crowding distance

# Algorithm state
print(f"Generations run:  {res.algorithm.n_gen}")
print(f"Evaluations used: {res.algorithm.evaluator.n_eval}")
print(f"Wall time:        {res.exec_time:.2f}s")
print(f"Seed used:        {res.seed}")

# Convergence history (requires save_history=True)
for gen_snap in res.history:
    n_nds  = len(gen_snap.opt)
    n_eval = gen_snap.evaluator.n_eval
    print(f"Gen {gen_snap.n_gen}: {n_nds} non-dominated, {n_eval} evals")
```

---

## Verbose Output

When `verbose=True` is passed to `minimize()`, NSGA-II prints a header and one row per generation:

```
n_gen | n_eval | n_nds | cv (min) | cv (avg) | eps      | indicator
===========================================================================================
1     | 100    | 6     | 0.0      | 0.0      | -        | -
2     | 200    | 9     | 0.0      | 0.0      | 2.0E+00  | ideal
3     | 300    | 14    | 0.0      | 0.0      | 1.5E+00  | nadir
```

| Column | Description |
|---|---|
| `n_gen` | Current generation number (starts at 1). |
| `n_eval` | Cumulative number of objective function evaluations so far. |
| `n_nds` | Number of non-dominated solutions (Pareto front 1 size) in the current population. A steadily growing `n_nds` is a sign of healthy convergence. |
| `cv (min)` | Minimum constraint violation in the current population. Only shown for constrained problems. `0.0` means at least one individual is feasible. |
| `cv (avg)` | Average constraint violation across the current population. Only shown for constrained problems. |
| `eps` | The convergence metric value at this generation. Measures how much the Pareto front has moved since the previous evaluation window. Computed as the maximum of: change in ideal point, change in nadir point, and change in front spread. Lower values mean closer to convergence. `-` means not yet computed (within `n_skip` interval). |
| `indicator` | Which component (`ideal`, `nadir`, or `f`) drove the `eps` value in this generation. Tells you *why* the algorithm has or has not converged yet. |

---

## Sampling Options Reference

| Class | Module | Variable Type | Description |
|---|---|---|---|
| `FloatRandomSampling` | `pymoo.operators.sampling.rnd` | Real (`float`) | Uniform random sampling within problem bounds. Default for continuous problems. |
| `BinaryRandomSampling` | `pymoo.operators.sampling.rnd` | Binary (`0/1`) | Randomly assigns 0 or 1 to each variable with equal probability. |
| `IntegerRandomSampling` | `pymoo.operators.sampling.rnd` | Integer | Random integers sampled uniformly within bounds. |
| `PermutationRandomSampling` | `pymoo.operators.sampling.rnd` | Permutation | Generates random orderings (e.g., for TSP-type problems). |
| `LHS` | `pymoo.operators.sampling.lhs` | Real | Latin Hypercube Sampling - ensures better space-filling coverage. Strongly recommended when `pop_size` is small or `n_var` is large. |

```python
from pymoo.operators.sampling.lhs import LHS
NSGA2(sampling=LHS())    # Better initial coverage than pure random
```

---

## Crossover Options Reference

| Class | Module | Variable Type | Notes |
|---|---|---|---|
| `SBX` | `pymoo.operators.crossover.sbx` | Real | Simulated Binary Crossover. Default for continuous problems. Most widely used. |
| `SinglePointCrossover` | `pymoo.operators.crossover.pntx` | Binary / Integer | Cuts both parents at one point and swaps tails. |
| `TwoPointCrossover` | `pymoo.operators.crossover.pntx` | Binary / Integer | Cuts at two points and swaps the middle segment. |
| `UniformCrossover` (`UX`) | `pymoo.operators.crossover.ux` | Binary | Each gene independently inherited from either parent with probability 0.5. |
| `HalfUniformCrossover` (`HUX`) | `pymoo.operators.crossover.hux` | Binary | Only swaps the differing genes between parents; preserves shared bits. |
| `OrderCrossover` (`OX`) | `pymoo.operators.crossover.ox` | Permutation | Preserves relative order of elements. Standard for TSP-type problems. |
| `EdgeRecombinationCrossover` (`ERX`) | `pymoo.operators.crossover.erx` | Permutation | Uses edge tables for tour recombination in TSP-style problems. |

---

## Mutation Options Reference

| Class | Module | Variable Type | Notes |
|---|---|---|---|
| `PM` | `pymoo.operators.mutation.pm` | Real | Polynomial Mutation. Default for continuous problems. |
| `BitflipMutation` | `pymoo.operators.mutation.bitflip` | Binary | Flips each bit independently with probability `prob`. |
| `InversionMutation` | `pymoo.operators.mutation.inversion` | Permutation | Reverses a randomly selected sub-sequence of the permutation. |

---

## Performance Indicators

After optimization, pymoo provides several indicators to measure the **quality** of the Pareto front found. These are especially useful for benchmarking and convergence analysis.

### Overview of Indicators

| Indicator | Class | Requires | Optimization Direction | Description |
|---|---|---|---|---|
| **GD** | `GD` | True Pareto front | Minimize | Generational Distance - average distance from each found solution to the nearest point on the true Pareto front. Measures **convergence** only, not diversity. |
| **GD+** | `GDPlus` | True Pareto front | Minimize | Modified GD using a Pareto-compliant distance. Preferred over plain GD. |
| **IGD** | `IGD` | True Pareto front | Minimize | Inverted GD - average distance from each true Pareto front point to the nearest found solution. Measures both convergence and **coverage**. |
| **IGD+** | `IGDPlus` | True Pareto front | Minimize | Pareto-compliant version of IGD. Preferred over plain IGD in most research. |
| **Hypervolume** | `HV` | Reference point | Maximize | Volume of objective space dominated by found solutions relative to a reference point. Pareto-compliant; measures convergence and spread simultaneously. No true Pareto front needed. |

### Usage

```python
from pymoo.indicators.igd import IGD
from pymoo.indicators.igd_plus import IGDPlus
from pymoo.indicators.gd import GD
from pymoo.indicators.hv import HV
import numpy as np

res = minimize(problem, algorithm, ('n_gen', 200), seed=1, save_history=True)

# --- Pareto-front based indicators (need the true Pareto front) ---
pf = problem.pareto_front()       # Only available for test problems

igd      = IGD(pf)
igd_plus = IGDPlus(pf)
gd       = GD(pf)

print("IGD:  ", igd.do(res.F))        # lower is better
print("IGD+: ", igd_plus.do(res.F))   # lower is better
print("GD:   ", gd.do(res.F))         # lower is better

# --- Hypervolume (needs a reference point, not the Pareto front) ---
# ref_point must be strictly dominated by all Pareto front points
ref_point = np.array([1.1, 1.1])
hv = HV(ref_point=ref_point)
print("HV:   ", hv.do(res.F))         # higher is better

# --- Automatic reference point from found solutions ---
max_F = res.F.max(axis=0)
ref_point_auto = max_F * 1.1
hv_auto = HV(ref_point=ref_point_auto)
print("HV (auto ref):", hv_auto.do(res.F))

# --- Convergence curve over generations ---
n_evals = []
hv_over_time = []

for gen_snap in res.history:
    opt_F = gen_snap.opt.get("F")
    n_evals.append(gen_snap.evaluator.n_eval)
    hv_over_time.append(hv.do(opt_F))

import matplotlib.pyplot as plt
plt.plot(n_evals, hv_over_time, '-o', markersize=3)
plt.xlabel("Function Evaluations")
plt.ylabel("Hypervolume")
plt.title("NSGA-II Convergence")
plt.show()
```

### Indicator Selection Guide

| Situation | Recommended Indicator |
|---|---|
| True Pareto front is known (test problems) | IGD+ (Pareto-compliant, measures both convergence and spread) |
| True Pareto front is unknown (real problems) | Hypervolume (needs only a reference point) |
| Comparing convergence speed only | GD+ |
| Need a single ranking number | Hypervolume (most theoretically sound) |
| Computational budget is tight (many-obj) | IGD (faster than exact Hypervolume in high dimensions) |

---

## Parallelization

Expensive objective functions are common in real-world problems (simulations, FEM, CFD, etc.). pymoo supports several parallelization strategies that work seamlessly with NSGA-II without modifying the algorithm itself.

### Strategy 1: Vectorized Evaluation (Fastest - No Overhead)

Implement `_evaluate` to accept a full batch of solutions at once (`X` is a 2D array). This is the default mode and relies on NumPy's vectorized operations.

```python
import numpy as np
from pymoo.core.problem import Problem

class VectorizedProblem(Problem):
    def __init__(self):
        super().__init__(n_var=10, n_obj=2, xl=0.0, xu=1.0)

    def _evaluate(self, X, out, *args, **kwargs):
        # X shape: (pop_size, n_var) - entire population at once
        f1 = np.sum(X ** 2, axis=1)
        f2 = np.sum((X - 1) ** 2, axis=1)
        out["F"] = np.column_stack([f1, f2])
```

### Strategy 2: Python Multiprocessing via `starmap`

Use Python's built-in `multiprocessing.Pool` to evaluate individuals in parallel. Best for CPU-bound Python evaluations.

```python
from multiprocessing.pool import Pool
from pymoo.core.problem import ElementwiseProblem
from pymoo.algorithms.moo.nsga2 import NSGA2
from pymoo.optimize import minimize
from pymoo.problems.parallelization import StarMapParallelization

class MyExpensiveProblem(ElementwiseProblem):
    def __init__(self, **kwargs):
        super().__init__(n_var=5, n_obj=2, xl=0.0, xu=1.0, **kwargs)

    def _evaluate(self, x, out, *args, **kwargs):
        import time
        time.sleep(0.01)  # Simulate expensive evaluation
        out["F"] = [float(sum(x**2)), float(sum((x-1)**2))]

# Run with 4 parallel workers
n_proccess = 4
pool = Pool(n_proccess)
runner = StarMapParallelization(pool.starmap)

problem = MyExpensiveProblem(elementwise_runner=runner)
algorithm = NSGA2(pop_size=100)
res = minimize(problem, algorithm, ('n_gen', 50), seed=1)
pool.close()
```

### Strategy 3: Joblib (Simpler API, Cross-Platform)

```python
from joblib import Parallel, delayed
import numpy as np
from pymoo.core.problem import Problem
from pymoo.algorithms.moo.nsga2 import NSGA2
from pymoo.optimize import minimize

class JoblibProblem(Problem):
    def __init__(self, n_jobs=-1):
        super().__init__(n_var=10, n_obj=2, xl=0.0, xu=1.0)
        self.n_jobs = n_jobs

    def _evaluate(self, X, out, *args, **kwargs):
        def eval_single(x):
            return [float(np.sum(x ** 2)), float(np.sum((x - 1) ** 2))]

        F = Parallel(n_jobs=self.n_jobs)(
            delayed(eval_single)(X[i]) for i in range(len(X))
        )
        out["F"] = np.array(F)

problem = JoblibProblem(n_jobs=8)
algorithm = NSGA2(pop_size=100)
res = minimize(problem, algorithm, ('n_gen', 200), seed=1)
```

### Strategy 4: Custom Evaluator (Dask / External Cluster)

For cluster-based or distributed evaluations, implement a custom `Evaluator`:

```python
from pymoo.core.evaluator import Evaluator
from pymoo.algorithms.moo.nsga2 import NSGA2

class AsyncEvaluator(Evaluator):
    def __init__(self, submit_fn, gather_fn):
        super().__init__()
        self.submit_fn = submit_fn
        self.gather_fn = gather_fn

    def _eval(self, problem, pop, **kwargs):
        # Submit all evaluations asynchronously
        futures = [self.submit_fn(problem._evaluate_single, ind.X) for ind in pop]
        results = self.gather_fn(futures)
        for ind, res in zip(pop, results):
            ind.F = res
        return pop

# Usage with Dask (example)
# from dask.distributed import Client
# client = Client()
# evaluator = AsyncEvaluator(client.submit, client.gather)
# algorithm = NSGA2(pop_size=100, evaluator=evaluator)
```

### Parallelization Strategy Comparison

| Strategy | Best For | Overhead | Complexity |
|---|---|---|---|
| Vectorized (`numpy`) | Pure Python/NumPy math | None | Low |
| `starmap` / multiprocessing | CPU-bound Python functions | Medium (IPC) | Low |
| Joblib | CPU-bound, cross-platform | Medium | Low |
| Custom Evaluator + Dask | Distributed/cluster simulation | High (network) | High |

---

## When NOT to Use NSGA-II

NSGA-II is an excellent default choice, but it has known limitations:

| Scenario | Problem | Recommended Alternative |
|---|---|---|
| **4+ objectives** | NSGA-II's crowding distance degrades badly in high-dimensional objective spaces - most solutions end up on the first front, destroying selection pressure. | **NSGA-III**, **MOEA/D**, or **AGE-MOEA** |
| **Highly multimodal / many local Pareto fronts** | NSGA-II can converge to local fronts and struggles to escape them. | **RVEA**, **AGE-MOEA2**, or restart strategies |
| **Very expensive evaluations (low budget)** | NSGA-II needs many evaluations. With fewer than ~500 evaluations, surrogate-assisted methods outperform it. | Bayesian optimization, surrogate-based MOO |
| **Continuous gradient available** | NSGA-II ignores gradient information entirely. | Multi-objective gradient descent, NSGA-II + gradient-guided operators |
| **Discrete / combinatorial at scale** | SBX and PM are designed for continuous spaces. Binary/permutation adaptations exist but underperform specialized methods. | **BRKGA** (permutations), problem-specific EAs |
| **Dynamic problems (objectives change over time)** | Standard NSGA-II has no mechanism to track moving Pareto fronts. | **D-NSGA-II** (`pymoo.algorithms.moo.dnsga2`) |
| **Known preference or reference point** | When the decision-maker targets a specific region of the Pareto front, NSGA-II explores the full front wastefully. | **R-NSGA-II** (`pymoo.algorithms.moo.rnsga2`) |

---

## Full Configuration Examples

### Example 1: Default Configuration (Continuous Real Variables)

```python
from pymoo.algorithms.moo.nsga2 import NSGA2
from pymoo.problems import get_problem
from pymoo.optimize import minimize
from pymoo.visualization.scatter import Scatter

problem = get_problem("zdt1")
algorithm = NSGA2(pop_size=100)

res = minimize(problem, algorithm, ('n_gen', 200), seed=1, verbose=True)

Scatter().add(problem.pareto_front(), plot_type="line", color="black") \
         .add(res.F, facecolor="none", edgecolor="red").show()
```

---

### Example 2: Customized Continuous Problem (Steady-State + LHS + Pruning Crowding)

```python
from pymoo.algorithms.moo.nsga2 import NSGA2
from pymoo.operators.crossover.sbx import SBX
from pymoo.operators.mutation.pm import PM
from pymoo.operators.sampling.lhs import LHS
from pymoo.operators.survival.rank_and_crowding import RankAndCrowding
from pymoo.optimize import minimize

algorithm = NSGA2(
    pop_size=150,
    n_offsprings=30,
    sampling=LHS(),
    crossover=SBX(prob=0.9, eta=20),
    mutation=PM(prob=None, eta=15),
    survival=RankAndCrowding(crowding_func='pcd'),
    eliminate_duplicates=True,
)

res = minimize(problem, algorithm, ('n_gen', 300), seed=42, verbose=True)
```

---

### Example 3: Binary Variable Problem (ZDT5)

```python
from pymoo.algorithms.moo.nsga2 import NSGA2
from pymoo.operators.crossover.pntx import TwoPointCrossover
from pymoo.operators.mutation.bitflip import BitflipMutation
from pymoo.operators.sampling.rnd import BinaryRandomSampling
from pymoo.problems import get_problem
from pymoo.optimize import minimize

problem = get_problem("zdt5")

algorithm = NSGA2(
    pop_size=100,
    sampling=BinaryRandomSampling(),
    crossover=TwoPointCrossover(),
    mutation=BitflipMutation(),
    eliminate_duplicates=True
)

res = minimize(problem, algorithm, ('n_gen', 500), seed=1, verbose=False)
```

---

### Example 4: Constrained Problem with Repair Operator

```python
import numpy as np
from pymoo.algorithms.moo.nsga2 import NSGA2
from pymoo.core.problem import ElementwiseProblem
from pymoo.core.repair import Repair
from pymoo.optimize import minimize

class PortfolioProblem(ElementwiseProblem):
    """Two-objective portfolio: maximize return, minimize risk. Weights must sum to 1."""
    def __init__(self):
        super().__init__(n_var=5, n_obj=2, xl=0.0, xu=1.0)

    def _evaluate(self, x, out, *args, **kwargs):
        out["F"] = [-np.dot(x, [0.10, 0.20, 0.15, 0.12, 0.18]),
                     np.dot(x, [0.05, 0.08, 0.07, 0.06, 0.09])]

class SumToOneRepair(Repair):
    def _do(self, problem, X, **kwargs):
        row_sums = X.sum(axis=1, keepdims=True)
        row_sums[row_sums == 0] = 1.0
        return X / row_sums

algorithm = NSGA2(
    pop_size=100,
    repair=SumToOneRepair(),
    eliminate_duplicates=True,
    return_least_infeasible=True,
)

res = minimize(PortfolioProblem(), algorithm, ('n_gen', 200), seed=1, verbose=True)
print("Optimal weights:\n", res.X)
print("Return / Risk tradeoffs:\n", res.F)
```

---

### Example 5: Callbacks, History, and Performance Indicators

```python
from pymoo.algorithms.moo.nsga2 import NSGA2
from pymoo.core.callback import Callback
from pymoo.indicators.hv import HV
from pymoo.indicators.igd_plus import IGDPlus
from pymoo.problems import get_problem
from pymoo.optimize import minimize
import numpy as np
import matplotlib.pyplot as plt

class HVCallback(Callback):
    """Track hypervolume every generation."""
    def __init__(self, ref_point):
        super().__init__()
        self.hv_indicator = HV(ref_point=ref_point)
        self.data["hv"] = []
        self.data["n_eval"] = []

    def notify(self, algorithm):
        F = algorithm.opt.get("F")
        if F is not None and len(F) > 0:
            self.data["hv"].append(self.hv_indicator.do(F))
            self.data["n_eval"].append(algorithm.evaluator.n_eval)

problem = get_problem("zdt1")
ref_point = np.array([1.1, 1.1])
callback = HVCallback(ref_point=ref_point)

algorithm = NSGA2(pop_size=100, eliminate_duplicates=True, callback=callback)

res = minimize(problem, algorithm, ('n_gen', 200), seed=1, verbose=True, save_history=True)

# Plot convergence
plt.plot(callback.data["n_eval"], callback.data["hv"], '-o', markersize=3)
plt.xlabel("Function Evaluations")
plt.ylabel("Hypervolume")
plt.title("NSGA-II Convergence on ZDT1")
plt.show()

# Final performance
igd_plus = IGDPlus(problem.pareto_front())
hv       = HV(ref_point=ref_point)
print(f"IGD+:        {igd_plus.do(res.F):.6f}")
print(f"Hypervolume: {hv.do(res.F):.6f}")
print(f"Exec time:   {res.exec_time:.2f}s")
print(f"Total evals: {res.algorithm.evaluator.n_eval}")
```

---

### Example 6: Smart Auto-Termination

```python
from pymoo.algorithms.moo.nsga2 import NSGA2
from pymoo.termination.default import DefaultMultiObjectiveTermination
from pymoo.problems import get_problem
from pymoo.optimize import minimize

problem = get_problem("zdt3")

termination = DefaultMultiObjectiveTermination(
    xtol=1e-8,
    cvtol=1e-8,
    ftol=0.001,
    period=30,
    n_skip=5,
    n_max_gen=2000,
    n_max_evals=200000,
)

algorithm = NSGA2(pop_size=100, eliminate_duplicates=True)

res = minimize(problem, algorithm, termination, seed=1, verbose=True)
print(f"Stopped at generation: {res.algorithm.n_gen}")
print(f"Non-dominated solutions found: {len(res.F)}")
```

---

## Quick Reference Card

```
NSGA2(
    # --- Population & Offspring ---
    pop_size              = 100,         # Population size
    n_offsprings          = None,        # Offspring per gen (None = pop_size)

    # --- Operators ---
    sampling              = FloatRandomSampling(),    # or LHS(), BinaryRandom, ndarray
    selection             = TournamentSelection(
                              func_comp=binary_tournament,
                              pressure=2              # tournament size
                            ),
    crossover             = SBX(
                              prob=0.9,               # crossover probability
                              eta=15,                 # distribution index
                              prob_var=0.5            # per-variable probability
                            ),
    mutation              = PM(
                              prob=None,              # per-var rate (None = 1/n_var)
                              eta=20                  # distribution index
                            ),
    survival              = RankAndCrowding(
                              crowding_func='cd'      # 'cd','pcd','ce','mnn','2nn'
                            ),
    repair                = None,                     # Repair operator (optional)
    mating                = None,                     # Full mating pipeline (optional)

    # --- Diversity & Quality ---
    eliminate_duplicates  = True,

    # --- Display ---
    output                = MultiObjectiveOutput(),

    # --- Inherited from Algorithm base ---
    termination           = None,        # or DefaultMultiObjectiveTermination(...)
    seed                  = None,        # int for reproducibility
    verbose               = False,       # print per-generation output
    callback              = None,        # Callback object
    save_history          = False,       # store per-gen snapshots in res.history
    return_least_infeasible = False,     # return best infeasible if none feasible
    display               = None,        # custom Display object
    evaluator             = None,        # custom Evaluator (e.g., for parallelism)
    archive               = None,        # external archive
)
```

---

*Documentation compiled from the official [pymoo documentation](https://pymoo.org/algorithms/moo/nsga2.html) (v0.6.1.6), source code at [github.com/anyoptimization/pymoo](https://github.com/anyoptimization/pymoo), and Deb et al. (2002). For the latest API changes always refer to the pymoo GitHub repository.*
