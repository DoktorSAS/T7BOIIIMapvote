# Multiplayer MapVote

A Black Ops III Multiplayer MapVote implementation with revoting, GSC-based gametype configuration and optional map preview images.

## Features

- Map selection with support for three or five map choices.
- Change a vote while voting is active.
- Vote counters based on each player's current selection.
- Gametype settings applied through GSC.
- Map rotation to the winning map.
- Optional custom map preview images.

## Server-side scripts

The server-side scripts are located in `scripts/mp/gametypes/`.

The same server-side implementation can run with or without the custom preview mod. When the preview mod is not loaded, the voting system remains functional, but the custom map images are not rendered.

This avoids maintaining separate copies of the voting logic solely to support installations without images.

## Optional map preview mod

The preview mod provides the custom materials and images used by the MapVote interface.

- **Steam Workshop ID:** `3827969881`
- **Workshop page:** https://steamcommunity.com/sharedfiles/filedetails/?id=3827969881

Servers that want to display map previews must make the client mod available to their players and configure it according to the requirements of their BOIII client and server setup.

The mod is optional. Servers that do not use it can still use the MapVote functionality without custom map previews.

## Build the client mod from source

The source project is located in `mods/mp_mapvote/`.

It contains the APE asset definitions, source PNG images, zone definition and material precache script required to rebuild the client mod using Black Ops III Mod Tools.

See [`mods/mp_mapvote/README.md`](mods/mp_mapvote/README.md) for build and installation instructions.

## Compatibility and testing

The scripts have been compiled and checked with Black Ops III Mod Tools and tested with the T7x and Ezz BOIII clients.

When modifying the voting logic, test both the server-side behaviour and the optional client preview mod.
