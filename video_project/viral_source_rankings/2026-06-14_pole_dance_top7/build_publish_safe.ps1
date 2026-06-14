$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$Project = $PSScriptRoot
$Safe = Join-Path $Project "publish_safe"
$Source = Join-Path $Safe "source_media"
$Selects = Join-Path $Safe "selects"
$Audio = Join-Path $Safe "audio"
$Combined = Join-Path $Safe "combined"
$Captions = Join-Path $Safe "captions"
$Qa = Join-Path $Safe "qa"
$Runs = Join-Path $Safe "runs"
$Capcut = Join-Path $Safe "capcut_project"
$Work = Join-Path $Combined "work"
$Utf8 = New-Object System.Text.UTF8Encoding($false)
$Invariant = [Globalization.CultureInfo]::InvariantCulture
$RightsChecker = Join-Path $env:USERPROFILE ".codex\skills\video-editing-compliance-skill\scripts\rights_check.py"
$RightsManifest = Join-Path $Project "rights.manifest.replacement.json"
$ScriptLines = @(
    Get-Content -Encoding UTF8 (Join-Path $Safe "script_ko.txt") |
        Where-Object { $_.Trim() }
)

New-Item -ItemType Directory -Force -Path `
    $Selects, $Audio, $Combined, $Qa, $Runs, $Work, `
    (Join-Path $Capcut "media"), `
    (Join-Path $Capcut "audio"), `
    (Join-Path $Capcut "captions") | Out-Null

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

Run "python" @(
    $RightsChecker,
    $RightsManifest,
    "--operation", "render",
    "--log-dir", $Runs
)

$Items = @(
    @{ Name="01_fire_sword"; Source="01_fire_sword.mp4"; Start=0.0 },
    @{ Name="02_aerial_aerobics"; Source="02_aerial_aerobics.mp4"; Start=4.0 },
    @{ Name="03_circus_ropes"; Source="03_circus_ropes.mp4"; Start=3.0 },
    @{ Name="04_rope_performers"; Source="04_rope_performers.mp4"; Start=1.0 },
    @{ Name="05_neon_dancer"; Source="05_neon_dancer.mp4"; Start=0.0 },
    @{ Name="06_silhouette_duet"; Source="06_silhouette_duet.mp4"; Start=1.0 },
    @{ Name="07_abandoned_dance"; Source="07_abandoned_dance.mp4"; Start=2.0 }
)

if ($ScriptLines.Count -ne $Items.Count) {
    throw "Expected $($Items.Count) narration lines, found $($ScriptLines.Count)"
}

$Profiles = Invoke-RestMethod -Uri "http://127.0.0.1:17493/profiles"
$SoheeProfile = $Profiles |
    Where-Object {
        $_ -and
        ($_.PSObject.Properties.Name -contains "voice_type") -and
        $_.voice_type -eq "preset" -and
        $_.preset_engine -eq "qwen_custom_voice" -and
        $_.preset_voice_id -eq "Sohee"
    } |
    Select-Object -First 1
if (-not $SoheeProfile) {
    $ProfileRequest = @{
        name = "Sohee Korean Narration"
        description = "Built-in Qwen CustomVoice Sohee preset"
        language = "ko"
        voice_type = "preset"
        preset_engine = "qwen_custom_voice"
        preset_voice_id = "Sohee"
        default_engine = "qwen_custom_voice"
    } | ConvertTo-Json -Depth 4
    $SoheeProfile = Invoke-RestMethod `
        -Uri "http://127.0.0.1:17493/profiles" `
        -Method Post `
        -ContentType "application/json; charset=utf-8" `
        -Body ([Text.Encoding]::UTF8.GetBytes($ProfileRequest))
}
$ProfileId = $SoheeProfile.id

$Concat = New-Object System.Collections.Generic.List[string]
$NarrationInputs = New-Object System.Collections.Generic.List[string]
$NarrationFilters = New-Object System.Collections.Generic.List[string]

for ($Index = 0; $Index -lt $Items.Count; $Index++) {
    $Item = $Items[$Index]
    $Input = Join-Path $Source $Item.Source
    $Clip = Join-Path $Selects "$($Item.Name).mp4"
    $Voice = Join-Path $Audio "$($Item.Name).wav"
    $NarrationText = $ScriptLines[$Index].ToString()

    if (-not (Test-Path $Input)) {
        throw "Missing source: $Input"
    }

    $VideoFilter = "scale=1080:1920:force_original_aspect_ratio=increase:flags=lanczos," +
        "crop=1080:1920,setsar=1,fps=30," +
        "zoompan=z='min(zoom+0.00014,1.035)':" +
        "x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':" +
        "d=1:s=1080x1920:fps=30," +
        "eq=contrast=1.07:saturation=1.12," +
        "fade=t=in:st=0:d=0.12,fade=t=out:st=7.82:d=0.18,format=yuv420p"

    Run "ffmpeg" @(
        "-y", "-hide_banner", "-loglevel", "warning",
        "-ss", (Number $Item.Start), "-i", $Input, "-t", "8",
        "-vf", $VideoFilter, "-an",
        "-c:v", "h264_nvenc", "-preset", "p5", "-cq", "20", "-b:v", "0",
        "-movflags", "+faststart", $Clip
    )

    if (-not (Test-Path $Voice)) {
        $RequestPath = Join-Path $Work "$($Item.Name)_request.json"
        $ResponsePath = Join-Path $Work "$($Item.Name)_response.json"
        $Request = @{
            profile_id = $ProfileId
            text = $NarrationText
            language = "ko"
            model_size = "0.6B"
            engine = "qwen_custom_voice"
            instruct = "Energetic, natural Korean documentary narration with clear pronunciation and a medium-fast pace."
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
        $Deadline = (Get-Date).AddMinutes(20)
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
            "-o", $Voice
        )
    }

    $Concat.Add("file '$($Clip.Replace('\','/'))'")
    $NarrationInputs.Add("-i")
    $NarrationInputs.Add($Voice)
    $Delay = $Index * 8000 + 250
    $NarrationFilters.Add(
        "[$($Index):a]adelay=$Delay|$Delay,volume=1.04,aresample=48000[n$Index]"
    )

    Copy-Item $Clip (Join-Path $Capcut "media\$($Item.Name).mp4") -Force
    Copy-Item $Voice (Join-Path $Capcut "audio\$($Item.Name).wav") -Force
}

$ConcatPath = Join-Path $Work "concat.txt"
[IO.File]::WriteAllLines($ConcatPath, [string[]]$Concat, $Utf8)
$Joined = Join-Path $Work "joined.mp4"
Run "ffmpeg" @(
    "-y", "-hide_banner", "-loglevel", "warning",
    "-f", "concat", "-safe", "0", "-i", $ConcatPath,
    "-c", "copy", "-movflags", "+faststart", $Joined
)

$Bgm = Join-Path $Audio "original_bgm.wav"
$BgmFilter = "[0:a]volume=0.20,tremolo=f=2:d=0.82[low];" +
    "[1:a]volume=0.055,tremolo=f=4:d=0.68[high];" +
    "[2:a]lowpass=f=900,volume=0.24[texture];" +
    "[low][high][texture]amix=inputs=3:normalize=0," +
    "afade=t=in:st=0:d=0.8,afade=t=out:st=54.5:d=1.5," +
    "loudnorm=I=-27:LRA=7:TP=-3[a]"
Run "ffmpeg" @(
    "-y", "-hide_banner", "-loglevel", "warning",
    "-f", "lavfi", "-i", "sine=frequency=55:duration=56:sample_rate=48000",
    "-f", "lavfi", "-i", "sine=frequency=110:duration=56:sample_rate=48000",
    "-f", "lavfi", "-i", "anoisesrc=color=pink:duration=56:amplitude=0.06:sample_rate=48000",
    "-filter_complex", $BgmFilter,
    "-map", "[a]", "-c:a", "pcm_s16le", $Bgm
)

$Narration = Join-Path $Audio "narration.wav"
$NarrationFilter = ($NarrationFilters -join ";") + ";" +
    ((0..($Items.Count - 1) | ForEach-Object { "[n$_]" }) -join "") +
    "amix=inputs=$($Items.Count):duration=longest:normalize=0," +
    "atrim=0:56,loudnorm=I=-16:LRA=7:TP=-1.5[narr]"
$NarrationArgs = @("-y", "-hide_banner", "-loglevel", "warning")
$NarrationArgs += [string[]]$NarrationInputs
$NarrationArgs += @(
    "-filter_complex", $NarrationFilter,
    "-map", "[narr]", "-c:a", "pcm_s16le", $Narration
)
Run "ffmpeg" $NarrationArgs

$Mixed = Join-Path $Audio "final_mix.m4a"
$MixFilter = "[0:a]volume=0.48[bgm];[1:a]volume=1.0[voice];" +
    "[bgm][voice]amix=inputs=2:duration=first:dropout_transition=0," +
    "loudnorm=I=-15:LRA=7:TP=-1.5[a]"
Run "ffmpeg" @(
    "-y", "-hide_banner", "-loglevel", "warning",
    "-i", $Bgm, "-i", $Narration,
    "-filter_complex", $MixFilter,
    "-map", "[a]", "-t", "56", "-c:a", "aac", "-b:a", "192k",
    "-ar", "48000", $Mixed
)

$AssPath = (Join-Path $Captions "publish_safe.ass").Replace("\", "/").Replace(":", "\:")
$Final = Join-Path $Combined "pole_aerial_top7_publish_safe.mp4"
Run "ffmpeg" @(
    "-y", "-hide_banner", "-loglevel", "warning",
    "-i", $Joined, "-i", $Mixed,
    "-vf", "subtitles='$AssPath'",
    "-map", "0:v", "-map", "1:a", "-t", "56",
    "-c:v", "h264_nvenc", "-preset", "p5", "-cq", "19", "-b:v", "0",
    "-c:a", "copy", "-movflags", "+faststart", $Final
)

Copy-Item $Final (Join-Path $Project "pole_aerial_top7_publish_safe.mp4") -Force
Copy-Item $Final (Join-Path $Capcut "pole_aerial_top7_publish_safe.mp4") -Force
Copy-Item $Bgm (Join-Path $Capcut "audio\original_bgm.wav") -Force
Copy-Item $Narration (Join-Path $Capcut "audio\narration.wav") -Force
Copy-Item (Join-Path $Captions "publish_safe.srt") (Join-Path $Capcut "captions") -Force
Copy-Item (Join-Path $Captions "publish_safe.ass") (Join-Path $Capcut "captions") -Force

$QaTimes = @(1, 9, 17, 25, 33, 41, 49, 55)
foreach ($Second in $QaTimes) {
    $Frame = Join-Path $Qa ("frame_{0:D2}.jpg" -f $Second)
    Run "ffmpeg" @(
        "-y", "-hide_banner", "-loglevel", "error",
        "-ss", $Second.ToString(), "-i", $Final,
        "-frames:v", "1", "-q:v", "2", $Frame
    )
}

Run "ffprobe" @(
    "-v", "error",
    "-show_entries", "format=duration:stream=index,codec_name,width,height,r_frame_rate",
    "-of", "json", $Final
)

Write-Host "Created $Final"
