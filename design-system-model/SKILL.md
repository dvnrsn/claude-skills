---
name: design-system-model
description: >-
  A coherent way to think about any design system: the four-layer structure that the major published design systems converge on (foundations/tokens, components, patterns, guidelines & governance), what belongs in each, and the canonical references behind them (Atomic Design, W3C Design Tokens, Open UI, Smashing / Vitaly Friedman / Alla Kholmatova). Use whenever reasoning about how to structure, audit, or explain a design system, deciding which layer a given concern belongs to (color, tables, forms, motion, textures, empty states, page headers...), or when someone asks "what's the standard breakdown" / "how should we organise this" / "is a small number of top-level buckets the right approach". Provider-neutral and repo-neutral; if a repo has its own project-specific `design-system` skill, use that for application details and this for the underlying model.
---

# How to think about a design system

## The one principle

Organise by **altitude** (how composed a thing is), never by **artifact type**. A list like "tables, forms, colors, textures" fails because it mixes a raw value (color), a rendering treatment (texture), a primitive component (table), and a multi-component composition (form). Re-sort every concern by how composed it is and it lands in one of four layers. This four-layer split is not a ratified spec; it is the common denominator across the major published design systems (Material 3, Shopify Polaris, IBM Carbon, Atlassian, GitHub Primer, Adobe Spectrum, GOV.UK), which converge on it under different names and with the boundaries drawn slightly differently. See "Where this comes from" at the end.

## The four layers

### 1. Foundations, encoded as tokens

The invisible, cross-cutting decisions every screen inherits: color, typography, spacing / sizing scale, layout / grid, elevation / shadow, motion (easing, duration), border radius, border width, opacity, breakpoints, iconography, and surface treatments (gradients, textures, noise, blur). These are expressed as **design tokens** in three tiers:

- **Primitive / global**: raw values with descriptive names, no meaning. `color-red-600 = oklch(...)`, `space-4 = 16px`. Just a palette.
- **Semantic / alias**: reference primitives by *role*. `color-bg-danger -> color-red-600`, `color-text-primary`. This is the tier components consume.
- **Component**: per-component overrides, only when a component needs to be themed independently. `button-bg-primary -> color-bg-danger`. Optional.

Tokens are the contract between design and code and the seam for every kind of theming (light / dark, brands, density). The W3C Design Tokens Community Group spec reached its first stable version (2025.10) in October 2025: a standard JSON format with Style Dictionary and Tokens Studio as the common tooling.

### 2. Components

Single reusable UI units with one job each: button, input / field, select, checkbox, radio, badge, avatar, card, table, tabs, dialog, sheet, tooltip, toast, breadcrumb. Each gets a fixed spec (this is exactly what **Open UI** standardises):

- **Anatomy / parts**: the named sub-elements (a Select has trigger, value, icon, listbox, option, group label).
- **Variants**: intentional alternatives, each with a rule for when to reach for it (primary / secondary / destructive; sm / md / lg).
- **States**: rest, hover, focus-visible, active, disabled, loading, invalid, selected, open / closed. Every interactive component answers the *same* state checklist.
- **Accessibility contract**: roles, keyboard model, focus management, ARIA wiring, contrast obligations.
- **Tokens consumed**: which semantic tokens it reads. Never raw primitives.
- **API**: props / slots, and what is deliberately not configurable.

**Atomic Design** (Brad Frost) is the finer-grained version of this idea: atoms -> molecules -> organisms -> templates -> pages. Most teams collapse it to "components" with an internal sense of simple versus composed; Carbon's "Level 1 / 2 / 3" is the same gradient. Treat it as vocabulary, not process.

### 3. Patterns

Recurring *compositions* that solve a whole user problem, spanning several components plus rules: forms (layout, labelling, validation timing, error summary, required / optional convention), data tables (sort, filter, paginate, row selection, bulk actions, empty / loading / error, column sizing), navigation, page templates, empty states, feedback / notifications, destructive-action confirmation, edit-in-drawer versus edit-in-page, search-and-autocomplete, multi-step flows. A pattern is usually *guidance plus a reference implementation*, not one shippable component.

This is where **Vitaly Friedman**'s work concentrates (Smart Interface Design Patterns, the data-table and multi-page-form deep-dives, a decision tree per component) and where **Alla Kholmatova**'s distinction lives: *functional patterns* (behaviour and structure) versus *perceptual patterns* (brand and visual style).

### 4. Guidelines and governance

The connective tissue that keeps layers 1 to 3 coherent over time: content voice and tone, writing style (capitalisation, dates, numbers, currency), the accessibility baseline and how it is tested, the **contribution model** (how something gets *into* the system, who reviews, what the bar is), versioning and deprecation, naming conventions, and a decision log recording why each resolution went the way it did. Kholmatova's "strict versus loose" and "modular versus integrated" are governance choices. This layer is what separates a design system from a component library.

## How the references relate

| Reference | What it actually gives you |
|---|---|
| Atomic Design (Brad Frost) | A decomposition vocabulary *within* layer 2, bleeding into 3. |
| W3C Design Tokens Community Group | The encoding standard for layer 1 (format, tiers, tooling). |
| Open UI (open-ui.org) | The spec template for layer 2 (anatomy / parts / states / behaviours + a11y), plus cross-system component research and a "design system analysis" guide. |
| Smashing / Vitaly Friedman / Kholmatova | The reasoning for layers 3 and 4: pattern depth, system character, governance. |
| Material, Polaris, Carbon, Primer, Spectrum, GOV.UK | Worked examples. Steal their layer names and their component specs, not their brand. |

## Placing a concern

| Concern | Layer(s) |
|---|---|
| Color values | 1: primitive + semantic tokens |
| Gradients / textures / noise / blur | 1: a "surfaces" or "elevation" foundation; tokenise if reused |
| Typography, spacing, motion durations | 1 |
| Icons | 1 (assets) + 2 (an `Icon` component) |
| Button, Badge, Input, Table (the primitive) | 2 |
| Data table (sort / filter / bulk / empty state) | 2 (`Table`) + 3 (the "data table" pattern) |
| Forms | 2 (`Field`, `Input`, `Select`) + 3 (the form pattern) + 4 (validation copy, required/optional convention) |
| Page header | 2 (`PageHeader` component) + 3 (page-template pattern) |
| Empty / loading / error states | 3 |
| Voice, tone, contribution bar, deprecation policy | 4 |

## Answering "is a small number of top-level buckets right?"

Yes. A small number is what the major systems do, and three to four is the usual count. The failure mode is not the count, it is cutting the buckets by artifact type instead of by altitude. Recommend: **Foundations & tokens -> Components -> Patterns -> Guidelines & governance.**

## Where this comes from

The four-layer model is a synthesis, not a published standard. What is directly verifiable is the primary navigation of the major design systems, which converge on it:

| System | Foundations-type section | Tokens | Components | Patterns | Content / governance |
|---|---|---|---|---|---|
| Material 3 | Foundations, Styles | under Styles | Components | under Foundations | Content design |
| Shopify Polaris | Foundations, Design | under Design | Components | Patterns | Content |
| IBM Carbon | Elements / Guidelines | under Elements | Components | Patterns | Guidelines |
| Atlassian | Foundations | under Foundations | Components | Patterns | Content |
| GitHub Primer | Foundations | Primitives | Components | UI Patterns, Scenario Patterns | Guides |
| Adobe Spectrum | Foundations | Tokens | Components | thin / scattered | Principles |
| GOV.UK | Styles | plain CSS vars | Components | Patterns | Community / contribution |

Honest caveats: a `Components` and a `Patterns` section is near-universal (Spectrum is the weak spot for patterns); a foundations-type layer is universal but its label is not (Foundations / Styles / Elements / Design); tokens are sometimes a top-level section and sometimes folded into foundations; the content/governance layer is explicit in roughly half and scattered in the rest. Separately codified and citable: the W3C Design Tokens spec (token tiering), Brad Frost's Atomic Design (the layer-2 decomposition vocabulary), Open UI (the component spec shape), and Alla Kholmatova's *Design Systems* (functional vs perceptual patterns, strict/loose, modular/integrated).
