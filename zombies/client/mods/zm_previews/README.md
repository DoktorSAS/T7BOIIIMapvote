# **Zombies MapVote - Map Preview Mod**

This optional client mod adds map preview images to the Black Ops III Zombies MapVote interface. The server-side MapVote logic can be used without the preview mod. Servers that want to display the custom map images must make the client mod available to their players.

## Create your mod

The compiled Mod Tools files are not duplicated in this repository. The source project and assets **required** to rebuild the mod are maintained here.

## Repository contents

- `source_data/zm_previews.gdt` - APE definitions for the custom image assets.
- `texture_assets/previews/zm` - Source PNG images for the map previews.
- `mods/zm_previews/zone_source/zm_mod.zone` - Zone definition for the Multiplayer client mod.
- `mods/zm_previews/scripts/zm/gametypes/_mv_material_precache.gsc` - Script that precaches the custom preview materials.

The `mods/zm_previews/` directory is the Mod Tools source project.

## Requirements

- **Call of Duty: Black Ops III for PC.**
- **Call of Duty: Black Ops III Mod Tools, if building the mod from source.**
- The source assets **included** in this directory.

## Building from source

1. Copy `source_data` into the game directory.
2. Copy `texture_assets` into the game directory.
3. Copy the `mods/zm_previews` project directory into the game's `mods/` directory, preserving its internal structure.
4. Open the Black Ops III Mod Tools, navigate to `mods/zm_previews`, and check only the following boxes: `zm_mod`, `Compile`, and `Link`. Then, click `Build`.
5. Verify that the build completes successfully and produces the compiled mod files, including `zm_mod.ff` and `en_zm_mod.ff`. It should have been generated here: `C:\Program Files (x86)\Steam\steamapps\common\Call of Duty Black Ops III\mods\zm_previews\zone`

Generated build files and intermediate asset reports do not need to be committed unless they are specifically required to reproduce the build.

## FastDL Setup - Option 1 (**RECOMMENDED**)

1. Once you have the compiled mod files, copy `mods/zm_previews/` to your dedicated server directory.
2. Start the dedicated server and type `fastdl_manifest` in the console; this will generate the necessary manifest (**ONLY EZZ**)
3. Host the mod and its corresponding files on a public server.
4. Configure the following Dvars in your `server.cfg` configuration file:
```
// FastDL
set sv_wwwBaseURL "" // Mod download source in the form of "http://{server ip or website domain}:{port}"
set sv_wwwDownload "1"
set sv_wwwDlDisconnected "0"
```

## Publish the Mod on Steam - Option 2

1. Publish your mod on Steam, obtain the ID, and load it onto your server.

## Note

1. Add the source PNG to `texture_assets/previews/zm`.
2. Define the corresponding image and material in `source_data/zm_previews.gdt`.
3. Add the material and image entries to `mods/zm_previews/zone_source/zm_mod.zone`.
4. Ensure the material name referenced by the MapVote script matches the APE material name exactly.
5. Build and test the client mod before publishing an updated version.

> Only distribute source images that you have permission to redistribute.