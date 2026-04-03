// ============================================================================
// Business Process Flows - BPFs via Dataverse Web API (OData)
// ============================================================================
// Uses OData.Feed - no TDS endpoint needed.
// Dataverse entity: workflows
// Filtered to: category eq 4 (Business Process Flow), type eq 1 (Definition)
// ============================================================================

let
    // -----------------------------------------------------------------------
    // CONNECTION - Update this URL to your Dataverse environment
    // -----------------------------------------------------------------------
    EnvironmentURL = "org0d734703.crm.dynamics.com",

    BaseURL = "https://" & EnvironmentURL & "/api/data/v9.2/",

    // Query BPFs: category=4, type=1
    Source = OData.Feed(
        BaseURL & "workflows?$filter=category eq 4 and type eq 1"
            & "&$select=workflowid,name,description,category,statecode,statuscode,"
            & "_ownerid_value,createdon,modifiedon,primaryentity,solutionid",
        null,
        [Implementation = "2.0", ODataVersion = 4]
    ),

    // Rename columns
    RenamedColumns = Table.RenameColumns(Source, {
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
