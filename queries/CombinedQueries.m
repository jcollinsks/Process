// ============================================================================
// Combined Queries - Union data across multiple environments
// ============================================================================
// Use these queries when connecting to multiple Dataverse environments.
// Each query unions the single-environment queries together.
//
// SETUP:
// 1. Duplicate CloudFlows, FlowRuns, SystemUsers queries for each environment
//    (e.g., CloudFlows_Prod, CloudFlows_Dev, CloudFlows_Test)
// 2. Update the EnvironmentURL in each duplicate
// 3. Use these combined queries to union them all
// ============================================================================


// ----- Combined Cloud Flows -----
// Paste this as a new query named "AllCloudFlows"
/*
let
    Prod = CloudFlows_Prod,
    Dev = CloudFlows_Dev,
    Test = CloudFlows_Test,
    Combined = Table.Combine({Prod, Dev, Test})
in
    Combined
*/


// ----- Combined Flow Runs -----
// Paste this as a new query named "AllFlowRuns"
/*
let
    Prod = FlowRuns_Prod,
    Dev = FlowRuns_Dev,
    Test = FlowRuns_Test,
    Combined = Table.Combine({Prod, Dev, Test})
in
    Combined
*/


// ----- Combined System Users -----
// Paste this as a new query named "AllSystemUsers"
/*
let
    Prod = SystemUsers_Prod,
    Dev = SystemUsers_Dev,
    Test = SystemUsers_Test,
    Combined = Table.Combine({Prod, Dev, Test}),
    // Deduplicate users who exist in multiple environments
    Deduplicated = Table.Distinct(Combined, {"Email"})
in
    Deduplicated
*/


// ============================================================================
// DYNAMIC MULTI-ENVIRONMENT APPROACH (Advanced)
// ============================================================================
// This approach dynamically iterates over the Environments table
// and pulls data from each. Requires enabling dynamic data sources.
//
// In Power BI: File > Options > Global > Security >
//   Check "Allow ... dynamic data sources"
// ============================================================================

// ----- Dynamic Cloud Flows -----
// Paste as a new query named "DynamicCloudFlows"
/*
let
    Envs = Environments,
    GetFlows = (envUrl as text) =>
        let
            Source = CommonDataService.Database(envUrl),
            WorkflowTable = Source{[Schema="dbo", Item="workflow"]}[Data],
            Filtered = Table.SelectRows(WorkflowTable, each [category] = 5 and [type] = 1),
            Selected = Table.SelectColumns(Filtered, {
                "workflowid", "name", "description", "statecode",
                "statuscode", "_ownerid_value", "createdon", "modifiedon"
            }, MissingField.Ignore),
            AddEnv = Table.AddColumn(Selected, "EnvironmentURL", each envUrl, type text)
        in
            AddEnv,

    EnvURLs = Envs[EnvironmentURL],
    AllFlows = List.Transform(EnvURLs, each GetFlows(_)),
    Combined = Table.Combine(AllFlows),
    Renamed = Table.RenameColumns(Combined, {
        {"workflowid", "FlowID"}, {"name", "FlowName"},
        {"description", "FlowDescription"}, {"statecode", "StateCode"},
        {"statuscode", "StatusCode"}, {"_ownerid_value", "OwnerID"},
        {"createdon", "CreatedOn"}, {"modifiedon", "ModifiedOn"}
    }, MissingField.Ignore)
in
    Renamed
*/


// ----- Dynamic Flow Runs -----
// Paste as a new query named "DynamicFlowRuns"
/*
let
    Envs = Environments,
    DaysToLoad = 90,
    CutoffDate = Date.AddDays(DateTime.LocalNow(), -DaysToLoad),

    GetRuns = (envUrl as text) =>
        let
            Source = CommonDataService.Database(envUrl),
            FlowSessionTable = Source{[Schema="dbo", Item="flowsession"]}[Data],
            DateFiltered = Table.SelectRows(FlowSessionTable, each [createdon] >= CutoffDate),
            Selected = Table.SelectColumns(DateFiltered, {
                "flowsessionid", "_regardingobjectid_value", "statuscode",
                "startedon", "completedon", "errorcode", "errormessage", "createdon"
            }, MissingField.Ignore),
            AddEnv = Table.AddColumn(Selected, "EnvironmentURL", each envUrl, type text)
        in
            AddEnv,

    EnvURLs = Envs[EnvironmentURL],
    AllRuns = List.Transform(EnvURLs, each GetRuns(_)),
    Combined = Table.Combine(AllRuns),
    Renamed = Table.RenameColumns(Combined, {
        {"flowsessionid", "RunID"}, {"_regardingobjectid_value", "FlowID"},
        {"statuscode", "RunStatusCode"}, {"startedon", "StartedOn"},
        {"completedon", "CompletedOn"}, {"errorcode", "ErrorCode"},
        {"errormessage", "ErrorMessage"}, {"createdon", "CreatedOn"}
    }, MissingField.Ignore)
in
    Renamed
*/
