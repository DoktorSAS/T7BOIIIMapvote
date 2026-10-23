# MapVote UI — Client Mod

This optional Black Ops III Multiplayer client mod adds custom map preview images to the MapVote interface.

## Contents

- `source_data/mapvote_ui.gdt` — APE image and material definitions.
- `texture_assets/mapvote_ui/` — Source PNG files used by the image assets.
- `mods/mapvote_ui/zone_source/mp_mod.zone` — Zone definition containing the map preview materials, images and precache script.
- `mods/mapvote_ui/scripts/mp/gametypes/_mv_material_precache.gsc` — Script that precaches the custom map preview materials.

## Requirements

- A legitimate installation of Call of Duty: Black Ops III for PC.
- Call of Duty: Black Ops III Mod Tools.

## Building the client mod

The project files are stored under the `mapvote_ui/` directory in this repository. Copy them into the corresponding locations in the Black Ops III installation directory:

1. Copy `source_data/mapvote_ui.gdt` into the game's `source_data/` directory.
2. Copy the PNG files from `texture_assets/mapvote_ui/` into the game's `texture_assets/mapvote_ui/` directory.
3. Copy the contents of `mods/mapvote_ui/` into the game's `mods/mapvote_ui/` directory, preserving the directory structure.
4. Open Black Ops III Mod Tools and compile the `mapvote_ui` Multiplayer mod using `mods/mapvote_ui/zone_source/mp_mod.zone`.
5. Confirm that the resulting mod contains the custom image and material assets and the precache script.

Use the generated mod output for installation. The source files alone are not a compiled client mod.

## Installation

### Game client

Place the compiled `mapvote_ui` mod in the game's `mods/mapvote_ui/` directory and load it through the Black Ops III Mods menu.

### Dedicated server

Deploy the compiled mod to the dedicated server's `mods/mapvote_ui/` directory, preserving the compiled output structure.

The MapVote gameplay script must also be installed according to the instructions in the main repository README.

## Adding or updating map previews

1. Add the PNG source image under `texture_assets/mapvote_ui/`.
2. Define the image and material in `source_data/mapvote_ui.gdt`.
3. Add the corresponding `material,` and `image,` entries to `mods/mapvote_ui/zone_source/mp_mod.zone`.
4. Ensure the material name used by the MapVote GSC matches the material defined in APE.
5. Recompile the client mod and test the preview in game.

The material names and asset references must match exactly.
