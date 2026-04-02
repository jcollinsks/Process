// ============================================================================
// Desktop Flows - Power Automate Desktop flows from Dataverse workflow table
// ============================================================================
// Dataverse entity: workflow (logical name)
// Filtered to: category = 6 (Desktop Flow)
//              type = 1 (Definition)
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

    // Filter to Desktop Flows (category = 6) and Definitions (type = 1)
    FilteredFlows = Table.SelectRows(WorkflowTable, each
        [category] = 6 and [type] = 1
    ),

    // Select relevant columns
    SelectedColumns = Table.SelectColumns(FilteredFlows, {
        "workflowid",
        "name",
        "description",
        "statecode",
        "statuscode",
        "_ownerid_value",
        "createdon",
        "modifiedon"
    }, MissingField.Ignore),

    // Rename columns
    RenamedColumns = Table.RenameColumns(SelectedColumns, {
        {"workflowid", "FlowID"},
        {"name", "FlowName"},
        {"description", "FlowDescription"},
        {"statecode", "StateCode"},
        {"statuscode", "StatusCode"},
        {"_ownerid_value", "OwnerID"},
        {"createdon", "CreatedOn"},
        {"modifiedon", "ModifiedOn"}
    }, MissingField.Ignore),

    // Add flow type
    AddFlowType = Table.AddColumn(RenamedColumns, "FlowType", each "Desktop Flow", type text),

    // Add state description
    AddStateName = Table.AddColumn(AddFlowType, "FlowState", each
        if [StateCode] = 0 then "Draft"
        else if [StateCode] = 1 then "Activated"
        else if [StateCode] = 2 then "Suspended"
        else "Unknown"
    , type text),

    // Add environment source
    AddEnvironment = Table.AddColumn(AddStateName, "EnvironmentURL", each EnvironmentURL, type text),

    // Set data types
    TypedTable = Table.TransformColumnTypes(AddEnvironment, {
        {"FlowID", type text},
        {"FlowName", type text},
        {"CreatedOn", type datetimezone},
        {"ModifiedOn", type datetimezone},
        {"OwnerID", type text},
        {"EnvironmentURL", type text}
    })
in
    TypedTable
