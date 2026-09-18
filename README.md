# v8-ir-fault-localization

![Alt Text](images/my-screenshot.png)


A labeled dataset of **Google V8 TurboFan Internal Representation (IR) graphs** built around a known V8 miscompilation bug, packaged
for downstream fault-localization and visualization research.

A single proof-of-concept (PoC) that triggers a real V8 typer bug was mutated into many
program variants using and LLM (GPT 4.0). Each variant was run on the buggy `d8` with the `--trace-turbo` flag to capture its IR.
The varients were labled as either bug-reproducing (failing) or bug-fixing (passing) and the IR JSONs were separated out into 
each graph type and each optimization phase. Each graph carries two similarity scores: similarity to  original PoC per phase, and 
similarity between phases.


This repo provides the similarity data for **Dr. Katy William's Davidson College Data Vizualiation Lab**. The IR graphs, similarity scores, and mutant programs are all here.


## How the dataset is structured

1. **Seed** — `minimised-NumberMax.js`, the minimized PoC.
2. **Mutate** — an LLM (`mutate.py`, `gpt-4o-mini`) generated 54 variants, each a small
   AST-level edit: swapped operators, renamed identifiers, changed constants, altered loop
   bounds. `mutation_description.txt` records which AST node(s) each one touched.
3. **Run and label** — each variant executed on the buggy `d8`. A variant is **`failing`** if
   it still reproduces the bug (interpreted and optimized runs disagree) and **`passing`** if
   the mutation destroyed the trigger. 11 failing, 34 passing.
4. **Capture IR** — `d8 --allow-natives-syntax --trace-turbo`, split into one graph per
   optimization phase per graph type.
5. **Score** — each graph annotated with `baseline_similarity` (vs. the seed) and
   `prior_phase_similarity` (vs. the previous phase), also exported as CSVs. **The scoring
   code is not in this repository.**

---

## Layout

```
minimised-NumberMax.js              seed PoC (triggers the bug)
minimised-NumberMax-modified.js     same PoC with the trigger removed
turbo-buggy-pretty.json             full --trace-turbo dump, buggy run
turbo-passing-pretty.json           full --trace-turbo dump, non-triggering run
buggy_node_129.json                 the NumberMax node, buggy    (excerpt, not valid JSON)
passing_node_129.json               the NumberMax node, passing  (excerpt, not valid JSON)
description.txt                     full bug write-up and debugging commands
buggy vs. passing P{1,2}.jpg        side-by-side IR screenshots

mutate.py                           LLM mutation generator
combine_graph_types.py              merges per-graph-type IR JSONs into one file per mutant
scripts/build_v8_d8.sh              builds d8 at a given V8 commit (see scripts/README.md)

similarity-score-july-16/
    mutations/                      54 mutant .js programs + mutation_description.txt
    mutated-JSON-files/             34 whole-run --trace-turbo dumps
    similarity_irs/                 THE MAIN DATASET — per-phase, per-graph-type IR
        passing/<mutant>/phase_NN_<V8 phase>/after_<graph type>.json
        failing/<mutant>/...
    similarity_to_seed/             similarity vs. the seed PoC   (6 CSVs)
    similarity_per_phase/           similarity vs. the prior phase (6 CSVs)
```


## Data reference

### Similarity CSVs

The two directories hold the **same two metrics** that annotate the IR JSONs, pivoted into
tables. Each contains one CSV per graph type (`value`, `control`, `effect`, `context`,
`frame-state`) plus `similarity_combined.csv`.

**`similarity_to_seed/`** — the `baseline_similarity` metric. How much a mutant's graph at
phase *P* differs from the *seed's* graph at that same phase. Low = the mutation changed the
compiled shape a lot.

```
mutation,label,global,V8.TFBytecodeGraphBuilder,V8.TFInlining,...,V8.TFLateGraphTrimming
```

45 rows — one per mutant, no seed row (the seed's similarity to itself is trivially 1.0).

**`similarity_per_phase/`** — the `prior_phase_similarity` metric. How much a program's own
graph changed *between* phase *P-1* and phase *P*. Low = that phase rewrote the graph heavily.

```
program,label,avg,V8.TFBytecodeGraphBuilder,V8.TFInlining,...,V8.TFLateGraphTrimming
```

46 rows — 45 mutants plus a `seed` row. The `V8.TFBytecodeGraphBuilder` column is always
`0.000000`: it is the first phase, so there is no prior phase to compare against.

`label` is `passing` / `failing` / `seed`. `global` and `avg` are both the unweighted mean of
the 19 phase columns (verified across every CSV in both directories).

The CSVs are a pivot of the per-graph annotations, not an independent computation. For
`mutation_1` at `V8.TFTyper`, graph type `value`:

```
similarity_irs/passing/mutation_1/phase_03_V8.TFTyper/after_value.json
    baseline_similarity     = 0.5365853658536586   -> similarity_to_seed/similarity_value.csv
    prior_phase_similarity  = 0.2682926829268293   -> similarity_per_phase/similarity_value.csv
```

### IR JSONs

```
similarity_irs/{passing,failing}/<mutant>/phase_NN_<V8 phase>/after_<graph type>.json
```

**Phases** — 19 per mutant, identical set across all 45, from `phase_00_V8.TFBytecodeGraphBuilder`
through `phase_19_V8.TFLateGraphTrimming`. Indices run `00`–`10` then `12`–`19`: **index 11 is
absent everywhere**, not missing data. (An earlier revision captured
`phase_11_effect linearization schedule`; it was dropped.)

**Graph types** — five files per phase: `after_value.json`, `after_control.json`,
`after_effect.json`, `after_context.json`, `after_frame-state.json`. They are five *views of one
graph*: the `NODES` list is byte-identical across all five, and only the `EDGES` subset differs,
filtered by each edge's `kind`. Verified across all 4275 files — no node-list divergence.

Every file has exactly these top-level keys:

| Key | |
|---|---|
| `NODES` | node list, shared across all five graph types |
| `EDGES` | `{"from": <id>, "to": <id>, "kind": "<graph type>"}` — may be empty for a type in a given phase |
| `KIND` | the graph types present, e.g. `["value"]` |
| `baseline_similarity` | float, vs. the seed at this phase |
| `prior_phase_similarity` | float, vs. this program's previous phase |

Node fields: `id`, `opcode`, `label`, `title`, `type`, `live`, `control`, `properties`,
`opinfo`, `origin`, `sourcePosition`, `rankInputs`, `rankWithInput`.

The fields that matter most for this bug are `type` (the typer's verdict — `Range(1, inf)` vs.
`Range(0, 1)` on node 129) and `live` (in the buggy IR, node 129 dies after four phases; in the
passing IR it survives to the end).

There is **no seed IR tree** under `similarity_irs/` — only mutants.

