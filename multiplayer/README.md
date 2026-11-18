# Multiplayer Mapvote

A Mapvote implementation for Black Ops III multiplayer, focused on community dedicated servers.

## Features
* **Map selection** with support for three or five options.
* **Ability to change** votes while the voting period is active.
* **Vote counters** based on each player's current selection.
* **Match type configuration** applied via GSC.
* **Rotation** to the winning map.
* **Optional** map preview images.

## Server
> [!TIP]
> Get the script directly here

The server-side script is located in `\server\boiii\custom_scripts\mp`. 

This same implementation works with or without the preview mod. If the mod is not loaded, the Mapvote will still function, but map preview images will not be displayed. This avoids having to maintain separate versions of the voting logic just to support installations that do not use images.

You can find the dvar configurations for `server.cfg` in `\server\zone`.

**IMPORTANT:** This script only works with Ezz Boiii. It must be placed in the specified path within your dedicated server folder (no compilation required).

## Client
> [!NOTE]
> Build the mods here

* **Preview images mod:** Located in `\client\mods\mp_previews`
* **Source data:** Located in `\client\source_data`
* **Texture assets:** Located in `\client\texture_assets\mp_previews\mp`

## Note
Servers that wish to display map previews can click [**here**](client/mods/mp_previews/README.md) for detailed instructions.

The mod is completely optional; servers that choose not to use it can still utilize the core voting functionality without the map previews.