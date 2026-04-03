// ============================================================================
// Combined Queries - Multi-environment data via OData
// ============================================================================
// Lists your environment URLs directly below, then pulls and unions
// cloud flow data from each one.
//
// If you only have ONE environment, you do NOT need this query.
// Just use CloudFlows, FlowRuns, and SystemUsers directly.
//
// To add environments: add URLs to the EnvironmentURLs list below.
// ============================================================================

let
    // -----------------------------------------------------------------------
    // ENVIRONMENT LIST - Add your Dataverse environment URLs here
    // -----------------------------------------------------------------------
    EnvironmentURLs = {
        "org0d734703.crm.dynamics.com"
        // Add more environments by uncommenting / adding lines:
        // ,"org-dev.crm.dynamics.com"
        // ,"org-test.crm.dynamics.com"
    },

    // ----- Fetch Cloud Flows from each environment -----
    GetFlows = (envUrl as text) =>
        let
            BaseURL = "https://" & envUrl & "/api/data/v9.2/",
            Source = OData.Feed(
                BaseURL & "workflows?$filter=category eq 5 and type eq 1"
                    & "&$select=workflowid,name,description,statecode,statuscode,"
                    & "_ownerid_value,createdon,modifiedon",
                null,
                [Implementation = "2.0", ODataVersion = 4]
            ),
            AddEnv = Table.AddColumn(Source, "EnvironmentURL", each envUrl, type text)
        in
            AddEnv,

    AllFlows = List.Transform(EnvironmentURLs, each GetFlows(_)),
    CombinedFlows = Table.Combine(AllFlows),

    Renamed = Table.RenameColumns(CombinedFlows, {
        {"workflowid", "FlowID"},
        {"name", "FlowName"},
        {"description", "FlowDescription"},
        {"statecode", "StateCode"},
        {"statuscode", "StatusCode"},
        {"_ownerid_value", "OwnerID"},
        {"createdon", "CreatedOn"},
        {"modifiedon", "ModifiedOn"}
    }, MissingField.Ignore)
in
    Renamed
