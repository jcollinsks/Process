// ============================================================================
// Cloud Flows - Power Automate Cloud Flows from Dataverse workflow table
// ============================================================================
// Dataverse entity: workflow (logical name)
// Filtered to: category = 5 (Modern Flow / Cloud Flow)
//              type = 1 (Definition, not Activation/Template)
//
// This query connects using the native Dataverse connector.
// Replace "yourorg.crm.dynamics.com" with your actual environment URL.
// For multiple environments, duplicate and union (see CombinedCloudFlows.m).
// ============================================================================

let
    // -----------------------------------------------------------------------
    // CONNECTION - Update this URL to your Dataverse environment
    // -----------------------------------------------------------------------
    EnvironmentURL = "yourorg.crm.dynamics.com",

    // Connect using native Dataverse connector
    Source = CommonDataService.Database(EnvironmentURL),

    // Navigate to the workflow table
    WorkflowTable = Source{[Schema="dbo", Item="workflow"]}[Data],

    // Filter to Cloud Flows only (category = 5) and Definitions (type = 1)
    FilteredFlows = Table.SelectRows(WorkflowTable, each
        [category] = 5 and [type] = 1
    ),

    // Select relevant columns
    SelectedColumns = Table.SelectColumns(FilteredFlows, {
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
        "clientdata",
        "solutionid"
    }, MissingField.Ignore),

    // Rename columns for clarity
    RenamedColumns = Table.RenameColumns(SelectedColumns, {
        {"workflowid", "FlowID"},
        {"name", "FlowName"},
        {"description", "FlowDescription"},
        {"statecode", "StateCode"},
        {"statuscode", "StatusCode"},
        {"_ownerid_value", "OwnerID"},
        {"createdon", "CreatedOn"},
        {"modifiedon", "ModifiedOn"},
        {"primaryentity", "PrimaryEntity"},
        {"clientdata", "ClientData"},
        {"solutionid", "SolutionID"}
    }, MissingField.Ignore),

    // Add flow state description
    AddStateName = Table.AddColumn(RenamedColumns, "FlowState", each
        if [StateCode] = 0 then "Draft"
        else if [StateCode] = 1 then "Activated"
        else if [StateCode] = 2 then "Suspended"
        else "Unknown"
    , type text),

    // Add flow status description
    AddStatusName = Table.AddColumn(AddStateName, "FlowStatus", each
        if [StatusCode] = 1 then "Draft"
        else if [StatusCode] = 2 then "Activated"
        else "Other"
    , type text),

    // Extract trigger type from ClientData JSON (if available)
    AddTriggerType = Table.AddColumn(AddStatusName, "TriggerType", each
        try
            let
                jsonData = Json.Document([ClientData]),
                properties = jsonData[properties],
                definition = properties[definition],
                triggers = Record.FieldNames(definition[triggers]),
                firstTrigger = triggers{0}
            in
                firstTrigger
        otherwise "Unknown"
    , type text),

    // Add environment source
    AddEnvironment = Table.AddColumn(AddTriggerType, "EnvironmentURL", each EnvironmentURL, type text),

    // Add IsInSolution flag
    AddSolutionFlag = Table.AddColumn(AddEnvironment, "IsInSolution", each
        [SolutionID] <> null and [SolutionID] <> "00000000-0000-0000-0000-000000000000"
    , type logical),

    // Set data types
    TypedTable = Table.TransformColumnTypes(AddSolutionFlag, {
        {"FlowID", type text},
        {"FlowName", type text},
        {"FlowDescription", type text},
        {"CreatedOn", type datetimezone},
        {"ModifiedOn", type datetimezone},
        {"OwnerID", type text},
        {"EnvironmentURL", type text}
    })
in
    TypedTable
