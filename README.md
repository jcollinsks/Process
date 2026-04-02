# Power Automate Governance Dashboard - Power BI Template

A comprehensive Power BI report template for governing Power Automate cloud flows, desktop flows, and business process flows across multiple Dataverse environments.

## What This Template Provides

### 7 Report Pages
1. **Executive Dashboard** - KPI cards, flow run status pie chart, time savings, risk summary, searchable slicers
2. **Flow Run Analysis** - Run trends, duration metrics, peak usage hours, error analysis
3. **Time Savings & ROI** - Hours saved, cost savings, FTE equivalent, ROI calculation
4. **Risk Assessment** - Risk reduction value, heat map, governance scoring
5. **User & Ownership** - Flow owners with real emails (not GUIDs), orphaned flow detection
6. **Environment Governance** - Cross-environment comparison, solution coverage, health scoring
7. **Error Analysis** - Drillthrough page for deep-diving into specific flow errors

### Key Features
- Resolves user GUIDs to actual email addresses via the `systemuser` table
- Configurable business process mapping (manual entry table)
- Configurable time savings per process (minutes saved per run)
- Risk scoring with monetary value estimation
- Multi-environment support with environment comparison
- Governance health score (0-100)
- Orphaned flow detection (flows owned by disabled users)
- Solution-aware (tracks managed vs unmanaged flows)
- Date intelligence (YoY, MoM, MTD, YTD, rolling averages)
- Searchable slicers for all filter dimensions

---

## Quick Start

### Prerequisites
- Power BI Desktop (latest version)
- Dataverse environment(s) with Power Automate flows
- Appropriate security role in Dataverse (System Admin or Environment Maker)

### Step 1: Create New Report
1. Open Power BI Desktop
2. Apply the theme: View > Themes > Browse > select `themes/GovernanceTheme.json`

### Step 2: Set Up Parameters
1. Home > Transform data > Manage Parameters > New Parameter
2. Create these parameters:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `EnvironmentURLs` | Text | `yourorg.crm.dynamics.com` | Comma-separated Dataverse URLs |
| `MinutesPerManualRun` | Decimal | `15` | Default minutes saved per automated run |
| `HourlyLaborCost` | Decimal | `50` | Average hourly cost for ROI calculations |

### Step 3: Add Power Query Connections
1. Home > Transform Data (opens Power Query Editor)
2. For each `.m` file in the `queries/` folder:
   - Home > New Source > Blank Query
   - View > Advanced Editor
   - Paste the contents of the `.m` file
   - Update the `EnvironmentURL` value to your actual environment
   - Rename the query to match the file name
3. Load these queries in order:
   1. `DateTable` - Calendar dimension
   2. `Environments` - Environment list
   3. `SystemUsers` - User details (emails)
   4. `CloudFlows` - Cloud flow definitions
   5. `FlowRuns` - Flow execution history
   6. `BusinessProcessFlows` - BPF definitions
   7. `DesktopFlows` - Desktop flow definitions
   8. `ProcessConfiguration` - Business process mapping (manual config)

### Step 4: Configure for Multiple Environments
For each additional environment:
1. Duplicate `CloudFlows`, `FlowRuns`, and `SystemUsers` queries
2. Rename with environment suffix (e.g., `CloudFlows_Prod`, `CloudFlows_Dev`)
3. Update the `EnvironmentURL` in each duplicate
4. Create union queries using `CombinedQueries.m` as reference

**Alternative**: Use the Dynamic approach in `CombinedQueries.m` to automatically iterate over environments (requires enabling dynamic data sources in Options).

### Step 5: Set Up Data Model
Switch to Model view and create these relationships:

```
CloudFlows[FlowID]         1:*  FlowRuns[FlowID]
CloudFlows[OwnerID]        *:1  SystemUsers[UserID]
CloudFlows[FlowName]       1:1  ProcessConfiguration[FlowName]
CloudFlows[EnvironmentURL] *:1  Environments[EnvironmentURL]
FlowRuns[RunDate]          *:1  DateTable[Date]
```

**Important**: Mark `DateTable` as the Date Table:
- Select DateTable > Table tools > Mark as date table > Column: `Date`

### Step 6: Add DAX Measures
1. Select the `CloudFlows` table (or create a dedicated Measures table)
2. For each `.dax` file in the `measures/` folder:
   - Modeling > New Measure
   - Paste each measure formula
   - Measures to add (in order):
     1. `CoreMetrics.dax` - Base KPIs
     2. `FlowRunAnalysis.dax` - Run performance
     3. `TimeSavings.dax` - Value calculations
     4. `RiskEstimation.dax` - Risk scoring
     5. `TimeIntelligence.dax` - Period comparisons
     6. `GovernanceMetrics.dax` - Governance scoring

### Step 7: Build Report Pages
Follow the detailed layout specifications in `report-spec/PageLayouts.md`.

### Step 8: Configure Business Process Mapping
1. Edit the `ProcessConfiguration` table in Power BI
2. For each flow you want to track:
   - Enter the exact `FlowName` (must match the name in Dataverse)
   - Assign a `BusinessProcess` name
   - Set `MinutesSavedPerRun` (estimated manual time per execution)
   - Set `RiskCategory` (Critical, High, Medium, Low)
   - Set `RiskReductionScore` (1-10)

**Tip**: Start with your most important flows and add more over time. Unmapped flows will use the default `MinutesPerManualRun` parameter value.

### Step 9: Save as Template
1. File > Save As > select `.pbit` (Power BI Template) format
2. This creates a reusable template that prompts for parameters when opened

---

## Connecting to Dataverse

### Authentication
The native Dataverse connector uses your Azure AD credentials. When connecting:
1. Select **Organizational account**
2. Sign in with your Microsoft 365 account
3. The account needs at minimum the **Environment Maker** security role

### Finding Your Environment URL
1. Go to [Power Platform Admin Center](https://admin.powerplatform.microsoft.com)
2. Select Environments > Your environment
3. Copy the Environment URL (e.g., `orgname.crm.dynamics.com`)

### Required Dataverse Tables
| Table (Logical Name) | Display Name | Purpose |
|----------------------|--------------|---------|
| `workflow` | Process | Cloud flows (category=5), desktop flows (category=6), BPFs (category=4) |
| `flowsession` | Flow Session | Flow run history with status, duration, errors |
| `systemuser` | User | Maps owner GUIDs to emails and display names |

### Performance Tips
- The `flowsession` table can be very large. The `FlowRuns.m` query includes a `DaysToLoad` variable (default: 90 days). Increase this for more history, but expect longer refresh times.
- Enable incremental refresh for the FlowRuns table if you need extensive history.
- For very large environments, consider using DirectQuery mode for the flowsession table.

---

## Configuring Time Savings

Time savings are calculated per successful flow run. Configure them in two ways:

### Per-Process Configuration (Recommended)
Edit the `ProcessConfiguration` table and set `MinutesSavedPerRun` for each mapped flow:
- Invoice processing: ~20 minutes (data entry, routing, filing)
- Employee onboarding: ~45 minutes (account creation, notifications, equipment requests)
- Approval routing: ~10 minutes (email chains, follow-ups, tracking)

### Global Default
Unmapped flows use the `MinutesPerManualRun` parameter (default: 15 minutes).

### Formulas Used
```
Time Saved = Successful Runs x Minutes Per Run
Cost Saved = (Time Saved / 60) x Hourly Labor Cost
FTE Equivalent = Total Hours / 2080 (annual working hours)
ROI = (Cost Saved - License Cost) / License Cost
```

---

## Configuring Risk Estimation

### Risk Categories
| Category | Score | Typical Use Case | Est. Incident Cost |
|----------|-------|-------------------|--------------------|
| Critical | 10 | Regulatory compliance, data security | $10,000+ |
| High | 8 | Customer-facing, SLA-bound, financial | $5,000 |
| Medium | 5 | Internal operations, reporting | $1,000 |
| Low | 2 | Convenience automation, notifications | $200 |

### Risk Reduction Value Formula
```
Risk Value = Successful Runs x Error Probability x Incident Cost x (Risk Score / 10)
```
Where:
- `Error Probability` = estimated chance of human error per manual execution (default: 5%)
- `Incident Cost` = estimated cost per incident based on risk category
- `Risk Score` = 1-10 value from ProcessConfiguration

---

## File Structure

```
powerbi-governance-template/
|-- README.md                              # This file
|-- queries/                               # Power Query M code
|   |-- Parameters.m                       # Report parameters
|   |-- Environments.m                     # Environment dimension
|   |-- CloudFlows.m                       # Cloud flows from workflow table
|   |-- FlowRuns.m                         # Run history from flowsession table
|   |-- SystemUsers.m                      # User emails from systemuser table
|   |-- BusinessProcessFlows.m             # BPFs from workflow table
|   |-- DesktopFlows.m                     # Desktop flows from workflow table
|   |-- ProcessConfiguration.m             # Manual config table (editable)
|   |-- DateTable.m                        # Calendar dimension for time intel
|   |-- CombinedQueries.m                  # Multi-environment union queries
|-- measures/                              # DAX measures
|   |-- CoreMetrics.dax                    # Total counts, rates, percentages
|   |-- FlowRunAnalysis.dax                # Duration, trends, error analysis
|   |-- TimeSavings.dax                    # Hours/cost saved, ROI
|   |-- RiskEstimation.dax                 # Risk scoring, risk reduction value
|   |-- TimeIntelligence.dax               # YoY, MoM, rolling averages
|   |-- GovernanceMetrics.dax              # Health score, adoption, compliance
|-- config/                                # Configuration templates
|   |-- ProcessMapping.csv                 # Sample business process mapping
|   |-- RiskCategories.csv                 # Risk category reference
|-- report-spec/                           # Report design specifications
|   |-- PageLayouts.md                     # Detailed page layout specs
|-- themes/                                # Power BI visual themes
|   |-- GovernanceTheme.json               # Fluent Design inspired theme
```

---

## Dataverse Column Reference

### workflow table (Cloud Flows: category=5)
| Column | Type | Description |
|--------|------|-------------|
| `workflowid` | GUID | Unique flow identifier |
| `name` | String | Flow display name |
| `description` | String | Flow description |
| `category` | Int | 4=BPF, 5=Cloud Flow, 6=Desktop Flow |
| `type` | Int | 1=Definition, 2=Activation, 3=Template |
| `statecode` | Int | 0=Draft, 1=Activated, 2=Suspended |
| `statuscode` | Int | 1=Draft, 2=Activated |
| `_ownerid_value` | GUID | Owner system user ID |
| `createdon` | DateTime | Creation timestamp |
| `modifiedon` | DateTime | Last modified timestamp |
| `clientdata` | String | JSON with trigger/action definitions |
| `solutionid` | GUID | Solution membership (null if unmanaged) |

### flowsession table (Flow Runs)
| Column | Type | Description |
|--------|------|-------------|
| `flowsessionid` | GUID | Unique run identifier |
| `_regardingobjectid_value` | GUID | Parent flow ID (links to workflow) |
| `statuscode` | Int | Run status (see below) |
| `startedon` | DateTime | Run start time |
| `completedon` | DateTime | Run completion time |
| `errorcode` | String | Error code (if failed) |
| `errormessage` | String | Error details (if failed) |

**Flow Run Status Codes**:
| Code | Status | Category |
|------|--------|----------|
| 0 | NotSpecified | Other |
| 1 | Paused | In Progress |
| 2 | Running | In Progress |
| 3 | Waiting | In Progress |
| 4 | Succeeded | Succeeded |
| 5 | Skipped | Other |
| 6 | Suspended | Other |
| 7 | Cancelled | Cancelled |
| 8 | Failed | Failed |
| 9 | Faulted | Failed |
| 10 | TimedOut | Timed Out |
| 11 | Aborted | Other |
| 12 | Ignored | Other |
| 13 | Deleted | Other |
| 14 | Terminated | Other |

### systemuser table
| Column | Type | Description |
|--------|------|-------------|
| `systemuserid` | GUID | Maps to `_ownerid_value` in workflow |
| `fullname` | String | Display name |
| `internalemailaddress` | String | User email address |
| `domainname` | String | UPN / domain login |
| `isdisabled` | Boolean | Account disabled flag |
| `title` | String | Job title |
| `azureactivedirectoryobjectid` | GUID | Azure AD object ID |

---

## Optional Enhancements

### Row-Level Security (RLS)
To restrict users to see only their own flows:
1. Modeling > Manage Roles > New Role
2. Add filter: `CloudFlows[OwnerID] = USERPRINCIPALNAME()`
3. Publish to Power BI Service and assign users to the role

### Incremental Refresh
For large `flowsession` tables:
1. Create `RangeStart` and `RangeEnd` date/time parameters
2. Filter FlowRuns query: `[CreatedOn] >= RangeStart and [CreatedOn] < RangeEnd`
3. Right-click table > Incremental refresh > Configure retention

### Power Automate Alert Integration
Create a Power Automate flow that:
1. Triggers on schedule (e.g., daily)
2. Reads the Power BI dataset via REST API
3. Sends Teams/email alerts when:
   - Failure rate exceeds threshold
   - Orphaned flows detected
   - Governance score drops below threshold

### Scheduled Refresh
1. Publish to Power BI Service
2. Dataset settings > Scheduled refresh
3. Configure gateway if on-premises data gateway is required
4. Recommended: Refresh 2-4 times daily
