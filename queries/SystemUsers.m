// ============================================================================
// System Users - User details from Dataverse systemuser table
// ============================================================================
// Dataverse entity: systemuser
// Purpose: Map OwnerID (GUID) to actual user emails and display names
//
// This resolves the object ID issue - flows show owner as a GUID,
// this table provides the human-readable email and name.
// ============================================================================

let
    // -----------------------------------------------------------------------
    // CONNECTION - Update this URL to your Dataverse environment
    // -----------------------------------------------------------------------
    EnvironmentURL = "yourorg.crm.dynamics.com",

    // Connect using native Dataverse connector
    Source = CommonDataService.Database(EnvironmentURL),

    // Navigate to the systemuser table
    SystemUserTable = let
        matchByItem = try Source{[Item="systemuser"]}[Data],
        matchBySearch = try Table.SelectRows(Source, each [Item] = "systemuser"){0}[Data]
    in
        if matchByItem[HasError] = false then matchByItem[Value]
        else if matchBySearch[HasError] = false then matchBySearch[Value]
        else error "Could not find 'systemuser' table. Check available table names in Power Query.",

    // Select relevant columns
    SelectedColumns = Table.SelectColumns(SystemUserTable, {
        "systemuserid",
        "fullname",
        "firstname",
        "lastname",
        "internalemailaddress",
        "domainname",
        "isdisabled",
        "title",
        "businessunitid",
        "azureactivedirectoryobjectid"
    }, MissingField.Ignore),

    // Rename columns for clarity
    RenamedColumns = Table.RenameColumns(SelectedColumns, {
        {"systemuserid", "UserID"},
        {"fullname", "FullName"},
        {"firstname", "FirstName"},
        {"lastname", "LastName"},
        {"internalemailaddress", "Email"},
        {"domainname", "DomainName"},
        {"isdisabled", "IsDisabled"},
        {"title", "JobTitle"},
        {"businessunitid", "BusinessUnitID"},
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

    // Filter out system accounts (optional - uncomment to exclude)
    // FilterSystemAccounts = Table.SelectRows(AddDisplayLabel, each
    //     not Text.Contains(Text.Lower([Email]), "system") and
    //     not Text.Contains(Text.Lower([FullName]), "system") and
    //     [Email] <> null and [Email] <> ""
    // ),

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
