# acceptance-tests.md - How "Done" is Verified

## Quality Gates (Loop Termination)

The iterative loop continues until:

### GATE 1: Implementation Guidance
- [ ] Architecture described: components, boundaries, data flow
- [ ] API specified: agent messages, abstractions, verification
- [ ] Data model: tables, fields, types, relationships
- [ ] Tasks: broken down, assigned, acceptance criteria written

### GATE 2: Coverage Complete
- [ ] All requirements → tasks (trace each requirement)
- [ ] Non-goals explicit (listed and justified)
- [ ] Risks identified + mitigations
- [ ] Test plan + acceptance criteria
- [ ] Deployment strategy

### GATE 3: No Blockers
- [ ] open-questions.md empty OR has mitigations
- [ ] Architecture/API/tasks are consistent (no contradictions)
- [ ] All agent responsibilities clear + non-overlapping
- [ ] All dependencies explicit

### GATE 4: Actionable
- [ ] Developer could pick any task and start coding
- [ ] Agent interfaces concrete (not "something like X")
- [ ] Milestones sequenced (MVP → V1 → V2)
- [ ] Edge cases enumerated

## Unit Tests

### [Component/Feature]
- [ ] Test 1
- [ ] Test 2
- [ ] Test 3

## Integration Tests

### [Workflow]
- [ ] Test 1
- [ ] Test 2

## System Tests

### Performance
- [ ] Latency <2s (95th percentile)
- [ ] Memory usage within limits

### Security
- [ ] No data leakage
- [ ] Encryption at rest and in transit
- [ ] Access controls enforced

## User Acceptance Tests

### [Feature]
- [ ] User survey: positive feedback
- [ ] Approval rate >85%
