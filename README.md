# SQL-Entity

This project has for purpose to generate SQL queries based on members defined in your custom classes.

It allows you to not take in charge the SQL queries in your powershell script to lighten them.<br>
It only supports SQL Server connection for the moment

## How to configure the SQL Connection

2 methods can be used to define the SQL instance and database

Either by defining it in the code
```powershell
using module .\src\Database.psm1

[Database]::SqlInstance = 'TEST-SQL\INSTDB01'
[Database]::SqlDatabase = 'Test'
[Database]::Password = ''
[Database]::Username = ''
```

Either by getting it from the config.json file with this code
```powershell
using module .\src\Database.psm1

[Database]::loadConnectionData()
```

**One of these 2 method should absolutely be used before trying to load data from Models**<br>
The models are using a method declared in Database who needs to know which Sql Server DBMS has to be used

## How to use it ?

To have more informations on how the class management system has been thought, you can check what has been written in the following files.
- .\src\Models\Customer.psm1
- .\src\Models\Order.psm1

I tried to manage it to be as simple as possible<br>
Once well parametered, you should just have to deal with 4 methods (select, insert, update and delete)

The select function can be tricky due to 'SQL.DataRow' conversion system to custom Object.<br>
But relax, an example is provided in the Customer model

Here is also a short example of how it can be used in a script
```powershell
using module .\src\Models\Customer.psm1

$c = [Customer]::new()

# Create a new Customer
$c.name = 'Test'
$c.decimal = 4.5
$c.insert()

# Update the Customer
$c.boolean = $true
$c.update()

# Delete the first customer
$c.delete()
```

You can also check the exemple.ps1 file at the root of the project