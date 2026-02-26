-- =============================================================================
-- Cybersecurity Incident Management System
-- Sample Data (DML)
-- PostgreSQL
-- Run after schema.sql
-- =============================================================================

-- -----------------------------------------------------------------------------
-- analysts
-- -----------------------------------------------------------------------------

INSERT INTO analysts (first_name, last_name, email, phone, department, role) VALUES
    ('Alice',   'Johnson',  'alice.johnson@corp.example',  '+1-555-0101', 'SOC',               'lead'),
    ('Bob',     'Martinez', 'bob.martinez@corp.example',   '+1-555-0102', 'SOC',               'senior'),
    ('Carol',   'Nguyen',   'carol.nguyen@corp.example',   '+1-555-0103', 'Threat Intelligence','senior'),
    ('David',   'Kim',      'david.kim@corp.example',      '+1-555-0104', 'SOC',               'junior'),
    ('Eva',     'Patel',    'eva.patel@corp.example',      '+1-555-0105', 'Incident Response', 'senior'),
    ('Frank',   'Chen',     'frank.chen@corp.example',     '+1-555-0106', 'Incident Response', 'lead'),
    ('Grace',   'Robinson', 'grace.robinson@corp.example', '+1-555-0107', 'Vulnerability Mgmt','senior'),
    ('Hiro',    'Tanaka',   'hiro.tanaka@corp.example',    '+1-555-0108', 'SOC',               'junior'),
    ('Irene',   'Müller',   'irene.muller@corp.example',   '+1-555-0109', 'Compliance',        'manager'),
    ('James',   'O''Brien', 'james.obrien@corp.example',   '+1-555-0110', 'SOC',               'senior');

-- -----------------------------------------------------------------------------
-- assets
-- -----------------------------------------------------------------------------

INSERT INTO assets (asset_name, asset_type, ip_address, hostname, os, location, owner_department, criticality) VALUES
    ('Primary Web Server',        'server',         '10.0.1.10',  'web01.corp.example',    'Ubuntu 22.04 LTS',  'DC-East',   'Engineering',   'critical'),
    ('Customer Database',         'database',       '10.0.1.20',  'db01.corp.example',     'PostgreSQL 15',     'DC-East',   'Engineering',   'critical'),
    ('HR Workstation #1',         'workstation',    '10.0.2.101', 'hr-ws-01.corp.example', 'Windows 11',        'HQ-Floor3', 'HR',            'medium'),
    ('Finance Workstation #1',    'workstation',    '10.0.2.201', 'fin-ws-01.corp.example','Windows 11',        'HQ-Floor4', 'Finance',       'high'),
    ('Core Network Switch',       'network_device', '10.0.0.1',   'sw-core-01',            'Cisco IOS 15.2',    'DC-East',   'IT Operations', 'critical'),
    ('VPN Gateway',               'network_device', '203.0.113.1','vpn-gw-01.corp.example','pfSense 2.7',       'DC-East',   'IT Operations', 'high'),
    ('Internal Wiki (Confluence)','application',    '10.0.1.50',  'wiki.corp.example',     'Confluence 8.0',    'DC-West',   'IT Operations', 'medium'),
    ('Employee Mobile Device',    'mobile_device',  NULL,         'iphone-cfo-001',        'iOS 17',            'Remote',    'Executive',     'high'),
    ('AWS S3 Backup Bucket',      'cloud_resource', NULL,         's3://corp-backups',      'AWS S3',            'us-east-1', 'IT Operations', 'high'),
    ('Dev CI/CD Pipeline',        'application',    '10.0.1.80',  'cicd.corp.example',     'Jenkins 2.414',     'DC-West',   'Engineering',   'high'),
    ('Secondary Mail Server',     'server',         '10.0.1.15',  'mail02.corp.example',   'Postfix / Ubuntu',  'DC-West',   'IT Operations', 'high'),
    ('Payroll Application',       'application',    '10.0.2.250', 'payroll.corp.example',  'Windows Server 2019','HQ-Floor4','Finance',       'critical');

-- -----------------------------------------------------------------------------
-- vulnerabilities
-- -----------------------------------------------------------------------------

INSERT INTO vulnerabilities (cve_id, title, description, severity, cvss_score, affected_software, published_date) VALUES
    ('CVE-2021-44228', 'Log4Shell Remote Code Execution',
     'A critical RCE vulnerability in Apache Log4j 2 allows unauthenticated remote attackers to execute arbitrary code by logging a specially crafted string.',
     'critical', 10.0, 'Apache Log4j 2.0–2.14.1', '2021-12-10'),

    ('CVE-2021-34527', 'PrintNightmare Windows Print Spooler RCE',
     'A remote code execution vulnerability exists when the Windows Print Spooler service improperly performs privileged file operations.',
     'critical', 8.8, 'Windows Print Spooler', '2021-07-01'),

    ('CVE-2022-22965', 'Spring4Shell Spring Framework RCE',
     'A Spring MVC or Spring WebFlux application running on JDK 9+ may be vulnerable to RCE via data binding.',
     'critical', 9.8, 'Spring Framework < 5.3.18 / 5.2.20', '2022-03-31'),

    ('CVE-2023-23397', 'Microsoft Outlook Privilege Escalation',
     'An attacker can send a specially crafted email that triggers automatically when retrieved, leaking NTLM hashes without any user interaction.',
     'critical', 9.8, 'Microsoft Outlook 2013–2021', '2023-03-14'),

    ('CVE-2020-1472', 'Zerologon Netlogon Privilege Escalation',
     'A flaw in the Netlogon protocol allows an unauthenticated attacker to establish a Netlogon session and gain domain-admin privileges.',
     'critical', 10.0, 'Windows Server (Netlogon)', '2020-08-11'),

    ('CVE-2019-0708', 'BlueKeep RDP Remote Code Execution',
     'A pre-authentication, wormable RCE vulnerability in Remote Desktop Services.',
     'critical', 9.8, 'Windows 7 / Server 2008 R2 RDP', '2019-05-14'),

    (NULL, 'Misconfigured S3 Bucket – Public Read',
     'Internal investigation found that the AWS S3 backup bucket had public-read ACL enabled, exposing sensitive backup data.',
     'high', 7.5, 'AWS S3', '2024-01-15'),

    ('CVE-2023-44487', 'HTTP/2 Rapid Reset Attack (DoS)',
     'A flaw in HTTP/2 allows attackers to send a stream of HEADERS followed by RST_STREAM frames, exhausting server resources.',
     'high', 7.5, 'HTTP/2 servers (nginx, Apache, IIS, etc.)', '2023-10-10'),

    ('CVE-2022-30190', 'Follina MSDT Remote Code Execution',
     'A code execution vulnerability exists when MSDT is called using the URL protocol from a calling application such as Word.',
     'high', 7.8, 'Microsoft Windows MSDT', '2022-05-30'),

    ('CVE-2021-26855', 'Microsoft Exchange Server SSRF (ProxyLogon)',
     'An SSRF vulnerability in Exchange Server allows unauthenticated attackers to send arbitrary HTTP requests authenticated as the Exchange server.',
     'critical', 9.1, 'Microsoft Exchange Server 2013–2019', '2021-03-02');

-- -----------------------------------------------------------------------------
-- incidents
-- -----------------------------------------------------------------------------

INSERT INTO incidents (title, description, incident_type, status, severity, detected_at, reported_at, resolved_at, assigned_analyst_id) VALUES
    -- 1
    ('Log4Shell Exploitation on Web Server',
     'Attacker exploited Log4Shell (CVE-2021-44228) on the primary web server to establish a reverse shell. Malicious JNDI lookups were observed in access logs.',
     'malware', 'closed', 'critical',
     '2021-12-11 03:22:00+00', '2021-12-11 08:00:00+00', '2021-12-13 18:45:00+00', 1),

    -- 2
    ('Phishing Campaign Targeting Finance Staff',
     'A spear-phishing email campaign delivered malicious Excel attachments to 14 Finance department employees. Three users opened the attachment.',
     'phishing', 'resolved', 'high',
     '2023-03-15 09:10:00+00', '2023-03-15 09:45:00+00', '2023-03-17 16:00:00+00', 2),

    -- 3
    ('Ransomware Infection on HR Workstation',
     'LockBit ransomware detected on HR workstation. Files were encrypted before endpoint protection quarantined the process.',
     'ransomware', 'resolved', 'critical',
     '2023-08-22 14:05:00+00', '2023-08-22 14:30:00+00', '2023-08-25 11:00:00+00', 5),

    -- 4
    ('Misconfigured S3 Bucket Data Exposure',
     'AWS S3 backup bucket was found to have public-read ACL enabled. Sensitive backup archives were potentially accessible to unauthenticated users for an estimated 72 hours.',
     'data_breach', 'closed', 'high',
     '2024-01-15 11:00:00+00', '2024-01-15 13:00:00+00', '2024-01-16 09:00:00+00', 7),

    -- 5
    ('Unauthorized VPN Access from Unknown IP',
     'Multiple successful VPN logins from an unrecognized IP in Eastern Europe using a shared service account. Suspicious lateral movement observed.',
     'unauthorized_access', 'in_progress', 'high',
     '2024-06-03 01:15:00+00', '2024-06-03 02:00:00+00', NULL, 6),

    -- 6
    ('DDoS Attack via HTTP/2 Rapid Reset',
     'Web server experienced a sustained DDoS attack using the HTTP/2 Rapid Reset technique. Server load reached 98% for 45 minutes before mitigation.',
     'dos', 'closed', 'high',
     '2023-10-12 16:30:00+00', '2023-10-12 16:40:00+00', '2023-10-12 18:00:00+00', 2),

    -- 7
    ('Insider Data Exfiltration via USB',
     'A departing employee was detected copying sensitive customer records to a USB drive. DLP alert triggered.',
     'insider_threat', 'resolved', 'critical',
     '2024-02-08 11:45:00+00', '2024-02-08 12:00:00+00', '2024-02-09 17:00:00+00', 9),

    -- 8
    ('Spring4Shell Exploitation Attempt on CI/CD',
     'Attempted exploitation of Spring4Shell (CVE-2022-22965) detected on the internal CI/CD pipeline. Attack was blocked by WAF but follow-up patching required.',
     'malware', 'open', 'high',
     '2024-11-20 07:55:00+00', '2024-11-20 08:30:00+00', NULL, 10),

    -- 9
    ('Credential Stuffing Attack on Customer Portal',
     'Approximately 2,400 login attempts using credential-stuffing within a 10-minute window were detected on the customer portal.',
     'unauthorized_access', 'closed', 'medium',
     '2024-09-05 22:00:00+00', '2024-09-05 22:15:00+00', '2024-09-06 10:00:00+00', 4),

    -- 10
    ('ProxyLogon Exploitation on Mail Server',
     'Successful exploitation of CVE-2021-26855 on the secondary mail server. Attacker installed a web shell used for further reconnaissance.',
     'malware', 'closed', 'critical',
     '2021-03-05 05:30:00+00', '2021-03-05 07:00:00+00', '2021-03-08 20:00:00+00', 1);

-- -----------------------------------------------------------------------------
-- incident_assets
-- -----------------------------------------------------------------------------

INSERT INTO incident_assets (incident_id, asset_id, impact_description) VALUES
    -- Incident 1 — Log4Shell: web server + customer database
    (1, 1, 'Reverse shell established; attacker had read access to web app configuration files.'),
    (1, 2, 'Database credentials exposed via web server compromise; potential data access.'),

    -- Incident 2 — Phishing: Finance workstations
    (2, 4, 'Malicious macro executed; credential harvester installed on Finance workstation.'),

    -- Incident 3 — Ransomware: HR workstation
    (3, 3, 'User files encrypted by LockBit. System reimaged from clean backup.'),

    -- Incident 4 — S3 Data Breach
    (4, 9, 'Backup bucket exposed with public-read ACL for ~72 hours.'),

    -- Incident 5 — Unauthorised VPN: VPN gateway + finance workstation
    (5, 6, 'Service account used to authenticate through VPN gateway.'),
    (5, 4, 'Lateral movement observed targeting Finance department host.'),

    -- Incident 6 — DDoS: web server
    (6, 1, 'Web server saturated; legitimate requests dropped for ~45 minutes.'),

    -- Incident 7 — Insider: workstation
    (7, 3, 'USB mass storage device connected; large volume of data transferred.'),

    -- Incident 8 — Spring4Shell: CI/CD
    (8, 10, 'Exploitation attempt blocked by WAF; application unpatched at time of event.'),

    -- Incident 9 — Credential stuffing: web server
    (9, 1, 'Customer portal hosted on primary web server; ~130 accounts temporarily locked.'),

    -- Incident 10 — ProxyLogon: mail server
    (10, 11, 'Web shell installed; attacker conducted internal reconnaissance via mail server.');

-- -----------------------------------------------------------------------------
-- incident_vulnerabilities
-- -----------------------------------------------------------------------------

INSERT INTO incident_vulnerabilities (incident_id, vulnerability_id) VALUES
    (1, 1),   -- Log4Shell exploit
    (2, 9),   -- Follina used in phishing macro (CVE-2022-30190)
    (3, 2),   -- PrintNightmare leveraged for privilege escalation
    (4, 7),   -- Misconfigured S3 Bucket
    (5, 5),   -- Zerologon used after initial VPN access
    (6, 8),   -- HTTP/2 Rapid Reset
    (8, 3),   -- Spring4Shell
    (10, 10); -- ProxyLogon

-- -----------------------------------------------------------------------------
-- remediation_actions
-- -----------------------------------------------------------------------------

INSERT INTO remediation_actions (incident_id, analyst_id, action_type, description, status, scheduled_at, completed_at) VALUES
    -- Incident 1 — Log4Shell
    (1, 1,  'isolate',            'Isolated web server from network to stop active shell session.',
     'completed', '2021-12-11 08:30:00+00', '2021-12-11 08:45:00+00'),
    (1, 5,  'patch',              'Applied Log4j patch (2.15.0 → 2.17.1) on all Java services.',
     'completed', '2021-12-11 10:00:00+00', '2021-12-12 14:00:00+00'),
    (1, 2,  'scan',               'Full vulnerability scan on all servers post-patch.',
     'completed', '2021-12-12 15:00:00+00', '2021-12-13 18:00:00+00'),

    -- Incident 2 — Phishing
    (2, 2,  'block_ip',           'Blocked malicious sender domain and IP at email gateway.',
     'completed', '2023-03-15 10:00:00+00', '2023-03-15 10:15:00+00'),
    (2, 4,  'reset_credentials',  'Reset passwords and revoked active sessions for affected Finance users.',
     'completed', '2023-03-15 11:00:00+00', '2023-03-15 12:30:00+00'),
    (2, 5,  'scan',               'EDR scan on all Finance workstations to detect payload remnants.',
     'completed', '2023-03-16 09:00:00+00', '2023-03-17 15:00:00+00'),

    -- Incident 3 — Ransomware
    (3, 5,  'isolate',            'Isolated HR workstation from network immediately after detection.',
     'completed', '2023-08-22 14:10:00+00', '2023-08-22 14:15:00+00'),
    (3, 6,  'backup_restore',     'Restored HR workstation from last clean backup (T-1 day snapshot).',
     'completed', '2023-08-23 09:00:00+00', '2023-08-24 17:00:00+00'),
    (3, 4,  'reset_credentials',  'Reset all HR department credentials as precaution.',
     'completed', '2023-08-22 15:00:00+00', '2023-08-22 17:00:00+00'),

    -- Incident 4 — S3 Exposure
    (4, 7,  'config_change',      'Removed public-read ACL from S3 bucket and enabled bucket policy blocking public access.',
     'completed', '2024-01-15 13:30:00+00', '2024-01-15 14:00:00+00'),
    (4, 7,  'monitor',            'Enabled S3 server access logging and CloudTrail for the bucket.',
     'completed', '2024-01-15 14:00:00+00', '2024-01-15 15:30:00+00'),

    -- Incident 5 — Unauthorised VPN (in_progress)
    (5, 6,  'block_ip',           'Blocked suspicious source IP at VPN gateway firewall.',
     'completed', '2024-06-03 02:15:00+00', '2024-06-03 02:30:00+00'),
    (5, 6,  'reset_credentials',  'Disabled shared service account and issued individual certificates.',
     'completed', '2024-06-03 03:00:00+00', '2024-06-03 04:00:00+00'),
    (5, 10, 'monitor',            'Increased VPN log verbosity; set up SIEM alert for off-hours logins.',
     'in_progress', '2024-06-04 09:00:00+00', NULL),
    (5, 1,  'scan',               'Full network scan to identify any persistence mechanisms left by attacker.',
     'pending', '2024-06-05 09:00:00+00', NULL),

    -- Incident 6 — DDoS
    (6, 2,  'block_ip',           'Deployed upstream BGP blackhole routing for attacker IP ranges.',
     'completed', '2023-10-12 16:50:00+00', '2023-10-12 17:10:00+00'),
    (6, 2,  'config_change',      'Enabled HTTP/2 rate-limiting and RESET_STREAM throttling on nginx.',
     'completed', '2023-10-12 17:00:00+00', '2023-10-12 17:45:00+00'),

    -- Incident 7 — Insider threat
    (7, 9,  'config_change',      'Disabled USB mass-storage device class via Group Policy.',
     'completed', '2024-02-08 13:00:00+00', '2024-02-08 14:00:00+00'),
    (7, 9,  'other',              'Evidence preserved; HR notified; legal hold placed on endpoint.',
     'completed', '2024-02-08 12:30:00+00', '2024-02-08 13:00:00+00'),

    -- Incident 8 — Spring4Shell (open — actions still pending)
    (8, 10, 'patch',              'Upgrade Spring Framework to 5.3.18+ on CI/CD pipeline.',
     'pending', '2024-11-21 09:00:00+00', NULL),
    (8, 7,  'scan',               'Run DAST scan on all Spring-based internal applications.',
     'pending', '2024-11-22 09:00:00+00', NULL),

    -- Incident 9 — Credential stuffing
    (9, 4,  'block_ip',           'Added attacker IP ranges to WAF deny list.',
     'completed', '2024-09-05 22:20:00+00', '2024-09-05 22:30:00+00'),
    (9, 2,  'config_change',      'Implemented CAPTCHA and account-lockout policy on customer portal.',
     'completed', '2024-09-06 08:00:00+00', '2024-09-06 09:30:00+00'),

    -- Incident 10 — ProxyLogon
    (10, 1, 'patch',              'Applied Microsoft Exchange CU + security patch (KB5000871).',
     'completed', '2021-03-05 09:00:00+00', '2021-03-06 18:00:00+00'),
    (10, 5, 'scan',               'Full forensic scan of mail server; web shell files removed.',
     'completed', '2021-03-05 08:00:00+00', '2021-03-07 12:00:00+00'),
    (10, 1, 'reset_credentials',  'Reset Exchange service account credentials and admin passwords.',
     'completed', '2021-03-06 09:00:00+00', '2021-03-06 11:00:00+00');
