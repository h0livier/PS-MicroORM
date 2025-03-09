using module .\..\Entity.psm1

class Order : Entity {

    [int] $Id
    [string] $date
    [int] $Customer

    Order(){
        $this.primaryKey = "Id"
    }

}

function Get-Order ([int] $id = 0){
    if( 0 -eq $id){
        return [Order]::new()
    }
    return [Order]::new($id)
}
