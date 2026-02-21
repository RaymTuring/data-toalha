# M365 Structure Framework - Xpirit AI Global Organization
# Generated: 2026-02-21 | Tenant: xpirit.ai (e4f4753f-2064-4a7a-a66d-8296c53099d7)

## 1. Organizational Hierarchy - 5 Autonomous Units (Pillars)

| # | AU Name | Code | Focus | Group Prefix | User UPN Pattern |
|---|---------|------|-------|-------------|-----------------|
| 1 | Xpirit AI | ARCH | Cloud/Tech/AI Architecture | XP-ARCH- | xp.arch##@xpirit.ai |
| 2 | Advanced Cybersecurity | SEC | Security/SOC/Compliance | XP-SEC- | xp.sec##@xpirit.ai |
| 3 | Macrobiotic Sustainability | BIO | Sustainability/Environment | XP-BIO- | xp.bio.specialist##@xpirit.ai |
| 4 | Operational Excellence | OPS | DevOps/Monitoring/SRE | XP-OPS- | xp.ops##@xpirit.ai |
| 5 | Data Toalha | DATA | Sales/Elections/Polling | XP-DATA-, DT- | dt.field.XX@xpirit.ai |

### Cross-Cutting Ventures
| Venture | Code | Scope | Group Prefix |
|---------|------|-------|-------------|
| Scientific Church | SC | Community/Social | SC- |
| MC Jesus | MCJ | Arts/YouTube/Media | MCJ- |
| WSRO | WSRO | Governance/Intergovernmental | WSRO- |

## 2. Naming Conventions (MANDATORY)

### Users (UPN)
```
PATTERN: {prefix}.{role}.{qualifier}@xpirit.ai
DISPLAY: {AU-Code} {Role} {Qualifier}

EXAMPLES:
- xp.arch.01@xpirit.ai     -> "XP-ARCH Engineer 01"
- dt.field.BR@xpirit.ai     -> "DT-DATA Field Collector BR"
- dt.lead.BR@xpirit.ai      -> "DT-DATA Lead BR"
- dt.rm.LATAM.1@xpirit.ai   -> "DT-DATA Regional Mgr LATAM 1"
- xp.sec.analyst.01@xpirit.ai -> "XP-SEC Analyst 01"
- eng.jr.01@xpirit.ai       -> "XP-ENG Junior Engineer 01"
- bigtech-employee001@xpirit.ai -> "BigTech-Employee-001" (placeholder batch)
```

### Groups
```
COUNTRY GROUPS (3 parallel schemes):
- XP-GLO-{CountryName}               (Global presence, mail-enabled)
- DT-Country-{CountryName}           (Data Toalha operations)
- XP-DATA-Polling-Country-{CountryName} (Polling specific)

CONTINENT PARENTS:
- XP-GLO-CONT-{Continent}            (7: Africa, Asia, Europe, North-America, South-America, Oceania, Antarctica)

REGION PARENTS:
- XP-DATA-Polling-Region-{Region}    (6: Africa, Americas, Asia, Europe, Oceania, Polar)

DEPARTMENT GROUPS (per pillar):
- {AU-Code}-DEPT-{Department}         (e.g., ARCH-DEPT-Engineering)

FUNCTIONAL GROUPS:
- {AU-Code}-GRP-{Function}           (e.g., XP-SEC-GRP-Cybersecurity)

FIELD OFFICES:
- DT-FieldOffice-{StateCode}         (Brazilian state codes: AC, AL, AM... TO)
```

### Country Name Rules
- Use English common name (not ISO official)
- Hyphens for multi-word: `Bosnia-and-Herzegovina` not `Bosnia and Herzegovina`
- No parentheses, no special characters
- Reference: ISO 3166-1 alpha-2 for codes, UN M49 for classification

## 3. Current State & Issues Found

### Users: 297 total
| Category | Count | Pattern | Status |
|----------|-------|---------|--------|
| BigTech-Employee batch | ~6 | bigtech-employee###@xpirit.ai | OK but needs dept assignment |
| BigTech-User batch | ~1 | bigtech.user##@xpirit.ai | NAMING CONFLICT with above |
| DT Field Collectors | ~52 | dt.field.XX@xpirit.ai | OK |
| DT Leads | ~52 | dt.lead.XX@xpirit.ai | OK |
| DT Regional Mgrs | ~20 | dt.rm.REGION.#@xpirit.ai | OK |
| XP Engineers | ~28 | eng.jr.#@xpirit.ai | OK |
| XP Architects | ~20 | xp.arch#@xpirit.ai | OK |
| Service accounts | ~10 | Various | Need standardization |
| Executive | ~5 | Various | OK |

### DUPLICATES FOUND (Users)
| Display Name | Count | Action |
|-------------|-------|--------|
| DT PA Collector/Lead | 2 each | DELETE duplicate |
| DT PB Collector/Lead | 2 each | DELETE duplicate |
| DT PE Collector/Lead | 2 each | DELETE duplicate |
| DT PI Collector/Lead | 2 each | DELETE duplicate |
| DT PR Collector/Lead | 2 each | DELETE duplicate |
| DT RJ Collector | 2 | DELETE duplicate |
| DT RN Collector/Lead | 2 each | DELETE duplicate |
| DT RO Collector/Lead | 2 each | DELETE duplicate |
| Wilson Matheus Lima Borba | 2 | MERGE/DELETE duplicate |
| Saulo Hutter | 2 | MERGE/DELETE duplicate |
| Eduardo Ewerton | 2 | MERGE/DELETE duplicate |

### Groups: 416 total
| Category | Count | Pattern | Status |
|----------|-------|---------|--------|
| XP-GLO-{Country} | 107 | Global country groups | INCOMPLETE (need 195) |
| DT-Country-{Country} | 136 | DT country groups | INCOMPLETE + DUPLICATES |
| XP-DATA-Polling-Country | 44 | Polling country | INCOMPLETE (need 195) |
| XP-GLO-CONT-{Continent} | 7 | Continent parents | COMPLETE |
| XP-DATA-Polling-Region | 6 | Region parents | COMPLETE |
| DT-FieldOffice | 9 | Brazilian offices | NEED 27 (all states) |
| Department groups | ~5 | HR, Marketing, etc. | INCOMPLETE |
| Pillar groups | ~10 | XP-ARCH-, XP-SEC-, etc. | OK |

### DUPLICATES FOUND (Groups - CRITICAL)
| Group Name | Count | Action |
|-----------|-------|--------|
| DT-Country-Bouvet Island | 3 | DELETE 2 |
| DT-Country-Bosnia and Herzegovina | 3 | DELETE 2, RENAME to hyphens |
| DT-Country-Antigua and Barbuda | 3 | DELETE 2, RENAME to hyphens |
| DT-Country-American Samoa | 3 | DELETE 2 |
| DT-Country-Aland Islands | 3 | DELETE 2 |
| MC-Jesus-Legacy-Archive-2006 | 2 | DELETE 1 |
| DT-Country-B* (many) | 2 each | DELETE duplicates |

## 4. Department Template (Per AU/Country)

Standard departments to create for each Administrative Unit:

| # | Department | Group Pattern | Key Roles |
|---|-----------|--------------|-----------|
| 1 | Executive & Governance | {AU}-DEPT-Executive | Director, VP, Board Rep |
| 2 | Engineering & Tech | {AU}-DEPT-Engineering | Architects, Developers, SRE |
| 3 | Security & Compliance | {AU}-DEPT-Security | Analysts, Auditors, GRC |
| 4 | Operations | {AU}-DEPT-Operations | Ops Managers, Support |
| 5 | HR & People | {AU}-DEPT-HR | Recruiters, L&D, HRBP |
| 6 | Finance & Accounting | {AU}-DEPT-Finance | Controllers, Tax, FP&A |
| 7 | Legal | {AU}-DEPT-Legal | Counsel, Compliance Officers |
| 8 | Marketing & PR | {AU}-DEPT-Marketing | Communications, Brand |
| 9 | Sales & Business Dev | {AU}-DEPT-Sales | Account Mgrs, BDMs |
| 10 | IT Infrastructure | {AU}-DEPT-IT | SysAdmin, Network, DBA |

## 5. Targets

| Metric | Current | Target | Gap |
|--------|---------|--------|-----|
| Total Users | 297 | 1,000+ | 703+ |
| XP-GLO Country Groups | 107 | 195 | 88 |
| DT-Country Groups | 136 | 195 | 59 |
| Polling Country Groups | 44 | 195 | 151 |
| Department Groups per AU | ~1 | 10 per AU (50 total) | ~45 |
| DT Field Offices (Brazil) | 9 | 27 | 18 |
| Mail-Enabled Groups | ~5 | All country groups | ~400+ |

## 6. Entra ID Service Limits

| Limit | Value | Current Usage |
|-------|-------|---------------|
| Conditional Access policies | 195 max | TBD |
| Role-assignable groups | 500 max | Low |
| Dynamic groups + dynamic AUs | 15,000 combined | Low |
| Users per tenant | 50,000 (free) | 297 |
| Groups per tenant | 500,000 | 416 |

## 7. Bot Task Scheduling Rules

When bots create M365 resources via hourly cron:
1. **Batch size**: Max 25 operations per hour (Azure rate limits)
2. **Error handling**: Log failure, notify group, skip to next task
3. **Deduplication**: Check if resource exists before creating
4. **Naming**: MUST follow conventions above
5. **Mail-enabled**: Country groups should be mail-enabled for document sharing
6. **Security groups**: Department groups should be security-enabled
7. **Verification**: After creation, verify with az ad group show / az ad user show
