# Notes for PnP Governance Sandbox

## Setting the environment

### 1. Register shell access for the application

```powershell
Register-PnPManagementShellAccess
```

### 2. Create the AAD Application

Create the application with default settings. As the Redirect URL use `https:localhost`. API permissions are as follows:

**SharePoint**
- SharePoint -> Delegated Permissions -> AllSites -> AllSites.FullControl
- SharePoint -> Delegated Permissions -> Sites -> Sites.Search.All
- SharePoint -> Delegated Permissions -> TermStore -> TermStore.ReadWrite.All
- SharePoint -> Delegated Permissions -> User -> User.ReadWrite.All

**MS Graph**
- Microsoft Graph -> Delegated Permissions -> User -> User.Read
- Microsoft Graph -> Delegated Permissions -> Directory -> Directory.ReadWrite.All
- Microsoft Graph -> Delegated Permissions -> Directory -> Directory.AccessAsUser.All
- Microsoft Graph -> Delegated Permissions -> Group -> Group.ReadWrite.All

Go to the *Authentication* menu under *Manage* category and check `Yes` in the *Enable the following mobile and desktop flows* section.

### 3. Authentication

For testing purposes, we can save the credentials to Windows Credential manager by running

```powershell
Add-PnPStoredCredential -Name "yourlabel" -Username youruser@domain.com
```

And then running the `Connect-PnPOnline` like:

```powershell
Connect-PnPOnline [yourtenant].sharepoint.com -Credentials "yourlabel"
```

