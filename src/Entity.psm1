Using Module .\Database.psm1
Using module .\Utils.psm1

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
        Constructs a SQL select instruction
    .PARAMETER tableName
        Represents the queried SQL table name
    .PARAMETER attributes
        Represents the columns to select
    .PARAMETER options
        Represents the options given to make the SQL instruction 
        Can contain joins and where options
    #>
    static [array] select([string] $tableName, [array] $attributes, [hashtable] $options){
        $attributes = if($options.Keys -contains "attributes") {$options["attributes"]} else {$attributes}
        $where = if($options.Keys -contains "where") {$options["where"]} else {@()}
        $joins = if($options.Keys -contains "joins") {
            for([int] $i=0; $i -lt $attributes.Count; $i++){
                $attributes[$i] = $tableName + "." + $attributes[$i]
            }
            $options["joins"]
        } else {@()}
        $query = "SELECT " + ($attributes -join ", ") + " FROM " +$tableName
        if($joins.Count -ne 0){
            $query += " INNER JOIN " + ($joins -join " INNER JOIN ")
        }
        if($where.Count -ne 0){
            $query += " WHERE " + ($where -join " AND ")
        }
        return [Database]::query($query)
    }

    <#
    .SYNOPSIS
        Constructs a SQL select instruction for the entity
    .PARAMETER options
        Represents the options given to make the SQL instruction
    #>
    [Object] select([hashtable]$options = @{}){
        return [Entity]::select($this.tableName, $this.baseColumns, $options)
    }

    <#
    .SYNOPSIS
        Constructs a SQL insert instruction from entity object instance
    #>
    [void] insert(){
        $query = "INSERT INTO "+ $this.tableName +""
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
        [Database]::query($query)
    }

    <#
    .SYNOPSIS
        Constructs a SQL update instruction based on the entity object instance
    .PARAMETER where
        Represents the options used to filter on which lines the update has to be applied
    #>
    [void] update(){
        $query = "UPDATE "+ $this.tableName +" SET "
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
        
        [Database]::query($query)
    }

    [void] delete(){
        $query = 'DELETE from '+ $this.tableName +' WHERE '
        $pk = $this.primaryKey
        $query += $pk+"="+$this.$pk
        [Database]::query($query)
    }

}
