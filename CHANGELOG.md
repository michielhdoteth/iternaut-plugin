# Changelog

All notable changes to the iternaut-plugin.

## [Unreleased]

### Added
- iter-code-simplifier agent for code cleanup and refactoring
- PRD versioning support (.claude/prds/)
- Version registry (.prd-registry) for multiple PRDs
- PRD template with versioning fields
- Code simplifier checklist for systematic refactoring

### Changed
- Updated PRD location from `.claude/PRD.md` to `.claude/prds/*.md`
- Skills now read from `.claude/prds/` directory
- Support for PRD versioning and registry

### Fixed
- Removed Ralph Loop terminology (replaced with "Iterative")
- Updated descriptions to PRD-to-SHIPPED

## [1.0.0] - 2026-01-19

### Added
- Initial plugin release
- 12 subagents (researcher, architect, planner, coder, tester, debugger, documenter, reviewer, security-auditor, deployer, monitor, synthesizer)
- 2 skills (iter-agent, iter-agent-loop)
- 6 commands (plan, plan:iter, implement, review, debug, deploy)
- Auto progress tracking via hooks
- Artifact templates (decisions, risks, open-questions, acceptance-tests)
- Example PRDs (basic, full-stack, api)
- Scripts for loop and review automation

### Features
- Claude orchestrates, subagents do all work
- All subagents log to `.iter/progress.txt`
- Quality gates with SHIP/REVISE iteration
- File-based state management
