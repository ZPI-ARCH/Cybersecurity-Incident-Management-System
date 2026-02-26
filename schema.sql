-- =============================================================================
-- Cybersecurity Incident Management System
-- Database Schema (DDL)
-- PostgreSQL
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Custom ENUM types
-- -----------------------------------------------------------------------------

CREATE TYPE analyst_role AS ENUM (
    'junior',
    'senior',
    'lead',
    'manager'
);

CREATE TYPE asset_type AS ENUM (
    'server',
    'workstation',
    'network_device',
    'database',
    'application',
    'mobile_device',
    'cloud_resource'
);

CREATE TYPE criticality_level AS ENUM (
    'low',
    'medium',
    'high',
    'critical'
);

CREATE TYPE severity_level AS ENUM (
    'low',
    'medium',
    'high',
    'critical'
);

CREATE TYPE incident_type AS ENUM (
    'malware',
    'phishing',
    'data_breach',
    'dos',
    'unauthorized_access',
    'insider_threat',
    'ransomware',
    'other'
);

CREATE TYPE incident_status AS ENUM (
    'open',
    'in_progress',
    'resolved',
    'closed'
);

CREATE TYPE action_type AS ENUM (
    'patch',
    'isolate',
    'block_ip',
    'reset_credentials',
    'backup_restore',
    'config_change',
    'scan',
    'monitor',
    'other'
);

CREATE TYPE action_status AS ENUM (
    'pending',
    'in_progress',
    'completed',
    'failed'
);

-- -----------------------------------------------------------------------------
-- Table: analysts
-- Security analysts who investigate and respond to incidents.
-- -----------------------------------------------------------------------------

CREATE TABLE analysts (
    analyst_id   SERIAL          PRIMARY KEY,
    first_name   VARCHAR(100)    NOT NULL,
    last_name    VARCHAR(100)    NOT NULL,
    email        VARCHAR(255)    NOT NULL UNIQUE,
    phone        VARCHAR(30),
    department   VARCHAR(100)    NOT NULL,
    role         analyst_role    NOT NULL DEFAULT 'junior',
    created_at   TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- Table: assets
-- IT assets that may be affected by security incidents.
-- -----------------------------------------------------------------------------

CREATE TABLE assets (
    asset_id           SERIAL            PRIMARY KEY,
    asset_name         VARCHAR(200)      NOT NULL,
    asset_type         asset_type        NOT NULL,
    ip_address         INET,
    hostname           VARCHAR(255),
    os                 VARCHAR(100),
    location           VARCHAR(200),
    owner_department   VARCHAR(100)      NOT NULL,
    criticality        criticality_level NOT NULL DEFAULT 'medium',
    created_at         TIMESTAMPTZ       NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_asset_has_identifier CHECK (
        ip_address IS NOT NULL OR hostname IS NOT NULL
    )
);

-- -----------------------------------------------------------------------------
-- Table: vulnerabilities
-- Known security vulnerabilities (CVEs or internal findings).
-- -----------------------------------------------------------------------------

CREATE TABLE vulnerabilities (
    vulnerability_id    SERIAL          PRIMARY KEY,
    cve_id              VARCHAR(20)     UNIQUE,          -- e.g. CVE-2021-44228
    title               VARCHAR(300)    NOT NULL,
    description         TEXT,
    severity            severity_level  NOT NULL,
    cvss_score          NUMERIC(3, 1)   CHECK (cvss_score BETWEEN 0.0 AND 10.0),
    affected_software   VARCHAR(300),
    published_date      DATE,
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- Table: incidents
-- Security incidents detected within the organisation.
-- -----------------------------------------------------------------------------

CREATE TABLE incidents (
    incident_id           SERIAL           PRIMARY KEY,
    title                 VARCHAR(300)     NOT NULL,
    description           TEXT,
    incident_type         incident_type    NOT NULL,
    status                incident_status  NOT NULL DEFAULT 'open',
    severity              severity_level   NOT NULL,
    detected_at           TIMESTAMPTZ      NOT NULL,
    reported_at           TIMESTAMPTZ      NOT NULL DEFAULT NOW(),
    resolved_at           TIMESTAMPTZ,
    assigned_analyst_id   INT              REFERENCES analysts (analyst_id)
                                               ON DELETE SET NULL,
    created_at            TIMESTAMPTZ      NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_resolved_after_detected CHECK (
        resolved_at IS NULL OR resolved_at >= detected_at
    )
);

-- -----------------------------------------------------------------------------
-- Table: incident_assets  (M : N — incidents ↔ assets)
-- Records which assets were affected by a given incident.
-- -----------------------------------------------------------------------------

CREATE TABLE incident_assets (
    incident_id          INT     NOT NULL REFERENCES incidents      (incident_id) ON DELETE CASCADE,
    asset_id             INT     NOT NULL REFERENCES assets         (asset_id)    ON DELETE CASCADE,
    impact_description   TEXT,

    PRIMARY KEY (incident_id, asset_id)
);

-- -----------------------------------------------------------------------------
-- Table: incident_vulnerabilities  (M : N — incidents ↔ vulnerabilities)
-- Records which vulnerabilities were exploited in a given incident.
-- -----------------------------------------------------------------------------

CREATE TABLE incident_vulnerabilities (
    incident_id        INT   NOT NULL REFERENCES incidents      (incident_id)     ON DELETE CASCADE,
    vulnerability_id   INT   NOT NULL REFERENCES vulnerabilities (vulnerability_id) ON DELETE CASCADE,

    PRIMARY KEY (incident_id, vulnerability_id)
);

-- -----------------------------------------------------------------------------
-- Table: remediation_actions
-- Actions taken (or planned) to remediate a security incident.
-- -----------------------------------------------------------------------------

CREATE TABLE remediation_actions (
    action_id       SERIAL         PRIMARY KEY,
    incident_id     INT            NOT NULL REFERENCES incidents (incident_id) ON DELETE CASCADE,
    analyst_id      INT            REFERENCES analysts (analyst_id) ON DELETE SET NULL,
    action_type     action_type    NOT NULL,
    description     TEXT           NOT NULL,
    status          action_status  NOT NULL DEFAULT 'pending',
    scheduled_at    TIMESTAMPTZ,
    completed_at    TIMESTAMPTZ,
    created_at      TIMESTAMPTZ    NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_completed_after_scheduled CHECK (
        completed_at IS NULL OR scheduled_at IS NULL OR completed_at >= scheduled_at
    )
);

-- -----------------------------------------------------------------------------
-- Indexes for common query patterns
-- -----------------------------------------------------------------------------

CREATE INDEX idx_incidents_status         ON incidents          (status);
CREATE INDEX idx_incidents_severity       ON incidents          (severity);
CREATE INDEX idx_incidents_assigned       ON incidents          (assigned_analyst_id);
CREATE INDEX idx_incidents_detected_at    ON incidents          (detected_at);
CREATE INDEX idx_remediation_incident     ON remediation_actions (incident_id);
CREATE INDEX idx_remediation_analyst      ON remediation_actions (analyst_id);
CREATE INDEX idx_remediation_status       ON remediation_actions (status);
CREATE INDEX idx_assets_criticality       ON assets             (criticality);
CREATE INDEX idx_vulnerabilities_severity ON vulnerabilities    (severity);
CREATE INDEX idx_vulnerabilities_cve      ON vulnerabilities    (cve_id);

-- -----------------------------------------------------------------------------
-- Views
-- -----------------------------------------------------------------------------

-- Open incidents with assigned analyst information
CREATE VIEW v_open_incidents AS
SELECT
    i.incident_id,
    i.title,
    i.incident_type,
    i.severity,
    i.status,
    i.detected_at,
    i.reported_at,
    a.analyst_id,
    a.first_name || ' ' || a.last_name AS analyst_name,
    a.email                            AS analyst_email
FROM incidents i
LEFT JOIN analysts a ON a.analyst_id = i.assigned_analyst_id
WHERE i.status IN ('open', 'in_progress');

-- Incident summary including affected asset count and remediation action count
CREATE VIEW v_incident_summary AS
SELECT
    i.incident_id,
    i.title,
    i.incident_type,
    i.severity,
    i.status,
    i.detected_at,
    i.resolved_at,
    a.first_name || ' ' || a.last_name               AS analyst_name,
    COUNT(DISTINCT ia.asset_id)                                           AS affected_asset_count,
    COUNT(DISTINCT iv.vulnerability_id)                                   AS exploited_vuln_count,
    COUNT(DISTINCT ra.action_id)                                          AS remediation_action_count,
    COUNT(DISTINCT ra.action_id) FILTER (WHERE ra.status = 'completed')   AS completed_actions
FROM incidents i
LEFT JOIN analysts          a  ON a.analyst_id       = i.assigned_analyst_id
LEFT JOIN incident_assets   ia ON ia.incident_id     = i.incident_id
LEFT JOIN incident_vulnerabilities iv ON iv.incident_id = i.incident_id
LEFT JOIN remediation_actions ra ON ra.incident_id   = i.incident_id
GROUP BY i.incident_id, a.analyst_id;
