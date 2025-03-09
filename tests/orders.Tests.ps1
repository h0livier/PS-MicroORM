Import-Module ".\src\Models\Order.ps1" -Force

Describe 'Orders Tests' {
    It 'Given no parameters, it should insert empty Order' {
        $order = Get-Order
        $order.generateInsertQuery() | Should Be "INSERT INTO [Order] (Customer, date) values(0, NULL)"
    }
}