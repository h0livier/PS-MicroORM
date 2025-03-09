. $PSScriptRoot\src\Models\User.ps1

Describe 'Users Tests' {
    It 'Given no parameters, it should insert empty user' {
        $user = Get-User
        $user.generateInsertQuery() | Should Be "INSERT INTO [User] (Mail, Name, Password) values(NULL, NULL, NULL)"
    }
    It 'Given parameters, it should insert full user' {
        $user = Get-User
        $user.Mail = "o.hayot@test.be"
        $user.Name = "Olivier"
        $user.Password = "password123*"
        $user.generateInsertQuery() | Should Be "INSERT INTO [User] (Mail, Name, Password) values('o.hayot@test.be', 'Olivier', 'password123*')"
    }
}