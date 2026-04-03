// ============================================================================
// Combined Queries - Dynamic multi-environment data via OData
// ============================================================================
// Iterates over the Environments table and pulls data from each.
//
// SETUP:
// 1. Edit the Environments query with your actual environment URLs
// 2. In Power BI: File > Options > Global > Security >
//    Check "Allow ... dynamic data sources"
// 3. Use this query as-is, or split into separate queries below.
//
// NOTE: If you only have ONE environment, you do NOT need this file.
//       Just use CloudFlows, FlowRuns, SystemUsers directly.
//
// If you have MULTIPLE environments but do NOT want dynamic sources,
// duplicate each query per environment, update the URL in each,
// and union them with Table.Combine. Example at the bottom of this file.
// ============================================================================

let
    Envs = Environments,
    EnvURLs = Envs[EnvironmentURL],

    // ----- Fetch Cloud Flows from all environments -----
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

    AllFlows = List.Transform(EnvURLs, each GetFlows(_)),
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

// ============================================================================
// ALTERNATIVE: If you do NOT want dynamic data sources, create separate
// queries for each environment and combine them manually.
//
// Create a new query named "AllCloudFlows" with:
//
//   let
//       Prod = CloudFlows_Prod,
//       Dev = CloudFlows_Dev,
//       Combined = Table.Combine({Prod, Dev})
//   in
//       Combined
//
// Do the same for FlowRuns and SystemUsers.
// ============================================================================
