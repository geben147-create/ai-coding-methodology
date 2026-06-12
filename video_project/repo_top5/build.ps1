$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$ProjectDir = $PSScriptRoot
$Workspace = (Resolve-Path (Join-Path $ProjectDir "..\..")).Path
$SourceDir = Join-Path $Workspace ".firecrawl"
$WorkDir = Join-Path $ProjectDir "work"
$AudioDir = Join-Path $ProjectDir "audio"
$OutputDir = Join-Path $Workspace "video_project\output"
$OutputPath = Join-Path $OutputDir "repo_top5_47s.mp4"

New-Item -ItemType Directory -Force -Path $WorkDir, $AudioDir, $OutputDir | Out-Null

$Clips = @(
    @{
        Source = "original-jIu33PzSnHg.mp4"
        Start = "00:12:03"
        Duration = 3.0
        HasAudio = $true
        Narration = "견인하다 벌어진, 미친 상황 다섯 가지."
    },
    @{
        Source = "extra-RRb7aqar1Sc.mp4"
        Start = "00:15:15"
        Duration = 7.0
        HasAudio = $false
        Narration = "첫 번째. 차를 막겠다며 트럭 앞에 그대로 드러눕습니다."
    },
    @{
        Source = "extra-2sAqcEajeO8.mp4"
        Start = "00:15:35"
        Duration = 7.0
        HasAudio = $true
        Narration = "두 번째. 이번에는 차주가 방망이까지 들고 나왔습니다."
    },
    @{
        Source = "extra-qzgWQLj1dfc.mp4"
        Start = "00:07:07"
        Duration = 7.0
        HasAudio = $false
        Narration = "세 번째. 견인차 운전석 문까지 열고 직접 막아섭니다."
    },
    @{
        Source = "extra-Om_ihugM7W4.mp4"
        Start = "00:04:38"
        Duration = 7.0
        HasAudio = $false
        Narration = "네 번째. 견인 장비 앞을 막고 절대 못 가져간다고 버팁니다."
    },
    @{
        Source = "extra-sY11RG_WvDQ.mp4"
        Start = "00:06:08"
        Duration = 6.0
        HasAudio = $false
        Narration = "다섯 번째는 결국 몸싸움 직전까지 번졌습니다."
    },
    @{
        Source = "original-jIu33PzSnHg.mp4"
        Start = "00:12:15"
        Duration = 10.0
        HasAudio = $true
        Narration = "그리고 가장 위험했던 순간. 동네 사람들이 기사 한 명을 전부 에워쌌습니다. 여러분이라면 그래도 견인하시겠습니까?"
    }
)

function Invoke-External {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Command,
        [Parameter(Mandatory = $true)]
        [string[]] $Arguments
    )

    & $Command @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "$Command failed with exit code $LASTEXITCODE"
    }
}

function Get-MediaDuration {
    param([Parameter(Mandatory = $true)][string] $Path)

    $durationText = & ffprobe -v error -show_entries format=duration `
        -of default=noprint_wrappers=1:nokey=1 $Path
    if ($LASTEXITCODE -ne 0) {
        throw "ffprobe failed for $Path"
    }

    return [double]::Parse(
        $durationText.Trim(),
        [Globalization.CultureInfo]::InvariantCulture
    )
}

function Get-AtempoFilter {
    param([Parameter(Mandatory = $true)][double] $Factor)

    $filters = New-Object System.Collections.Generic.List[string]
    while ($Factor -gt 2.0) {
        $filters.Add("atempo=2.0")
        $Factor /= 2.0
    }
    while ($Factor -lt 0.5) {
        $filters.Add("atempo=0.5")
        $Factor /= 0.5
    }
    $filters.Add(
        "atempo=" + $Factor.ToString("0.0000", [Globalization.CultureInfo]::InvariantCulture)
    )
    return $filters -join ","
}

$VideoConcat = New-Object System.Collections.Generic.List[string]
$VoiceConcat = New-Object System.Collections.Generic.List[string]
$BedConcat = New-Object System.Collections.Generic.List[string]

for ($Index = 0; $Index -lt $Clips.Count; $Index++) {
    $Clip = $Clips[$Index]
    $Number = ($Index + 1).ToString("00")
    $SourcePath = Join-Path $SourceDir $Clip.Source
    $VideoPath = Join-Path $WorkDir "segment_$Number.mp4"
    $RawVoicePath = Join-Path $AudioDir "edge_raw_$Number.mp3"
    $VoicePath = Join-Path $AudioDir "voice_$Number.wav"
    $BedPath = Join-Path $AudioDir "bed_$Number.wav"
    $DurationText = $Clip.Duration.ToString(
        "0.000",
        [Globalization.CultureInfo]::InvariantCulture
    )

    if (-not (Test-Path $SourcePath)) {
        throw "Missing source: $SourcePath"
    }

    Write-Host "Rendering segment $Number..."
    $VideoFilter = @"
[0:v]split=2[background][foreground];
[background]scale=1080:1920:force_original_aspect_ratio=increase:flags=lanczos,crop=1080:1920,boxblur=24:8,eq=brightness=-0.34:saturation=0.82[bg];
[foreground]scale=1080:-2:flags=lanczos[fg];
[bg][fg]overlay=(W-w)/2:(H-h)/2,setsar=1,fps=30,format=yuv420p[v]
"@ -replace "`r`n", ""

    Invoke-External ffmpeg @(
        "-y",
        "-hide_banner",
        "-loglevel", "warning",
        "-ss", $Clip.Start,
        "-i", $SourcePath,
        "-t", $DurationText,
        "-filter_complex", $VideoFilter,
        "-map", "[v]",
        "-an",
        "-c:v", "h264_nvenc",
        "-preset", "p5",
        "-tune", "hq",
        "-rc", "vbr",
        "-cq", "21",
        "-b:v", "0",
        "-r", "30",
        "-pix_fmt", "yuv420p",
        $VideoPath
    )

    if (-not (Test-Path $RawVoicePath)) {
        Write-Host "Generating Edge TTS narration $Number..."
        Invoke-External edge-tts @(
            "--voice", "ko-KR-HyunsuMultilingualNeural",
            "--rate=+22%",
            "--pitch=-2Hz",
            "--text", $Clip.Narration,
            "--write-media", $RawVoicePath
        )
    }

    $RawDuration = Get-MediaDuration $RawVoicePath
    $TargetSpeechDuration = [Math]::Max(1.0, $Clip.Duration - 0.35)
    $SpeedFactor = $RawDuration / $TargetSpeechDuration
    $Atempo = Get-AtempoFilter $SpeedFactor
    $VoiceFilter = "$Atempo,aresample=48000,aformat=channel_layouts=stereo," +
        "apad=pad_dur=$DurationText,atrim=0:$DurationText"

    Invoke-External ffmpeg @(
        "-y",
        "-hide_banner",
        "-loglevel", "warning",
        "-i", $RawVoicePath,
        "-af", $VoiceFilter,
        "-ar", "48000",
        "-ac", "2",
        "-c:a", "pcm_s16le",
        $VoicePath
    )

    if ($Clip.HasAudio) {
        Invoke-External ffmpeg @(
            "-y",
            "-hide_banner",
            "-loglevel", "warning",
            "-ss", $Clip.Start,
            "-i", $SourcePath,
            "-t", $DurationText,
            "-vn",
            "-af", "aresample=48000,aformat=channel_layouts=stereo,volume=0.28,apad=pad_dur=$DurationText,atrim=0:$DurationText",
            "-ar", "48000",
            "-ac", "2",
            "-c:a", "pcm_s16le",
            $BedPath
        )
    }
    else {
        Invoke-External ffmpeg @(
            "-y",
            "-hide_banner",
            "-loglevel", "warning",
            "-f", "lavfi",
            "-i", "anullsrc=r=48000:cl=stereo",
            "-t", $DurationText,
            "-c:a", "pcm_s16le",
            $BedPath
        )
    }

    $EscapedVideo = $VideoPath.Replace("'", "''").Replace("\", "/")
    $EscapedVoice = $VoicePath.Replace("'", "''").Replace("\", "/")
    $EscapedBed = $BedPath.Replace("'", "''").Replace("\", "/")
    $VideoConcat.Add("file '$EscapedVideo'")
    $VoiceConcat.Add("file '$EscapedVoice'")
    $BedConcat.Add("file '$EscapedBed'")
}

$VideoList = Join-Path $WorkDir "video_concat.txt"
$VoiceList = Join-Path $WorkDir "voice_concat.txt"
$BedList = Join-Path $WorkDir "bed_concat.txt"
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[IO.File]::WriteAllLines($VideoList, [string[]] $VideoConcat, $Utf8NoBom)
[IO.File]::WriteAllLines($VoiceList, [string[]] $VoiceConcat, $Utf8NoBom)
[IO.File]::WriteAllLines($BedList, [string[]] $BedConcat, $Utf8NoBom)

$JoinedVideo = Join-Path $WorkDir "joined_video.mp4"
$JoinedVoice = Join-Path $AudioDir "narration_47s.wav"
$JoinedBed = Join-Path $AudioDir "source_bed_47s.wav"
$MixedAudio = Join-Path $AudioDir "mixed_47s.wav"

Invoke-External ffmpeg @(
    "-y",
    "-hide_banner",
    "-loglevel", "warning",
    "-f", "concat",
    "-safe", "0",
    "-i", $VideoList,
    "-c", "copy",
    $JoinedVideo
)

Invoke-External ffmpeg @(
    "-y",
    "-hide_banner",
    "-loglevel", "warning",
    "-f", "concat",
    "-safe", "0",
    "-i", $VoiceList,
    "-c:a", "pcm_s16le",
    $JoinedVoice
)

Invoke-External ffmpeg @(
    "-y",
    "-hide_banner",
    "-loglevel", "warning",
    "-f", "concat",
    "-safe", "0",
    "-i", $BedList,
    "-c:a", "pcm_s16le",
    $JoinedBed
)

Invoke-External ffmpeg @(
    "-y",
    "-hide_banner",
    "-loglevel", "warning",
    "-i", $JoinedVoice,
    "-i", $JoinedBed,
    "-filter_complex", "[0:a]volume=1.0[voice];[1:a]volume=1.0[bed];[voice][bed]amix=inputs=2:duration=first:dropout_transition=0,loudnorm=I=-16:LRA=7:TP=-1.5[a]",
    "-map", "[a]",
    "-ar", "48000",
    "-ac", "2",
    "-c:a", "pcm_s16le",
    $MixedAudio
)

$AssPath = (Join-Path $ProjectDir "captions.ass").Replace("\", "/").Replace(":", "\:")
$SubtitleFilter = "subtitles='$AssPath'"

Write-Host "Rendering final video..."
Invoke-External ffmpeg @(
    "-y",
    "-hide_banner",
    "-loglevel", "warning",
    "-i", $JoinedVideo,
    "-i", $MixedAudio,
    "-vf", $SubtitleFilter,
    "-map", "0:v:0",
    "-map", "1:a:0",
    "-t", "47.000",
    "-c:v", "h264_nvenc",
    "-preset", "p5",
    "-tune", "hq",
    "-rc", "vbr",
    "-cq", "20",
    "-b:v", "0",
    "-pix_fmt", "yuv420p",
    "-c:a", "aac",
    "-b:a", "192k",
    "-movflags", "+faststart",
    $OutputPath
)

Write-Host "Created: $OutputPath"
