// ============================================================================
// Cloud Flows - Power Automate Cloud Flows via Dataverse Web API (OData)
// ============================================================================
// Uses OData.Feed against the Dataverse Web API - no TDS endpoint needed.
// Dataverse entity: workflows
// Filtered to: category eq 5 (Cloud Flow) and type eq 1 (Definition)
//
// Replace "org0d734703.crm.dynamics.com" with your environment URL.
// ============================================================================

let
    // -----------------------------------------------------------------------
    // CONNECTION - Update this URL to your Dataverse environment
    // -----------------------------------------------------------------------
    EnvironmentURL = "org0d734703.crm.dynamics.com",

    BaseURL = "https://" & EnvironmentURL & "/api/data/v9.2/",

    // Query cloud flows: category=5 (Modern Flow), type=1 (Definition)
    Source = OData.Feed(
        BaseURL & "workflows?$filter=category eq 5 and type eq 1"
            & "&$select=workflowid,name,description,category,statecode,statuscode,"
            & "_ownerid_value,createdon,modifiedon,primaryentity,clientdata,solutionid",
        null,
        [Implementation = "2.0", ODataVersion = 4]
    ),

    // Rename columns for clarity
    RenamedColumns = Table.RenameColumns(Source, {
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
        try ([SolutionID] <> null and [SolutionID] <> "00000000-0000-0000-0000-000000000000") otherwise false
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
