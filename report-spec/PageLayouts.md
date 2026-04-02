# Report Page Layout Specifications

## Data Model Relationships

Set these up in Model view before building pages:

```
CloudFlows[FlowID]        -->  FlowRuns[FlowID]           (1:many)
CloudFlows[OwnerID]       -->  SystemUsers[UserID]         (many:1)
CloudFlows[FlowName]      -->  ProcessConfiguration[FlowName] (1:1, left outer)
CloudFlows[EnvironmentURL] --> Environments[EnvironmentURL] (many:1)
FlowRuns[RunDate]         -->  DateTable[Date]              (many:1)
CloudFlows[CreatedOn]     -->  DateTable[Date]              (many:1, inactive - use USERELATIONSHIP)
BusinessProcessFlows[OwnerID] --> SystemUsers[UserID]       (many:1)
DesktopFlows[OwnerID]     -->  SystemUsers[UserID]          (many:1)
```

Mark DateTable as the official Date Table (Table tools > Mark as date table).

---

## Page 1: Executive Dashboard

**Purpose**: High-level KPI overview for leadership

### Layout (1280 x 720 canvas)

```
+------------------------------------------------------------------+
|  [Logo]  Power Automate Governance Dashboard    [Date Range Slicer]|
+------------------------------------------------------------------+
|                                                                    |
|  +--------+ +--------+ +--------+ +--------+ +--------+          |
|  | Total  | | Total  | | Active | | Success| |  Hours | [Slicers]|
|  | Envs   | | Flows  | | Flows  | |  Rate  | | Saved  | [------]|
|  |   3    | |  142   | |  118   | | 94.2%  | |  1,247 | [Env   ]|
|  +--------+ +--------+ +--------+ +--------+ +--------+ [------]|
|                                                           [Status]|
|  +---------------------------+  +-------------------------[------]|
|  |                           |  |                         [Biz   ]|
|  |     PIE CHART             |  | TIME SAVINGS SUMMARY    [Proc  ]|
|  |   Flow Runs by Status     |  |                         [------]|
|  |                           |  | Days Saved: 156         [Owner ]|
|  |   [Succeeded] 89,412     |  | Cost Saved: $62,350     [------]|
|  |   [Failed]     3,847     |  | FTE Equiv: 0.6          [Dept  ]|
|  |   [Cancelled]    892     |  | ROI: 287%               [------]|
|  |   [Timed Out]    234     |  |                                 |
|  |   [Other]        156     |  +-------------------------------+ |
|  |                           |  | RISK REDUCTION                | |
|  +---------------------------+  | Risk Value: $45,200           | |
|                                 | High Risk Covered: 8/10       | |
|                                 | Governance Score: 82 (Good)   | |
|                                 +-------------------------------+ |
+------------------------------------------------------------------+
```

### Visuals Detail

| Visual | Type | Measures/Fields | Position |
|--------|------|-----------------|----------|
| Total Envs | Card | `Total Environments` | Top row, col 1 |
| Total Flows | Card | `Total All Workflows` | Top row, col 2 |
| Active Flows | Card | `Total Active Flows` | Top row, col 3 |
| Success Rate | KPI | `Success Rate` vs target 0.95 | Top row, col 4 |
| Hours Saved | Card | `Total Hours Saved` | Top row, col 5 |
| Status Pie | Pie Chart | Values: `Total Flow Runs`, Legend: `StatusCategory` | Center-left |
| Time Savings | Multi-row Card | `Total Days Saved`, `Estimated Cost Savings`, `Total FTE Equivalent`, `ROI Percentage` | Center-right |
| Risk Summary | Multi-row Card | `Risk Reduction Value`, `High Risk Automated Successfully`, `Governance Score` | Bottom-right |
| Env Slicer | Slicer (dropdown, search) | `Environments[EnvironmentName]` | Right panel |
| Status Slicer | Slicer (list) | `FlowRuns[StatusCategory]` | Right panel |
| Process Slicer | Slicer (dropdown, search) | `ProcessConfiguration[BusinessProcess]` | Right panel |
| Owner Slicer | Slicer (dropdown, search) | `SystemUsers[UserDisplayLabel]` | Right panel |
| Department Slicer | Slicer (dropdown, search) | `ProcessConfiguration[Department]` | Right panel |
| Date Slicer | Date range slicer | `DateTable[Date]` | Top-right |

### Conditional Formatting
- Success Rate card: Green >= 95%, Yellow 85-94%, Red < 85%
- Governance Score: Green >= 75, Yellow 50-74, Red < 50
- Pie chart colors: Succeeded=#107C10, Failed=#D13438, Cancelled=#FFB900, Timed Out=#FF8C00, Other=#8764B8

---

## Page 2: Flow Run Analysis

**Purpose**: Detailed flow run performance and trends

### Layout

```
+------------------------------------------------------------------+
|  Flow Run Analysis                              [Date Range Slicer]|
+------------------------------------------------------------------+
|  +--------+ +--------+ +--------+ +--------+                     |
|  | Runs   | | Avg    | | P95    | | Failure|                     |
|  | Today  | | Duration| Duration| |  Rate  |                     |
|  |  342   | | 2.3 min| | 8.7min | | 4.1%   |                     |
|  +--------+ +--------+ +--------+ +--------+                     |
|                                                                    |
|  +------------------------------------------+  +----------------+ |
|  |  LINE CHART                              |  | BAR CHART      | |
|  |  Daily Run Count + 7-Day Rolling Avg     |  | Runs by Hour   | |
|  |  X: DateTable[Date]                      |  | (Peak Usage)   | |
|  |  Y1: Daily Runs                          |  |                | |
|  |  Y2: Rolling 7 Day Avg Runs              |  |                | |
|  +------------------------------------------+  +----------------+ |
|                                                                    |
|  +------------------------------------------+  +----------------+ |
|  |  STACKED BAR CHART                       |  | DONUT CHART    | |
|  |  Daily Runs by Status Category           |  | Error Category | |
|  |  X: DateTable[Date]                      |  | Breakdown      | |
|  |  Y: Count of RunID                       |  |                | |
|  |  Legend: StatusCategory                   |  |                | |
|  +------------------------------------------+  +----------------+ |
|                                                                    |
|  +--------------------------------------------------------------+ |
|  |  TABLE: Top 10 Failing Flows                                 | |
|  |  FlowName | Total Runs | Failed | Failure Rate | Last Error  | |
|  +--------------------------------------------------------------+ |
+------------------------------------------------------------------+
```

---

## Page 3: Time Savings & ROI

**Purpose**: Quantify the value of automation

### Layout

```
+------------------------------------------------------------------+
|  Automation Value & ROI                         [Date Range Slicer]|
+------------------------------------------------------------------+
|  +--------+ +--------+ +--------+ +--------+                     |
|  | Total  | | Cost   | |  FTE   | |  ROI   |                     |
|  | Hours  | | Saved  | | Equiv  | |  %     |                     |
|  | 1,247  | | $62.3K | |  0.6   | | 287%   |                     |
|  +--------+ +--------+ +--------+ +--------+                     |
|                                                                    |
|  +------------------------------------------+  +----------------+ |
|  |  LINE CHART                              |  | BAR CHART      | |
|  |  Cumulative Hours Saved (over time)      |  | Hours Saved    | |
|  |  X: DateTable[YearMonth]                 |  | by Business    | |
|  |  Y: Cumulative Hours Saved               |  | Process        | |
|  +------------------------------------------+  +----------------+ |
|                                                                    |
|  +--------------------------------------------------------------+ |
|  |  TABLE: Process Time Savings Detail                          | |
|  |  Business Process | Flows | Runs | Min/Run | Hours | Cost   | |
|  |  Accounts Payable |   3   | 4,521|   20    |  1507 | $75.3K | |
|  |  HR Onboarding    |   2   | 1,203|   45    |   901 | $45.1K | |
|  |  ...              |       |      |         |       |        | |
|  +--------------------------------------------------------------+ |
|                                                                    |
|  +---------------------------+  +-------------------------------+ |
|  |  GAUGE                    |  |  WATERFALL CHART              | |
|  |  Annual Savings vs Target |  |  Monthly Savings Breakdown   | |
|  |  Target: configurable     |  |  by Department               | |
|  +---------------------------+  +-------------------------------+ |
+------------------------------------------------------------------+
```

---

## Page 4: Risk Assessment

**Purpose**: Understand risk reduction from automation

### Layout

```
+------------------------------------------------------------------+
|  Risk Assessment & Reduction                    [Date Range Slicer]|
+------------------------------------------------------------------+
|  +--------+ +--------+ +--------+ +--------+                     |
|  | Risk   | | High   | | Risk   | |Governan|                     |
|  |Reductn | | Risk   | |Achieve | |ce Score|                     |
|  |Value   | |Covered | | ment   | |        |                     |
|  |$45.2K  | |  8/10  | |  82%   | |82 Good |                     |
|  +--------+ +--------+ +--------+ +--------+                     |
|                                                                    |
|  +------------------------------------------+  +----------------+ |
|  |  MATRIX / HEAT MAP                       |  | BAR CHART      | |
|  |  Rows: Business Process                  |  | Risk Reduction | |
|  |  Columns: Risk Category                  |  | Value by       | |
|  |  Values: Risk Reduction Score             |  | Process        | |
|  |  Conditional formatting: Red-Yellow-Green |  |                | |
|  +------------------------------------------+  +----------------+ |
|                                                                    |
|  +--------------------------------------------------------------+ |
|  |  TABLE: Process Risk Detail                                  | |
|  |  Process | Risk Cat | Score | Success% | Runs | Risk Value  | |
|  |  Data Backup | Critical | 9 | 99.8% | 2,190 | $9,855      | |
|  |  Invoice Proc| High     | 8 | 96.2% | 4,521 | $12,657     | |
|  +--------------------------------------------------------------+ |
|                                                                    |
|  +---------------------------+  +-------------------------------+ |
|  |  TREEMAP                  |  |  GAUGE                        | |
|  |  Risk Value Distribution  |  |  Risk Reduction Achievement   | |
|  |  by Department/Category   |  |  vs 100% target               | |
|  +---------------------------+  +-------------------------------+ |
+------------------------------------------------------------------+
```

---

## Page 5: User & Ownership

**Purpose**: Who owns what, using real emails instead of GUIDs

### Layout

```
+------------------------------------------------------------------+
|  User & Ownership Analysis                      [Date Range Slicer]|
+------------------------------------------------------------------+
|  +--------+ +--------+ +--------+ +--------+                     |
|  | Total  | | Active | |Orphaned| |  Avg   |                     |
|  | Makers | | Users  | | Flows  | |Flows/  |                     |
|  |        | |        | |        | | Owner  |                     |
|  |   24   | |   312  | |    7   | |  5.9   |                     |
|  +--------+ +--------+ +--------+ +--------+                     |
|                                                                    |
|  +--------------------------------------------------------------+ |
|  |  TABLE: Flow Ownership Detail                                | |
|  |  Owner Email | Name | Dept | Active | Draft | Suspended | Runs|
|  |  john@co.com | John | IT   |   8    |   2   |     0     | 3.2K|
|  |  jane@co.com | Jane | HR   |   5    |   1   |     1     | 1.8K|
|  +--------------------------------------------------------------+ |
|                                                                    |
|  +---------------------------+  +-------------------------------+ |
|  |  BAR CHART                |  |  TABLE                        | |
|  |  Top 10 Flow Owners       |  |  Orphaned Flows               | |
|  |  (by flow count)          |  |  (disabled user owns them)    | |
|  |  Y: UserDisplayLabel      |  |  FlowName | Owner | Status    | |
|  |  X: Count of FlowID       |  |  Shows email of disabled user | |
|  +---------------------------+  +-------------------------------+ |
+------------------------------------------------------------------+
```

---

## Page 6: Environment Governance

**Purpose**: Cross-environment comparison and health

### Layout

```
+------------------------------------------------------------------+
|  Environment Governance                         [Date Range Slicer]|
+------------------------------------------------------------------+
|                                                                    |
|  +--------------------------------------------------------------+ |
|  |  MATRIX: Environment Comparison                              | |
|  |  Rows: EnvironmentName                                       | |
|  |  Values: Total Flows | Active | Runs | Success% | Governance | |
|  |  Conditional formatting on Governance Score                   | |
|  +--------------------------------------------------------------+ |
|                                                                    |
|  +---------------------------+  +-------------------------------+ |
|  |  STACKED BAR              |  |  CLUSTERED BAR               | |
|  |  Flows by State           |  |  Solution Coverage           | |
|  |  per Environment          |  |  per Environment             | |
|  +---------------------------+  +-------------------------------+ |
|                                                                    |
|  +---------------------------+  +-------------------------------+ |
|  |  PIE CHART                |  |  TABLE                        | |
|  |  Flow Distribution        |  |  Environment Health Details   | |
|  |  across Environments      |  |  Stale | Orphaned | Unmapped  | |
|  +---------------------------+  +-------------------------------+ |
+------------------------------------------------------------------+
```

---

## Page 7: Error Analysis (Drillthrough)

**Purpose**: Deep-dive into flow errors (drillthrough from other pages)

### Layout

```
+------------------------------------------------------------------+
|  Error Analysis                    [Back Button] [Date Range Slicer]|
+------------------------------------------------------------------+
|  Flow: [Selected Flow Name]        Environment: [Selected Env]     |
|                                                                    |
|  +--------+ +--------+ +--------+ +--------+                     |
|  | Total  | | Failed | | Error  | | Avg    |                     |
|  | Runs   | |  Runs  | | Rate   | |Recover |                     |
|  |  4,521 | |   187  | |  4.1%  | | 12min  |                     |
|  +--------+ +--------+ +--------+ +--------+                     |
|                                                                    |
|  +--------------------------------------------------------------+ |
|  |  LINE CHART: Error Rate Trend                                | |
|  |  X: Date  Y: Daily Failure Rate                              | |
|  +--------------------------------------------------------------+ |
|                                                                    |
|  +---------------------------+  +-------------------------------+ |
|  |  PIE/DONUT                |  |  TABLE                        | |
|  |  Error Categories         |  |  Recent Errors                | |
|  |  (from ErrorCategory)     |  |  Date | ErrorCode | Message   | |
|  +---------------------------+  +-------------------------------+ |
+------------------------------------------------------------------+
```

Configure as **Drillthrough page**:
- Drillthrough field: `CloudFlows[FlowName]`
- Right-click a flow name on any page to drill through here

---

## Slicer Configuration

All slicers on the right panel should have:
- **Search enabled**: Slicer settings > Selection > Show search bar
- **Single/Multi-select**: Allow multi-select with Ctrl+Click
- **Type**: Dropdown (to save space) except Status (use List/Tile)
- **Sync slicers**: Sync across all pages (View > Sync slicers)

### Recommended Slicers (synced across pages)
1. Date Range (between start/end)
2. Environment
3. Business Process
4. Department
5. Flow Owner (shows email)
6. Run Status Category
7. Risk Category

---

## Bookmarks (Quick Views)

Create these bookmarks for one-click views:
1. **Executive Summary** - Page 1 with no filters
2. **Production Only** - All pages filtered to Production environment
3. **Failed Flows** - Page 2 filtered to Failed status
4. **High Risk** - Page 4 filtered to High/Critical risk
5. **This Month** - All pages filtered to current month
6. **My Flows** - Filtered to current user (if using RLS)
