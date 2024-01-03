using module .\..\Entity.psm1

class User : Entity {

    [int] $Id
    [string] $Name
    [string] $Mail
    [string] $Password

    User([int] $id){
        $this.primaryKey = "Id"
        $this.select(@{"Where" = @("Id="+$id)})
    }

    User(){
        $this.primaryKey = "Id"
    }

    [array] getUserList(){
        $users = [Entity]::select($this.tableName, $this.baseColumns, @{})
        return $users
    }

}

function Get-User ([int] $id = 0){
    if( 0 -eq $id){
        return [User]::new()
    }
    return [User]::new($id)
}

function Get-Users (){
    return [User]::new().getUserList()
}

