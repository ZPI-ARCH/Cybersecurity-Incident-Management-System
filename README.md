# Cybersecurity Incident Management System

A relational database project built with **PostgreSQL** that models a real-world
cybersecurity incident management workflow.  
The system tracks security incidents, vulnerabilities, affected IT assets,
security analysts, and remediation actions.

---

## Entity-Relationship Overview

```
analysts ────────────────────────────────────────────────────────┐
  │ 1                                                             │ 1
  │ assigned_analyst_id                                           │ analyst_id
  │ N                                                             │ N
incidents ──── incident_assets ──── assets              remediation_actions
  │ N                                       
  │                                         
  └──── incident_vulnerabilities ──── vulnerabilities
```

### Tables

| Table | Description |
|-------|-------------|
| `analysts` | Security analysts who investigate and respond to incidents |
| `assets` | IT assets (servers, workstations, network devices, cloud resources, …) |
| `vulnerabilities` | Known vulnerabilities (CVEs or internal findings) with CVSS scores |
| `incidents` | Security incidents detected within the organisation |
| `incident_assets` | Many-to-many: which assets were affected by each incident |
| `incident_vulnerabilities` | Many-to-many: which vulnerabilities were exploited in each incident |
| `remediation_actions` | Actions taken (or planned) to resolve an incident |

### Views

| View | Description |
|------|-------------|
| `v_open_incidents` | All incidents with status `open` or `in_progress`, joined with analyst info |
| `v_incident_summary` | Per-incident aggregation of asset count, vulnerability count, and remediation progress |

---

## Project Structure

```
.
├── schema.sql   # DDL: ENUM types, tables, indexes, views
├── seed.sql     # DML: realistic sample data (10 analysts, 12 assets, 10 vulnerabilities, 10 incidents, …)
└── queries.sql  # 15 analytical SQL queries (reports, aggregations, joins, subqueries)
```

---

## Getting Started

### Prerequisites

- PostgreSQL 14 or later
- `psql` command-line client

### Setup

```bash
# 1. Create the database
psql -U postgres -c "CREATE DATABASE cims;"

# 2. Create all tables, indexes and views
psql -U postgres -d cims -f schema.sql

# 3. Load sample data
psql -U postgres -d cims -f seed.sql

# 4. Run the analytical queries
psql -U postgres -d cims -f queries.sql
```

---

## Sample Queries

The `queries.sql` file contains 15 ready-to-run analytical queries:

| # | Query | Concepts Used |
|---|-------|---------------|
| 1 | Incident overview with analyst assignment and hours-to-resolve | LEFT JOIN, `EXTRACT`, `COALESCE` |
| 2 | Open / in-progress incidents (view) | View |
| 3 | Incident summary with remediation % (view) | View, `ROUND`, `CASE` |
| 4 | Incidents by severity breakdown | `GROUP BY`, `COUNT … FILTER` |
| 5 | Analyst workload — active and critical incident counts | LEFT JOIN, aggregate filters |
| 6 | Mean Time to Resolve (MTTR) per incident type | `AVG … FILTER`, `EXTRACT(EPOCH …)` |
| 7 | Most affected assets | JOIN, `GROUP BY`, `ORDER BY` |
| 8 | Most exploited vulnerabilities | JOIN, aggregate |
| 9 | Full remediation action log per incident | Multi-table JOIN |
| 10 | Pending remediation backlog ordered by priority | `WHERE … IN`, `CASE` ordering |
| 11 | Assets with no incidents (clean assets) | `NOT EXISTS` correlated subquery |
| 12 | Incidents involving critical assets | JOIN with filter |
| 13 | Vulnerabilities with CVSS ≥ 9 that have been exploited | `WHERE`, `STRING_AGG` |
| 14 | Incident trend by month | `DATE_TRUNC`, `GROUP BY` |
| 15 | Full detail for one incident (assets + vulns + actions) | `UNION ALL` |

---

## Schema Highlights

- **ENUM types** for all categorical fields (`severity_level`, `incident_status`, `action_type`, etc.) to enforce domain integrity at the database level.
- **CHECK constraints** prevent logical impossibilities (e.g. `resolved_at` cannot be before `detected_at`; an asset must have at least an IP address or a hostname).
- **Indexes** on every foreign key and the most-queried filter columns (`status`, `severity`, `detected_at`).
- **Cascading deletes** from `incidents` to `incident_assets`, `incident_vulnerabilities`, and `remediation_actions`.
- **`ON DELETE SET NULL`** for analyst references so incident/action records are preserved if an analyst is removed.

