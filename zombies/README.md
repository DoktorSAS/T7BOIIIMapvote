# Zombies Mapvote

A Mapvote implementation for Black Ops III zombies, focused on community dedicated servers.

## Features
* **Map selection** with support for three or five options.
* **Ability to change** votes while the voting period is active.
* **Vote counters** based on each player's current selection.
* **Rotation** to the winning map.
* **Optional** map preview images.

## Server
> [!TIP]
> Get the scripts directly here

The server-side scripts are located in `/server/scripts/zm/gametypes`. 

This same implementation works with or without the preview mod. If the mod is not loaded, the Mapvote will still function, but map preview images will not be displayed. This avoids having to maintain separate versions of the voting logic just to support installations that do not use images.

You can find the dvar configurations for your `server_zm.cfg` in `/server/zone`.

## Client
> [!NOTE]
> Build the mods here

* **Server scripts mod:** Located in `\client\mods\zm_scripts\scripts\mp\gametypes`
* **Preview images mod:** Located in `\client\mods\zm_previews`
* **Source data:** Located in `\client\source_data`
* **Texture assets:** Located in `\client\texture_assets\previews\zm`

## Note
Servers that wish to display map previews can click [`here`](client/mods/zm_previews/README.md) for detailed instructions.

The mod is completely optional; servers that choose not to use it can still utilize the core voting functionality without the map previews.