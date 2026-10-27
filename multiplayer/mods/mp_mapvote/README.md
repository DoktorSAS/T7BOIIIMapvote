# Multiplayer MapVote â€” Map Preview Mod

This optional client mod adds map preview images to the Black Ops III Multiplayer MapVote interface.

The server-side MapVote logic can be used without the preview mod. Servers that want to display the custom map images must make the client mod available to their players.

## Steam Workshop

**Workshop ID:** `3827969881`

**Workshop page:** https://steamcommunity.com/sharedfiles/filedetails/?id=3827969881

The compiled client mod is distributed through Steam Workshop. Server administrators can obtain the published version from Workshop instead of compiling the assets themselves.

The compiled Workshop files are not duplicated in this repository. The source project and assets required to rebuild the mod are maintained here.

## Repository contents

- `source_data/mapvote_ui.gdt` â€” APE definitions for the custom image assets.
- `texture_assets/mapvote_ui/` â€” Source PNG images for the map previews.
- `mods/mapvote_ui/zone_source/mp_mod.zone` â€” Zone definition for the Multiplayer client mod.
- `mods/mapvote_ui/scripts/mp/gametypes/_mv_material_precache.gsc` â€” Script that precaches the custom preview materials.

The `mods/mapvote_ui/` directory is the Mod Tools source project. It is not the same thing as the published Workshop item or its numeric ID directory.

## Requirements

- Call of Duty: Black Ops III for PC.
- Call of Duty: Black Ops III Mod Tools, if building the mod from source.
- The source assets included in this directory.

## Building from source

1. Copy `source_data/mapvote_ui.gdt` into the game's `source_data/` directory.
2. Copy the contents of `texture_assets/mapvote_ui/` into the game's `texture_assets/mapvote_ui/` directory.
3. Copy the `mods/mapvote_ui/` project directory into the game's `mods/` directory, preserving its internal structure.
4. Open Black Ops III Mod Tools and build the Multiplayer mod using `mods/mapvote_ui/zone_source/mp_mod.zone`.
5. Verify that the build completes successfully and produces the compiled mod files, including `mp_mod.ff` and `en_mp_mod.ff`.

Generated build files and intermediate asset reports do not need to be committed unless they are specifically required to reproduce the build.

## Installation and use

Subscribe to the published Workshop item to obtain the compiled client mod.

Server administrators must deploy and configure the mod according to the requirements of their BOIII server and client version. The Workshop item ID is `3827969881`.

The preview mod is optional. The same server-side MapVote script can run without it: voting, revoting, vote counters and map rotation remain available, but custom map preview images are not rendered.

## Adding map previews

1. Add the source PNG to `texture_assets/mapvote_ui/`.
2. Define the corresponding image and material in `source_data/mapvote_ui.gdt`.
3. Add the material and image entries to `mods/mapvote_ui/zone_source/mp_mod.zone`.
4. Ensure the material name referenced by the MapVote script matches the APE material name exactly.
5. Build and test the client mod before publishing an updated Workshop version.

Only distribute source images that you have permission to redistribute.
