# Variables - Update these
$Calendar = "sharedcalendar@yourdomain.com:\Calendar"
$Editors = @(
    "user1@yourdomain.com",
    "user2@yourdomain.com",
    "user3@yourdomain.com"
)

# Connect if not already connected
if (-not (Get-ConnectionInformation -ErrorAction SilentlyContinue)) {
    Connect-ExchangeOnline -ShowBanner:$false
}

# Get existing permissions once
$ExistingPerms = Get-MailboxFolderPermission -Identity $Calendar | 
    Select-Object -ExpandProperty User

# Set Default (everyone) permission
if ($ExistingPerms -contains "Default") {
    Set-MailboxFolderPermission -Identity $Calendar -User Default -AccessRights Reviewer -Confirm:$false
} else {
    Add-MailboxFolderPermission -Identity $Calendar -User Default -AccessRights Reviewer -Confirm:$false
}

# Batch process editors
$Editors | ForEach-Object -Parallel {
    $User = $_
    $CalendarPath = $using:Calendar
    $Existing = $using:ExistingPerms
    
    if ($User -in $Existing) {
        Set-MailboxFolderPermission -Identity $CalendarPath -User $User -AccessRights Editor -Confirm:$false
    } else {
        Add-MailboxFolderPermission -Identity $CalendarPath -User $User -AccessRights Editor -Confirm:$false
    }
} -ThrottleLimit 3
