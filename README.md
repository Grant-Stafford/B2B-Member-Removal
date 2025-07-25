# 🔍 B2B Guest Cleanup Script for Entra ID (Azure AD)

## 📌 Purpose

This PowerShell script connects to **Microsoft Graph** and identifies **stale B2B (Guest) users** who meet the following criteria:

- `userType` is `"Guest"`
- Account is **15 days old or older**
- `extensionAttribute5` is **null or blank**
- **Invitation has not been accepted** (`ExternalUserState` = `PendingAcceptance`)

It then safely deletes these users and logs any failures.

---

## ⚙️ What the Script Does

1. Authenticates to Microsoft Graph using interactive sign-in.
2. Retrieves all B2B (Guest) users from the tenant.
3. Filters users who:
   - Are **15+ days old**
   - Have **not accepted** their invitation
   - Have **no value** in `extensionAttribute5`
4. Exports a backup list of users selected for deletion.
5. Attempts to delete each user.
6. Logs any failed deletions to `B2B_DeleteFailures.csv`.

---

## ✅ Requirements

- PowerShell 5.1+ (or PowerShell Core)
- Microsoft Graph PowerShell SDK

Install the SDK if needed:
```powershell
Install-Module Microsoft.Graph -Scope CurrentUser -Force
