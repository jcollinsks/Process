// ============================================================================
// System Users - User details via Dataverse Web API (OData)
// ============================================================================
// Uses OData.Feed - no TDS endpoint needed.
// Dataverse entity: systemusers
// Purpose: Map OwnerID (GUID) to actual user emails and display names
// ============================================================================

let
    // -----------------------------------------------------------------------
    // CONNECTION - Update this URL to your Dataverse environment
    // -----------------------------------------------------------------------
    EnvironmentURL = "org0d734703.crm.dynamics.com",

    BaseURL = "https://" & EnvironmentURL & "/api/data/v9.2/",

    // Query system users
    Source = OData.Feed(
        BaseURL & "systemusers?$select=systemuserid,fullname,firstname,lastname,"
            & "internalemailaddress,domainname,isdisabled,title,"
            & "azureactivedirectoryobjectid",
        null,
        [Implementation = "2.0", ODataVersion = 4]
    ),

    // Rename columns for clarity
    RenamedColumns = Table.RenameColumns(Source, {
        {"systemuserid", "UserID"},
        {"fullname", "FullName"},
        {"firstname", "FirstName"},
        {"lastname", "LastName"},
        {"internalemailaddress", "Email"},
        {"domainname", "DomainName"},
        {"isdisabled", "IsDisabled"},
        {"title", "JobTitle"},
        {"azureactivedirectoryobjectid", "AzureADObjectID"}
    }, MissingField.Ignore),

    // Add user status
    AddUserStatus = Table.AddColumn(RenamedColumns, "UserStatus", each
        if [IsDisabled] = true then "Disabled"
        else "Active"
    , type text),

    // Add display label (Name + Email)
    AddDisplayLabel = Table.AddColumn(AddUserStatus, "UserDisplayLabel", each
        let
            name = if [FullName] <> null and [FullName] <> "" then [FullName] else "Unknown",
            email = if [Email] <> null and [Email] <> "" then " (" & [Email] & ")" else ""
        in
            name & email
    , type text),

    // Add environment source
    AddEnvironment = Table.AddColumn(AddDisplayLabel, "EnvironmentURL", each EnvironmentURL, type text),

    // Set data types
    TypedTable = Table.TransformColumnTypes(AddEnvironment, {
        {"UserID", type text},
        {"FullName", type text},
        {"FirstName", type text},
        {"LastName", type text},
        {"Email", type text},
        {"DomainName", type text},
        {"IsDisabled", type logical},
        {"JobTitle", type text},
        {"AzureADObjectID", type text},
        {"EnvironmentURL", type text}
    })
in
    TypedTable
