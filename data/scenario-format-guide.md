# Scenario File Guide: how to write a scenario JSON

Every AI Architect game is one JSON file (for example `zoo.json`) that the engine loads. The file must follow `scenarios/schema.json`. This guide explains what the file needs, how to format it, and what type each field is.

Run `tools/validate.js` on every change. The schema catches structure and type mistakes, and the validator catches broken references (see "What the schema cannot check").

---

## 1. Ground rules

**JSON formatting**
- Use double quotes for all keys and strings. Single quotes are invalid.
- No comments and no trailing commas. JSON allows neither.
- Save as UTF-8. Use `\"` for a quote inside a string and `\n` for a line break.
- Numbers have no quotes. Use `2.5`, not `"2.5"`. Booleans are `true` or `false`, with no quotes.
- Optionally start the file with `"$schema": "./schema.json"` so editors can validate as you type.

**No extra fields.** Almost every object in the schema is closed (`additionalProperties: false`). A misspelled or invented key (`"labl"`, `"notes"`) fails validation. Put new ideas in the schema first, then in the file.

**Shared types used throughout**

| Type | Meaning | Rule |
|---|---|---|
| `id` | Stable identifier | String, 1-64 chars. Starts with a letter or digit. Then letters, digits, `_` or `-` only (no spaces). Example: `opt_llm`, `3A`, `ev_price` |
| `text` | Required display text | Non-empty string |
| `skillId` | One tracked skill | `"S1"` to `"S12"` exactly |
| `skillList` | List of skills | Array of `skillId`, no duplicates |
| `effects` | Meter changes | Object mapping a meter `id` to a number, e.g. `{ "privacy": -2.5, "budget": 1 }`. Negative numbers lower the meter |
| `rule` | Trigger condition | See section 4 |

IDs are written into research logs, so **never rename an ID after playtests start**. Bump `meta.version` whenever content changes.

---

## 2. Top-level structure

Nine sections are required. `variants` is optional.

| Section | Type | Required | What it holds |
|---|---|---|---|
| `$schema` | string | no | Path to the schema, for editor support |
| `meta` | object | **yes** | ID, title, type, difficulty, focus skills, time, version |
| `client` | object | **yes** | The brief, the stakeholders and their answers |
| `meters` | array (1+) | **yes** | Meters, start values, client targets |
| `rooms` | array (1+) | **yes** | Ordered rooms and their decisions |
| `options` | array (1+) | **yes** | Every selectable card, with hidden effects |
| `events` | array | **yes** | Six-months-later consequences (may be empty) |
| `risks` | array | **yes** | Trade-off check warnings (may be empty) |
| `blueprint` | object | **yes** | Diagram parts, layers, connections |
| `debrief` | object | **yes** | Reflection prompts and the expert design |
| `variants` | array | no | Replay variants with different hidden constraints |

Order inside the file does not matter to the engine, but keeping this order makes files easy to review.

---

## 3. Section reference

In the tables, **Req** means required. Types in `code`.

### 3.1 `meta`

| Field | Type | Req | Notes |
|---|---|---|---|
| `id` | `id` | yes | e.g. `evergreen-zoo` |
| `title` | `text` | yes | |
| `type` | string | yes | One of `classic`, `ML`, `GenAI`, `hybrid` (case-sensitive) |
| `difficulty` | string | yes | `intro`, `intermediate`, `advanced`, `capstone`, `interview` |
| `focusSkills` | `skillList` | yes | 1-4 skills the game targets. Used by the skill check |
| `estimatedMinutes` | integer | yes | 1 or more |
| `version` | string | yes | `major.minor.patch`, e.g. `"1.0.0"`. Written into every log |
| `touchedSkills` | `skillList` | no | Skills practiced but not the focus |
| `schemaVersion` | string | no | |
| `language` | string | no | Default `"en"` |

### 3.2 `client`

| Field | Type | Req | Notes |
|---|---|---|---|
| `name` | `text` | yes | Fictional organization only |
| `ask` | `text` | yes | One-line summary of the request |
| `brief` | `text` | yes | The full brief, reopenable by the player anytime |
| `stakeholders` | array (1+) | yes | See below |
| `sceneArt` | string | no | Path or name of art |
| `discovery` | object | no | `maxQuestions` (integer, 1 or more) and `criticalBonus` (an `effects` object, e.g. `{ "trust": 1 }` for each critical question asked) |

**Stakeholder** (each interview question):

| Field | Type | Req | Notes |
|---|---|---|---|
| `id` | `id` | yes | |
| `name` | `text` | yes | |
| `role` | `text` | yes | |
| `question` | `text` | yes | Full question (shown in the helper) |
| `answer` | `text` | yes | Full answer revealed when asked |
| `critical` | boolean | yes | `true` for the few most important questions |
| `shortQuestion`, `shortAnswer` | string | no | Card label and speech-bubble versions |
| `icon` | string | no | |
| `reveals` | string | no | Plain-language hidden constraint this uncovers |
| `revealsConstraint` | `id` | no | Machine ID of that constraint, usable in rules and variants |
| `skills` | `skillList` | no | |

### 3.3 `meters`

Each item:

| Field | Type | Req | Notes |
|---|---|---|---|
| `id` | `id` | yes | Used as the key in every `effects` object |
| `name` | `text` | yes | |
| `start` | number | yes | Usually 5 |
| `target` | number | yes | The client's target |
| `priority` | string | yes | `high`, `medium` or `low`. Hidden from the player. High-priority meters count toward the skill check |
| `min`, `max` | number | no | Default 0 and 10 |
| `warnBelow` | number | no | Default 3 (client warning) |
| `crisisAt` | number | no | Default 0 (crisis) |
| `icon`, `description` | string | no | |

### 3.4 `rooms` and decisions

Rooms are played **in the order listed**.

| Field | Type | Req | Notes |
|---|---|---|---|
| `id` | `id` | yes | |
| `title` | `text` | yes | |
| `kind` | string | yes | `brief`, `discovery`, `decisions`, `consequences`, `debrief`. Chooses which screen the engine shows |
| `goal` | `text` | yes | |
| `decisions` | array | **required when `kind` is `"decisions"`** | See below |
| `scene` | object | no | `{ "image": string, "alt": string }` |
| `helperText` | string | no | Why the room matters (helper notes) |
| `helperReaction` | array of strings | no | Short helper reactions after lock-in |
| `effortBudget` | integer, 0 or more | no | Effort points to spend across the room (e.g. 3 in the data room) |
| `reflectionPrompt` | string | no | The helper's question at this room's trade-off check |
| `tradeOffCheck` | object | no | `{ "enabled": boolean, "showRisks": boolean }`, both default `true`. `showRisks: false` hides risk warnings for more surprise |
| `skills` | `skillList` | no | |

**Decision** (inside `rooms[].decisions`):

| Field | Type | Req | Notes |
|---|---|---|---|
| `id` | `id` | yes | Options point to this |
| `prompt` | `text` | yes | The question the player answers |
| `selection` | string | yes | `single` or `multi` |
| `minPicks` | integer, 0 or more | no | |
| `maxPicks` | integer, 1 or more | no | e.g. `2` for monitoring tools |
| `dependsOn` | `rule` | no | Show this decision only when the rule is true |
| `locked` | boolean | no | Default `true`: cannot be changed after lock-in |
| `helperText` | string | no | |

### 3.5 `options`

Options live in one flat top-level list, not inside rooms. Each option names its decision.

| Field | Type | Req | Notes |
|---|---|---|---|
| `id` | `id` | yes | |
| `decision` | `id` | yes | The decision this card belongs to |
| `label` | `text` | yes | Short card label |
| `effects` | `effects` | yes | Meter changes. Use `{}` for none. **Hidden until lock-in** |
| `value` | string | no | Short word used in rules. Defaults to the option `id` |
| `hint`, `cost`, `speed` | string | no | Visible on the card. `cost` and `speed` are free-text cues (e.g. `"$$"`, `"Fast"`) |
| `helperText` | string | no | Full description for the helper |
| `icon` | string | no | |
| `effort` | number, 0 or more | no | Effort points this option uses. Default 0 |
| `tokens` | integer, 0 or more | no | Tokens earned if the option matches client priorities |
| `skills` | `skillList` | no | Skills this decision demonstrates |
| `reaction` | string | no | Helper reaction after choosing |
| `when` | array | no | Extra effects only if a rule is true: `[{ "if": rule, "effects": effects }]`. Both keys are required in each item |

### 3.6 `events` (six months later)

| Field | Type | Req | Notes |
|---|---|---|---|
| `id` | `id` | yes | |
| `title` | `text` | yes | |
| `headline` | `text` | yes | News-style headline |
| `trigger` | `rule` | yes | When the event fires |
| `damage` | `effects` | yes | Meter changes if unmitigated |
| `story` | string | no | Full story for the helper |
| `mitigation` | object | no | `pilotMultiplier` and `monitoringMultiplier`, each a number from 0 to 1. Defaults 0.5 (pilot launch halves damage, matching monitoring halves it again) |
| `monitoringOption` | `id` | no | The monitoring option that would have caught it |
| `fix` | object | no | `label` (required), `cost` (**required**, an `effects` object), plus optional `description` and `recovers` (`effects`) |
| `icon` | string | no | |
| `skills` | `skillList` | no | |

### 3.7 `risks` (trade-off check warnings)

| Field | Type | Req | Notes |
|---|---|---|---|
| `id` | `id` | yes | |
| `text` | `text` | yes | Plain language. Hint at the problem without saying exactly what will happen |
| `trigger` | `rule` | yes | When the warning appears |
| `severity` | string | no | `low`, `medium`, `high`. Default `medium` |
| `blueprintPart` | `id` | no | The blueprint part that gets the red outline and "!" |
| `room` | `id` | no | Room after which it first shows |
| `relatedEvent` | `id` | no | The event it foreshadows (never shown to the player) |
| `skills` | `skillList` | no | |

### 3.8 `blueprint` (the live diagram)

Only `parts` is required.

- **`layers`**: array of `{ "id", "label" }`, listed in display order (both required).
- **`parts`**: array (1+), each with:
  - required: `id`, `label`
  - optional: `kind` (`client`, `load-balancer`, `app`, `cache`, `database`, `queue`, `service`, `model`, `vector-store`, `guardrail`, `human`, `monitor`, `storage`, `other`), `icon`, `layer` (a layer `id`), `position` (`{ "col": int, "row": int }`, each 0 or more), `initial` (`dashed` default, `hidden`, or `solid`)
  - `fills`: array of `{ "when": rule, "label"?: string, "visible"?: boolean }`. A part turns solid when a `when` rule is true. `label` renames it, and `visible: false` hides it. This is how choices shape the diagram.
- **`connections`**: array of `{ "from": id, "to": id, "label"?: string, "when"?: rule }`. Without `when`, the line is always drawn.

### 3.9 `debrief`

`reflectionPrompts` and `expertDesign` are required.

- **`reflectionPrompts`**: array (1+) of `{ "id", "text" }` (both required) plus optional `skills` and `minWords` (integer, 0 or more).
- **`expertDesign`**:
  - `choices` (**required**): object mapping a **decision id** to an **option id**, or an array of option ids for multi-select. Example: `{ "d_model": "opt_faq", "d_monitor": ["opt_review", "opt_cost"] }`
  - `askedQuestions`: array of stakeholder ids
  - `expectedEvents`: array of event ids (used by automated tests, e.g. "the expert design triggers E4 and E5 only")
- **`intro`**: string.
- **`rationale`**: either one string, or an object mapping an id to a string.
- **`reportCards`**: array of `{ "title": text, "when": rule, "description"?: string }` for style-based endings like "The Cautious Guardian".

### 3.10 `variants` (replays)

Each variant needs `id` and `title`. All other fields are optional overrides applied on top of the base game:

| Field | Type | Meaning |
|---|---|---|
| `description` | string | e.g. "a ferry is cancelled mid-sale" |
| `constraints` | array of `id` | Hidden constraints active in this variant |
| `stakeholderAnswers` | object | Stakeholder id to `{ answer, shortAnswer, reveals, revealsConstraint }` (all optional) |
| `eventTriggers` | object | Event id to a replacement `rule` |
| `extraEvents` | array of events | Events that exist only in this variant (same shape as section 3.6) |
| `optionEffects` | object | Option id to replacement `effects` |
| `teaser` | string | Replay hook shown after the debrief |

---

## 4. Trigger rules

Rules are used in `events[].trigger`, `risks[].trigger`, `decisions[].dependsOn`, `options[].when[].if`, blueprint `fills[].when` and `connections[].when`, `reportCards[].when`, and variant `eventTriggers`.

Each rule is an object that matches **exactly one** of these shapes. Do not mix keys from different shapes in one object. Combine them with `all`, `any` or `not` instead.

| Shape | Form | Notes |
|---|---|---|
| All | `{ "all": [rule, rule] }` | Array with at least 1 rule. True if every rule is true |
| Any | `{ "any": [rule, rule] }` | Array with at least 1 rule. True if any is true |
| Not | `{ "not": rule }` | |
| Choice | `{ "choice": "d_model", "is": "llm" }` | `choice` is a **decision id**. Add at least one of: `is`, `isNot` (string), `isAnyOf` (non-empty array of strings), `includes` (string, for multi-select), `answered` (boolean). Values match the option's `value` (or its `id` if no `value`) |
| Meter | `{ "meter": "privacy", "lt": 3 }` | `meter` is a meter id. Add at least one of `lt`, `lte`, `gt`, `gte` (numbers) |
| Asked | `{ "asked": "sh_director", "is": false }` | Was this stakeholder question asked? `is` defaults to `true` |
| Constraint | `{ "constraint": "price_accuracy", "active": true }` | Is this hidden constraint active in the current variant? `active` defaults to `true` |
| Always | `{ "always": true }` | Only the value `true` is allowed |

Example from the Build Brief format:

```json
{ "any": [
  { "choice": "3A", "is": "everything" },
  { "choice": "4D", "is": "name" }
] }
```

---

## 5. What the schema cannot check (`tools/validate.js` must)

JSON Schema checks shape and types only. The validator should also confirm:

- Every `id` is unique within its list, and rule/effect references point to real things:
  - `options[].decision` matches a real decision id
  - every key in any `effects` object is a meter id
  - `choice`, `asked`, `constraint`, `meter` in rules are real ids
  - `monitoringOption`, `blueprintPart`, `relatedEvent`, `room`, `layer`, and `from`/`to` in connections are real ids
  - `expertDesign.choices` points to real decisions and options that belong to them
- Each decision has at least two options, and `maxPicks` is not larger than the option count.
- The effort points of options do not make `effortBudget` impossible (e.g. all four decisions fully done costs 5 but the budget is 3, which is intended in Demo 1 but should be deliberate).
- `discovery.maxQuestions` is no larger than the number of stakeholders. Only the intended few are `critical`.
- At least one meter has `priority: high`, and each `focusSkills` skill is tagged on some option, reflection or event.
- Every `kind: "decisions"` room has decisions, and room order matches the intended game flow.

---

## 6. Checklist for a new scenario

1. Copy a working file (or the example below) and change `meta.id`, `title`, `type`, `focusSkills`, `version`.
2. Write the `client` brief and stakeholders. Mark the few critical questions and tag the hidden constraint each one reveals.
3. Define `meters`, with targets and hidden priorities (about 5 high and 3 medium for a GenAI-style game).
4. List the `rooms` in order, then each room's `decisions`.
5. Add `options` for every decision, with effects. Check that no single strategy wins every meter.
6. Write `events` and the `risks` that foreshadow them. Link them with `relatedEvent`, `monitoringOption` and `fix`.
7. Build the `blueprint` parts and `fills` so each key choice changes the diagram.
8. Write the `debrief`: reflection prompts and the expert design. Add the events the expert design is expected to trigger.
9. Optionally add a `variant` with different hidden constraints and triggers.
10. Run `tools/validate.js`. Keep all content fictional, with no real company names or people.

---

## 7. Minimal valid example

This small file passes the schema. A full scenario has many more options, events and parts, but the shape is the same.

```json
{
  "$schema": "./schema.json",
  "meta": {
    "id": "example-game",
    "title": "Example Scenario",
    "type": "GenAI",
    "difficulty": "intro",
    "focusSkills": ["S1", "S3"],
    "estimatedMinutes": 25,
    "version": "0.1.0"
  },
  "client": {
    "name": "Evergreen City Zoo",
    "ask": "A public visitor chatbot.",
    "brief": "We want a chatbot that answers visitor questions about hours, tickets and animals.",
    "stakeholders": [
      {
        "id": "sh_director",
        "name": "Dana",
        "role": "Executive director",
        "question": "What worries you most about a chatbot?",
        "answer": "It must never invent admission prices or free days.",
        "critical": true,
        "revealsConstraint": "price_accuracy"
      }
    ],
    "discovery": { "maxQuestions": 1, "criticalBonus": { "trust": 1 } }
  },
  "meters": [
    { "id": "budget", "name": "Budget", "start": 5, "target": 7, "priority": "high" },
    { "id": "trust", "name": "Stakeholder trust", "start": 5, "target": 7, "priority": "high" }
  ],
  "rooms": [
    { "id": "room_brief", "title": "Visitor Center", "kind": "brief", "goal": "Read the client's request." },
    { "id": "room_meeting", "title": "Meeting Room", "kind": "discovery", "goal": "Ask the questions that matter." },
    {
      "id": "room_studio",
      "title": "Architecture Studio",
      "kind": "decisions",
      "goal": "Pick a model for the visitor bot.",
      "decisions": [
        { "id": "d_model", "prompt": "Which model powers the visitor bot?", "selection": "single" }
      ],
      "reflectionPrompt": "What does this model give up in exchange for what it gains?"
    },
    { "id": "room_later", "title": "Six Months Later", "kind": "consequences", "goal": "See what your choices caused." },
    { "id": "room_debrief", "title": "Debrief Gallery", "kind": "debrief", "goal": "Compare your design with the expert's." }
  ],
  "options": [
    {
      "id": "opt_faq",
      "decision": "d_model",
      "value": "faq",
      "label": "FAQ bot",
      "hint": "Cheap and fast, but rigid.",
      "effects": { "budget": 1.5, "trust": -0.5 },
      "effort": 0,
      "skills": ["S3"]
    },
    {
      "id": "opt_llm",
      "decision": "d_model",
      "value": "llm",
      "label": "Cloud LLM",
      "hint": "Flexible, but can invent facts.",
      "effects": { "budget": -1, "trust": -1 },
      "skills": ["S11"]
    }
  ],
  "events": [
    {
      "id": "ev_price",
      "title": "Invented free day",
      "headline": "Zoo bot promises a free admission day that does not exist",
      "trigger": {
        "all": [
          { "choice": "d_model", "is": "llm" },
          { "asked": "sh_director", "is": false }
        ]
      },
      "damage": { "trust": -2 },
      "mitigation": { "pilotMultiplier": 0.5, "monitoringMultiplier": 0.5 },
      "fix": {
        "label": "Issue a public correction",
        "cost": { "budget": -1 },
        "recovers": { "trust": 1 }
      }
    }
  ],
  "risks": [
    {
      "id": "risk_invented_facts",
      "text": "A general-purpose model may answer confidently about things it was never given.",
      "trigger": { "choice": "d_model", "is": "llm" },
      "severity": "high",
      "blueprintPart": "part_model",
      "room": "room_studio",
      "relatedEvent": "ev_price"
    }
  ],
  "blueprint": {
    "layers": [
      { "id": "layer_users", "label": "Users" },
      { "id": "layer_assistants", "label": "Assistants" }
    ],
    "parts": [
      {
        "id": "part_visitors",
        "label": "Visitors",
        "kind": "client",
        "layer": "layer_users",
        "position": { "col": 0, "row": 0 },
        "initial": "solid"
      },
      {
        "id": "part_model",
        "label": "Visitor bot model",
        "kind": "model",
        "layer": "layer_assistants",
        "position": { "col": 0, "row": 0 },
        "initial": "dashed",
        "fills": [
          { "when": { "choice": "d_model", "is": "llm" }, "label": "Cloud LLM" },
          { "when": { "choice": "d_model", "is": "faq" }, "label": "FAQ bot" }
        ]
      }
    ],
    "connections": [{ "from": "part_visitors", "to": "part_model" }]
  },
  "debrief": {
    "intro": "Here is how your design compares with an expert's.",
    "reflectionPrompts": [
      { "id": "refl_1", "text": "Which trade-off did you find hardest, and why?", "skills": ["S3"], "minWords": 20 }
    ],
    "expertDesign": {
      "choices": { "d_model": "opt_faq" },
      "askedQuestions": ["sh_director"],
      "expectedEvents": []
    },
    "rationale": "A rule-based bot cannot invent prices, which the client cares about most."
  },
  "variants": [
    {
      "id": "variant_b",
      "title": "Variant B",
      "description": "The price constraint is stricter and fires more easily.",
      "constraints": ["price_accuracy"],
      "eventTriggers": { "ev_price": { "choice": "d_model", "is": "llm" } },
      "teaser": "Next time: the zoo's servers are in the basement and it floods."
    }
  ]
}
```
