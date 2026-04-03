// ============================================================================
// Business Process Flows - BPFs from Dataverse workflow table
// ============================================================================
// Dataverse entity: workflow (logical name)
// Filtered to: category = 4 (Business Process Flow)
//              type = 1 (Definition)
//
// These are the structured business process flows in Dataverse,
// separate from Cloud Flows (category 5).
// ============================================================================

let
    // -----------------------------------------------------------------------
    // CONNECTION - Update this URL to your Dataverse environment
    // -----------------------------------------------------------------------
    EnvironmentURL = "yourorg.crm.dynamics.com",

    // Connect using native Dataverse connector
    Source = CommonDataService.Database(EnvironmentURL),

    // Navigate to the workflow table
    WorkflowTable = let
        matchByItem = try Source{[Item="workflow"]}[Data],
        matchBySearch = try Table.SelectRows(Source, each [Item] = "workflow"){0}[Data]
    in
        if matchByItem[HasError] = false then matchByItem[Value]
        else if matchBySearch[HasError] = false then matchBySearch[Value]
        else error "Could not find 'workflow' table. Check available table names in Power Query.",

    // Filter to Business Process Flows (category = 4) and Definitions (type = 1)
    FilteredBPFs = Table.SelectRows(WorkflowTable, each
        [category] = 4 and [type] = 1
    ),

    // Select relevant columns
    SelectedColumns = Table.SelectColumns(FilteredBPFs, {
        "workflowid",
        "name",
        "description",
        "category",
        "statecode",
        "statuscode",
        "_ownerid_value",
        "createdon",
        "modifiedon",
        "primaryentity",
        "solutionid"
    }, MissingField.Ignore),

    // Rename columns
    RenamedColumns = Table.RenameColumns(SelectedColumns, {
        {"workflowid", "ProcessID"},
        {"name", "ProcessName"},
        {"description", "ProcessDescription"},
        {"statecode", "StateCode"},
        {"statuscode", "StatusCode"},
        {"_ownerid_value", "OwnerID"},
        {"createdon", "CreatedOn"},
        {"modifiedon", "ModifiedOn"},
        {"primaryentity", "PrimaryEntity"},
        {"solutionid", "SolutionID"}
    }, MissingField.Ignore),

    // Add state description
    AddStateName = Table.AddColumn(RenamedColumns, "ProcessState", each
        if [StateCode] = 0 then "Draft"
        else if [StateCode] = 1 then "Activated"
        else if [StateCode] = 2 then "Suspended"
        else "Unknown"
    , type text),

    // Add environment source
    AddEnvironment = Table.AddColumn(AddStateName, "EnvironmentURL", each EnvironmentURL, type text),

    // Set data types
    TypedTable = Table.TransformColumnTypes(AddEnvironment, {
        {"ProcessID", type text},
        {"ProcessName", type text},
        {"ProcessDescription", type text},
        {"CreatedOn", type datetimezone},
        {"ModifiedOn", type datetimezone},
        {"OwnerID", type text},
        {"EnvironmentURL", type text}
    })
in
    TypedTable
