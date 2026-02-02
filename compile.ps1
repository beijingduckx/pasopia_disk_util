function DoCpm{
    param(
        $arg
    )
    $arg = "./cpm.exe " + $arg
    Write-Host "Doing: $arg"
    $output = Invoke-Expression $arg
    
    '----'
    $arg
    $output

    if($output -match '[0-9]+ Fatal error'){
        Pop-Location
        Exit
    }
}

function Build{
    param(
        $basename
    )

    push-Location . 

    cd build

    try{
        New-Item -ItemType HardLink -Path . -Target "../$basename.z80" -Name "$basename.z80"
    }
    catch{
        Pop-Location
        Exit
    }

    # build
    try{
        DoCpm "m80 $basename.rel,$basename.prn=$basename.z80"
        DoCpm "l80 $basename.rel,$basename.bin /n/e"
    }
    catch{
        '** Assembly error'
        Pop-Location
        Exit
    }

    Pop-Location

}

# create source link

Build diskio
