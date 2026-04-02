// ============================================================================
// Process Configuration - Manual mapping table for business processes
// ============================================================================
// This is the CONFIGURABLE table where you manually assign:
//   - Business Process name to each flow
//   - Estimated time saved per run (minutes)
//   - Risk category and risk reduction score
//   - Process owner/department
//
// HOW TO SET UP:
// Option A (Recommended): Import the ProcessMapping.csv file from /config/
//          Then edit it in Power BI using "Edit Data" on the table.
//
// Option B: Use "Enter Data" in Power BI to create this table manually.
//
// Option C: Link to a SharePoint Excel file for collaborative editing.
// ============================================================================

// ----- Option A: Load from CSV -----
// Uncomment and update the file path:
// let
//     Source = Csv.Document(
//         File.Contents("C:\path\to\ProcessMapping.csv"),
//         [Delimiter=",", Encoding=65001, QuoteStyle=QuoteStyle.None]
//     ),
//     PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
//     TypedTable = Table.TransformColumnTypes(PromotedHeaders, {
//         {"FlowName", type text},
//         {"BusinessProcess", type text},
//         {"ProcessCategory", type text},
//         {"Department", type text},
//         {"MinutesSavedPerRun", type number},
//         {"RiskCategory", type text},
//         {"RiskReductionScore", Int64.Type},
//         {"ProcessOwner", type text},
//         {"Notes", type text}
//     })
// in
//     TypedTable

// ----- Option B: Enter Data directly (starter template) -----
// Use this as your starting point, then add rows in Power BI Desktop
let
    Source = Table.FromRecords({
        [
            FlowName = "Example: Invoice Processing Flow",
            BusinessProcess = "Accounts Payable",
            ProcessCategory = "Finance",
            Department = "Finance",
            MinutesSavedPerRun = 20,
            RiskCategory = "High",
            RiskReductionScore = 8,
            ProcessOwner = "finance-team@yourorg.com",
            Notes = "Automates invoice receipt to approval"
        ],
        [
            FlowName = "Example: Employee Onboarding",
            BusinessProcess = "HR Onboarding",
            ProcessCategory = "Human Resources",
            Department = "HR",
            MinutesSavedPerRun = 45,
            RiskCategory = "Medium",
            RiskReductionScore = 6,
            ProcessOwner = "hr-team@yourorg.com",
            Notes = "New hire provisioning and notifications"
        ],
        [
            FlowName = "Example: Approval Workflow",
            BusinessProcess = "Document Approval",
            ProcessCategory = "Operations",
            Department = "Operations",
            MinutesSavedPerRun = 10,
            RiskCategory = "Low",
            RiskReductionScore = 3,
            ProcessOwner = "ops-team@yourorg.com",
            Notes = "Multi-stage document approval routing"
        ]
    }),

    // Set data types
    TypedTable = Table.TransformColumnTypes(Source, {
        {"FlowName", type text},
        {"BusinessProcess", type text},
        {"ProcessCategory", type text},
        {"Department", type text},
        {"MinutesSavedPerRun", type number},
        {"RiskCategory", type text},
        {"RiskReductionScore", Int64.Type},
        {"ProcessOwner", type text},
        {"Notes", type text}
    })
in
    TypedTable
