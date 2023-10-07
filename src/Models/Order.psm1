using module .\..\Entity.psm1

class Order : Entity {

    [int] $Id
    [string] $date
    [int] $Customer

    Order(){
        $this.primaryKey = "Id"
    }

}
