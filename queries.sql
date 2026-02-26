-- =============================================================================
-- Cybersecurity Incident Management System
-- Analytical Queries
-- PostgreSQL
-- Run after schema.sql and seed.sql
-- =============================================================================

-- ---------------------------------------------------------------------------
-- 1. Incident Overview
--    List all incidents with analyst assignment and basic counts.
-- ---------------------------------------------------------------------------

SELECT
    i.incident_id,
    i.title,
    i.incident_type,
    i.severity,
    i.status,
    i.detected_at,
    i.resolved_at,
    COALESCE(a.first_name || ' ' || a.last_name, 'Unassigned') AS assigned_analyst,
    EXTRACT(EPOCH FROM (COALESCE(i.resolved_at, NOW()) - i.detected_at)) / 3600 AS hours_to_resolve
FROM incidents i
LEFT JOIN analysts a ON a.analyst_id = i.assigned_analyst_id
ORDER BY i.detected_at DESC;

-- ---------------------------------------------------------------------------
-- 2. Open / In-Progress Incidents (using the view)
-- ---------------------------------------------------------------------------

SELECT * FROM v_open_incidents
ORDER BY severity DESC, detected_at;

-- ---------------------------------------------------------------------------
-- 3. Incident Summary with Affected Assets and Remediation Progress
--    (uses the v_incident_summary view)
-- ---------------------------------------------------------------------------

SELECT
    incident_id,
    title,
    severity,
    status,
    analyst_name,
    affected_asset_count,
    exploited_vuln_count,
    remediation_action_count,
    completed_actions,
    ROUND(
        CASE WHEN remediation_action_count > 0
             THEN completed_actions::NUMERIC / remediation_action_count * 100
             ELSE 0
        END, 1
    ) AS remediation_pct
FROM v_incident_summary
ORDER BY severity DESC, incident_id;

-- ---------------------------------------------------------------------------
-- 4. Incidents by Severity (count breakdown)
-- ---------------------------------------------------------------------------

SELECT
    severity,
    COUNT(*)                                                    AS total,
    COUNT(*) FILTER (WHERE status = 'closed')                  AS closed,
    COUNT(*) FILTER (WHERE status = 'resolved')                AS resolved,
    COUNT(*) FILTER (WHERE status IN ('open', 'in_progress'))  AS still_open
FROM incidents
GROUP BY severity
ORDER BY
    CASE severity
        WHEN 'critical' THEN 1
        WHEN 'high'     THEN 2
        WHEN 'medium'   THEN 3
        WHEN 'low'      THEN 4
    END;

-- ---------------------------------------------------------------------------
-- 5. Analyst Workload — incidents assigned per analyst
-- ---------------------------------------------------------------------------

SELECT
    a.analyst_id,
    a.first_name || ' ' || a.last_name  AS analyst_name,
    a.role,
    a.department,
    COUNT(i.incident_id)                AS total_incidents,
    COUNT(i.incident_id) FILTER (WHERE i.status IN ('open', 'in_progress'))  AS active_incidents,
    COUNT(i.incident_id) FILTER (WHERE i.severity = 'critical')              AS critical_incidents
FROM analysts a
LEFT JOIN incidents i ON i.assigned_analyst_id = a.analyst_id
GROUP BY a.analyst_id
ORDER BY active_incidents DESC, total_incidents DESC;

-- ---------------------------------------------------------------------------
-- 6. Mean Time to Resolve (MTTR) per incident type
-- ---------------------------------------------------------------------------

SELECT
    incident_type,
    COUNT(*)                                                            AS total_incidents,
    COUNT(*) FILTER (WHERE resolved_at IS NOT NULL)                    AS resolved_count,
    ROUND(AVG(
        EXTRACT(EPOCH FROM (resolved_at - detected_at)) / 3600.0
    ) FILTER (WHERE resolved_at IS NOT NULL), 2)                       AS avg_hours_to_resolve,
    ROUND(MIN(
        EXTRACT(EPOCH FROM (resolved_at - detected_at)) / 3600.0
    ) FILTER (WHERE resolved_at IS NOT NULL), 2)                       AS min_hours,
    ROUND(MAX(
        EXTRACT(EPOCH FROM (resolved_at - detected_at)) / 3600.0
    ) FILTER (WHERE resolved_at IS NOT NULL), 2)                       AS max_hours
FROM incidents
GROUP BY incident_type
ORDER BY avg_hours_to_resolve DESC NULLS LAST;

-- ---------------------------------------------------------------------------
-- 7. Most Affected Assets
--    Assets that appear in the most incidents.
-- ---------------------------------------------------------------------------

SELECT
    a.asset_id,
    a.asset_name,
    a.asset_type,
    a.criticality,
    a.owner_department,
    COUNT(ia.incident_id) AS incident_count
FROM assets a
JOIN incident_assets ia ON ia.asset_id = a.asset_id
GROUP BY a.asset_id
ORDER BY incident_count DESC, a.criticality DESC;

-- ---------------------------------------------------------------------------
-- 8. Most Exploited Vulnerabilities
-- ---------------------------------------------------------------------------

SELECT
    v.vulnerability_id,
    COALESCE(v.cve_id, 'N/A')   AS cve_id,
    v.title,
    v.severity,
    v.cvss_score,
    COUNT(iv.incident_id)        AS times_exploited
FROM vulnerabilities v
JOIN incident_vulnerabilities iv ON iv.vulnerability_id = v.vulnerability_id
GROUP BY v.vulnerability_id
ORDER BY times_exploited DESC, v.cvss_score DESC;

-- ---------------------------------------------------------------------------
-- 9. Remediation Action Status Summary (per incident)
-- ---------------------------------------------------------------------------

SELECT
    i.incident_id,
    i.title,
    i.status              AS incident_status,
    ra.action_type,
    ra.status             AS action_status,
    COALESCE(a.first_name || ' ' || a.last_name, 'Unassigned') AS assigned_to,
    ra.scheduled_at,
    ra.completed_at
FROM remediation_actions ra
JOIN incidents i ON i.incident_id = ra.incident_id
LEFT JOIN analysts a ON a.analyst_id = ra.analyst_id
ORDER BY i.incident_id, ra.action_id;

-- ---------------------------------------------------------------------------
-- 10. Pending Remediation Actions (actionable backlog)
-- ---------------------------------------------------------------------------

SELECT
    ra.action_id,
    i.incident_id,
    i.title             AS incident_title,
    i.severity          AS incident_severity,
    ra.action_type,
    ra.description,
    ra.status,
    ra.scheduled_at,
    COALESCE(a.first_name || ' ' || a.last_name, 'Unassigned') AS assigned_to
FROM remediation_actions ra
JOIN incidents i ON i.incident_id = ra.incident_id
LEFT JOIN analysts a ON a.analyst_id = ra.analyst_id
WHERE ra.status IN ('pending', 'in_progress')
ORDER BY
    CASE i.severity
        WHEN 'critical' THEN 1
        WHEN 'high'     THEN 2
        WHEN 'medium'   THEN 3
        WHEN 'low'      THEN 4
    END,
    ra.scheduled_at NULLS LAST;

-- ---------------------------------------------------------------------------
-- 11. Assets with No Incidents (clean assets)
-- ---------------------------------------------------------------------------

SELECT
    a.asset_id,
    a.asset_name,
    a.asset_type,
    a.criticality,
    a.owner_department
FROM assets a
WHERE NOT EXISTS (
    SELECT 1 FROM incident_assets ia WHERE ia.asset_id = a.asset_id
)
ORDER BY a.criticality DESC, a.asset_name;

-- ---------------------------------------------------------------------------
-- 12. Incidents involving Critical assets
-- ---------------------------------------------------------------------------

SELECT
    i.incident_id,
    i.title             AS incident_title,
    i.severity          AS incident_severity,
    i.status,
    a.asset_name,
    a.criticality       AS asset_criticality,
    ia.impact_description
FROM incidents i
JOIN incident_assets ia ON ia.incident_id = i.incident_id
JOIN assets a           ON a.asset_id     = ia.asset_id
WHERE a.criticality = 'critical'
ORDER BY i.detected_at DESC;

-- ---------------------------------------------------------------------------
-- 13. Vulnerabilities with CVSS >= 9 that have been exploited
-- ---------------------------------------------------------------------------

SELECT
    v.cve_id,
    v.title,
    v.severity,
    v.cvss_score,
    v.affected_software,
    COUNT(iv.incident_id) AS times_exploited,
    STRING_AGG(i.title, '; ' ORDER BY i.detected_at) AS incident_titles
FROM vulnerabilities v
JOIN incident_vulnerabilities iv ON iv.vulnerability_id = v.vulnerability_id
JOIN incidents i                 ON i.incident_id       = iv.incident_id
WHERE v.cvss_score >= 9.0
GROUP BY v.vulnerability_id
ORDER BY v.cvss_score DESC;

-- ---------------------------------------------------------------------------
-- 14. Incidents per month (trend over time)
-- ---------------------------------------------------------------------------

SELECT
    DATE_TRUNC('month', detected_at)  AS month,
    COUNT(*)                           AS total_incidents,
    COUNT(*) FILTER (WHERE severity = 'critical') AS critical_count,
    COUNT(*) FILTER (WHERE severity = 'high')     AS high_count
FROM incidents
GROUP BY DATE_TRUNC('month', detected_at)
ORDER BY month;

-- ---------------------------------------------------------------------------
-- 15. Full Incident Detail — correlated subqueries + aggregations
--     For a given incident, show all linked assets, vulnerabilities,
--     and remediation actions in a single combined result set.
-- ---------------------------------------------------------------------------

-- Assets affected by incident #5
SELECT 'asset' AS entity_type,
       a.asset_name  AS name,
       a.asset_type::TEXT AS category,
       ia.impact_description AS notes
FROM incident_assets ia
JOIN assets a ON a.asset_id = ia.asset_id
WHERE ia.incident_id = 5

UNION ALL

-- Vulnerabilities exploited in incident #5
SELECT 'vulnerability',
       COALESCE(v.cve_id, 'INTERNAL') || ' – ' || v.title,
       v.severity::TEXT,
       'CVSS: ' || COALESCE(v.cvss_score::TEXT, 'N/A')
FROM incident_vulnerabilities iv
JOIN vulnerabilities v ON v.vulnerability_id = iv.vulnerability_id
WHERE iv.incident_id = 5

UNION ALL

-- Remediation actions for incident #5
SELECT 'remediation',
       ra.action_type::TEXT,
       ra.status::TEXT,
       ra.description
FROM remediation_actions ra
WHERE ra.incident_id = 5
ORDER BY entity_type, name;
