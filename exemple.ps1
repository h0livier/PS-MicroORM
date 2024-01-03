using module ".\src\Database.psm1"
Import-Module ".\src\Models\User.ps1" -Force

[Database]::SqlInstance = 'localhost'
[Database]::SqlDatabase = 'Test'
[Database]::Password = ''
[Database]::Username = ''

# Create a new User
$user = Get-User

# Fill only one variable and insert it
$user.Mail = "Test@gmail.com"
$user.insert()

# Fill another variable and modify it
$user.Name = "Test"
$user.update()

# Removes the user
#$user.delete()