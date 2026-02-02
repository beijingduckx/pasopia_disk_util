#
#  Generate BLOAD sound for every track of a disk image
#

# WAV パラメータ
#$sampleRate = 32000
$sampleRate = 22050
$bitsPerSample = 8
$channels = 1

function WritePcmData($wav, $outfile) {
    # WAV ヘッダ作成
    $byteRate = $sampleRate * $channels * ($bitsPerSample / 8)
    $blockAlign = $channels * ($bitsPerSample / 8)
    $dataSize = $wav.Count
    $fileSize = 36 + $dataSize

    $fs = [System.IO.File]::Open($outfile, 'Create')
    $bw = New-Object System.IO.BinaryWriter($fs)

    # RIFFヘッダ
    $bw.Write([Text.Encoding]::ASCII.GetBytes("RIFF"))
    $bw.Write([BitConverter]::GetBytes($fileSize))

    $bw.Write([Text.Encoding]::ASCII.GetBytes("WAVE"))

    # fmt チャンク
    $bw.Write([Text.Encoding]::ASCII.GetBytes("fmt "))
    $bw.Write([BitConverter]::GetBytes(16))              # fmt chunk size
    $bw.Write([BitConverter]::GetBytes([int16]1))        # PCM
    $bw.Write([BitConverter]::GetBytes([int16]$channels))
    $bw.Write([BitConverter]::GetBytes($sampleRate))
    $bw.Write([BitConverter]::GetBytes($sampleRate))
    $bw.Write([BitConverter]::GetBytes([int16]$blockAlign))
    $bw.Write([BitConverter]::GetBytes([int16]$bitsPerSample))

    # data チャンク
    $bw.Write([Text.Encoding]::ASCII.GetBytes("data"))
    $bw.Write([BitConverter]::GetBytes($dataSize))
    $bw.Write($wav.ToArray())

    $bw.Close()
    $fs.Close()
}

function OutputData($bit, $duration, $wav) {
    $sampleCount = $sampleRate * $duration / 1000000
    for ($local:i = 0; $local:i -lt $sampleCount; $local:i++) {
        # リトルエンディアンで書き込み
        $wav.Add([byte]$bit)
    }
}

function OutputBit($bit, $wav) {
    $duration = 208
    if($bit -eq 1){
        $duration *= 2
    }

    OutputData 255 $duration $wav
    OutputData 0 $duration $wav

}

function OutputByte($byte, $wav) {
    # Start bit
    OutputBit 0 $wav
    #
    for($j = 0; $j -lt 8; $j++) {
        $bit = $byte -band 1
        OutputBit $bit $wav
        $byte = [byte]$byte -shr 1
    }
    # Stop bit
    OutputBit 1 $wav
}

function OutputByteArray($arr, $wav) {
    foreach($byte in $arr) {
        OutputByte $byte $wav
    }
}

#
#
#

function OutputBlock($headerLen, $block, $wav) {
    $header = New-Object System.Collections.Generic.List[byte]

    # Header 
    for($i = 0; $i -lt $headerLen; $i++) {
        OutputBit 1 $wav
    }

    # AA * 10 bytes
    for($i = 0; $i -lt 10; $i++){
        $header.Add(0xaa)
    }

    $header.AddRange($block)
    OutputByteArray $header $wav

    # Checksum
    $sum = 0
    foreach($abyte in $block) {
        $sum = $sum -bxor $abyte
    }
    OutputByte (($sum -band 0xff)) $wav

    # Post
    OutputByte 0xaa $wav
}

function GenBinPcmData($binData, $loadAddr, $pasofile, $wav) {
    $block = New-Object System.Collections.Generic.List[byte]

    # Block size (12bytes)
    $block.Add(0x0c)
    $block.Add(0x00)

    #
    # First block (File info)
    #

    $block.Add(0x01)
    $block.Add(0xfe)

    # Filename
    $filename = $pasofile

    $filename.ToCharArray()| ForEach-Object { 
        $abyte = [byte][char]$_
        $block.Add($abyte)
    }

    $len = 6 - $filename.Length
    for($i = 0; $i -lt $len; $i++) {
        $block.Add(0x00)
    }

    # Load Addr
    $block.AddRange([System.BitConverter]::GetBytes([uint16]$loadAddr))

    # Load Size
    $dataSize = $binData.Count
    $block.AddRange([System.BitConverter]::GetBytes([uint16]$dataSize))

#    OutputBlock 4800 $block $wav
    OutputBlock 1000 $block $wav


    #
    # Second block (binary data)
    #
    $block.Clear()

    $block.AddRange([System.BitConverter]::GetBytes([uint16]$dataSize))
    $block.AddRange($binData)

    OutputBlock 960 $block $wav
}

#
# Script Main
#

$tmpFilename = Join-path $PSScriptRoot "./tmp.wav"
$loadAddr = 0xe000

$trackLength = 256 * 16
$maxTrack = 70

$pasopiaFilename = "track"

if ($args.Count -eq 0) {
    $script = Split-Path $PSCommandPath -Leaf
    Write-Host "Usage: $script [disk image]"
    Write-Host "'disk image' need to be a plain (256bytes/sector) disk image."
    return
}

#

$loadFileName = Resolve-Path $args[0]

$diskImage = [System.IO.File]::ReadAllBytes($loadFileName)

$trackData = New-Object byte[] $trackLength
$pcm = New-Object System.Collections.Generic.List[byte]

$job = $null

for($track = 1; $track -lt $maxTrack; $track++) {
    [Buffer]::BlockCopy($diskImage, $track * $trackLength, $trackData, 0, $trackLength)

    $pcm.Clear()

    GenBinPcmData $trackData $loadAddr $pasopiaFilename $pcm

    if ($job) {
        Wait-Job $job | Out-Null
        Receive-Job $job
        Remove-Job $job
    }
    WritePcmData $pcm $tmpFilename
    Write-Host "Track: $track"

    $job = Start-Job -ScriptBlock {
        param($path)
        $player = New-Object System.Media.SoundPlayer $path
        $player.PlaySync()
    } -ArgumentList $tmpFileName
}

Wait-Job $job | Out-Null
Receive-Job $job
Remove-Job $job
