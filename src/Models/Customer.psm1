using module .\..\Entity.psm1
using module .\Order.psm1

class Customer : Entity {

    [int] $Id
    [string] $name
    [double] $decimal
    [bool] $boolean

    Customer([int] $id){
        $this.primaryKey = "Id"
        $this.select(@{"Where" = @("Id="+$id)})
    }
    
    Customer(){
        $this.primaryKey = "Id"
    }

    [array] getOrders(){
        $order = [Order]::new()
        $results = [Entity]::select($order.tableName, $order.baseColumns, @{"where"=@("Customer="+$this.ID)})
        $output = @() 
        foreach($r in $results){
            $output += $order.rowToEntity($r, [Order]::new())
        }
        return $output
    }

}
