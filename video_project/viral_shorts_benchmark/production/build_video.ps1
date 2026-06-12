$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Audio = Join-Path $Root "audio"
$Work = Join-Path $Root "work"
$Output = Join-Path $Root "output"

New-Item -ItemType Directory -Force -Path $Audio, $Work, $Output | Out-Null

$voice = "ko-KR-HyunsuMultilingualNeural"
edge-tts --voice $voice --rate="+10%" --file (Join-Path $Root "script\hook.txt") --write-media (Join-Path $Audio "hook.mp3")
edge-tts --voice $voice --rate="+10%" --file (Join-Path $Root "script\rank3.txt") --write-media (Join-Path $Audio "rank3.mp3")
edge-tts --voice $voice --rate="+10%" --file (Join-Path $Root "script\rank2.txt") --write-media (Join-Path $Audio "rank2.mp3")
edge-tts --voice $voice --rate="+10%" --file (Join-Path $Root "script\rank1.txt") --write-media (Join-Path $Audio "rank1.mp3")

$otters = Join-Path $Root "sources\01_otters.mp4"
$cat = Join-Path $Root "sources\02_cat.mp4"
$meerkats = Join-Path $Root "sources\03_meerkats.mp4"
$ass = (Join-Path $Root "overlays.ass").Replace("\", "/").Replace(":", "\:")
$final = Join-Path $Output "cute_animal_ranking_top3.mp4"

$filter = @"
[2:v]trim=start=0:end=8.36,setpts=PTS-STARTPTS,tpad=stop_mode=clone:stop_duration=1.14,scale=1080:1920,setsar=1[v3];
[1:v]trim=start=14:end=25,setpts=PTS-STARTPTS,scale=1080:1920,setsar=1[v2];
[0:v]trim=start=1.8:end=14.8,setpts=PTS-STARTPTS,scale=1080:1920,setsar=1[v1];
[v3][v2][v1]concat=n=3:v=1:a=0,eq=contrast=1.04:saturation=1.08,ass='$ass'[vout];
[2:a]atrim=start=0:end=8.36,asetpts=PTS-STARTPTS,apad=pad_dur=1.14[a3];
[1:a]atrim=start=14:end=25,asetpts=PTS-STARTPTS[a2];
[0:a]atrim=start=1.8:end=14.8,asetpts=PTS-STARTPTS[a1];
[a3][a2][a1]concat=n=3:v=0:a=1,volume=0.18[ambient];
[3:a]adelay=100|100,volume=1.0[hook];
[4:a]adelay=3300|3300,volume=1.0[rank3];
[5:a]adelay=9800|9800,volume=1.0[rank2];
[6:a]adelay=20800|20800,volume=1.0[rank1];
[ambient][hook][rank3][rank2][rank1]amix=inputs=5:duration=longest:normalize=0,alimiter=limit=0.92,atrim=duration=33.5[aout]
"@

ffmpeg -y `
  -i $otters `
  -i $cat `
  -i $meerkats `
  -i (Join-Path $Audio "hook.mp3") `
  -i (Join-Path $Audio "rank3.mp3") `
  -i (Join-Path $Audio "rank2.mp3") `
  -i (Join-Path $Audio "rank1.mp3") `
  -filter_complex $filter `
  -map "[vout]" -map "[aout]" `
  -r 30 -c:v libx264 -preset medium -crf 18 -pix_fmt yuv420p `
  -c:a aac -b:a 192k -movflags +faststart -t 33.5 $final

ffmpeg -y -v error -ss 00:00:04 -i $final -frames:v 1 (Join-Path $Output "check_rank3.jpg")
ffmpeg -y -v error -ss 00:00:15 -i $final -frames:v 1 (Join-Path $Output "check_rank2.jpg")
ffmpeg -y -v error -ss 00:00:26 -i $final -frames:v 1 (Join-Path $Output "check_rank1.jpg")

Write-Output $final
