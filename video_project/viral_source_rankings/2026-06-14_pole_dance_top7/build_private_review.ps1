$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$Project = $PSScriptRoot
$Source = Join-Path $Project "source_media"
$Core = Join-Path $Project "selects\core"
$Handles = Join-Path $Project "selects\handles"
$Work = Join-Path $Project "combined\work"
$Voice = Join-Path $Project "audio\voicebox"
$Output = Join-Path $Project "combined"
$Qa = Join-Path $Project "qa"
$Capcut = Join-Path $Project "capcut_project"
$CapcutMedia = Join-Path $Capcut "media"
$CapcutAudio = Join-Path $Capcut "audio"
$CapcutCaptions = Join-Path $Capcut "captions"
$Utf8 = New-Object System.Text.UTF8Encoding($false)
$Invariant = [Globalization.CultureInfo]::InvariantCulture
$ScriptLines = @(
    Get-Content -Encoding UTF8 (Join-Path $Project "script_ko.txt") |
        Where-Object { $_.Trim() }
)

New-Item -ItemType Directory -Force -Path `
    $Core, $Handles, $Work, $Voice, $Output, $Qa, `
    $CapcutMedia, $CapcutAudio, $CapcutCaptions | Out-Null

function Run {
    param([string]$Command, [string[]]$Arguments)
    & $Command @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "$Command failed with exit code $LASTEXITCODE"
    }
}

function Number {
    param([double]$Value)
    return $Value.ToString("0.###", $Invariant)
}

$Items = @(
    @{ Name="01_spiral_pole"; Source="ZHhePoJhs8g.mp4"; Start=303.0 },
    @{ Name="02_red_stage_invert"; Source="oawEi97c65w.mp4"; Start=207.5 },
    @{ Name="03_high_leg_extension"; Source="iU7vnUh2eaI.mp4"; Start=224.0 },
    @{ Name="04_one_arm_surprise"; Source="wgsbpMrFjAE.mp4"; Start=127.0 },
    @{ Name="05_artistic_transition"; Source="awcrkc_0cKo.mp4"; Start=33.0 },
    @{ Name="06_practice_to_winner"; Source="7630820577996967200.mp4"; Start=2.4 },
    @{ Name="07_exo_gen_finish"; Source="7577612168657521938.mp4"; Start=28.0 }
)

if ($ScriptLines.Count -ne $Items.Count) {
    throw "Expected $($Items.Count) narration lines, found $($ScriptLines.Count)"
}

$VideoFilter = "[0:v]split=2[bg][fg];" +
    "[bg]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920," +
    "gblur=sigma=34,eq=brightness=-0.24:saturation=0.82[back];" +
    "[fg]scale=1080:-2:flags=lanczos[front];" +
    "[back][front]overlay=(W-w)/2:(H-h)/2,setsar=1,fps=30," +
    "zoompan=z='min(zoom+0.00011,1.025)':x='iw/2-(iw/zoom/2)':" +
    "y='ih/2-(ih/zoom/2)':d=1:s=1080x1920:fps=30,format=yuv420p[v]"

$Concat = New-Object System.Collections.Generic.List[string]
$MidFrames = New-Object System.Collections.Generic.List[string]

for ($Index = 0; $Index -lt $Items.Count; $Index++) {
    $Item = $Items[$Index]
    $Input = Join-Path $Source $Item.Source
    $CorePath = Join-Path $Core "$($Item.Name).mp4"
    $HandlePath = Join-Path $Handles "$($Item.Name)_handles.mp4"
    $VoicePath = Join-Path $Voice "$($Item.Name).wav"
    $HandleStart = [Math]::Max(0, $Item.Start - 1.0)
    $NarrationText = $ScriptLines[$Index].ToString()

    if (-not (Test-Path $Input)) {
        throw "Missing source: $Input"
    }

    if (-not (Test-Path $CorePath)) {
        Run "ffmpeg" @(
            "-y", "-hide_banner", "-loglevel", "warning",
            "-ss", (Number $Item.Start), "-i", $Input, "-t", "8",
            "-filter_complex", $VideoFilter,
            "-map", "[v]", "-map", "0:a?",
            "-c:v", "h264_nvenc", "-preset", "p5", "-cq", "20", "-b:v", "0",
            "-c:a", "aac", "-b:a", "160k", "-ar", "48000",
            "-movflags", "+faststart", $CorePath
        )
    }

    if (-not (Test-Path $HandlePath)) {
        Run "ffmpeg" @(
            "-y", "-hide_banner", "-loglevel", "warning",
            "-ss", (Number $HandleStart), "-i", $Input, "-t", "10",
            "-filter_complex", $VideoFilter,
            "-map", "[v]", "-map", "0:a?",
            "-c:v", "h264_nvenc", "-preset", "p5", "-cq", "20", "-b:v", "0",
            "-c:a", "aac", "-b:a", "160k", "-ar", "48000",
            "-movflags", "+faststart", $HandlePath
        )
    }

    if (-not (Test-Path $VoicePath)) {
        $RequestPath = Join-Path $Work "$($Item.Name)_request.json"
        $ResponsePath = Join-Path $Work "$($Item.Name)_response.json"
        $Request = @{
            profile_id = "a4370ede-b139-451f-a868-96deee16b21d"
            text = $NarrationText
            language = "ko"
            model_size = "0.6B"
            engine = "qwen_custom_voice"
            instruct = "Energetic and natural Korean YouTube narration, clear pronunciation, medium-fast pace."
            normalize = $true
        } | ConvertTo-Json -Depth 4
        [IO.File]::WriteAllText($RequestPath, $Request, $Utf8)
        Run "curl.exe" @(
            "-sS", "-X", "POST", "http://127.0.0.1:17493/generate",
            "-H", "Content-Type: application/json; charset=utf-8",
            "--data-binary", "@$RequestPath",
            "-o", $ResponsePath
        )
        $Response = Get-Content -Raw -Encoding UTF8 $ResponsePath | ConvertFrom-Json
        if (
            -not ($Response.PSObject.Properties.Name -contains "id") -or
            -not $Response.id
        ) {
            throw "VoiceBox did not return a generation id for $($Item.Name)"
        }
        $GenerationId = $Response.id
        $Deadline = (Get-Date).AddMinutes(15)
        do {
            Start-Sleep -Seconds 3
            $StatusPath = Join-Path $Work "$($Item.Name)_status.json"
            Run "curl.exe" @(
                "-sS", "http://127.0.0.1:17493/history/$GenerationId",
                "-o", $StatusPath
            )
            $Status = Get-Content -Raw -Encoding UTF8 $StatusPath | ConvertFrom-Json
            if ($Status.status -eq "failed") {
                throw "VoiceBox generation failed for $($Item.Name): $($Status.error)"
            }
        } while ($Status.status -ne "completed" -and (Get-Date) -lt $Deadline)
        if ($Status.status -ne "completed") {
            throw "VoiceBox generation timed out for $($Item.Name)"
        }
        Run "curl.exe" @(
            "-sS", "http://127.0.0.1:17493/audio/$GenerationId",
            "-o", $VoicePath
        )
    }

    $Narrated = Join-Path $Work "$($Item.Name)_narrated.mp4"
    $AudioFilter = "[0:a]volume=0.30,aresample=48000,apad=pad_dur=8,atrim=0:8[src];" +
        "[1:a]adelay=250|250,volume=1.08,aresample=48000,apad=pad_dur=8,atrim=0:8[tts];" +
        "[src][tts]amix=inputs=2:duration=first:dropout_transition=0," +
        "loudnorm=I=-16:LRA=7:TP=-1.5[a]"
    Run "ffmpeg" @(
        "-y", "-hide_banner", "-loglevel", "warning",
        "-i", $CorePath, "-i", $VoicePath,
        "-filter_complex", $AudioFilter,
        "-map", "0:v", "-map", "[a]", "-t", "8",
        "-c:v", "copy", "-c:a", "aac", "-b:a", "192k",
        "-movflags", "+faststart", $Narrated
    )
    $Concat.Add("file '$($Narrated.Replace('\','/'))'")

    $Mid = Join-Path $Qa "$($Item.Name)_mid.jpg"
    Run "ffmpeg" @(
        "-y", "-hide_banner", "-loglevel", "error",
        "-ss", "4", "-i", $CorePath, "-frames:v", "1",
        "-vf", "scale=270:480:force_original_aspect_ratio=decrease,pad=270:480:(ow-iw)/2:(oh-ih)/2:black",
        $Mid
    )
    $MidFrames.Add($Mid)

    Copy-Item $CorePath (Join-Path $CapcutMedia ([IO.Path]::GetFileName($CorePath))) -Force
    Copy-Item $HandlePath (Join-Path $CapcutMedia ([IO.Path]::GetFileName($HandlePath))) -Force
    Copy-Item $VoicePath (Join-Path $CapcutAudio ([IO.Path]::GetFileName($VoicePath))) -Force
}

$ConcatPath = Join-Path $Work "concat.txt"
[IO.File]::WriteAllLines($ConcatPath, [string[]]$Concat, $Utf8)
$Joined = Join-Path $Work "joined.mp4"
Run "ffmpeg" @(
    "-y", "-hide_banner", "-loglevel", "warning",
    "-f", "concat", "-safe", "0", "-i", $ConcatPath,
    "-c", "copy", "-movflags", "+faststart", $Joined
)

$Final = Join-Path $Output "selects_combined.mp4"
$Subtitle = (Join-Path $Project "captions\private_review.ass").Replace("\", "/").Replace(":", "\:")
Run "ffmpeg" @(
    "-y", "-hide_banner", "-loglevel", "warning",
    "-i", $Joined, "-vf", "subtitles='$Subtitle'",
    "-c:v", "h264_nvenc", "-preset", "p5", "-cq", "20", "-b:v", "0",
    "-c:a", "copy", "-movflags", "+faststart", $Final
)

$Montage = Join-Path $Qa "core_mid_montage.jpg"
$MontageArgs = @("-y", "-hide_banner", "-loglevel", "error")
foreach ($Mid in $MidFrames) {
    $MontageArgs += @("-i", $Mid)
}
$MontageArgs += @(
    "-filter_complex",
    "xstack=inputs=7:layout=0_0|270_0|540_0|810_0|0_480|270_480|540_480:fill=black",
    "-frames:v", "1", $Montage
)
Run "ffmpeg" $MontageArgs

Copy-Item $Final (Join-Path $Project "private_review.mp4") -Force
Copy-Item $Final (Join-Path $Capcut "private_review.mp4") -Force
Copy-Item (Join-Path $Project "captions\private_review.srt") $CapcutCaptions -Force
Copy-Item (Join-Path $Project "captions\private_review.ass") $CapcutCaptions -Force

Write-Host "Created $Final"
