# Multiplayer Mapvote

A Mapvote implementation for Black Ops III multiplayer, focused on community dedicated servers.

<img width="1919" height="1079" alt="Captura de pantalla 2026-11-23 012815" src="https://github.com/user-attachments/assets/89ee4fea-5737-4932-ab52-82f7f5ea7e5e" />


## Features
* **Map selection** with support for three or five options.
* **Ability to change** votes while the voting period is active.
* **Vote counters** based on each player's current selection.
* **Match type configuration** applied via GSC.
* **Rotation** to the winning map.
* **Optional** map preview images.

## Server
> [!TIP]
> Get the scripts directly here

The server-side scripts are located in `/server/scripts/mp/gametypes`. 

This same implementation works with or without the preview mod. If the mod is not loaded, the Mapvote will still function, but map preview images will not be displayed. This avoids having to maintain separate versions of the voting logic just to support installations that do not use images.

You can find the `dvar` configurations for your `server.cfg` file in `/server/zone`.

### Ezz Client (Optional)

> [!IMPORTANT]
> For Ezz client users only

For servers running Ezz BOIII, we recommend the dedicated script for multiplayer mode. Ezz Client (BOIII) allows for the implementation of a multiplayer map-voting system as a single server-side script, and it is also better optimized. For a standard Black Ops III installation or any other client, please follow the general server instructions mentioned above.

Steps:
1. Copy the [ezz_client_mapvote_mp.gsc](ezz_client_mapvote_mp.gsc) file and place it in `<server folder>/boiii/custom_scripts/mp` (create the folders if they don't exist). Ezz automatically compiles the source code when the server loads the map.
2. If you add multiple game modes, game settings are edited directly in the CFG files located in `\boiii\gamesettings\mp`. E.g: `gamesettings_tdm.cfg`, `gamesettings_dom.cfg`, etc.
3. Use the settings in [mp_config.cfg](server/zone/mp_config.cfg) in your `server_mp.cfg`. Restart the Multiplayer server to load the script.

> The image preview mod remains compatible with this version.

## Client
> [!TIP]
> Build the mods here

* **Server scripts mod:** Located in `\client\mods\mp_scripts\scripts\mp\gametypes`
* **Preview images mod:** Located in `\client\mods\mp_previews`
* **Source data:** Located in `\client\source_data`
* **Texture assets:** Located in `\client\texture_assets\mp_previews\mp`

## Note
Servers that wish to display map previews can click [`here`](client/mods/mp_previews/README.md) for detailed instructions.

The mod is completely optional; servers that choose not to use it can still utilize the core voting functionality without the map previews.
