// ============================================================================
// Date Table - Calendar dimension for time intelligence
// ============================================================================
// Auto-generated date dimension table for proper time intelligence
// in DAX. Covers 2 years back to 1 year forward.
// Mark this as a "Date Table" in Power BI Model view.
// ============================================================================

let
    StartDate = Date.StartOfYear(Date.AddYears(DateTime.Date(DateTime.LocalNow()), -2)),
    EndDate = Date.EndOfYear(Date.AddYears(DateTime.Date(DateTime.LocalNow()), 1)),

    // Generate date list
    DateCount = Duration.Days(EndDate - StartDate) + 1,
    DateList = List.Dates(StartDate, DateCount, #duration(1, 0, 0, 0)),

    // Convert to table
    DateTable = Table.FromList(DateList, Splitter.SplitByNothing(), {"Date"}),

    // Set date type
    TypedDate = Table.TransformColumnTypes(DateTable, {{"Date", type date}}),

    // Add date components
    AddYear = Table.AddColumn(TypedDate, "Year", each Date.Year([Date]), Int64.Type),
    AddMonth = Table.AddColumn(AddYear, "MonthNumber", each Date.Month([Date]), Int64.Type),
    AddMonthName = Table.AddColumn(AddMonth, "MonthName", each Date.MonthName([Date]), type text),
    AddMonthShort = Table.AddColumn(AddMonthName, "MonthShort", each Text.Start(Date.MonthName([Date]), 3), type text),
    AddDay = Table.AddColumn(AddMonthShort, "Day", each Date.Day([Date]), Int64.Type),
    AddDayOfWeek = Table.AddColumn(AddDay, "DayOfWeek", each Date.DayOfWeek([Date], Day.Monday) + 1, Int64.Type),
    AddDayName = Table.AddColumn(AddDayOfWeek, "DayName", each Date.DayOfWeekName([Date]), type text),
    AddDayShort = Table.AddColumn(AddDayName, "DayShort", each Text.Start(Date.DayOfWeekName([Date]), 3), type text),
    AddQuarter = Table.AddColumn(AddDayShort, "Quarter", each Date.QuarterOfYear([Date]), Int64.Type),
    AddQuarterLabel = Table.AddColumn(AddQuarter, "QuarterLabel", each "Q" & Text.From(Date.QuarterOfYear([Date])), type text),
    AddWeekOfYear = Table.AddColumn(AddQuarterLabel, "WeekOfYear", each Date.WeekOfYear([Date]), Int64.Type),
    AddYearMonth = Table.AddColumn(AddWeekOfYear, "YearMonth", each
        Text.From(Date.Year([Date])) & "-" & Text.PadStart(Text.From(Date.Month([Date])), 2, "0")
    , type text),
    AddYearQuarter = Table.AddColumn(AddYearMonth, "YearQuarter", each
        Text.From(Date.Year([Date])) & " Q" & Text.From(Date.QuarterOfYear([Date]))
    , type text),
    AddIsWeekend = Table.AddColumn(AddYearQuarter, "IsWeekend", each
        Date.DayOfWeek([Date], Day.Monday) >= 5
    , type logical),
    AddIsCurrentMonth = Table.AddColumn(AddIsWeekend, "IsCurrentMonth", each
        Date.Year([Date]) = Date.Year(DateTime.Date(DateTime.LocalNow())) and
        Date.Month([Date]) = Date.Month(DateTime.Date(DateTime.LocalNow()))
    , type logical),
    AddFiscalYear = Table.AddColumn(AddIsCurrentMonth, "FiscalYear", each
        // Adjust fiscal year start month here (default: July = FY starts July)
        let fiscalStartMonth = 7 in
        if Date.Month([Date]) >= fiscalStartMonth
        then Date.Year([Date]) + 1
        else Date.Year([Date])
    , Int64.Type),

    // Sort by date
    SortedTable = Table.Sort(AddFiscalYear, {{"Date", Order.Ascending}})
in
    SortedTable
