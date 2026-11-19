# Multiplayer Mapvote

A map voting implementation for Black Ops III Multiplayer, designed for community-hosted dedicated servers.

## Features
* **Map selection** supporting three or five options.
* **Ability to change** your vote while the voting period is active.
* **Vote counters** based on each player's current choice.
* **Gametype settings** applied via GSC.
* **Rotation** to the winning map.
* **Map preview images** (optional).

## Server
> [!TIP]
> Get the scripts directly here

Server-side scripts are located in `/server/scripts/mp/gametypes`.

This implementation works both with and without the preview mod. If the mod is not loaded, the voting system will still function, though map preview images will not be displayed. This avoids having to maintain separate versions of the voting logic for setups that do not use images.

You can find the `dvar` configurations for your `server.cfg` file in `/server/zone`.

### Ezz BOIII Dedicated Servers (Optional)

Ezz Boiii allows loading the multiplayer mapvote system as a single server-side script. Use this option on an Ezz BOIII server with the built-in GSC compiler and `executecommand` support. For a standard Black Ops III installation or any other client, follow the server instructions mentioned above.

1. Download [mapvote_mp.gsc](https://raw.githubusercontent.com/luismrtnezz/T7BOIIIMapvote/6772277449560d51068be3031cd0edd61505f420/multiplayer/server/boiii/custom_scripts/mp/mapvote_mp.gsc) and save it as `boiii/custom_scripts/mp/mapvote_mp.gsc` inside your dedicated server's game directory. Create the necessary folders if needed. Ezz compiles the source code when the server loads the map.
2. Add the same dvar configuration to your `server.cfg` as used for the standard version. You can view it [here](server/zone/mp_config.cfg).

Each gamemode requires a CFG file that the server can execute. For example, if SD wins the vote, the server will execute `exec gamedata/gamesettings/mp/gamesettings_sd.cfg` before changing the map. Keep the `exec` command out of the rotation string. When starting the server from scratch, the first map will use your startup configuration. If your launcher does not load its rules, add `exec "gamedata/gamesettings/mp/gamesettings_tdm.cfg"` to your `server.cfg` for the initial map (in this example, TDM).

3. Start the server, finish a match, and vote for a different gamemode. The menu will appear after the final killcam, if one plays. For an SD (Search and Destroy) vote, make sure the next map uses the round limits and player lives configured for SD. To enable preview images, install the [preview mod](client/mods/mp_previews/README.md) and set `mv_previews 1`.

## Client
> [!NOTE]
> Build the mods here

* **Server Scripts Mod:** Located in `\client\mods\mp_scripts\scripts\mp\gametypes`
* **Map Preview Images Mod:** Located in `\client\mods\mp_previews`
* **Source Data:** Located in `\client\source_data`
* **Texture Assets:** Located in `\client\texture_assets\mp_previews\mp`

## Note
Servers wishing to display map previews can click [`here`](client/mods/mp_previews/README.md) for detailed instructions.

The mod is completely optional; servers that choose not to use it can still use the core voting functionality without map previews.
