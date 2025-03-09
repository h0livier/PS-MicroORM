. $PSScriptRoot\..\src\Models\Order.ps1



Describe 'Orders Tests' {
    It 'Given no parameters, it should insert empty Order' {
        Write-Host $PSScriptRoot
        $order = Get-Order
        $order.generateInsertQuery() | Should Be "INSERT INTO [Order] (Customer, date) values(0, NULL)"
    }
}