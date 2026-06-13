# Operation Presets — Global Pool Seed Data

44 operations across two presets, deduplicated to 42 unique global ops.
IDs are permanent and never reassigned.

## Categories
Design · Cutting · Forming · Joining · Finishing · Quality · Procurement ·
Scanning · Analysis · Prototyping · Documentation

---

## Preset 1 — Sheet Metal Fabrication (26 ops, OP-00001 to OP-00026)

| ID       | Name                       | Category    | Default Fulfillment | Typical Levels |
|----------|----------------------------|-------------|---------------------|----------------|
| OP-00001 | CAD / Drawing Preparation  | Design      | In-house            | L0, L1, L2     |
| OP-00002 | DFM Review                 | Design      | In-house            | L0, L1         |
| OP-00003 | Laser Cutting              | Cutting     | In-house            | L2             |
| OP-00004 | Plasma Cutting             | Cutting     | In-house            | L2             |
| OP-00005 | Waterjet Cutting           | Cutting     | Outsourced          | L2             |
| OP-00006 | Shearing                   | Cutting     | In-house            | L2             |
| OP-00007 | Punching / Nibbling        | Cutting     | In-house            | L2             |
| OP-00008 | Press Brake Bending        | Forming     | In-house            | L2             |
| OP-00009 | Rolling                    | Forming     | In-house            | L2             |
| OP-00010 | Stamping                   | Forming     | Outsourced          | L2             |
| OP-00011 | Deburring / Edge Finishing | Finishing   | In-house            | L2             |
| OP-00012 | MIG Welding                | Joining     | In-house            | L1             |
| OP-00013 | TIG Welding                | Joining     | In-house            | L1             |
| OP-00014 | Spot Welding               | Joining     | In-house            | L1             |
| OP-00015 | Hardware Insertion         | Joining     | In-house            | L1, L2         |
| OP-00016 | Mechanical Assembly        | Joining     | In-house            | L0             |
| OP-00017 | Grinding / Weld Dressing   | Finishing   | In-house            | L1             |
| OP-00018 | Shot Blasting              | Finishing   | In-house            | L1, L0         |
| OP-00019 | Powder Coating             | Finishing   | In-house            | L1, L0         |
| OP-00020 | Wet Paint                  | Finishing   | Outsourced          | L1, L0         |
| OP-00021 | Galvanizing                | Finishing   | Outsourced          | L2, L1         |
| OP-00022 | Anodizing                  | Finishing   | Outsourced          | L2             |
| OP-00023 | Procurement / Purchasing   | Procurement | In-house            | L2             |
| OP-00024 | Dimensional Inspection     | Quality     | In-house            | L0, L1, L2     |
| OP-00025 | Visual Inspection          | Quality     | In-house            | L0             |
| OP-00026 | Packaging                  | Quality     | In-house            | L0             |

---

## Preset 2 — Engineering Services / Prototyping (18 ops, OP-00027 to OP-00042)

Shared ops (Dimensional Inspection = OP-00024, Procurement = OP-00023) reuse
existing global IDs — not duplicated.

| ID       | Name                             | Category      | Default Fulfillment | Typical Levels |
|----------|----------------------------------|---------------|---------------------|----------------|
| OP-00027 | Client Brief / Scope Definition  | Documentation | In-house            | L0             |
| OP-00028 | 3D Scanning                      | Scanning      | In-house            | L2, L1         |
| OP-00029 | Scan Data Processing             | Scanning      | In-house            | L2, L1         |
| OP-00030 | Reverse Engineering / CAD Recon  | Design        | In-house            | L2, L1         |
| OP-00031 | CAD Design / Modelling           | Design        | In-house            | L0, L1, L2     |
| OP-00032 | DFM / DFA Analysis               | Analysis      | In-house            | L0, L1         |
| OP-00033 | FEA / Simulation                 | Analysis      | In-house            | L0, L1         |
| OP-00034 | Technical Drawing Production     | Design        | In-house            | L0, L1, L2     |
| OP-00035 | FDM 3D Printing                  | Prototyping   | In-house            | L2, L1         |
| OP-00036 | Resin / SLA Printing             | Prototyping   | In-house            | L2             |
| OP-00037 | Laser Engraving / Marking        | Prototyping   | In-house            | L2             |
| OP-00038 | Post-Processing / Finishing      | Prototyping   | In-house            | L2, L1         |
| OP-00039 | CNC Machining                    | Prototyping   | Outsourced          | L2             |
| OP-00040 | Injection Moulding (prototype)   | Prototyping   | Outsourced          | L2             |
| OP-00041 | Client Review / Approval         | Documentation | In-house            | L0             |
| OP-00042 | Report / Documentation Writing   | Documentation | In-house            | L0             |
| OP-00024 | Dimensional Inspection (shared)  | Quality       | In-house            | L0, L1, L2     |
| OP-00023 | Procurement / Purchasing (shared)| Procurement   | In-house            | L2             |

---

## Onboarding Flow

**Sheet Metal:** System pre-ticks universal ops (Laser Cutting, Press Brake Bending,
MIG Welding, Powder Coating, Deburring, Dimensional Inspection, Packaging).
Org unticks what they don't have. Outsourced ops kept ticked with fulfillment=Outsourced.
One screen, one action.

**Engineering Services:** System pre-ticks (3D Scanning, Scan Data Processing,
CAD Design / Modelling, Technical Drawing Production, FDM 3D Printing,
Client Review / Approval, Dimensional Inspection).
Same one-screen flow.

## Stirg Activation (~18 ops from Preset 1)
Excludes: Waterjet Cutting (outsourced, rarely used), Stamping (outsourced),
Anodizing (outsourced, aluminum only). All others active, some as outsourced.

## Prototip Activation (~15 ops from Preset 2)
Excludes: Injection Moulding (rarely used), FEA/Simulation (case by case).
All others active.
