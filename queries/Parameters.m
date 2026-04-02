// ============================================================================
// PARAMETERS - Configure these before loading data
// ============================================================================
// In Power BI Desktop: Home > Manage Parameters > New Parameter
// Create each parameter below. Users will be prompted to enter values
// when opening the template.
// ============================================================================

// Parameter: EnvironmentURLs
// Type: Text
// Description: Comma-separated list of Dataverse environment URLs
// Example: "org1.crm.dynamics.com,org2.crm.dynamics.com"
// Create this as a Parameter in Power BI Desktop:
//   Name: EnvironmentURLs
//   Type: Text
//   Current Value: "yourorg.crm.dynamics.com"

// Parameter: MinutesPerManualRun (Default time savings estimate)
// Type: Decimal Number
// Description: Default estimated minutes saved per automated flow run
// Current Value: 15

// Parameter: HourlyLaborCost
// Type: Decimal Number
// Description: Average hourly labor cost for ROI calculations
// Current Value: 50

// ============================================================================
// Helper function to parse environment list
// ============================================================================
let
    ParseEnvironments = (envList as text) as list =>
        let
            Trimmed = Text.Trim(envList),
            Split = Text.Split(Trimmed, ","),
            Cleaned = List.Transform(Split, each Text.Trim(_)),
            NonEmpty = List.Select(Cleaned, each _ <> "")
        in
            NonEmpty
in
    ParseEnvironments
