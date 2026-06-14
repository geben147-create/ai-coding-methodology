$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$ProjectDir = $PSScriptRoot
$PlanPath = Join-Path $ProjectDir "render_plan.json"
$SourceDir = Join-Path $ProjectDir "source_media"
$AudioDir = Join-Path $ProjectDir "audio"
$CoreDir = Join-Path $ProjectDir "selects\core"
$HandleDir = Join-Path $ProjectDir "selects\handles"
$CombinedDir = Join-Path $ProjectDir "combined"
$CaptionDir = Join-Path $ProjectDir "captions"
$WorkDir = Join-Path $ProjectDir "work"
$QaDir = Join-Path $ProjectDir "qa"
$CapCutDir = Join-Path $ProjectDir "capcut_project"
$CapCutCore = Join-Path $CapCutDir "media\core"
$CapCutHandles = Join-Path $CapCutDir "media\handles"
$CapCutAudio = Join-Path $CapCutDir "audio"
$CapCutCaptions = Join-Path $CapCutDir "captions"
$BgmPath = Join-Path $AudioDir "Never Coming Down - The Soundlings.mp3"

New-Item -ItemType Directory -Force -Path `
    $AudioDir, $CoreDir, $HandleDir, $CombinedDir, $CaptionDir, $WorkDir, `
    $QaDir, $CapCutCore, $CapCutHandles, $CapCutAudio, $CapCutCaptions |
    Out-Null

$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$Plan = Get-Content -Raw -Encoding UTF8 $PlanPath | ConvertFrom-Json

function Invoke-External {
    param([string]$Command, [string[]]$Arguments)
    & $Command @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "$Command failed with exit code $LASTEXITCODE"
    }
}

function Escape-AssText {
    param([string]$Text)
    return $Text.Replace("\", "\\").Replace("{", "\{").Replace("}", "\}")
}

function Write-ClipAss {
    param(
        [object]$Clip,
        [string]$Path
    )

    $title = Escape-AssText ([string]$Plan.topic)
    $subtitle = Escape-AssText ([string]$Plan.subtitle)
    $captionA = Escape-AssText ([string]$Clip.caption_a)
    $captionB = Escape-AssText ([string]$Clip.caption_b)

    $events = New-Object System.Collections.Generic.List[string]
    $events.Add("Dialogue: 0,0:00:00.00,0:00:08.00,Title,,0,0,0,,{\fad(100,100)}$title")
    $events.Add("Dialogue: 0,0:00:00.00,0:00:08.00,Subtitle,,0,0,0,,{\fad(100,100)}$subtitle")

    for ($rank = 1; $rank -le 7; $rank++) {
        $y = 425 + (($rank - 1) * 78)
        if ($rank -eq [int]$Clip.order) {
            $events.Add("Dialogue: 0,0:00:00.00,0:00:08.00,Current,,0,0,0,,{\pos(78,$y)\an5\fad(80,80)\t(0,180,\fscx118\fscy118)}$rank")
        } else {
            $events.Add("Dialogue: 0,0:00:00.00,0:00:08.00,Rank,,0,0,0,,{\pos(78,$y)\an5}$rank")
        }
    }

    $events.Add("Dialogue: 0,0:00:00.10,0:00:04.00,Reaction,,0,0,0,,{\fad(120,120)\t(100,350,\fscx106\fscy106)}$captionA")
    $events.Add("Dialogue: 0,0:00:04.00,0:00:07.90,Reaction,,0,0,0,,{\fad(120,120)\t(0,250,\fscx106\fscy106)}$captionB")

    $header = @"
[Script Info]
ScriptType: v4.00+
PlayResX: 1080
PlayResY: 1920
ScaledBorderAndShadow: yes

[V4+ Styles]
Format: Name,Fontname,Fontsize,PrimaryColour,SecondaryColour,OutlineColour,BackColour,Bold,Italic,Underline,StrikeOut,ScaleX,ScaleY,Spacing,Angle,BorderStyle,Outline,Shadow,Alignment,MarginL,MarginR,MarginV,Encoding
Style: Title,Malgun Gothic,72,&H0000FFFF,&H0000FFFF,&H00101010,&H80000000,-1,0,0,0,100,100,0,0,1,5,1,8,30,30,72,1
Style: Subtitle,Malgun Gothic,54,&H00FFFFFF,&H00FFFFFF,&H00101010,&H80000000,-1,0,0,0,100,100,0,0,1,4,1,8,30,30,154,1
Style: Rank,Malgun Gothic,42,&H00E8E8E8,&H00E8E8E8,&H00101010,&H60000000,-1,0,0,0,100,100,0,0,1,4,1,7,0,0,0,1
Style: Current,Malgun Gothic,62,&H003030FF,&H003030FF,&H00FFFFFF,&H80000000,-1,0,0,0,100,100,0,0,1,5,1,7,0,0,0,1
Style: Reaction,Malgun Gothic,74,&H00FFFFFF,&H00FFFFFF,&H00101010,&HA0000000,-1,0,0,0,100,100,0,0,3,12,0,2,80,80,285,1

[Events]
Format: Layer,Start,End,Style,Name,MarginL,MarginR,MarginV,Effect,Text
"@
    $content = $header + "`r`n" + (($events.ToArray()) -join "`r`n") + "`r`n"
    [IO.File]::WriteAllText($Path, $content, $Utf8NoBom)
}

if (-not (Test-Path $BgmPath)) {
    throw "Missing YouTube Audio Library track: $BgmPath"
}

$HighResGrandma = Join-Path $SourceDir "7451355930031033646.mp4"
$AudioGrandma = Join-Path $SourceDir "7451355930031033646_audio.mp4"
$MuxedGrandma = Join-Path $SourceDir "7451355930031033646_muxed.mp4"
if (-not (Test-Path $MuxedGrandma)) {
    if (-not (Test-Path $HighResGrandma) -or -not (Test-Path $AudioGrandma)) {
        throw "Missing grandma video or audio source"
    }
    Invoke-External ffmpeg @(
        "-y", "-hide_banner", "-loglevel", "warning",
        "-i", $HighResGrandma,
        "-i", $AudioGrandma,
        "-map", "0:v:0", "-map", "1:a:0",
        "-c:v", "copy", "-c:a", "copy",
        "-shortest",
        $MuxedGrandma
    )
}

$concatLines = New-Object System.Collections.Generic.List[string]
$corePaths = New-Object System.Collections.Generic.List[string]

foreach ($clip in $Plan.clips) {
    $index = ([int]$clip.order).ToString("00")
    $slug = [string]$clip.slug
    $source = Join-Path $SourceDir ([string]$clip.source)
    $core = Join-Path $CoreDir "${index}_${slug}.mp4"
    $handle = Join-Path $HandleDir "${index}_${slug}_handles.mp4"
    $ass = Join-Path $CaptionDir "${index}_${slug}.ass"

    if (-not (Test-Path $source)) {
        throw "Missing source: $source"
    }

    Write-ClipAss -Clip $clip -Path $ass
    $assFilter = $ass.Replace("\", "/").Replace(":", "\:")
    $videoBase = "scale=1166:2074:force_original_aspect_ratio=increase,crop=1080:1920:x='(iw-ow)/2+10*sin(t*1.3)':y='(ih-oh)/2+10*cos(t*1.1)',setsar=1,fps=30,eq=contrast=1.025:saturation=1.04"
    $videoOverlay = "$videoBase,drawbox=x=0:y=0:w=iw:h=250:color=black@0.42:t=fill,drawbox=x=18:y=370:w=120:h=610:color=black@0.28:t=fill,drawbox=x=0:y=0:w=iw:h=ih:color=white@0.38:t=fill:enable='lt(t,0.12)',subtitles='$assFilter'"
    $audioFilter = "aresample=48000,highpass=f=70,alimiter=limit=0.95,atrim=0:8,asetpts=N/SR/TB"

    Invoke-External ffmpeg @(
        "-y", "-hide_banner", "-loglevel", "warning",
        "-ss", ([string]$clip.core_in), "-i", $source,
        "-t", "8",
        "-vf", $videoOverlay,
        "-af", $audioFilter,
        "-c:v", "libx264", "-preset", "veryfast", "-crf", "19",
        "-r", "30", "-pix_fmt", "yuv420p",
        "-c:a", "aac", "-b:a", "192k", "-ar", "48000",
        "-movflags", "+faststart",
        $core
    )

    Invoke-External ffmpeg @(
        "-y", "-hide_banner", "-loglevel", "warning",
        "-ss", ([string]$clip.handle_in), "-i", $source,
        "-t", "10",
        "-vf", "$videoBase",
        "-af", "aresample=48000,highpass=f=70,alimiter=limit=0.95,atrim=0:10,asetpts=N/SR/TB",
        "-c:v", "libx264", "-preset", "veryfast", "-crf", "19",
        "-r", "30", "-pix_fmt", "yuv420p",
        "-c:a", "aac", "-b:a", "192k", "-ar", "48000",
        "-movflags", "+faststart",
        $handle
    )

    $corePaths.Add($core)
    $concatLines.Add("file '$($core.Replace('\','/'))'")
}

$concatPath = Join-Path $WorkDir "core_concat.txt"
[IO.File]::WriteAllLines($concatPath, $concatLines.ToArray(), $Utf8NoBom)

$joined = Join-Path $WorkDir "joined_source_audio.mp4"
Invoke-External ffmpeg @(
    "-y", "-hide_banner", "-loglevel", "warning",
    "-f", "concat", "-safe", "0", "-i", $concatPath,
    "-c", "copy",
    $joined
)

$combined = Join-Path $CombinedDir "selects_combined.mp4"
Invoke-External ffmpeg @(
    "-y", "-hide_banner", "-loglevel", "warning",
    "-i", $joined,
    "-stream_loop", "-1", "-i", $BgmPath,
    "-t", "56",
    "-filter_complex", "[0:a]aresample=48000,volume=1.0[a0];[1:a]aresample=48000,atrim=0:56,asetpts=N/SR/TB,volume=0.04,afade=t=in:st=0:d=0.5,afade=t=out:st=55.5:d=0.5[a1];[a0][a1]amix=inputs=2:duration=first:dropout_transition=0:normalize=0,alimiter=limit=0.95[a]",
    "-map", "0:v:0", "-map", "[a]",
    "-c:v", "copy",
    "-c:a", "aac", "-b:a", "192k", "-ar", "48000",
    "-movflags", "+faststart",
    $combined
)

$montage = Join-Path $QaDir "core_mid_montage.jpg"
$montageArgs = New-Object System.Collections.Generic.List[string]
$montageArgs.AddRange([string[]]@("-y", "-hide_banner", "-loglevel", "warning"))
foreach ($corePath in $corePaths) {
    $montageArgs.AddRange([string[]]@("-ss", "4", "-i", $corePath))
}
$montageArgs.AddRange([string[]]@(
    "-filter_complex",
    "[0:v]scale=270:480[v0];[1:v]scale=270:480[v1];[2:v]scale=270:480[v2];[3:v]scale=270:480[v3];[4:v]scale=270:480[v4];[5:v]scale=270:480[v5];[6:v]scale=270:480[v6];[v0][v1][v2][v3][v4][v5][v6]xstack=inputs=7:layout=0_0|270_0|0_480|270_480|0_960|270_960|0_1440:fill=black[v]",
    "-map", "[v]", "-frames:v", "1", "-q:v", "2", $montage
))
Invoke-External ffmpeg $montageArgs.ToArray()

Copy-Item $combined (Join-Path $ProjectDir "private_review.mp4") -Force
Copy-Item $combined (Join-Path $CapCutDir "private_review.mp4") -Force
Copy-Item $BgmPath (Join-Path $CapCutAudio (Split-Path $BgmPath -Leaf)) -Force
Copy-Item (Join-Path $CaptionDir "selects_combined.srt") $CapCutCaptions -Force
Copy-Item (Join-Path $CoreDir "*.mp4") $CapCutCore -Force
Copy-Item (Join-Path $HandleDir "*.mp4") $CapCutHandles -Force

Write-Host "Created $combined"
