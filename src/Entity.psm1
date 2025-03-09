Using Module .\Database.psm1

class Entity {

    [string] $tableName
    [array] $baseColumns
    [string] $primaryKey

    Entity(){
        $this.tableName = $this.GetType().Name
        $this.baseColumns = ($this | Get-Member -MemberType Property).Name | Where-Object {$_ -notlike '*baseColumns*' -and $_ -notlike '*tableName*' -and $_ -notlike '*primaryKey*'} 
    }

    <#
    .SYNOPSIS
        fills the instance object with the value of the object given
    .PARAMETER input
        Represents data got by a SQL query
    #>
    [void] morph([Object] $source){
        foreach($m in $this.baseColumns){
            $this.$m = $source.$m
        }
    }

    <#
    .SYNOPSIS
        fills the output member with the value of the input given and return the output
    .PARAMETER input
        Represents data got by a SQL query
    .PARAMETER output
        Represents the object that members has to be filled
    #>
    [Entity] rowToEntity([Object] $source, [Entity] $output){
        foreach($m in $output.baseColumns){
            if($null -ne $source.$m -and "" -ne $source.$m){
                $output.$m = $source.$m
            }
        }
        return $output
    }

    <#
    .SYNOPSIS
        Executes a SQL select instruction
    .PARAMETER tableName
        Represents the queried SQL table name
    .PARAMETER attributes
        Represents the columns to select
    .PARAMETER options
        Represents the options given to make the SQL instruction 
        Can contain joins and where options
    #>
    static [object] select([string] $tableName, [array] $attributes, [hashtable] $options){
        $query = [Entity]::generateSelectQuery($tableName, $attributes, $options)
        $queryRes = [Database]::query($query)
        return $queryRes
    }

    <#
    .SYNOPSIS
        Executes a SQL Select instruction for the entity
    .PARAMETER options
        Represents the options given to make the SQL instruction
    #>
    [void] select([hashtable]$options = @{}){
        $object = [Entity]::select($this.tableName, $this.baseColumns, $options)
        $this.morph($object)
    }

    <#
    .SYNOPSIS
        Executes a SQL Insert instruction from entity object instance
    #>
    [void] insert(){
        $query = $this.generateInsertQuery()
        [Database]::query($query)
    }

    <#
    .SYNOPSIS
        Executes a SQL Update instruction based on the entity object instance
    #>
    [void] update(){
        $query = $this.generateUpdateQuery()
        [Database]::query($query)
    }

    <#
    .SYNOPSIS
        Executes a SQL Delete instruction based on the entity object instance
    #>
    [void] delete(){
        $query = $this.generateDeleteQuery()
        [Database]::query($query)
    }
    
    static [string] generateSelectQuery([string] $tableName, [array] $attributes, [hashtable] $options){
        $attributes = if($options.Keys -contains "attributes") {$options["attributes"]} else {$attributes}
        $where = if($options.Keys -contains "where") {$options["where"]} else {@()}
        $joins = if($options.Keys -contains "joins") {
            for([int] $i=0; $i -lt $attributes.Count; $i++){
                $attributes[$i] = $tableName + "." + $attributes[$i]
            }
            $options["joins"]
        } else {@()}
        $query = "SELECT " + ($attributes -join ", ") + " FROM [" +$tableName +"]"
        if($joins.Count -ne 0){
            $query += " INNER JOIN " + ($joins -join " INNER JOIN ")
        }
        if($where.Count -ne 0){
            $query += " WHERE " + ($where -join " AND ")
        }
        return $query
    }

    <#
    .SYNOPSIS
        Constructs a SQL Insert instruction based on the entity object instance
    #>
    [string] generateInsertQuery(){
        $query = "INSERT INTO ["+ $this.tableName +"] "
        $columns = @()
        $values = @()
        foreach($item in $this.baseColumns){
            if($item -ne $this.primaryKey){
                $columns += $item
                if($null -eq $this.$item){
                    $values += "NULL"
                }else{
                    if($this.$item.GetType().Name -eq "String"){
                        $values += "'"+$this.$item+"'"
                    }else{
                        $values += ""+$this.$item
                    }
                }
            }
        }
        $query += "("+($columns -join ", ")+") "
        $query += "values("+($values -join ", ")+")"
        return $query
    }

    <#
    .SYNOPSIS
        Constructs a SQL Update instruction based on the entity object instance
    #>
    [string] generateUpdateQuery(){
        $query = "UPDATE ["+ $this.tableName +"] SET "
        $vals = @()
        foreach($item in $this.baseColumns){
            if($item -ne $this.primaryKey){
                $line = ""
                $line += $item+"="
                if($null -eq $this.$item){
                    $line += "NULL"
                }else{
                    if($this.$item.GetType().Name -eq "String"){
                        $line += "'"+$this.$item+"'"
                    }else{
                        $line += ""+$this.$item
                    }
                }
                $vals += $line
            }
        }
        $query += ($vals -join ", ")

        # Add where option on primary key
        $query += " WHERE "
        $pk = $this.primaryKey
        $query += $pk+"="+$this.$pk
        return $query
    }

    <#
    .SYNOPSIS
        Constructs a SQL Delete instruction based on the entity object instance
    #>
    [string] generateDeleteQuery(){
        $pk = $this.primaryKey
        $query = 'DELETE from ['+ $this.tableName +'] WHERE '
        $query += $pk+"="+$this.$pk
        return $query
    }

}
