# Multiplayer MapVote - Map Preview Mod

This optional client mod adds map preview images to the Black Ops III Multiplayer MapVote interface. The server-side MapVote logic can be used without the preview mod. Servers that want to display the custom map images must make the client mod available to their players.

## Create your mod

The compiled Mod Tools files are not duplicated in this repository. The source project and assets required to rebuild the mod are maintained here.

## Repository contents

- `source_data/mapvote_ui.gdt` - APE definitions for the custom image assets.
- `texture_assets/mapvote_ui/mp` - Source PNG images for the map previews.
- `mods/mapvote_ui/zone_source/mp_mod.zone` - Zone definition for the Multiplayer client mod.
- `mods/mapvote_ui/scripts/mp/gametypes/_mv_material_precache.gsc` - Script that precaches the custom preview materials.

The `mods/mapvote_ui/` directory is the Mod Tools source project.

## Requirements

- Call of Duty: Black Ops III for PC.
- Call of Duty: Black Ops III Mod Tools, if building the mod from source.
- The source assets included in this directory.

## Building from source

1. Copy `source_data/mapvote_ui.gdt` into the game's `source_data/` directory.
2. Copy the contents of `texture_assets/mapvote_ui/mp` into the game's `texture_assets` directory.
3. Copy the `mods/mapvote_ui/` project directory into the game's `mods/` directory, preserving its internal structure.
4. Open Black Ops III Mod Tools and build the Multiplayer mod using `mods/mapvote_ui/zone_source/mp_mod.zone`.
5. Verify that the build completes successfully and produces the compiled mod files, including `mp_mod.ff` and `en_mp_mod.ff`.

Generated build files and intermediate asset reports do not need to be committed unless they are specifically required to reproduce the build.

## FastDL Setup - Option 1

1. Once you have the compiled mod files, copy `mods/mapvote_ui/` to your dedicated server directory.
2. Start the dedicated server and type `fastdl_manifest` in the console; this will generate the necessary manifest.
3. Host the mod and its corresponding files on a public server.
4. Configure the following Dvars in your `server.cfg` configuration file:
```
// FastDL
set sv_wwwBaseURL "PATH_TO_YOUR_PUBLIC_SERVER"
set sv_wwwDownload "1"
set sv_wwwDlDisconnected "0"
```

## Publish the Mod on Steam - Option 2

1. Publish your mod on Steam, obtain the ID, and load it onto your server.

## Note

1. Add the source PNG to `texture_assets/mapvote_ui/`.
2. Define the corresponding image and material in `source_data/mapvote_ui.gdt`.
3. Add the material and image entries to `mods/mapvote_ui/zone_source/mp_mod.zone`.
4. Ensure the material name referenced by the MapVote script matches the APE material name exactly.
5. Build and test the client mod before publishing an updated Workshop version.

Only distribute source images that you have permission to redistribute.