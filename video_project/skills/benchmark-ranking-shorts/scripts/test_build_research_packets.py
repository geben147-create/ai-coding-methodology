import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

from PIL import Image


SCRIPT = Path(__file__).with_name("build_research_packets.py")


class BuildResearchPacketsTest(unittest.TestCase):
    def test_builds_metrics_packet_and_contact_sheet(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            metadata_dir = root / "metadata"
            captions_dir = root / "captions"
            storyboards_dir = root / "storyboards"
            output_dir = root / "output"
            metadata_dir.mkdir()
            captions_dir.mkdir()
            (storyboards_dir / "sample123").mkdir(parents=True)

            storyboard_url = "https://example.invalid/M0.jpg"
            metadata = {
                "id": "sample123",
                "title": "Sample Short",
                "channel": "Sample Channel",
                "duration": 9,
                "view_count": 1000,
                "like_count": 100,
                "comment_count": 10,
                "upload_date": "20260612",
                "language": "ko",
                "webpage_url": "https://youtube.com/shorts/sample123",
                "formats": [
                    {
                        "format_id": "sb0",
                        "width": 20,
                        "height": 30,
                        "rows": 3,
                        "columns": 3,
                        "fragments": [{"url": storyboard_url, "duration": 9}],
                    }
                ],
            }
            (metadata_dir / "sample123.info.json").write_text(
                json.dumps(metadata), encoding="utf-8"
            )

            captions = {
                "events": [
                    {
                        "tStartMs": 0,
                        "dDurationMs": 1000,
                        "segs": [{"utf8": "short hook"}],
                    },
                    {
                        "tStartMs": 3000,
                        "dDurationMs": 1500,
                        "segs": [{"utf8": "payoff line"}],
                    },
                ]
            }
            (captions_dir / "sample123.ko-orig.json3").write_text(
                json.dumps(captions), encoding="utf-8"
            )

            sheet = Image.new("RGB", (60, 90))
            for index in range(9):
                color = (index * 20, 255 - index * 20, index * 10)
                tile = Image.new("RGB", (20, 30), color)
                sheet.paste(tile, ((index % 3) * 20, (index // 3) * 30))
            sheet.save(storyboards_dir / "sample123" / "sheet_00.jpg")

            result = subprocess.run(
                [
                    sys.executable,
                    str(SCRIPT),
                    "--metadata-dir",
                    str(metadata_dir),
                    "--captions-dir",
                    str(captions_dir),
                    "--storyboards-dir",
                    str(storyboards_dir),
                    "--output-dir",
                    str(output_dir),
                ],
                check=False,
                capture_output=True,
                text=True,
            )

            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertTrue((output_dir / "metrics.csv").exists())
            packet = (output_dir / "sample123.md").read_text(encoding="utf-8")
            self.assertIn("Speech coverage", packet)
            self.assertIn("Visual change candidates", packet)
            contacts = list((output_dir / "contact_sheets").glob("*.jpg"))
            self.assertEqual(len(contacts), 1)


if __name__ == "__main__":
    unittest.main()
