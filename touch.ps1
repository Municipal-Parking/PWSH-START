function touch
{
    $file = $args[0]
    if($file -eq $null) {
        throw "No filename supplied"
    }

    if(Test-Path $file)
    {
        throw "file already exists"
    }
    else
    {
        # echo $null > $file
        New-Item -ItemType File -Name ($file)
    }
}
