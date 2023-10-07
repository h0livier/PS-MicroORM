class Database {
    
    static [string] $SqlInstance
    static [string] $SqlDatabase

    <#
    .SYNOPSIS
        Loads Sql Server database instance and database name from config file
    #>
    static [bool] loadConnectionData(){
        try {
            $json = Get-Content -Path '..\config.json' | ConvertFrom-Json 
            [Database]::SqlInstance = $json.SqlInstance
            [Database]::SqlDatabase = $json.SqlDatabase
        }catch {
            return $false
        }
        return $true
    }

    <#
    .SYNOPSIS
        Checks if the Sql Server database instance and database are filled
    #>
    static [bool] connectionDataFilled(){
        $inst = [Database]::SqlInstance
        $dbName = [Database]::SqlDatabase
        if($null -ne $inst -and "" -ne $inst -and $null -ne $dbName -and "" -ne $dbName){
            return $true
        }
        return $false
    }

    <#
    .SYNOPSIS
        Defines the SqlInstance and SqlDatabase to use
    .PARAMETER instance
        Represents the instance to link
    .PARAMETER dbName
        Represents the database to link
    #>
    static setInstance([string] $instance, [string] $dbName){
        [Database]::SqlInstance = $instance
        [Database]::SqlDatabase = $dbName
    }

    <#
    .SYNOPSIS
        Executes an sql query on the defined database
    .PARAMETER sql
        SQL code to execute
    #>
    static [array] query([string] $sql){
        $inst = [Database]::SqlInstance
        $db = [Database]::SqlDatabase
        if([Database]::connectionDataFilled()){
            return Invoke-Sqlcmd -ServerInstance $inst -Database $db -Query $sql
        }
        return $null
    }

}