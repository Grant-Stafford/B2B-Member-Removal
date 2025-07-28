# Connect to Microsoft Graph with elevated permissions
Connect-MgGraph -Scopes "User.ReadWrite.All", "Directory.Read.All"

# Query all B2B (Guest) users
$guests = Get-MgUser -Filter "userType eq 'Guest'" `
    -Select Id,DisplayName,UserPrincipalName,Mail,UserType,CreatedDateTime,ExternalUserState,OnPremisesExtensionAttributes `
    -All

# Define age threshold
$cutoffDate = (Get-Date).AddDays(-15)

# Filter for users to delete
# - UserPrincipalName does not contain tva.com
# - Created over 15 days ago
# - Invitation is not accepted (ExternalUserState = PendingAcceptance)
$toDelete = $guests | Where-Object {
    ($_.UserPrincipalName -notlike "*tva.com") -and
    ($_.CreatedDateTime -lt $cutoffDate) -and
    ($_.ExternalUserState -eq "PendingAcceptance")
}

# Confirm count
Write-Host "Users to be deleted: $($toDelete.Count)"

# Export a backup list before deleting
$toDelete | Select-Object DisplayName, UserPrincipalName, CreatedDateTime, ExternalUserState |
    Export-Csv -Path ".\B2B_Guests_ToBeDeleted.csv" -NoTypeInformation

# Create a list to store failed deletions
$failedDeletions = @()

# Delete each user and log failures
foreach ($user in $toDelete) {
    try {
        Remove-MgUser -UserId $user.Id -ErrorAction Stop
        Write-Host "✅ Deleted: $($user.UserPrincipalName)"
    }
    catch {
        Write-Warning "❌ Failed to delete: $($user.UserPrincipalName) - $($_.Exception.Message)"

        # Add failed deletion to log
        $failedDeletions += [PSCustomObject]@{
            DisplayName        = $user.DisplayName
            UserPrincipalName  = $user.UserPrincipalName
            CreatedDateTime    = $user.CreatedDateTime
            ExternalUserState  = $user.ExternalUserState
            ErrorMessage       = $_.Exception.Message
        }
    }
}

# Export failed deletions to CSV if there are any
if ($failedDeletions.Count -gt 0) {
    $failedDeletions | Export-Csv -Path ".\B2B_DeleteFailures.csv" -NoTypeInformation
    Write-Host "`n Failed deletions exported to B2B_DeleteFailures.csv"
}
else {
    Write-Host "`n All deletions completed without errors."
}
