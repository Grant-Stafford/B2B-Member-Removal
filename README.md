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
- User.Administrator Permissions

Install the SDK if needed:
powershell
Install-Module Microsoft.Graph -Scope CurrentUser -Force 

---

## 🔐 Microsoft Graph Permissions

These permissions are required and will be requested during interactive sign-in via `Connect-MgGraph`:

- `User.ReadWrite.All`
- `Directory.Read.All`

---

## 🚀 How to Use

1. Open **PowerShell as Administrator**.
2. Run the script.
3. Sign in when prompted.
4. Review the output:

   - ✅ **Deleted users** will be shown in the console.
   - 📁 **Backups** are exported to `B2B_Guests_ToBeDeleted.csv`.
   - ⚠️ **Failures** are logged in `B2B_DeleteFailures.csv`.

---

## ⚠️ Warnings

- This script **permanently deletes users**.
- Carefully review `B2B_Guests_ToBeDeleted.csv` before running the script in production.
- Deleted B2B accounts **cannot be recovered** unless they are still within the soft-delete retention period (typically 30 days).

---

## 📂 Output Files

| File Name                    | Description                                      |
|-----------------------------|--------------------------------------------------|
| `B2B_Guests_ToBeDeleted.csv` | Backup list of users targeted for deletion       |
| `B2B_DeleteFailures.csv`     | Log of failed deletions, including error messages |

---

## 💡 Optional Enhancements

You may extend this script to:

- Add a **dry-run mode** for testing without making changes
- Send **email or Teams alerts** when deletions or errors occur
- Schedule as a job using **Azure Automation**, **Windows Task Scheduler**, or a **CI/CD pipeline**
