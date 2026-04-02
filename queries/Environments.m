// ============================================================================
// Environments - Master list of connected Dataverse environments
// ============================================================================
// This query builds the environment dimension table.
// Each environment URL becomes a row with metadata.
//
// SETUP: Replace the placeholder with your actual environment URLs.
// You can also use the EnvironmentURLs parameter if configured.
// ============================================================================

let
    // Option 1: Use the parameter (uncomment when parameter is set up)
    // EnvList = ParseEnvironments(EnvironmentURLs),

    // Option 2: Hardcode your environment URLs here
    EnvList = {
        "yourorg-prod.crm.dynamics.com",
        "yourorg-dev.crm.dynamics.com",
        "yourorg-test.crm.dynamics.com"
    },

    // Build environment table
    EnvTable = Table.FromList(EnvList, Splitter.SplitByNothing(), {"EnvironmentURL"}),

    // Add environment display name (extract org name)
    AddDisplayName = Table.AddColumn(EnvTable, "EnvironmentName", each
        let
            url = [EnvironmentURL],
            name = Text.BeforeDelimiter(url, ".crm")
        in
            Text.Proper(Text.Replace(name, "-", " "))
    , type text),

    // Add environment type classification
    AddEnvType = Table.AddColumn(AddDisplayName, "EnvironmentType", each
        let
            url = Text.Lower([EnvironmentURL])
        in
            if Text.Contains(url, "-prod") or (not Text.Contains(url, "-dev") and not Text.Contains(url, "-test") and not Text.Contains(url, "-uat") and not Text.Contains(url, "-sandbox")) then "Production"
            else if Text.Contains(url, "-dev") then "Development"
            else if Text.Contains(url, "-test") then "Test"
            else if Text.Contains(url, "-uat") then "UAT"
            else if Text.Contains(url, "-sandbox") then "Sandbox"
            else "Other"
    , type text),

    // Add index for joining
    AddIndex = Table.AddIndexColumn(AddEnvType, "EnvironmentID", 1, 1, Int64.Type),

    // Add full API base URL
    AddAPIUrl = Table.AddColumn(AddIndex, "APIBaseURL", each
        "https://" & [EnvironmentURL] & "/api/data/v9.2/"
    , type text),

    // Set types
    TypedTable = Table.TransformColumnTypes(AddAPIUrl, {
        {"EnvironmentURL", type text},
        {"EnvironmentName", type text},
        {"EnvironmentType", type text},
        {"EnvironmentID", Int64.Type},
        {"APIBaseURL", type text}
    })
in
    TypedTable
