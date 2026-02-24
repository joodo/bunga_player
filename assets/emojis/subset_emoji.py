# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "fonttools",
#     "lxml",
#     "brotli",
# ]
# ///

# 1. Move Emoji font to this dir and rename to `NotoColorEmoji.ttf`
# 2. Run `uv run subset_emoji.py`
# 3. Delete original font file.

import os
import json
from fontTools import subset


def get_target_emojis() -> str:
    with open("emojis.json", "r", encoding="utf-8") as f:
        data = json.load(f)
        return "".join(
            [emoji for category in data["categories"] for emoji in category["emojis"]]
        )


def create_subset(target_emojis: str) -> None:
    input_font = "NotoColorEmoji.ttf"
    output_font = "emojis.ttf"

    # We need to preserve 'CBDT' and 'CBLC' tables for color bitmaps
    options = subset.Options()
    options.layout_features = ["*"]
    options.glyph_names = True

    font = subset.load_font(input_font, options)
    subsetter = subset.Subsetter(options=options)
    subsetter.populate(text=target_emojis)
    subsetter.subset(font)

    font.save(output_font)
    print(f"Success! SubsetFont saved to: {output_font}")
    print(f"New size: {os.path.getsize(output_font) / 1024:.2f} KB")


if __name__ == "__main__":
    emojis = get_target_emojis()
    create_subset(emojis)
