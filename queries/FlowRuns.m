// ============================================================================
// Flow Runs - Power Automate flow execution history from flowsession table
// ============================================================================
// Dataverse entity: flowsession (logical name)
// Contains: run status, start/end times, errors, duration
//
// IMPORTANT: This table can be very large. Consider adding date filters
// to limit the data pulled (see DateFilter section below).
// ============================================================================

let
    // -----------------------------------------------------------------------
    // CONNECTION - Update this URL to your Dataverse environment
    // -----------------------------------------------------------------------
    EnvironmentURL = "yourorg.crm.dynamics.com",

    // -----------------------------------------------------------------------
    // DATE FILTER - Adjust to control data volume
    // Default: last 90 days. Increase for more history.
    // -----------------------------------------------------------------------
    DaysToLoad = 90,
    CutoffDate = Date.AddDays(DateTime.LocalNow(), -DaysToLoad),

    // Connect using native Dataverse connector
    Source = CommonDataService.Database(EnvironmentURL),

    // Navigate to the flowsession table
    FlowSessionTable = let
        matchByItem = try Source{[Item="flowsession"]}[Data],
        matchBySearch = try Table.SelectRows(Source, each [Item] = "flowsession"){0}[Data]
    in
        if matchByItem[HasError] = false then matchByItem[Value]
        else if matchBySearch[HasError] = false then matchBySearch[Value]
        else error "Could not find 'flowsession' table. Check available table names in Power Query.",

    // Apply date filter to limit data volume
    DateFiltered = Table.SelectRows(FlowSessionTable, each
        [createdon] >= CutoffDate
    ),

    // Select relevant columns
    SelectedColumns = Table.SelectColumns(DateFiltered, {
        "flowsessionid",
        "name",
        "_regardingobjectid_value",
        "statuscode",
        "statecode",
        "startedon",
        "completedon",
        "errorcode",
        "errormessage",
        "createdon",
        "context",
        "gateway"
    }, MissingField.Ignore),

    // Rename columns for clarity
    RenamedColumns = Table.RenameColumns(SelectedColumns, {
        {"flowsessionid", "RunID"},
        {"name", "RunName"},
        {"_regardingobjectid_value", "FlowID"},
        {"statuscode", "RunStatusCode"},
        {"statecode", "RunStateCode"},
        {"startedon", "StartedOn"},
        {"completedon", "CompletedOn"},
        {"errorcode", "ErrorCode"},
        {"errormessage", "ErrorMessage"},
        {"createdon", "CreatedOn"},
        {"context", "RunContext"},
        {"gateway", "Gateway"}
    }, MissingField.Ignore),

    // Add run status description
    AddRunStatus = Table.AddColumn(RenamedColumns, "RunStatus", each
        if [RunStatusCode] = 0 then "NotSpecified"
        else if [RunStatusCode] = 1 then "Paused"
        else if [RunStatusCode] = 2 then "Running"
        else if [RunStatusCode] = 3 then "Waiting"
        else if [RunStatusCode] = 4 then "Succeeded"
        else if [RunStatusCode] = 5 then "Skipped"
        else if [RunStatusCode] = 6 then "Suspended"
        else if [RunStatusCode] = 7 then "Cancelled"
        else if [RunStatusCode] = 8 then "Failed"
        else if [RunStatusCode] = 9 then "Faulted"
        else if [RunStatusCode] = 10 then "TimedOut"
        else if [RunStatusCode] = 11 then "Aborted"
        else if [RunStatusCode] = 12 then "Ignored"
        else if [RunStatusCode] = 13 then "Deleted"
        else if [RunStatusCode] = 14 then "Terminated"
        else "Unknown"
    , type text),

    // Add simplified status category for the pie chart
    AddStatusCategory = Table.AddColumn(AddRunStatus, "StatusCategory", each
        if [RunStatusCode] = 4 then "Succeeded"
        else if [RunStatusCode] = 8 or [RunStatusCode] = 9 then "Failed"
        else if [RunStatusCode] = 7 then "Cancelled"
        else if [RunStatusCode] = 10 then "Timed Out"
        else if [RunStatusCode] = 2 or [RunStatusCode] = 3 then "In Progress"
        else "Other"
    , type text),

    // Calculate duration in seconds
    AddDuration = Table.AddColumn(AddStatusCategory, "DurationSeconds", each
        try Duration.TotalSeconds([CompletedOn] - [StartedOn]) otherwise null
    , type number),

    // Calculate duration in minutes
    AddDurationMinutes = Table.AddColumn(AddDuration, "DurationMinutes", each
        try [DurationSeconds] / 60 otherwise null
    , type number),

    // Add run date (date only, for time intelligence)
    AddRunDate = Table.AddColumn(AddDurationMinutes, "RunDate", each
        try DateTime.Date(DateTime.From([StartedOn])) otherwise null
    , type date),

    // Add run hour (for time-of-day analysis)
    AddRunHour = Table.AddColumn(AddRunDate, "RunHour", each
        try Time.Hour(DateTime.Time(DateTime.From([StartedOn]))) otherwise null
    , Int64.Type),

    // Add day of week
    AddDayOfWeek = Table.AddColumn(AddRunHour, "DayOfWeek", each
        try Date.DayOfWeekName([RunDate]) otherwise null
    , type text),

    // Add is business hours flag (Mon-Fri, 8am-6pm)
    AddBusinessHours = Table.AddColumn(AddDayOfWeek, "IsBusinessHours", each
        try
            let
                dow = Date.DayOfWeek([RunDate], Day.Monday),
                hour = [RunHour],
                isWeekday = dow >= 0 and dow <= 4,
                isWorkHour = hour >= 8 and hour < 18
            in
                isWeekday and isWorkHour
        otherwise null
    , type logical),

    // Add error category
    AddErrorCategory = Table.AddColumn(AddBusinessHours, "ErrorCategory", each
        if [RunStatusCode] <> 8 and [RunStatusCode] <> 9 then null
        else if [ErrorCode] = null or [ErrorCode] = "" then "Uncategorized Error"
        else if Text.Contains(Text.Lower(Text.From([ErrorCode])), "timeout") then "Timeout"
        else if Text.Contains(Text.Lower(Text.From([ErrorCode])), "unauthorized") or Text.Contains(Text.Lower(Text.From([ErrorCode])), "403") then "Authorization"
        else if Text.Contains(Text.Lower(Text.From([ErrorCode])), "notfound") or Text.Contains(Text.Lower(Text.From([ErrorCode])), "404") then "Not Found"
        else if Text.Contains(Text.Lower(Text.From([ErrorCode])), "throttl") or Text.Contains(Text.Lower(Text.From([ErrorCode])), "429") then "Throttled"
        else if Text.Contains(Text.Lower(Text.From([ErrorCode])), "badrequest") or Text.Contains(Text.Lower(Text.From([ErrorCode])), "400") then "Bad Request"
        else if Text.Contains(Text.Lower(Text.From([ErrorCode])), "500") or Text.Contains(Text.Lower(Text.From([ErrorCode])), "internal") then "Server Error"
        else "Other Error"
    , type text),

    // Add environment source
    AddEnvironment = Table.AddColumn(AddErrorCategory, "EnvironmentURL", each EnvironmentURL, type text),

    // Set data types
    TypedTable = Table.TransformColumnTypes(AddEnvironment, {
        {"RunID", type text},
        {"FlowID", type text},
        {"StartedOn", type datetimezone},
        {"CompletedOn", type datetimezone},
        {"CreatedOn", type datetimezone},
        {"ErrorCode", type text},
        {"ErrorMessage", type text},
        {"EnvironmentURL", type text}
    })
in
    TypedTable
