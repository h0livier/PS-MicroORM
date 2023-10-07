class Utils{

    static [string] arrayCharacterFormatted([array] $array, [string] $char){
        [string] $result = ""
        [int] $last = $array.Length -1
        for($i = 0; $i -lt $array.Length; $i++){
            $val = $array[$i]
            if($i -ne $last){
                $result += $val + $char
            }else {
                $result += $val
            }
        }
        return $result
    }

    static [string] completeFolderName([string] $path){
        if($path[-1] -ne "\"){
            $path += "\"
        }
        return $path
    }

}