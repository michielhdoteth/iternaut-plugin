---
description: Deploy applications, configure CI/CD, and set up monitoring using iter-deployer and iter-monitor
---

# Iternaut Deploy Command

Deploy applications and configure production infrastructure.

## Usage

```
/iternaut:deploy [ENVIRONMENT]
```

## What It Does

1. iter-deployer sets up environment
2. Configures CI/CD pipeline
3. Deploys application
4. iter-monitor sets up observability
5. Runs smoke tests
6. Verifies health checks

## Example

```bash
/iternaut:deploy staging
/iternaut:deploy production
```

## Pre-Deployment Checklist

- [ ] All tests pass
- [ ] Code review approved
- [ ] Security scan passed
- [ ] Documentation updated
- [ ] Configuration validated

## Progress Logged

```
[TIMESTAMP] [AGENT:deployer] [PHASE:deployment] [STATUS:START] Deploying to staging
[TIMESTAMP] [AGENT:deployer] [PHASE:deployment] [STATUS:DONE] Deployed successfully
[TIMESTAMP] [AGENT:monitor] [PHASE:observability] [STATUS:DONE] Monitoring configured
```
