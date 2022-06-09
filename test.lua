--local lunamark = require("lunamark")
--local writer = lunamark.writer.html.new()
--local parse = lunamark.reader.markdown.new(writer, { smart = false })
to_parse = [=[
Minetest Lua Modding API Reference
==================================

* More information at <http://www.minetest.net/>
* Developer Wiki: <http://dev.minetest.net/>
* (Unofficial) Minetest Modding Book by rubenwardy: <https://rubenwardy.com/minetest_modding_book/>

Introduction
------------

Content and functionality can be added to Minetest using Lua scripting
in run-time loaded mods.

A mod is a self-contained bunch of scripts, textures and other related
things, which is loaded by and interfaces with Minetest.

Mods are contained and ran solely on the server side. Definitions and media
files are automatically transferred to the client.

If you see a deficiency in the API, feel free to attempt to add the
functionality in the engine and API, and to document it here.

Programming in Lua
------------------

If you have any difficulty in understanding this, please read
[Programming in Lua](http://www.lua.org/pil/).

Startup
-------

Mods are loaded during server startup from the mod load paths by running
the `init.lua` scripts in a shared environment.

Paths
-----

* `RUN_IN_PLACE=1` (Windows release, local build)
    * `$path_user`: `<build directory>`
    * `$path_share`: `<build directory>`
* `RUN_IN_PLACE=0`: (Linux release)
    * `$path_share`:
        * Linux: `/usr/share/minetest`
        * Windows: `<install directory>/minetest-0.4.x`
    * `$path_user`:
        * Linux: `$HOME/.minetest`
        * Windows: `C:/users/<user>/AppData/minetest` (maybe)




Games
=====

Games are looked up from:

* `$path_share/games/<gameid>/`
* `$path_user/games/<gameid>/`

Where `<gameid>` is unique to each game.

The game directory can contain the following files:

* `game.conf`, with the following keys:
    * `title`: Required, a human-readable title to address the game, e.g. `title = Minetest Game`.
    * `name`: (Deprecated) same as title.
    * `description`: Short description to be shown in the content tab
    * `allowed_mapgens = <comma-separated mapgens>`
      e.g. `allowed_mapgens = v5,v6,flat`
      Mapgens not in this list are removed from the list of mapgens for the
      game.
      If not specified, all mapgens are allowed.
    * `disallowed_mapgens = <comma-separated mapgens>`
      e.g. `disallowed_mapgens = v5,v6,flat`
      These mapgens are removed from the list of mapgens for the game.
      When both `allowed_mapgens` and `disallowed_mapgens` are
      specified, `allowed_mapgens` is applied before
      `disallowed_mapgens`.
    * `disallowed_mapgen_settings= <comma-separated mapgen settings>`
      e.g. `disallowed_mapgen_settings = mgv5_spflags`
      These mapgen settings are hidden for this game in the world creation
      dialog and game start menu. Add `seed` to hide the seed input field.
    * `disabled_settings = <comma-separated settings>`
      e.g. `disabled_settings = enable_damage, creative_mode`
      These settings are hidden for this game in the "Start game" tab
      and will be initialized as `false` when the game is started.
      Prepend a setting name with an exclamation mark to initialize it to `true`
      (this does not work for `enable_server`).
      Only these settings are supported:
          `enable_damage`, `creative_mode`, `enable_server`.
    * `author`: The author of the game. It only appears when downloaded from
                ContentDB.
    * `release`: Ignore this: Should only ever be set by ContentDB, as it is
                 an internal ID used to track versions.
* `minetest.conf`:
  Used to set default settings when running this game.
* `settingtypes.txt`:
  In the same format as the one in builtin.
  This settingtypes.txt will be parsed by the menu and the settings will be
  displayed in the "Games" category in the advanced settings tab.
* If the game contains a folder called `textures` the server will load it as a
  texturepack, overriding mod textures.
  Any server texturepack will override mod textures and the game texturepack.

Menu images
-----------

Games can provide custom main menu images. They are put inside a `menu`
directory inside the game directory.

The images are named `$identifier.png`, where `$identifier` is one of
`overlay`, `background`, `footer`, `header`.
If you want to specify multiple images for one identifier, add additional
images named like `$identifier.$n.png`, with an ascending number $n starting
with 1, and a random image will be chosen from the provided ones.

Menu music
-----------

Games can provide custom main menu music. They are put inside a `menu`
directory inside the game directory.

The music files are named `theme.ogg`.
If you want to specify multiple music files for one game, add additional
images named like `theme.$n.ogg`, with an ascending number $n starting
with 1 (max 10), and a random music file will be chosen from the provided ones.

Mods
====

Mod load path
-------------

Paths are relative to the directories listed in the [Paths] section above.

* `games/<gameid>/mods/`
* `mods/`
* `worlds/<worldname>/worldmods/`

World-specific games
--------------------

It is possible to include a game in a world; in this case, no mods or
games are loaded or checked from anywhere else.

This is useful for e.g. adventure worlds and happens if the `<worldname>/game/`
directory exists.

Mods should then be placed in `<worldname>/game/mods/`.

Modpacks
--------

Mods can be put in a subdirectory, if the parent directory, which otherwise
should be a mod, contains a file named `modpack.conf`.
The file is a key-value store of modpack details.

* `name`: The modpack name. Allows Minetest to determine the modpack name even
          if the folder is wrongly named.
* `description`: Description of mod to be shown in the Mods tab of the main
                 menu.
* `author`: The author of the modpack. It only appears when downloaded from
            ContentDB.
* `release`: Ignore this: Should only ever be set by ContentDB, as it is an
             internal ID used to track versions.
* `title`: A human-readable title to address the modpack.

Note: to support 0.4.x, please also create an empty modpack.txt file.

Mod directory structure
-----------------------

    mods
    ├── modname
    │   ├── mod.conf
    │   ├── screenshot.png
    │   ├── settingtypes.txt
    │   ├── init.lua
    │   ├── models
    │   ├── textures
    │   │   ├── modname_stuff.png
    │   │   ├── modname_stuff_normal.png
    │   │   ├── modname_something_else.png
    │   │   ├── subfolder_foo
    │   │   │   ├── modname_more_stuff.png
    │   │   │   └── another_subfolder
    │   │   └── bar_subfolder
    │   ├── sounds
    │   ├── media
    │   ├── locale
    │   └── <custom data>
    └── another

### modname

The location of this directory can be fetched by using
`minetest.get_modpath(modname)`.

### mod.conf

A `Settings` file that provides meta information about the mod.

* `name`: The mod name. Allows Minetest to determine the mod name even if the
          folder is wrongly named.
* `description`: Description of mod to be shown in the Mods tab of the main
                 menu.
* `depends`: A comma separated list of dependencies. These are mods that must be
             loaded before this mod.
* `optional_depends`: A comma separated list of optional dependencies.
                      Like a dependency, but no error if the mod doesn't exist.
* `author`: The author of the mod. It only appears when downloaded from
            ContentDB.
* `release`: Ignore this: Should only ever be set by ContentDB, as it is an
             internal ID used to track versions.
* `title`: A human-readable title to address the mod.

Note: to support 0.4.x, please also provide depends.txt.

### `screenshot.png`

A screenshot shown in the mod manager within the main menu. It should
have an aspect ratio of 3:2 and a minimum size of 300×200 pixels.

### `depends.txt`

**Deprecated:** you should use mod.conf instead.

This file is used if there are no dependencies in mod.conf.

List of mods that have to be loaded before loading this mod.

A single line contains a single modname.

Optional dependencies can be defined by appending a question mark
to a single modname. This means that if the specified mod
is missing, it does not prevent this mod from being loaded.

### `description.txt`

**Deprecated:** you should use mod.conf instead.

This file is used if there is no description in mod.conf.

A file containing a description to be shown in the Mods tab of the main menu.

### `settingtypes.txt`

The format is documented in `builtin/settingtypes.txt`.
It is parsed by the main menu settings dialogue to list mod-specific
settings in the "Mods" category.

### `init.lua`

The main Lua script. Running this script should register everything it
wants to register. Subsequent execution depends on minetest calling the
registered callbacks.

`minetest.settings` can be used to read custom or existing settings at load
time, if necessary. (See [`Settings`])

### `textures`, `sounds`, `media`, `models`, `locale`

Media files (textures, sounds, whatever) that will be transferred to the
client and will be available for use by the mod and translation files for
the clients (see [Translations]).

It is suggested to use the folders for the purpose they are thought for,
eg. put textures into `textures`, translation files into `locale`,
models for entities or meshnodes into `models` et cetera.

These folders and subfolders can contain subfolders.
Subfolders with names starting with `_` or `.` are ignored.
If a subfolder contains a media file with the same name as a media file
in one of its parents, the parent's file is used.

Although it is discouraged, a mod can overwrite a media file of any mod that it
depends on by supplying a file with an equal name.

Naming conventions
------------------

Registered names should generally be in this format:

    modname:<whatever>

`<whatever>` can have these characters:

    a-zA-Z0-9_

This is to prevent conflicting names from corrupting maps and is
enforced by the mod loader.

Registered names can be overridden by prefixing the name with `:`. This can
be used for overriding the registrations of some other mod.

The `:` prefix can also be used for maintaining backwards compatibility.

### Example

In the mod `experimental`, there is the ideal item/node/entity name `tnt`.
So the name should be `experimental:tnt`.

Any mod can redefine `experimental:tnt` by using the name

    :experimental:tnt

when registering it. That mod is required to have `experimental` as a
dependency.




Aliases
=======

Aliases of itemnames can be added by using
`minetest.register_alias(alias, original_name)` or
`minetest.register_alias_force(alias, original_name)`.

This adds an alias `alias` for the item called `original_name`.
From now on, you can use `alias` to refer to the item `original_name`.

The only difference between `minetest.register_alias` and
`minetest.register_alias_force` is that if an item named `alias` already exists,
`minetest.register_alias` will do nothing while
`minetest.register_alias_force` will unregister it.

This can be used for maintaining backwards compatibility.

This can also set quick access names for things, e.g. if
you have an item called `epiclylongmodname:stuff`, you could do

    minetest.register_alias("stuff", "epiclylongmodname:stuff")

and be able to use `/giveme stuff`.

Mapgen aliases
--------------

In a game, a certain number of these must be set to tell core mapgens which
of the game's nodes are to be used for core mapgen generation. For example:

    minetest.register_alias("mapgen_stone", "default:stone")

### Aliases for non-V6 mapgens

#### Essential aliases

* mapgen_stone
* mapgen_water_source
* mapgen_river_water_source

`mapgen_river_water_source` is required for mapgens with sloping rivers where
it is necessary to have a river liquid node with a short `liquid_range` and
`liquid_renewable = false` to avoid flooding.

#### Optional aliases

* mapgen_lava_source

Fallback lava node used if cave liquids are not defined in biome definitions.
Deprecated for non-V6 mapgens, define cave liquids in biome definitions instead.

* mapgen_cobble

Fallback node used if dungeon nodes are not defined in biome definitions.
Deprecated for non-V6 mapgens, define dungeon nodes in biome definitions instead.

### Aliases needed for Mapgen V6

* mapgen_stone
* mapgen_water_source
* mapgen_lava_source
* mapgen_dirt
* mapgen_dirt_with_grass
* mapgen_sand
* mapgen_gravel
* mapgen_desert_stone
* mapgen_desert_sand
* mapgen_dirt_with_snow
* mapgen_snowblock
* mapgen_snow
* mapgen_ice

* mapgen_tree
* mapgen_leaves
* mapgen_apple
* mapgen_jungletree
* mapgen_jungleleaves
* mapgen_junglegrass
* mapgen_pine_tree
* mapgen_pine_needles

* mapgen_cobble
* mapgen_stair_cobble
* mapgen_mossycobble
* mapgen_stair_desert_stone

### Setting the node used in Mapgen Singlenode

By default the world is filled with air nodes. To set a different node use, for
example:

    minetest.register_alias("mapgen_singlenode", "default:stone")




Textures
========

Mods should generally prefix their textures with `modname_`, e.g. given
the mod name `foomod`, a texture could be called:

    foomod_foothing.png

Textures are referred to by their complete name, or alternatively by
stripping out the file extension:

* e.g. `foomod_foothing.png`
* e.g. `foomod_foothing`


Texture modifiers
-----------------

There are various texture modifiers that can be used
to let the client generate textures on-the-fly.
The modifiers are applied directly in sRGB colorspace,
i.e. without gamma-correction.

### Texture overlaying

Textures can be overlaid by putting a `^` between them.

Example:

    default_dirt.png^default_grass_side.png

`default_grass_side.png` is overlaid over `default_dirt.png`.
The texture with the lower resolution will be automatically upscaled to
the higher resolution texture.

### Texture grouping

Textures can be grouped together by enclosing them in `(` and `)`.

Example: `cobble.png^(thing1.png^thing2.png)`

A texture for `thing1.png^thing2.png` is created and the resulting
texture is overlaid on top of `cobble.png`.

### Escaping

Modifiers that accept texture names (e.g. `[combine`) accept escaping to allow
passing complex texture names as arguments. Escaping is done with backslash and
is required for `^` and `:`.

Example: `cobble.png^[lowpart:50:color.png\^[mask\:trans.png`

The lower 50 percent of `color.png^[mask:trans.png` are overlaid
on top of `cobble.png`.

### Advanced texture modifiers

#### Crack

* `[crack:<n>:<p>`
* `[cracko:<n>:<p>`
* `[crack:<t>:<n>:<p>`
* `[cracko:<t>:<n>:<p>`

Parameters:

* `<t>`: tile count (in each direction)
* `<n>`: animation frame count
* `<p>`: current animation frame

Draw a step of the crack animation on the texture.
`crack` draws it normally, while `cracko` lays it over, keeping transparent
pixels intact.

Example:

    default_cobble.png^[crack:10:1

#### `[combine:<w>x<h>:<x1>,<y1>=<file1>:<x2>,<y2>=<file2>:...`

* `<w>`: width
* `<h>`: height
* `<x>`: x position
* `<y>`: y position
* `<file>`: texture to combine

Creates a texture of size `<w>` times `<h>` and blits the listed files to their
specified coordinates.

Example:

    [combine:16x32:0,0=default_cobble.png:0,16=default_wood.png

#### `[resize:<w>x<h>`

Resizes the texture to the given dimensions.

Example:

    default_sandstone.png^[resize:16x16

#### `[opacity:<r>`

Makes the base image transparent according to the given ratio.

`r` must be between 0 (transparent) and 255 (opaque).

Example:

    default_sandstone.png^[opacity:127

#### `[invert:<mode>`

Inverts the given channels of the base image.
Mode may contain the characters "r", "g", "b", "a".
Only the channels that are mentioned in the mode string will be inverted.

Example:

    default_apple.png^[invert:rgb

#### `[brighten`

Brightens the texture.

Example:

    tnt_tnt_side.png^[brighten

#### `[noalpha`

Makes the texture completely opaque.

Example:

    default_leaves.png^[noalpha

#### `[makealpha:<r>,<g>,<b>`

Convert one color to transparency.

Example:

    default_cobble.png^[makealpha:128,128,128

#### `[transform<t>`

* `<t>`: transformation(s) to apply

Rotates and/or flips the image.

`<t>` can be a number (between 0 and 7) or a transform name.
Rotations are counter-clockwise.

    0  I      identity
    1  R90    rotate by 90 degrees
    2  R180   rotate by 180 degrees
    3  R270   rotate by 270 degrees
    4  FX     flip X
    5  FXR90  flip X then rotate by 90 degrees
    6  FY     flip Y
    7  FYR90  flip Y then rotate by 90 degrees

Example:

    default_stone.png^[transformFXR90

#### `[inventorycube{<top>{<left>{<right>`

Escaping does not apply here and `^` is replaced by `&` in texture names
instead.

Create an inventory cube texture using the side textures.

Example:

    [inventorycube{grass.png{dirt.png&grass_side.png{dirt.png&grass_side.png

Creates an inventorycube with `grass.png`, `dirt.png^grass_side.png` and
`dirt.png^grass_side.png` textures

#### `[lowpart:<percent>:<file>`

Blit the lower `<percent>`% part of `<file>` on the texture.

Example:

    base.png^[lowpart:25:overlay.png

#### `[verticalframe:<t>:<n>`

* `<t>`: animation frame count
* `<n>`: current animation frame

Crops the texture to a frame of a vertical animation.

Example:

    default_torch_animated.png^[verticalframe:16:8

#### `[mask:<file>`

Apply a mask to the base image.

The mask is applied using binary AND.

#### `[sheet:<w>x<h>:<x>,<y>`

Retrieves a tile at position x,y from the base image
which it assumes to be a tilesheet with dimensions w,h.

#### `[colorize:<color>:<ratio>`

Colorize the textures with the given color.
`<color>` is specified as a `ColorString`.
`<ratio>` is an int ranging from 0 to 255 or the word "`alpha`".  If
it is an int, then it specifies how far to interpolate between the
colors where 0 is only the texture color and 255 is only `<color>`. If
omitted, the alpha of `<color>` will be used as the ratio.  If it is
the word "`alpha`", then each texture pixel will contain the RGB of
`<color>` and the alpha of `<color>` multiplied by the alpha of the
texture pixel.

#### `[multiply:<color>`

Multiplies texture colors with the given color.
`<color>` is specified as a `ColorString`.
Result is more like what you'd expect if you put a color on top of another
color, meaning white surfaces get a lot of your new color while black parts
don't change very much.

#### `[png:<base64>`

Embed a base64 encoded PNG image in the texture string.
You can produce a valid string for this by calling
`minetest.encode_base64(minetest.encode_png(tex))`,
refer to the documentation of these functions for details.
You can use this to send disposable images such as captchas
to individual clients, or render things that would be too
expensive to compose with `[combine:`.

IMPORTANT: Avoid sending large images this way.
This is not a replacement for asset files, do not use it to do anything
that you could instead achieve by just using a file.
In particular consider `minetest.dynamic_add_media` and test whether
using other texture modifiers could result in a shorter string than
embedding a whole image, this may vary by use case.

Hardware coloring
-----------------

The goal of hardware coloring is to simplify the creation of
colorful nodes. If your textures use the same pattern, and they only
differ in their color (like colored wool blocks), you can use hardware
coloring instead of creating and managing many texture files.
All of these methods use color multiplication (so a white-black texture
with red coloring will result in red-black color).

### Static coloring

This method is useful if you wish to create nodes/items with
the same texture, in different colors, each in a new node/item definition.

#### Global color

When you register an item or node, set its `color` field (which accepts a
`ColorSpec`) to the desired color.

An `ItemStack`'s static color can be overwritten by the `color` metadata
field. If you set that field to a `ColorString`, that color will be used.

#### Tile color

Each tile may have an individual static color, which overwrites every
other coloring method. To disable the coloring of a face,
set its color to white (because multiplying with white does nothing).
You can set the `color` property of the tiles in the node's definition
if the tile is in table format.

### Palettes

For nodes and items which can have many colors, a palette is more
suitable. A palette is a texture, which can contain up to 256 pixels.
Each pixel is one possible color for the node/item.
You can register one node/item, which can have up to 256 colors.

#### Palette indexing

When using palettes, you always provide a pixel index for the given
node or `ItemStack`. The palette is read from left to right and from
top to bottom. If the palette has less than 256 pixels, then it is
stretched to contain exactly 256 pixels (after arranging the pixels
to one line). The indexing starts from 0.

Examples:

* 16x16 palette, index = 0: the top left corner
* 16x16 palette, index = 4: the fifth pixel in the first row
* 16x16 palette, index = 16: the pixel below the top left corner
* 16x16 palette, index = 255: the bottom right corner
* 2 (width) x 4 (height) palette, index = 31: the top left corner.
  The palette has 8 pixels, so each pixel is stretched to 32 pixels,
  to ensure the total 256 pixels.
* 2x4 palette, index = 32: the top right corner
* 2x4 palette, index = 63: the top right corner
* 2x4 palette, index = 64: the pixel below the top left corner

#### Using palettes with items

When registering an item, set the item definition's `palette` field to
a texture. You can also use texture modifiers.

The `ItemStack`'s color depends on the `palette_index` field of the
stack's metadata. `palette_index` is an integer, which specifies the
index of the pixel to use.

#### Linking palettes with nodes

When registering a node, set the item definition's `palette` field to
a texture. You can also use texture modifiers.
The node's color depends on its `param2`, so you also must set an
appropriate `paramtype2`:

* `paramtype2 = "color"` for nodes which use their full `param2` for
  palette indexing. These nodes can have 256 different colors.
  The palette should contain 256 pixels.
* `paramtype2 = "colorwallmounted"` for nodes which use the first
  five bits (most significant) of `param2` for palette indexing.
  The remaining three bits are describing rotation, as in `wallmounted`
  paramtype2. Division by 8 yields the palette index (without stretching the
  palette). These nodes can have 32 different colors, and the palette
  should contain 32 pixels.
  Examples:
    * `param2 = 17` is 2 * 8 + 1, so the rotation is 1 and the third (= 2 + 1)
      pixel will be picked from the palette.
    * `param2 = 35` is 4 * 8 + 3, so the rotation is 3 and the fifth (= 4 + 1)
      pixel will be picked from the palette.
* `paramtype2 = "colorfacedir"` for nodes which use the first
  three bits of `param2` for palette indexing. The remaining
  five bits are describing rotation, as in `facedir` paramtype2.
  Division by 32 yields the palette index (without stretching the
  palette). These nodes can have 8 different colors, and the
  palette should contain 8 pixels.
  Examples:
    * `param2 = 17` is 0 * 32 + 17, so the rotation is 17 and the
      first (= 0 + 1) pixel will be picked from the palette.
    * `param2 = 35` is 1 * 32 + 3, so the rotation is 3 and the
      second (= 1 + 1) pixel will be picked from the palette.

To colorize a node on the map, set its `param2` value (according
to the node's paramtype2).

### Conversion between nodes in the inventory and on the map

Static coloring is the same for both cases, there is no need
for conversion.

If the `ItemStack`'s metadata contains the `color` field, it will be
lost on placement, because nodes on the map can only use palettes.

If the `ItemStack`'s metadata contains the `palette_index` field, it is
automatically transferred between node and item forms by the engine,
when a player digs or places a colored node.
You can disable this feature by setting the `drop` field of the node
to itself (without metadata).
To transfer the color to a special drop, you need a drop table.

Example:

    minetest.register_node("mod:stone", {
        description = "Stone",
        tiles = {"default_stone.png"},
        paramtype2 = "color",
        palette = "palette.png",
        drop = {
            items = {
                -- assume that mod:cobblestone also has the same palette
                {items = {"mod:cobblestone"}, inherit_color = true },
            }
        }
    })

### Colored items in craft recipes

Craft recipes only support item strings, but fortunately item strings
can also contain metadata. Example craft recipe registration:

    minetest.register_craft({
        output = minetest.itemstring_with_palette("wool:block", 3),
        type = "shapeless",
        recipe = {
            "wool:block",
            "dye:red",
        },
    })

To set the `color` field, you can use `minetest.itemstring_with_color`.

Metadata field filtering in the `recipe` field are not supported yet,
so the craft output is independent of the color of the ingredients.

Soft texture overlay
--------------------

Sometimes hardware coloring is not enough, because it affects the
whole tile. Soft texture overlays were added to Minetest to allow
the dynamic coloring of only specific parts of the node's texture.
For example a grass block may have colored grass, while keeping the
dirt brown.

These overlays are 'soft', because unlike texture modifiers, the layers
are not merged in the memory, but they are simply drawn on top of each
other. This allows different hardware coloring, but also means that
tiles with overlays are drawn slower. Using too much overlays might
cause FPS loss.

For inventory and wield images you can specify overlays which
hardware coloring does not modify. You have to set `inventory_overlay`
and `wield_overlay` fields to an image name.

To define a node overlay, simply set the `overlay_tiles` field of the node
definition. These tiles are defined in the same way as plain tiles:
they can have a texture name, color etc.
To skip one face, set that overlay tile to an empty string.

Example (colored grass block):

    minetest.register_node("default:dirt_with_grass", {
        description = "Dirt with Grass",
        -- Regular tiles, as usual
        -- The dirt tile disables palette coloring
        tiles = {{name = "default_grass.png"},
            {name = "default_dirt.png", color = "white"}},
        -- Overlay tiles: define them in the same style
        -- The top and bottom tile does not have overlay
        overlay_tiles = {"", "",
            {name = "default_grass_side.png"}},
        -- Global color, used in inventory
        color = "green",
        -- Palette in the world
        paramtype2 = "color",
        palette = "default_foilage.png",
    })




Sounds
======

Only Ogg Vorbis files are supported.

For positional playing of sounds, only single-channel (mono) files are
supported. Otherwise OpenAL will play them non-positionally.

Mods should generally prefix their sounds with `modname_`, e.g. given
the mod name "`foomod`", a sound could be called:

    foomod_foosound.ogg

Sounds are referred to by their name with a dot, a single digit and the
file extension stripped out. When a sound is played, the actual sound file
is chosen randomly from the matching sounds.

When playing the sound `foomod_foosound`, the sound is chosen randomly
from the available ones of the following files:

* `foomod_foosound.ogg`
* `foomod_foosound.0.ogg`
* `foomod_foosound.1.ogg`
* (...)
* `foomod_foosound.9.ogg`

Examples of sound parameter tables:

    -- Play locationless on all clients
    {
        gain = 1.0,   -- default
        fade = 0.0,   -- default, change to a value > 0 to fade the sound in
        pitch = 1.0,  -- default
    }
    -- Play locationless to one player
    {
        to_player = name,
        gain = 1.0,   -- default
        fade = 0.0,   -- default, change to a value > 0 to fade the sound in
        pitch = 1.0,  -- default
    }
    -- Play locationless to one player, looped
    {
        to_player = name,
        gain = 1.0,  -- default
        loop = true,
    }
    -- Play at a location
    {
        pos = {x = 1, y = 2, z = 3},
        gain = 1.0,  -- default
        max_hear_distance = 32,  -- default, uses an euclidean metric
    }
    -- Play connected to an object, looped
    {
        object = <an ObjectRef>,
        gain = 1.0,  -- default
        max_hear_distance = 32,  -- default, uses an euclidean metric
        loop = true,
    }
    -- Play at a location, heard by anyone *but* the given player
    {
        pos = {x = 32, y = 0, z = 100},
        max_hear_distance = 40,
        exclude_player = name,
    }

Looped sounds must either be connected to an object or played locationless to
one player using `to_player = name`.

A positional sound will only be heard by players that are within
`max_hear_distance` of the sound position, at the start of the sound.

`exclude_player = name` can be applied to locationless, positional and object-
bound sounds to exclude a single player from hearing them.

`SimpleSoundSpec`
-----------------

Specifies a sound name, gain (=volume) and pitch.
This is either a string or a table.

In string form, you just specify the sound name or
the empty string for no sound.

Table form has the following fields:

* `name`: Sound name
* `gain`: Volume (`1.0` = 100%)
* `pitch`: Pitch (`1.0` = 100%)

`gain` and `pitch` are optional and default to `1.0`.

Examples:

* `""`: No sound
* `{}`: No sound
* `"default_place_node"`: Play e.g. `default_place_node.ogg`
* `{name = "default_place_node"}`: Same as above
* `{name = "default_place_node", gain = 0.5}`: 50% volume
* `{name = "default_place_node", gain = 0.9, pitch = 1.1}`: 90% volume, 110% pitch

Special sound files
-------------------

These sound files are played back by the engine if provided.

 * `player_damage`: Played when the local player takes damage (gain = 0.5)
 * `player_falling_damage`: Played when the local player takes
   damage by falling (gain = 0.5)
 * `player_jump`: Played when the local player jumps
 * `default_dig_<groupname>`: Default node digging sound
   (see node sound definition for details)

Registered definitions
======================

Anything added using certain [Registration functions] gets added to one or more
of the global [Registered definition tables].

Note that in some cases you will stumble upon things that are not contained
in these tables (e.g. when a mod has been removed). Always check for
existence before trying to access the fields.

Example:

All nodes register with `minetest.register_node` get added to the table
`minetest.registered_nodes`.

If you want to check the drawtype of a node, you could do:

    local function get_nodedef_field(nodename, fieldname)
        if not minetest.registered_nodes[nodename] then
            return nil
        end
        return minetest.registered_nodes[nodename][fieldname]
    end
    local drawtype = get_nodedef_field(nodename, "drawtype")




Nodes
=====

Nodes are the bulk data of the world: cubes and other things that take the
space of a cube. Huge amounts of them are handled efficiently, but they
are quite static.

The definition of a node is stored and can be accessed by using

    minetest.registered_nodes[node.name]

See [Registered definitions].

Nodes are passed by value between Lua and the engine.
They are represented by a table:

    {name="name", param1=num, param2=num}

`param1` and `param2` are 8-bit integers ranging from 0 to 255. The engine uses
them for certain automated functions. If you don't use these functions, you can
use them to store arbitrary values.

Node paramtypes
---------------

The functions of `param1` and `param2` are determined by certain fields in the
node definition.

The function of `param1` is determined by `paramtype` in node definition.
`param1` is reserved for the engine when `paramtype != "none"`.

* `paramtype = "light"`
    * The value stores light with and without sun in its lower and upper 4 bits
      respectively.
    * Required by a light source node to enable spreading its light.
    * Required by the following drawtypes as they determine their visual
      brightness from their internal light value:
        * torchlike
        * signlike
        * firelike
        * fencelike
        * raillike
        * nodebox
        * mesh
        * plantlike
        * plantlike_rooted
* `paramtype = "none"`
    * `param1` will not be used by the engine and can be used to store
      an arbitrary value

The function of `param2` is determined by `paramtype2` in node definition.
`param2` is reserved for the engine when `paramtype2 != "none"`.

* `paramtype2 = "flowingliquid"`
    * Used by `drawtype = "flowingliquid"` and `liquidtype = "flowing"`
    * The liquid level and a flag of the liquid are stored in `param2`
    * Bits 0-2: Liquid level (0-7). The higher, the more liquid is in this node;
      see `minetest.get_node_level`, `minetest.set_node_level` and `minetest.add_node_level`
      to access/manipulate the content of this field
    * Bit 3: If set, liquid is flowing downwards (no graphical effect)
* `paramtype2 = "wallmounted"`
    * Supported drawtypes: "torchlike", "signlike", "plantlike",
      "plantlike_rooted", "normal", "nodebox", "mesh"
    * The rotation of the node is stored in `param2`
    * You can make this value by using `minetest.dir_to_wallmounted()`
    * Values range 0 - 5
    * The value denotes at which direction the node is "mounted":
      0 = y+,   1 = y-,   2 = x+,   3 = x-,   4 = z+,   5 = z-
* `paramtype2 = "facedir"`
    * Supported drawtypes: "normal", "nodebox", "mesh"
    * The rotation of the node is stored in `param2`. Furnaces and chests are
      rotated this way. Can be made by using `minetest.dir_to_facedir()`.
    * Values range 0 - 23
    * facedir / 4 = axis direction:
      0 = y+,   1 = z+,   2 = z-,   3 = x+,   4 = x-,   5 = y-
    * facedir modulo 4 = rotation around that axis
* `paramtype2 = "leveled"`
    * Only valid for "nodebox" with 'type = "leveled"', and "plantlike_rooted".
        * Leveled nodebox:
            * The level of the top face of the nodebox is stored in `param2`.
            * The other faces are defined by 'fixed = {}' like 'type = "fixed"'
              nodeboxes.
            * The nodebox height is (`param2` / 64) nodes.
            * The maximum accepted value of `param2` is 127.
        * Rooted plantlike:
            * The height of the 'plantlike' section is stored in `param2`.
            * The height is (`param2` / 16) nodes.
* `paramtype2 = "degrotate"`
    * Valid for `plantlike` and `mesh` drawtypes. The rotation of the node is
      stored in `param2`.
    * Values range 0–239. The value stored in `param2` is multiplied by 1.5 to
      get the actual rotation in degrees of the node.
* `paramtype2 = "meshoptions"`
    * Only valid for "plantlike" drawtype. `param2` encodes the shape and
      optional modifiers of the "plant". `param2` is a bitfield.
    * Bits 0 to 2 select the shape.
      Use only one of the values below:
        * 0 = a "x" shaped plant (ordinary plant)
        * 1 = a "+" shaped plant (just rotated 45 degrees)
        * 2 = a "*" shaped plant with 3 faces instead of 2
        * 3 = a "#" shaped plant with 4 faces instead of 2
        * 4 = a "#" shaped plant with 4 faces that lean outwards
        * 5-7 are unused and reserved for future meshes.
    * Bits 3 to 7 are used to enable any number of optional modifiers.
      Just add the corresponding value(s) below to `param2`:
        * 8  - Makes the plant slightly vary placement horizontally
        * 16 - Makes the plant mesh 1.4x larger
        * 32 - Moves each face randomly a small bit down (1/8 max)
        * values 64 and 128 (bits 6-7) are reserved for future use.
    * Example: `param2 = 0` selects a normal "x" shaped plant
    * Example: `param2 = 17` selects a "+" shaped plant, 1.4x larger (1+16)
* `paramtype2 = "color"`
    * `param2` tells which color is picked from the palette.
      The palette should have 256 pixels.
* `paramtype2 = "colorfacedir"`
    * Same as `facedir`, but with colors.
    * The first three bits of `param2` tells which color is picked from the
      palette. The palette should have 8 pixels.
* `paramtype2 = "colorwallmounted"`
    * Same as `wallmounted`, but with colors.
    * The first five bits of `param2` tells which color is picked from the
      palette. The palette should have 32 pixels.
* `paramtype2 = "glasslikeliquidlevel"`
    * Only valid for "glasslike_framed" or "glasslike_framed_optional"
      drawtypes. "glasslike_framed_optional" nodes are only affected if the
      "Connected Glass" setting is enabled.
    * Bits 0-5 define 64 levels of internal liquid, 0 being empty and 63 being
      full.
    * Bits 6 and 7 modify the appearance of the frame and node faces. One or
      both of these values may be added to `param2`:
        * 64  - Makes the node not connect with neighbors above or below it.
        * 128 - Makes the node not connect with neighbors to its sides.
    * Liquid texture is defined using `special_tiles = {"modname_tilename.png"}`
* `paramtype2 = "colordegrotate"`
    * Same as `degrotate`, but with colors.
    * The first (most-significant) three bits of `param2` tells which color
      is picked from the palette. The palette should have 8 pixels.
    * Remaining 5 bits store rotation in range 0–23 (i.e. in 15° steps)
* `paramtype2 = "none"`
    * `param2` will not be used by the engine and can be used to store
      an arbitrary value

Nodes can also contain extra data. See [Node Metadata].

Node drawtypes
--------------

There are a bunch of different looking node types.

Look for examples in `games/devtest` or `games/minetest_game`.

* `normal`
    * A node-sized cube.
* `airlike`
    * Invisible, uses no texture.
* `liquid`
    * The cubic source node for a liquid.
    * Faces bordering to the same node are never rendered.
    * Connects to node specified in `liquid_alternative_flowing`.
    * Use `backface_culling = false` for the tiles you want to make
      visible when inside the node.
* `flowingliquid`
    * The flowing version of a liquid, appears with various heights and slopes.
    * Faces bordering to the same node are never rendered.
    * Connects to node specified in `liquid_alternative_source`.
    * Node textures are defined with `special_tiles` where the first tile
      is for the top and bottom faces and the second tile is for the side
      faces.
    * `tiles` is used for the item/inventory/wield image rendering.
    * Use `backface_culling = false` for the special tiles you want to make
      visible when inside the node
* `glasslike`
    * Often used for partially-transparent nodes.
    * Only external sides of textures are visible.
* `glasslike_framed`
    * All face-connected nodes are drawn as one volume within a surrounding
      frame.
    * The frame appearance is generated from the edges of the first texture
      specified in `tiles`. The width of the edges used are 1/16th of texture
      size: 1 pixel for 16x16, 2 pixels for 32x32 etc.
    * The glass 'shine' (or other desired detail) on each node face is supplied
      by the second texture specified in `tiles`.
* `glasslike_framed_optional`
    * This switches between the above 2 drawtypes according to the menu setting
      'Connected Glass'.
* `allfaces`
    * Often used for partially-transparent nodes.
    * External and internal sides of textures are visible.
* `allfaces_optional`
    * Often used for leaves nodes.
    * This switches between `normal`, `glasslike` and `allfaces` according to
      the menu setting: Opaque Leaves / Simple Leaves / Fancy Leaves.
    * With 'Simple Leaves' selected, the texture specified in `special_tiles`
      is used instead, if present. This allows a visually thicker texture to be
      used to compensate for how `glasslike` reduces visual thickness.
* `torchlike`
    * A single vertical texture.
    * If `paramtype2="[color]wallmounted":
        * If placed on top of a node, uses the first texture specified in `tiles`.
        * If placed against the underside of a node, uses the second texture
          specified in `tiles`.
        * If placed on the side of a node, uses the third texture specified in
          `tiles` and is perpendicular to that node.
    * If `paramtype2="none"`:
        * Will be rendered as if placed on top of a node (see
          above) and only the first texture is used.
* `signlike`
    * A single texture parallel to, and mounted against, the top, underside or
      side of a node.
    * If `paramtype2="[color]wallmounted", it rotates according to `param2`
    * If `paramtype2="none"`, it will always be on the floor.
* `plantlike`
    * Two vertical and diagonal textures at right-angles to each other.
    * See `paramtype2 = "meshoptions"` above for other options.
* `firelike`
    * When above a flat surface, appears as 6 textures, the central 2 as
      `plantlike` plus 4 more surrounding those.
    * If not above a surface the central 2 do not appear, but the texture
      appears against the faces of surrounding nodes if they are present.
* `fencelike`
    * A 3D model suitable for a wooden fence.
    * One placed node appears as a single vertical post.
    * Adjacently-placed nodes cause horizontal bars to appear between them.
* `raillike`
    * Often used for tracks for mining carts.
    * Requires 4 textures to be specified in `tiles`, in order: Straight,
      curved, t-junction, crossing.
    * Each placed node automatically switches to a suitable rotated texture
      determined by the adjacent `raillike` nodes, in order to create a
      continuous track network.
    * Becomes a sloping node if placed against stepped nodes.
* `nodebox`
    * Often used for stairs and slabs.
    * Allows defining nodes consisting of an arbitrary number of boxes.
    * See [Node boxes] below for more information.
* `mesh`
    * Uses models for nodes.
    * Tiles should hold model materials textures.
    * Only static meshes are implemented.
    * For supported model formats see Irrlicht engine documentation.
* `plantlike_rooted`
    * Enables underwater `plantlike` without air bubbles around the nodes.
    * Consists of a base cube at the co-ordinates of the node plus a
      `plantlike` extension above
    * If `paramtype2="leveled", the `plantlike` extension has a height
      of `param2 / 16` nodes, otherwise it's the height of 1 node
    * If `paramtype2="wallmounted"`, the `plantlike` extension
      will be at one of the corresponding 6 sides of the base cube.
      Also, the base cube rotates like a `normal` cube would
    * The `plantlike` extension visually passes through any nodes above the
      base cube without affecting them.
    * The base cube texture tiles are defined as normal, the `plantlike`
      extension uses the defined special tile, for example:
      `special_tiles = {{name = "default_papyrus.png"}},`

`*_optional` drawtypes need less rendering time if deactivated
(always client-side).

Node boxes
----------

Node selection boxes are defined using "node boxes".

A nodebox is defined as any of:

    {
        -- A normal cube; the default in most things
        type = "regular"
    }
    {
        -- A fixed box (or boxes) (facedir param2 is used, if applicable)
        type = "fixed",
        fixed = box OR {box1, box2, ...}
    }
    {
        -- A variable height box (or boxes) with the top face position defined
        -- by the node parameter 'leveled = ', or if 'paramtype2 == "leveled"'
        -- by param2.
        -- Other faces are defined by 'fixed = {}' as with 'type = "fixed"'.
        type = "leveled",
        fixed = box OR {box1, box2, ...}
    }
    {
        -- A box like the selection box for torches
        -- (wallmounted param2 is used, if applicable)
        type = "wallmounted",
        wall_top = box,
        wall_bottom = box,
        wall_side = box
    }
    {
        -- A node that has optional boxes depending on neighbouring nodes'
        -- presence and type. See also `connects_to`.
        type = "connected",
        fixed = box OR {box1, box2, ...}
        connect_top = box OR {box1, box2, ...}
        connect_bottom = box OR {box1, box2, ...}
        connect_front = box OR {box1, box2, ...}
        connect_left = box OR {box1, box2, ...}
        connect_back = box OR {box1, box2, ...}
        connect_right = box OR {box1, box2, ...}
        -- The following `disconnected_*` boxes are the opposites of the
        -- `connect_*` ones above, i.e. when a node has no suitable neighbour
        -- on the respective side, the corresponding disconnected box is drawn.
        disconnected_top = box OR {box1, box2, ...}
        disconnected_bottom = box OR {box1, box2, ...}
        disconnected_front = box OR {box1, box2, ...}
        disconnected_left = box OR {box1, box2, ...}
        disconnected_back = box OR {box1, box2, ...}
        disconnected_right = box OR {box1, box2, ...}
        disconnected = box OR {box1, box2, ...} -- when there is *no* neighbour
        disconnected_sides = box OR {box1, box2, ...} -- when there are *no*
                                                      -- neighbours to the sides
    }

A `box` is defined as:

    {x1, y1, z1, x2, y2, z2}

A box of a regular node would look like:

    {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},

To avoid collision issues, keep each value within the range of +/- 1.45.
This also applies to leveled nodeboxes, where the final height shall not
exceed this soft limit.



Map terminology and coordinates
===============================

Nodes, mapblocks, mapchunks
---------------------------

A 'node' is the fundamental cubic unit of a world and appears to a player as
roughly 1x1x1 meters in size.

A 'mapblock' (often abbreviated to 'block') is 16x16x16 nodes and is the
fundamental region of a world that is stored in the world database, sent to
clients and handled by many parts of the engine.
'mapblock' is preferred terminology to 'block' to help avoid confusion with
'node', however 'block' often appears in the API.

A 'mapchunk' (sometimes abbreviated to 'chunk') is usually 5x5x5 mapblocks
(80x80x80 nodes) and is the volume of world generated in one operation by
the map generator.
The size in mapblocks has been chosen to optimise map generation.

Coordinates
-----------

### Orientation of axes

For node and mapblock coordinates, +X is East, +Y is up, +Z is North.

### Node coordinates

Almost all positions used in the API use node coordinates.

### Mapblock coordinates

Occasionally the API uses 'blockpos' which refers to mapblock coordinates that
specify a particular mapblock.
For example blockpos (0,0,0) specifies the mapblock that extends from
node position (0,0,0) to node position (15,15,15).

#### Converting node position to the containing blockpos

To calculate the blockpos of the mapblock that contains the node at 'nodepos',
for each axis:

* blockpos = math.floor(nodepos / 16)

#### Converting blockpos to min/max node positions

To calculate the min/max node positions contained in the mapblock at 'blockpos',
for each axis:

* Minimum:
  nodepos = blockpos * 16
* Maximum:
  nodepos = blockpos * 16 + 15




HUD
===

HUD element types
-----------------

The position field is used for all element types.

To account for differing resolutions, the position coordinates are the
percentage of the screen, ranging in value from `0` to `1`.

The name field is not yet used, but should contain a description of what the
HUD element represents.

The `direction` field is the direction in which something is drawn.
`0` draws from left to right, `1` draws from right to left, `2` draws from
top to bottom, and `3` draws from bottom to top.

The `alignment` field specifies how the item will be aligned. It is a table
where `x` and `y` range from `-1` to `1`, with `0` being central. `-1` is
moved to the left/up, and `1` is to the right/down. Fractional values can be
used.

The `offset` field specifies a pixel offset from the position. Contrary to
position, the offset is not scaled to screen size. This allows for some
precisely positioned items in the HUD.

**Note**: `offset` _will_ adapt to screen DPI as well as user defined scaling
factor!

The `z_index` field specifies the order of HUD elements from back to front.
Lower z-index elements are displayed behind higher z-index elements. Elements
with same z-index are displayed in an arbitrary order. Default 0.
Supports negative values. By convention, the following values are recommended:

*  -400: Graphical effects, such as vignette
*  -300: Name tags, waypoints
*  -200: Wieldhand
*  -100: Things that block the player's view, e.g. masks
*     0: Default. For standard in-game HUD elements like crosshair, hotbar,
         minimap, builtin statbars, etc.
*   100: Temporary text messages or notification icons
*  1000: Full-screen effects such as full-black screen or credits.
         This includes effects that cover the entire screen
* Other: If your HUD element doesn't fit into any category, pick a number
         between the suggested values



Below are the specific uses for fields in each type; fields not listed for that
type are ignored.

### `image`

Displays an image on the HUD.

* `scale`: The scale of the image, with 1 being the original texture size.
  Only the X coordinate scale is used (positive values).
  Negative values represent that percentage of the screen it
  should take; e.g. `x=-100` means 100% (width).
* `text`: The name of the texture that is displayed.
* `alignment`: The alignment of the image.
* `offset`: offset in pixels from position.

### `text`

Displays text on the HUD.

* `scale`: Defines the bounding rectangle of the text.
  A value such as `{x=100, y=100}` should work.
* `text`: The text to be displayed in the HUD element.
* `number`: An integer containing the RGB value of the color used to draw the
  text. Specify `0xFFFFFF` for white text, `0xFF0000` for red, and so on.
* `alignment`: The alignment of the text.
* `offset`: offset in pixels from position.
* `size`: size of the text.
  The player-set font size is multiplied by size.x (y value isn't used).

### `statbar`

Displays a horizontal bar made up of half-images with an optional background.

* `text`: The name of the texture to use.
* `text2`: Optional texture name to enable a background / "off state"
  texture (useful to visualize the maximal value). Both textures
  must have the same size.
* `number`: The number of half-textures that are displayed.
  If odd, will end with a vertically center-split texture.
* `item`: Same as `number` but for the "off state" texture
* `direction`: To which direction the images will extend to
* `offset`: offset in pixels from position.
* `size`: If used, will force full-image size to this value (override texture
  pack image size)

### `inventory`

* `text`: The name of the inventory list to be displayed.
* `number`: Number of items in the inventory to be displayed.
* `item`: Position of item that is selected.
* `direction`
* `offset`: offset in pixels from position.

### `waypoint`

Displays distance to selected world position.

* `name`: The name of the waypoint.
* `text`: Distance suffix. Can be blank.
* `precision`: Waypoint precision, integer >= 0. Defaults to 10.
  If set to 0, distance is not shown. Shown value is `floor(distance*precision)/precision`.
  When the precision is an integer multiple of 10, there will be `log_10(precision)` digits after the decimal point.
  `precision = 1000`, for example, will show 3 decimal places (eg: `0.999`).
  `precision = 2` will show multiples of `0.5`; precision = 5 will show multiples of `0.2` and so on:
  `precision = n` will show multiples of `1/n`
* `number:` An integer containing the RGB value of the color used to draw the
  text.
* `world_pos`: World position of the waypoint.
* `offset`: offset in pixels from position.
* `alignment`: The alignment of the waypoint.

### `image_waypoint`

Same as `image`, but does not accept a `position`; the position is instead determined by `world_pos`, the world position of the waypoint.

* `scale`: The scale of the image, with 1 being the original texture size.
  Only the X coordinate scale is used (positive values).
  Negative values represent that percentage of the screen it
  should take; e.g. `x=-100` means 100% (width).
* `text`: The name of the texture that is displayed.
* `alignment`: The alignment of the image.
* `world_pos`: World position of the waypoint.
* `offset`: offset in pixels from position.

### `compass`

Displays an image oriented or translated according to current heading direction.

* `size`: The size of this element. Negative values represent percentage
  of the screen; e.g. `x=-100` means 100% (width).
* `scale`: Scale of the translated image (used only for dir = 2 or dir = 3).
* `text`: The name of the texture to use.
* `alignment`: The alignment of the image.
* `offset`: Offset in pixels from position.
* `dir`: How the image is rotated/translated:
  * 0 - Rotate as heading direction
  * 1 - Rotate in reverse direction
  * 2 - Translate as landscape direction
  * 3 - Translate in reverse direction

If translation is chosen, texture is repeated horizontally to fill the whole element.

### `minimap`

Displays a minimap on the HUD.

* `size`: Size of the minimap to display. Minimap should be a square to avoid
  distortion.
* `alignment`: The alignment of the minimap.
* `offset`: offset in pixels from position.

Representations of simple things
================================

Vector (ie. a position)
-----------------------

    vector.new(x, y, z)

See [Spatial Vectors] for details.

`pointed_thing`
---------------

* `{type="nothing"}`
* `{type="node", under=pos, above=pos}`
    * Indicates a pointed node selection box.
    * `under` refers to the node position behind the pointed face.
    * `above` refers to the node position in front of the pointed face.
* `{type="object", ref=ObjectRef}`

Exact pointing location (currently only `Raycast` supports these fields):

* `pointed_thing.intersection_point`: The absolute world coordinates of the
  point on the selection box which is pointed at. May be in the selection box
  if the pointer is in the box too.
* `pointed_thing.box_id`: The ID of the pointed selection box (counting starts
  from 1).
* `pointed_thing.intersection_normal`: Unit vector, points outwards of the
  selected selection box. This specifies which face is pointed at.
  Is a null vector `vector.zero()` when the pointer is inside the selection box.




Flag Specifier Format
=====================

Flags using the standardized flag specifier format can be specified in either
of two ways, by string or table.

The string format is a comma-delimited set of flag names; whitespace and
unrecognized flag fields are ignored. Specifying a flag in the string sets the
flag, and specifying a flag prefixed by the string `"no"` explicitly
clears the flag from whatever the default may be.

In addition to the standard string flag format, the schematic flags field can
also be a table of flag names to boolean values representing whether or not the
flag is set. Additionally, if a field with the flag name prefixed with `"no"`
is present, mapped to a boolean of any value, the specified flag is unset.

E.g. A flag field of value

    {place_center_x = true, place_center_y=false, place_center_z=true}

is equivalent to

    {place_center_x = true, noplace_center_y=true, place_center_z=true}

which is equivalent to

    "place_center_x, noplace_center_y, place_center_z"

or even

    "place_center_x, place_center_z"

since, by default, no schematic attributes are set.




Items
=====

Items are things that can be held by players, dropped in the map and
stored in inventories.
Items come in the form of item stacks, which are collections of equal
items that occupy a single inventory slot.

Item types
----------

There are three kinds of items: nodes, tools and craftitems.

* Node: Placeable item form of a node in the world's voxel grid
* Tool: Has a changable wear property but cannot be stacked
* Craftitem: Has no special properties

Every registered node (the voxel in the world) has a corresponding
item form (the thing in your inventory) that comes along with it.
This item form can be placed which will create a node in the
world (by default).
Both the 'actual' node and its item form share the same identifier.
For all practical purposes, you can treat the node and its item form
interchangeably. We usually just say 'node' to the item form of
the node as well.

Note the definition of tools is purely technical. The only really
unique thing about tools is their wear, and that's basically it.
Beyond that, you can't make any gameplay-relevant assumptions
about tools or non-tools. It is perfectly valid to register something
that acts as tool in a gameplay sense as a craftitem, and vice-versa.

Craftitems can be used for items that neither need to be a node
nor a tool.

Amount and wear
---------------

All item stacks have an amount between 0 and 65535. It is 1 by
default. Tool item stacks can not have an amount greater than 1.

Tools use a wear (damage) value ranging from 0 to 65535. The
value 0 is the default and is used for unworn tools. The values
1 to 65535 are used for worn tools, where a higher value stands for
a higher wear. Non-tools technically also have a wear property,
but it is always 0. There is also a special 'toolrepair' crafting
recipe that is only available to tools.

Item formats
------------

Items and item stacks can exist in three formats: Serializes, table format
and `ItemStack`.

When an item must be passed to a function, it can usually be in any of
these formats.

### Serialized

This is called "stackstring" or "itemstring". It is a simple string with
1-4 components:

1. Full item identifier ("item name")
2. Optional amount
3. Optional wear value
4. Optional item metadata

Syntax:

    <identifier> [<amount>[ <wear>[ <metadata>]]]

Examples:

* `"default:apple"`: 1 apple
* `"default:dirt 5"`: 5 dirt
* `"default:pick_stone"`: a new stone pickaxe
* `"default:pick_wood 1 21323"`: a wooden pickaxe, ca. 1/3 worn out
* `[[default:pick_wood 1 21323 "\u0001description\u0002My worn out pick\u0003"]]`:
  * a wooden pickaxe from the `default` mod,
  * amount must be 1 (pickaxe is a tool), ca. 1/3 worn out (it's a tool),
  * with the `description` field set to `"My worn out pick"` in its metadata
* `[[default:dirt 5 0 "\u0001description\u0002Special dirt\u0003"]]`:
  * analogeous to the above example
  * note how the wear is set to `0` as dirt is not a tool

You should ideally use the `ItemStack` format to build complex item strings
(especially if they use item metadata)
without relying on the serialization format. Example:

    local stack = ItemStack("default:pick_wood")
    stack:set_wear(21323)
    stack:get_meta():set_string("description", "My worn out pick")
    local itemstring = stack:to_string()

Additionally the methods `minetest.itemstring_with_palette(item, palette_index)`
and `minetest.itemstring_with_color(item, colorstring)` may be used to create
item strings encoding color information in their metadata.

### Table format

Examples:

5 dirt nodes:

    {name="default:dirt", count=5, wear=0, metadata=""}

A wooden pick about 1/3 worn out:

    {name="default:pick_wood", count=1, wear=21323, metadata=""}

An apple:

    {name="default:apple", count=1, wear=0, metadata=""}

### `ItemStack`

A native C++ format with many helper methods. Useful for converting
between formats. See the [Class reference] section for details.




Groups
======

In a number of places, there is a group table. Groups define the
properties of a thing (item, node, armor of entity, tool capabilities)
in such a way that the engine and other mods can can interact with
the thing without actually knowing what the thing is.

Usage
-----

Groups are stored in a table, having the group names with keys and the
group ratings as values. Group ratings are integer values within the
range [-32767, 32767]. For example:

    -- Default dirt
    groups = {crumbly=3, soil=1}

    -- A more special dirt-kind of thing
    groups = {crumbly=2, soil=1, level=2, outerspace=1}

Groups always have a rating associated with them. If there is no
useful meaning for a rating for an enabled group, it shall be `1`.

When not defined, the rating of a group defaults to `0`. Thus when you
read groups, you must interpret `nil` and `0` as the same value, `0`.

You can read the rating of a group for an item or a node by using

    minetest.get_item_group(itemname, groupname)

Groups of items
---------------

Groups of items can define what kind of an item it is (e.g. wool).

Groups of nodes
---------------

In addition to the general item things, groups are used to define whether
a node is destroyable and how long it takes to destroy by a tool.

Groups of entities
------------------

For entities, groups are, as of now, used only for calculating damage.
The rating is the percentage of damage caused by items with this damage group.
See [Entity damage mechanism].

    object.get_armor_groups() --> a group-rating table (e.g. {fleshy=100})
    object.set_armor_groups({fleshy=30, cracky=80})

Groups of tool capabilities
---------------------------

Groups in tool capabilities define which groups of nodes and entities they
are effective towards.

Groups in crafting recipes
--------------------------

An example: Make meat soup from any meat, any water and any bowl:

    {
        output = "food:meat_soup_raw",
        recipe = {
            {"group:meat"},
            {"group:water"},
            {"group:bowl"},
        },
    }

Another example: Make red wool from white wool and red dye:

    {
        type = "shapeless",
        output = "wool:red",
        recipe = {"wool:white", "group:dye,basecolor_red"},
    }

Special groups
--------------

The asterisk `(*)` after a group name describes that there is no engine
functionality bound to it, and implementation is left up as a suggestion
to games.

### Node and item groups

* `not_in_creative_inventory`: (*) Special group for inventory mods to indicate
  that the item should be hidden in item lists.


### Node-only groups

* `attached_node`: if the node under it is not a walkable block the node will be
  dropped as an item. If the node is wallmounted the wallmounted direction is
  checked.
* `bouncy`: value is bounce speed in percent
* `connect_to_raillike`: makes nodes of raillike drawtype with same group value
  connect to each other
* `dig_immediate`: Player can always pick up node without reducing tool wear
    * `2`: the node always gets the digging time 0.5 seconds (rail, sign)
    * `3`: the node always gets the digging time 0 seconds (torch)
* `disable_jump`: Player (and possibly other things) cannot jump from node
  or if their feet are in the node. Note: not supported for `new_move = false`
* `fall_damage_add_percent`: modifies the fall damage suffered when hitting
  the top of this node. There's also an armor group with the same name.
  The final player damage is determined by the following formula:
    damage =
      collision speed
      * ((node_fall_damage_add_percent   + 100) / 100) -- node group
      * ((player_fall_damage_add_percent + 100) / 100) -- player armor group
      - (14)                                           -- constant tolerance
  Negative damage values are discarded as no damage.
* `falling_node`: if there is no walkable block under the node it will fall
* `float`: the node will not fall through liquids (`liquidtype ~= "none"`)
* `level`: Can be used to give an additional sense of progression in the game.
     * A larger level will cause e.g. a weapon of a lower level make much less
       damage, and get worn out much faster, or not be able to get drops
       from destroyed nodes.
     * `0` is something that is directly accessible at the start of gameplay
     * There is no upper limit
     * See also: `leveldiff` in [Tool Capabilities]
* `slippery`: Players and items will slide on the node.
  Slipperiness rises steadily with `slippery` value, starting at 1.


### Tool-only groups

* `disable_repair`: If set to 1 for a tool, it cannot be repaired using the
  `"toolrepair"` crafting recipe


### `ObjectRef` armor groups

* `immortal`: Skips all damage and breath handling for an object. This group
  will also hide the integrated HUD status bars for players. It is
  automatically set to all players when damage is disabled on the server and
  cannot be reset (subject to change).
* `fall_damage_add_percent`: Modifies the fall damage suffered by players
  when they hit the ground. It is analog to the node group with the same
  name. See the node group above for the exact calculation.
* `punch_operable`: For entities; disables the regular damage mechanism for
  players punching it by hand or a non-tool item, so that it can do something
  else than take damage.



Known damage and digging time defining groups
---------------------------------------------

* `crumbly`: dirt, sand
* `cracky`: tough but crackable stuff like stone.
* `snappy`: something that can be cut using things like scissors, shears,
  bolt cutters and the like, e.g. leaves, small plants, wire, sheets of metal
* `choppy`: something that can be cut using force; e.g. trees, wooden planks
* `fleshy`: Living things like animals and the player. This could imply
  some blood effects when hitting.
* `explody`: Especially prone to explosions
* `oddly_breakable_by_hand`:
   Can be added to nodes that shouldn't logically be breakable by the
   hand but are. Somewhat similar to `dig_immediate`, but times are more
   like `{[1]=3.50,[2]=2.00,[3]=0.70}` and this does not override the
   digging speed of an item if it can dig at a faster speed than this
   suggests for the hand.

Examples of custom groups
-------------------------

Item groups are often used for defining, well, _groups of items_.

* `meat`: any meat-kind of a thing (rating might define the size or healing
  ability or be irrelevant -- it is not defined as of yet)
* `eatable`: anything that can be eaten. Rating might define HP gain in half
  hearts.
* `flammable`: can be set on fire. Rating might define the intensity of the
  fire, affecting e.g. the speed of the spreading of an open fire.
* `wool`: any wool (any origin, any color)
* `metal`: any metal
* `weapon`: any weapon
* `heavy`: anything considerably heavy

Digging time calculation specifics
----------------------------------

Groups such as `crumbly`, `cracky` and `snappy` are used for this
purpose. Rating is `1`, `2` or `3`. A higher rating for such a group implies
faster digging time.

The `level` group is used to limit the toughness of nodes an item capable
of digging can dig and to scale the digging times / damage to a greater extent.

**Please do understand this**, otherwise you cannot use the system to it's
full potential.

Items define their properties by a list of parameters for groups. They
cannot dig other groups; thus it is important to use a standard bunch of
groups to enable interaction with items.




Tool Capabilities
=================

'Tool capabilities' is a property of items that defines two things:

1) Which nodes it can dig and how fast
2) Which objects it can hurt by punching and by how much

Tool capabilities are available for all items, not just tools.
But only tools can receive wear from digging and punching.

Missing or incomplete tool capabilities will default to the
player's hand.

Tool capabilities definition
----------------------------

Tool capabilities define:

* Full punch interval
* Maximum drop level
* For an arbitrary list of node groups:
    * Uses (until the tool breaks)
    * Maximum level (usually `0`, `1`, `2` or `3`)
    * Digging times
* Damage groups
* Punch attack uses (until the tool breaks)

### Full punch interval

When used as a weapon, the item will do full damage if this time is spent
between punches. If e.g. half the time is spent, the item will do half
damage.

### Maximum drop level

Suggests the maximum level of node, when dug with the item, that will drop
its useful item. (e.g. iron ore to drop a lump of iron).

This is not automated; it is the responsibility of the node definition
to implement this.

### Uses (tools only)

Determines how many uses the tool has when it is used for digging a node,
of this group, of the maximum level. The maximum supported number of
uses is 65535. The special number 0 is used for infinite uses.
For lower leveled nodes, the use count is multiplied by `3^leveldiff`.
`leveldiff` is the difference of the tool's `maxlevel` `groupcaps` and the
node's `level` group. The node cannot be dug if `leveldiff` is less than zero.

* `uses=10, leveldiff=0`: actual uses: 10
* `uses=10, leveldiff=1`: actual uses: 30
* `uses=10, leveldiff=2`: actual uses: 90

For non-tools, this has no effect.

### Maximum level

Tells what is the maximum level of a node of this group that the item will
be able to dig.

### Digging times

List of digging times for different ratings of the group, for nodes of the
maximum level.

For example, as a Lua table, `times={2=2.00, 3=0.70}`. This would
result in the item to be able to dig nodes that have a rating of `2` or `3`
for this group, and unable to dig the rating `1`, which is the toughest.
Unless there is a matching group that enables digging otherwise.

If the result digging time is 0, a delay of 0.15 seconds is added between
digging nodes; If the player releases LMB after digging, this delay is set to 0,
i.e. players can more quickly click the nodes away instead of holding LMB.

### Damage groups

List of damage for groups of entities. See [Entity damage mechanism].

### Punch attack uses (tools only)

Determines how many uses (before breaking) the tool has when dealing damage
to an object, when the full punch interval (see above) was always
waited out fully.

Wear received by the tool is proportional to the time spent, scaled by
the full punch interval.

For non-tools, this has no effect.

Example definition of the capabilities of an item
-------------------------------------------------

    tool_capabilities = {
        full_punch_interval=1.5,
        max_drop_level=1,
        groupcaps={
            crumbly={maxlevel=2, uses=20, times={[1]=1.60, [2]=1.20, [3]=0.80}}
        },
        damage_groups = {fleshy=2},
    }

This makes the item capable of digging nodes that fulfil both of these:

* Have the `crumbly` group
* Have a `level` group less or equal to `2`

Table of resulting digging times:

    crumbly        0     1     2     3     4  <- level
         ->  0     -     -     -     -     -
             1  0.80  1.60  1.60     -     -
             2  0.60  1.20  1.20     -     -
             3  0.40  0.80  0.80     -     -

    level diff:    2     1     0    -1    -2

Table of resulting tool uses:

    ->  0     -     -     -     -     -
        1   180    60    20     -     -
        2   180    60    20     -     -
        3   180    60    20     -     -

**Notes**:

* At `crumbly==0`, the node is not diggable.
* At `crumbly==3`, the level difference digging time divider kicks in and makes
  easy nodes to be quickly breakable.
* At `level > 2`, the node is not diggable, because it's `level > maxlevel`




Entity damage mechanism
=======================

Damage calculation:

    damage = 0
    foreach group in cap.damage_groups:
        damage += cap.damage_groups[group]
            * limit(actual_interval / cap.full_punch_interval, 0.0, 1.0)
            * (object.armor_groups[group] / 100.0)
            -- Where object.armor_groups[group] is 0 for inexistent values
    return damage

Client predicts damage based on damage groups. Because of this, it is able to
give an immediate response when an entity is damaged or dies; the response is
pre-defined somehow (e.g. by defining a sprite animation) (not implemented;
TODO).
Currently a smoke puff will appear when an entity dies.

The group `immortal` completely disables normal damage.

Entities can define a special armor group, which is `punch_operable`. This
group disables the regular damage mechanism for players punching it by hand or
a non-tool item, so that it can do something else than take damage.

On the Lua side, every punch calls:

    entity:on_punch(puncher, time_from_last_punch, tool_capabilities, direction,
                    damage)

This should never be called directly, because damage is usually not handled by
the entity itself.

* `puncher` is the object performing the punch. Can be `nil`. Should never be
  accessed unless absolutely required, to encourage interoperability.
* `time_from_last_punch` is time from last punch (by `puncher`) or `nil`.
* `tool_capabilities` can be `nil`.
* `direction` is a unit vector, pointing from the source of the punch to
   the punched object.
* `damage` damage that will be done to entity
Return value of this function will determine if damage is done by this function
(retval true) or shall be done by engine (retval false)

To punch an entity/object in Lua, call:

  object:punch(puncher, time_from_last_punch, tool_capabilities, direction)

* Return value is tool wear.
* Parameters are equal to the above callback.
* If `direction` equals `nil` and `puncher` does not equal `nil`, `direction`
  will be automatically filled in based on the location of `puncher`.




Metadata
========

Node Metadata
-------------

The instance of a node in the world normally only contains the three values
mentioned in [Nodes]. However, it is possible to insert extra data into a node.
It is called "node metadata"; See `NodeMetaRef`.

Node metadata contains two things:

* A key-value store
* An inventory

Some of the values in the key-value store are handled specially:

* `formspec`: Defines an inventory menu that is opened with the
              'place/use' key. Only works if no `on_rightclick` was
              defined for the node. See also [Formspec].
* `infotext`: Text shown on the screen when the node is pointed at.
              Line-breaks will be applied automatically.
              If the infotext is very long, it will be truncated.

Example:

    local meta = minetest.get_meta(pos)
    meta:set_string("formspec",
            "size[8,9]"..
            "list[context;main;0,0;8,4;]"..
            "list[current_player;main;0,5;8,4;]")
    meta:set_string("infotext", "Chest");
    local inv = meta:get_inventory()
    inv:set_size("main", 8*4)
    print(dump(meta:to_table()))
    meta:from_table({
        inventory = {
            main = {[1] = "default:dirt", [2] = "", [3] = "", [4] = "",
                    [5] = "", [6] = "", [7] = "", [8] = "", [9] = "",
                    [10] = "", [11] = "", [12] = "", [13] = "",
                    [14] = "default:cobble", [15] = "", [16] = "", [17] = "",
                    [18] = "", [19] = "", [20] = "default:cobble", [21] = "",
                    [22] = "", [23] = "", [24] = "", [25] = "", [26] = "",
                    [27] = "", [28] = "", [29] = "", [30] = "", [31] = "",
                    [32] = ""}
        },
        fields = {
            formspec = "size[8,9]list[context;main;0,0;8,4;]list[current_player;main;0,5;8,4;]",
            infotext = "Chest"
        }
    })

Item Metadata
-------------

Item stacks can store metadata too. See [`ItemStackMetaRef`].

Item metadata only contains a key-value store.

Some of the values in the key-value store are handled specially:

* `description`: Set the item stack's description.
  See also: `get_description` in [`ItemStack`]
* `short_description`: Set the item stack's short description.
  See also: `get_short_description` in [`ItemStack`]
* `color`: A `ColorString`, which sets the stack's color.
* `palette_index`: If the item has a palette, this is used to get the
  current color from the palette.
* `count_meta`: Replace the displayed count with any string.
* `count_alignment`: Set the alignment of the displayed count value. This is an
  int value. The lowest 2 bits specify the alignment in x-direction, the 3rd and
  4th bit specify the alignment in y-direction:
  0 = default, 1 = left / up, 2 = middle, 3 = right / down
  The default currently is the same as right/down.
  Example: 6 = 2 + 1*4 = middle,up

Example:

    local meta = stack:get_meta()
    meta:set_string("key", "value")
    print(dump(meta:to_table()))

Example manipulations of "description" and expected output behaviors:

    print(ItemStack("default:pick_steel"):get_description()) --> Steel Pickaxe
    print(ItemStack("foobar"):get_description()) --> Unknown Item

    local stack = ItemStack("default:stone")
    stack:get_meta():set_string("description", "Custom description\nAnother line")
    print(stack:get_description()) --> Custom description\nAnother line
    print(stack:get_short_description()) --> Custom description

    stack:get_meta():set_string("short_description", "Short")
    print(stack:get_description()) --> Custom description\nAnother line
    print(stack:get_short_description()) --> Short

    print(ItemStack("mod:item_with_no_desc"):get_description()) --> mod:item_with_no_desc



Formspec
========

Formspec defines a menu. This supports inventories and some of the
typical widgets like buttons, checkboxes, text input fields, etc.
It is a string, with a somewhat strange format.

A formspec is made out of formspec elements, which includes widgets
like buttons but also can be used to set stuff like background color.

Many formspec elements have a `name`, which is a unique identifier which
is used when the server receives user input. You must not use the name
"quit" for formspec elements.

Spaces and newlines can be inserted between the blocks, as is used in the
examples.

Position and size units are inventory slots unless the new coordinate system
is enabled. `X` and `Y` position the formspec element relative to the top left
of the menu or container. `W` and `H` are its width and height values.

If the new system is enabled, all elements have unified coordinates for all
elements with no padding or spacing in between. This is highly recommended
for new forms. See `real_coordinates[<bool>]` and `Migrating to Real
Coordinates`.

Inventories with a `player:<name>` inventory location are only sent to the
player named `<name>`.

When displaying text which can contain formspec code, e.g. text set by a player,
use `minetest.formspec_escape`.
For coloured text you can use `minetest.colorize`.

Since formspec version 3, elements drawn in the order they are defined. All
background elements are drawn before all other elements.

**WARNING**: do _not_ use a element name starting with `key_`; those names are
reserved to pass key press events to formspec!

**WARNING**: Minetest allows you to add elements to every single formspec instance
using `player:set_formspec_prepend()`, which may be the reason backgrounds are
appearing when you don't expect them to, or why things are styled differently
to normal. See [`no_prepend[]`] and [Styling Formspecs].

Examples
--------

### Chest

    size[8,9]
    list[context;main;0,0;8,4;]
    list[current_player;main;0,5;8,4;]

### Furnace

    size[8,9]
    list[context;fuel;2,3;1,1;]
    list[context;src;2,1;1,1;]
    list[context;dst;5,1;2,2;]
    list[current_player;main;0,5;8,4;]

### Minecraft-like player inventory

    size[8,7.5]
    image[1,0.6;1,2;player.png]
    list[current_player;main;0,3.5;8,4;]
    list[current_player;craft;3,0;3,3;]
    list[current_player;craftpreview;7,1;1,1;]

Version History
---------------

* Formspec version 1 (pre-5.1.0):
  * (too much)
* Formspec version 2 (5.1.0):
  * Forced real coordinates
  * background9[]: 9-slice scaling parameters
* Formspec version 3 (5.2.0):
  * Formspec elements are drawn in the order of definition
  * bgcolor[]: use 3 parameters (bgcolor, formspec (now an enum), fbgcolor)
  * box[] and image[] elements enable clipping by default
  * new element: scroll_container[]
* Formspec version 4 (5.4.0):
  * Allow dropdown indexing events
* Formspec version 5 (5.5.0):
  * Added padding[] element

Elements
--------

### `formspec_version[<version>]`

* Set the formspec version to a certain number. If not specified,
  version 1 is assumed.
* Must be specified before `size` element.
* Clients older than this version can neither show newer elements nor display
  elements with new arguments correctly.
* Available since feature `formspec_version_element`.
* See also: [Version History]

### `size[<W>,<H>,<fixed_size>]`

* Define the size of the menu in inventory slots
* `fixed_size`: `true`/`false` (optional)
* deprecated: `invsize[<W>,<H>;]`

### `position[<X>,<Y>]`

* Must be used after `size` element.
* Defines the position on the game window of the formspec's `anchor` point.
* For X and Y, 0.0 and 1.0 represent opposite edges of the game window,
  for example:
    * [0.0, 0.0] sets the position to the top left corner of the game window.
    * [1.0, 1.0] sets the position to the bottom right of the game window.
* Defaults to the center of the game window [0.5, 0.5].

### `anchor[<X>,<Y>]`

* Must be used after both `size` and `position` (if present) elements.
* Defines the location of the anchor point within the formspec.
* For X and Y, 0.0 and 1.0 represent opposite edges of the formspec,
  for example:
    * [0.0, 1.0] sets the anchor to the bottom left corner of the formspec.
    * [1.0, 0.0] sets the anchor to the top right of the formspec.
* Defaults to the center of the formspec [0.5, 0.5].

* `position` and `anchor` elements need suitable values to avoid a formspec
  extending off the game window due to particular game window sizes.

### `padding[<X>,<Y>]`

* Must be used after the `size`, `position`, and `anchor` elements (if present).
* Defines how much space is padded around the formspec if the formspec tries to
  increase past the size of the screen and coordinates have to be shrunk.
* For X and Y, 0.0 represents no padding (the formspec can touch the edge of the
  screen), and 0.5 represents half the screen (which forces the coordinate size
  to 0). If negative, the formspec can extend off the edge of the screen.
* Defaults to [0.05, 0.05].

### `no_prepend[]`

* Must be used after the `size`, `position`, `anchor`, and `padding` elements
  (if present).
* Disables player:set_formspec_prepend() from applying to this formspec.

### `real_coordinates[<bool>]`

* INFORMATION: Enable it automatically using `formspec_version` version 2 or newer.
* When set to true, all following formspec elements will use the new coordinate system.
* If used immediately after `size`, `position`, `anchor`, and `no_prepend` elements
  (if present), the form size will use the new coordinate system.
* **Note**: Formspec prepends are not affected by the coordinates in the main form.
  They must enable it explicitly.
* For information on converting forms to the new coordinate system, see `Migrating
  to Real Coordinates`.

### `container[<X>,<Y>]`

* Start of a container block, moves all physical elements in the container by
  (X, Y).
* Must have matching `container_end`
* Containers can be nested, in which case the offsets are added
  (child containers are relative to parent containers)

### `container_end[]`

* End of a container, following elements are no longer relative to this
  container.

### `scroll_container[<X>,<Y>;<W>,<H>;<scrollbar name>;<orientation>;<scroll factor>]`

* Start of a scroll_container block. All contained elements will ...
  * take the scroll_container coordinate as position origin,
  * be additionally moved by the current value of the scrollbar with the name
    `scrollbar name` times `scroll factor` along the orientation `orientation` and
  * be clipped to the rectangle defined by `X`, `Y`, `W` and `H`.
* `orientation`: possible values are `vertical` and `horizontal`.
* `scroll factor`: optional, defaults to `0.1`.
* Nesting is possible.
* Some elements might work a little different if they are in a scroll_container.
* Note: If you want the scroll_container to actually work, you also need to add a
  scrollbar element with the specified name. Furthermore, it is highly recommended
  to use a scrollbaroptions element on this scrollbar.

### `scroll_container_end[]`

* End of a scroll_container, following elements are no longer bound to this
  container.

### `list[<inventory location>;<list name>;<X>,<Y>;<W>,<H>;<starting item index>]`

* Show an inventory list if it has been sent to the client.
* If the inventory list changes (eg. it didn't exist before, it's resized, or its items
  are moved) while the formspec is open, the formspec element may (but is not guaranteed
  to) adapt to the new inventory list.
* Item slots are drawn in a grid from left to right, then up to down, ordered
  according to the slot index.
* `W` and `H` are in inventory slots, not in coordinates.
* `starting item index` (Optional): The index of the first (upper-left) item to draw.
  Indices start at `0`. Default is `0`.
* The number of shown slots is the minimum of `W*H` and the inventory list's size minus
  `starting item index`.
* **Note**: With the new coordinate system, the spacing between inventory
  slots is one-fourth the size of an inventory slot by default. Also see
  [Styling Formspecs] for changing the size of slots and spacing.

### `listring[<inventory location>;<list name>]`

* Allows to create a ring of inventory lists
* Shift-clicking on items in one element of the ring
  will send them to the next inventory list inside the ring
* The first occurrence of an element inside the ring will
  determine the inventory where items will be sent to

### `listring[]`

* Shorthand for doing `listring[<inventory location>;<list name>]`
  for the last two inventory lists added by list[...]

### `listcolors[<slot_bg_normal>;<slot_bg_hover>]`

* Sets background color of slots as `ColorString`
* Sets background color of slots on mouse hovering

### `listcolors[<slot_bg_normal>;<slot_bg_hover>;<slot_border>]`

* Sets background color of slots as `ColorString`
* Sets background color of slots on mouse hovering
* Sets color of slots border

### `listcolors[<slot_bg_normal>;<slot_bg_hover>;<slot_border>;<tooltip_bgcolor>;<tooltip_fontcolor>]`

* Sets background color of slots as `ColorString`
* Sets background color of slots on mouse hovering
* Sets color of slots border
* Sets default background color of tooltips
* Sets default font color of tooltips

### `tooltip[<gui_element_name>;<tooltip_text>;<bgcolor>;<fontcolor>]`

* Adds tooltip for an element
* `bgcolor` tooltip background color as `ColorString` (optional)
* `fontcolor` tooltip font color as `ColorString` (optional)

### `tooltip[<X>,<Y>;<W>,<H>;<tooltip_text>;<bgcolor>;<fontcolor>]`

* Adds tooltip for an area. Other tooltips will take priority when present.
* `bgcolor` tooltip background color as `ColorString` (optional)
* `fontcolor` tooltip font color as `ColorString` (optional)

### `image[<X>,<Y>;<W>,<H>;<texture name>]`

* Show an image

### `animated_image[<X>,<Y>;<W>,<H>;<name>;<texture name>;<frame count>;<frame duration>;<frame start>]`

* Show an animated image. The image is drawn like a "vertical_frames" tile
    animation (See [Tile animation definition]), but uses a frame count/duration
    for simplicity
* `name`: Element name to send when an event occurs. The event value is the index of the current frame.
* `texture name`: The image to use.
* `frame count`: The number of frames animating the image.
* `frame duration`: Milliseconds between each frame. `0` means the frames don't advance.
* `frame start` (Optional): The index of the frame to start on. Default `1`.

### `model[<X>,<Y>;<W>,<H>;<name>;<mesh>;<textures>;<rotation X,Y>;<continuous>;<mouse control>;<frame loop range>;<animation speed>]`

* Show a mesh model.
* `name`: Element name that can be used for styling
* `mesh`: The mesh model to use.
* `textures`: The mesh textures to use according to the mesh materials.
   Texture names must be separated by commas.
* `rotation {X,Y}` (Optional): Initial rotation of the camera.
  The axes are euler angles in degrees.
* `continuous` (Optional): Whether the rotation is continuous. Default `false`.
* `mouse control` (Optional): Whether the model can be controlled with the mouse. Default `true`.
* `frame loop range` (Optional): Range of the animation frames.
    * Defaults to the full range of all available frames.
    * Syntax: `<begin>,<end>`
* `animation speed` (Optional): Sets the animation speed. Default 0 FPS.

### `item_image[<X>,<Y>;<W>,<H>;<item name>]`

* Show an inventory image of registered item/node

### `bgcolor[<bgcolor>;<fullscreen>;<fbgcolor>]`

* Sets background color of formspec.
* `bgcolor` and `fbgcolor` (optional) are `ColorString`s, they define the color
  of the non-fullscreen and the fullscreen background.
* `fullscreen` (optional) can be one of the following:
  * `false`: Only the non-fullscreen background color is drawn. (default)
  * `true`: Only the fullscreen background color is drawn.
  * `both`: The non-fullscreen and the fullscreen background color are drawn.
  * `neither`: No background color is drawn.
* Note: Leave a parameter empty to not modify the value.
* Note: `fbgcolor`, leaving parameters empty and values for `fullscreen` that
  are not bools are only available since formspec version 3.

### `background[<X>,<Y>;<W>,<H>;<texture name>]`

* Example for formspec 8x4 in 16x resolution: image shall be sized
  8 times 16px  times  4 times 16px.

### `background[<X>,<Y>;<W>,<H>;<texture name>;<auto_clip>]`

* Example for formspec 8x4 in 16x resolution:
  image shall be sized 8 times 16px  times  4 times 16px
* If `auto_clip` is `true`, the background is clipped to the formspec size
  (`x` and `y` are used as offset values, `w` and `h` are ignored)

### `background9[<X>,<Y>;<W>,<H>;<texture name>;<auto_clip>;<middle>]`

* 9-sliced background. See https://en.wikipedia.org/wiki/9-slice_scaling
* Middle is a rect which defines the middle of the 9-slice.
    * `x` - The middle will be x pixels from all sides.
    * `x,y` - The middle will be x pixels from the horizontal and y from the vertical.
    * `x,y,x2,y2` - The middle will start at x,y, and end at x2, y2. Negative x2 and y2 values
        will be added to the width and height of the texture, allowing it to be used as the
        distance from the far end.
    * All numbers in middle are integers.
* Example for formspec 8x4 in 16x resolution:
  image shall be sized 8 times 16px  times  4 times 16px
* If `auto_clip` is `true`, the background is clipped to the formspec size
  (`x` and `y` are used as offset values, `w` and `h` are ignored)
* Available since formspec version 2

### `pwdfield[<X>,<Y>;<W>,<H>;<name>;<label>]`

* Textual password style field; will be sent to server when a button is clicked
* When enter is pressed in field, fields.key_enter_field will be sent with the
  name of this field.
* With the old coordinate system, fields are a set height, but will be vertically
  centred on `H`. With the new coordinate system, `H` will modify the height.
* `name` is the name of the field as returned in fields to `on_receive_fields`
* `label`, if not blank, will be text printed on the top left above the field
* See `field_close_on_enter` to stop enter closing the formspec

### `field[<X>,<Y>;<W>,<H>;<name>;<label>;<default>]`

* Textual field; will be sent to server when a button is clicked
* When enter is pressed in field, `fields.key_enter_field` will be sent with
  the name of this field.
* With the old coordinate system, fields are a set height, but will be vertically
  centred on `H`. With the new coordinate system, `H` will modify the height.
* `name` is the name of the field as returned in fields to `on_receive_fields`
* `label`, if not blank, will be text printed on the top left above the field
* `default` is the default value of the field
    * `default` may contain variable references such as `${text}` which
      will fill the value from the metadata value `text`
    * **Note**: no extra text or more than a single variable is supported ATM.
* See `field_close_on_enter` to stop enter closing the formspec

### `field[<name>;<label>;<default>]`

* As above, but without position/size units
* When enter is pressed in field, `fields.key_enter_field` will be sent with
  the name of this field.
* Special field for creating simple forms, such as sign text input
* Must be used without a `size[]` element
* A "Proceed" button will be added automatically
* See `field_close_on_enter` to stop enter closing the formspec

### `field_close_on_enter[<name>;<close_on_enter>]`

* <name> is the name of the field
* if <close_on_enter> is false, pressing enter in the field will submit the
  form but not close it.
* defaults to true when not specified (ie: no tag for a field)

### `textarea[<X>,<Y>;<W>,<H>;<name>;<label>;<default>]`

* Same as fields above, but with multi-line input
* If the text overflows, a vertical scrollbar is added.
* If the name is empty, the textarea is read-only and
  the background is not shown, which corresponds to a multi-line label.

### `label[<X>,<Y>;<label>]`

* The label formspec element displays the text set in `label`
  at the specified position.
* **Note**: If the new coordinate system is enabled, labels are
  positioned from the center of the text, not the top.
* The text is displayed directly without automatic line breaking,
  so label should not be used for big text chunks.  Newlines can be
  used to make labels multiline.
* **Note**: With the new coordinate system, newlines are spaced with
  half a coordinate.  With the old system, newlines are spaced 2/5 of
  an inventory slot.

### `hypertext[<X>,<Y>;<W>,<H>;<name>;<text>]`
* Displays a static formatted text with hyperlinks.
* **Note**: This element is currently unstable and subject to change.
* `x`, `y`, `w` and `h` work as per field
* `name` is the name of the field as returned in fields to `on_receive_fields` in case of action in text.
* `text` is the formatted text using `Markup Language` described below.

### `vertlabel[<X>,<Y>;<label>]`
* Textual label drawn vertically
* `label` is the text on the label
* **Note**: If the new coordinate system is enabled, vertlabels are
  positioned from the center of the text, not the left.

### `button[<X>,<Y>;<W>,<H>;<name>;<label>]`

* Clickable button. When clicked, fields will be sent.
* With the old coordinate system, buttons are a set height, but will be vertically
  centred on `H`. With the new coordinate system, `H` will modify the height.
* `label` is the text on the button

### `image_button[<X>,<Y>;<W>,<H>;<texture name>;<name>;<label>]`

* `texture name` is the filename of an image
* **Note**: Height is supported on both the old and new coordinate systems
  for image_buttons.

### `image_button[<X>,<Y>;<W>,<H>;<texture name>;<name>;<label>;<noclip>;<drawborder>;<pressed texture name>]`

* `texture name` is the filename of an image
* `noclip=true` means the image button doesn't need to be within specified
  formsize.
* `drawborder`: draw button border or not
* `pressed texture name` is the filename of an image on pressed state

### `item_image_button[<X>,<Y>;<W>,<H>;<item name>;<name>;<label>]`

* `item name` is the registered name of an item/node
* The item description will be used as the tooltip. This can be overridden with
  a tooltip element.

### `button_exit[<X>,<Y>;<W>,<H>;<name>;<label>]`

* When clicked, fields will be sent and the form will quit.
* Same as `button` in all other respects.

### `image_button_exit[<X>,<Y>;<W>,<H>;<texture name>;<name>;<label>]`

* When clicked, fields will be sent and the form will quit.
* Same as `image_button` in all other respects.

### `textlist[<X>,<Y>;<W>,<H>;<name>;<listelem 1>,<listelem 2>,...,<listelem n>]`

* Scrollable item list showing arbitrary text elements
* `name` fieldname sent to server on doubleclick value is current selected
  element.
* `listelements` can be prepended by #color in hexadecimal format RRGGBB
  (only).
    * if you want a listelement to start with "#" write "##".

### `textlist[<X>,<Y>;<W>,<H>;<name>;<listelem 1>,<listelem 2>,...,<listelem n>;<selected idx>;<transparent>]`

* Scrollable itemlist showing arbitrary text elements
* `name` fieldname sent to server on doubleclick value is current selected
  element.
* `listelements` can be prepended by #RRGGBB (only) in hexadecimal format
    * if you want a listelement to start with "#" write "##"
* Index to be selected within textlist
* `true`/`false`: draw transparent background
* See also `minetest.explode_textlist_event`
  (main menu: `core.explode_textlist_event`).

### `tabheader[<X>,<Y>;<name>;<caption 1>,<caption 2>,...,<caption n>;<current_tab>;<transparent>;<draw_border>]`

* Show a tab**header** at specific position (ignores formsize)
* `X` and `Y`: position of the tabheader
* *Note*: Width and height are automatically chosen with this syntax
* `name` fieldname data is transferred to Lua
* `caption 1`...: name shown on top of tab
* `current_tab`: index of selected tab 1...
* `transparent` (optional): if true, tabs are semi-transparent
* `draw_border` (optional): if true, draw a thin line at tab base

### `tabheader[<X>,<Y>;<H>;<name>;<caption 1>,<caption 2>,...,<caption n>;<current_tab>;<transparent>;<draw_border>]`

* Show a tab**header** at specific position (ignores formsize)
* **Important note**: This syntax for tabheaders can only be used with the
  new coordinate system.
* `X` and `Y`: position of the tabheader
* `H`: height of the tabheader. Width is automatically determined with this syntax.
* `name` fieldname data is transferred to Lua
* `caption 1`...: name shown on top of tab
* `current_tab`: index of selected tab 1...
* `transparent` (optional): show transparent
* `draw_border` (optional): draw border

### `tabheader[<X>,<Y>;<W>,<H>;<name>;<caption 1>,<caption 2>,...,<caption n>;<current_tab>;<transparent>;<draw_border>]`

* Show a tab**header** at specific position (ignores formsize)
* **Important note**: This syntax for tabheaders can only be used with the
  new coordinate system.
* `X` and `Y`: position of the tabheader
* `W` and `H`: width and height of the tabheader
* `name` fieldname data is transferred to Lua
* `caption 1`...: name shown on top of tab
* `current_tab`: index of selected tab 1...
* `transparent` (optional): show transparent
* `draw_border` (optional): draw border

### `box[<X>,<Y>;<W>,<H>;<color>]`

* Simple colored box
* `color` is color specified as a `ColorString`.
  If the alpha component is left blank, the box will be semitransparent.
  If the color is not specified, the box will use the options specified by
  its style. If the color is specified, all styling options will be ignored.

### `dropdown[<X>,<Y>;<W>;<name>;<item 1>,<item 2>, ...,<item n>;<selected idx>;<index event>]`

* Show a dropdown field
* **Important note**: There are two different operation modes:
    1. handle directly on change (only changed dropdown is submitted)
    2. read the value on pressing a button (all dropdown values are available)
* `X` and `Y`: position of the dropdown
* `W`: width of the dropdown. Height is automatically chosen with this syntax.
* Fieldname data is transferred to Lua
* Items to be shown in dropdown
* Index of currently selected dropdown item
* `index event` (optional, allowed parameter since formspec version 4): Specifies the
  event field value for selected items.
    * `true`: Selected item index
    * `false` (default): Selected item value

### `dropdown[<X>,<Y>;<W>,<H>;<name>;<item 1>,<item 2>, ...,<item n>;<selected idx>;<index event>]`

* Show a dropdown field
* **Important note**: This syntax for dropdowns can only be used with the
  new coordinate system.
* **Important note**: There are two different operation modes:
    1. handle directly on change (only changed dropdown is submitted)
    2. read the value on pressing a button (all dropdown values are available)
* `X` and `Y`: position of the dropdown
* `W` and `H`: width and height of the dropdown
* Fieldname data is transferred to Lua
* Items to be shown in dropdown
* Index of currently selected dropdown item
* `index event` (optional, allowed parameter since formspec version 4): Specifies the
  event field value for selected items.
    * `true`: Selected item index
    * `false` (default): Selected item value

### `checkbox[<X>,<Y>;<name>;<label>;<selected>]`

* Show a checkbox
* `name` fieldname data is transferred to Lua
* `label` to be shown left of checkbox
* `selected` (optional): `true`/`false`
* **Note**: If the new coordinate system is enabled, checkboxes are
  positioned from the center of the checkbox, not the top.

### `scrollbar[<X>,<Y>;<W>,<H>;<orientation>;<name>;<value>]`

* Show a scrollbar using options defined by the previous `scrollbaroptions[]`
* There are two ways to use it:
    1. handle the changed event (only changed scrollbar is available)
    2. read the value on pressing a button (all scrollbars are available)
* `orientation`: `vertical`/`horizontal`. Default horizontal.
* Fieldname data is transferred to Lua
* Value of this trackbar is set to (`0`-`1000`) by default
* See also `minetest.explode_scrollbar_event`
  (main menu: `core.explode_scrollbar_event`).

### `scrollbaroptions[opt1;opt2;...]`
* Sets options for all following `scrollbar[]` elements
* `min=<int>`
    * Sets scrollbar minimum value, defaults to `0`.
* `max=<int>`
    * Sets scrollbar maximum value, defaults to `1000`.
      If the max is equal to the min, the scrollbar will be disabled.
* `smallstep=<int>`
    * Sets scrollbar step value when the arrows are clicked or the mouse wheel is
      scrolled.
    * If this is set to a negative number, the value will be reset to `10`.
* `largestep=<int>`
    * Sets scrollbar step value used by page up and page down.
    * If this is set to a negative number, the value will be reset to `100`.
* `thumbsize=<int>`
    * Sets size of the thumb on the scrollbar. Size is calculated in the number of
      units the thumb spans out of the range of the scrollbar values.
    * Example: If a scrollbar has a `min` of 1 and a `max` of 100, a thumbsize of 10
      would span a tenth of the scrollbar space.
    * If this is set to zero or less, the value will be reset to `1`.
* `arrows=<show/hide/default>`
    * Whether to show the arrow buttons on the scrollbar. `default` hides the arrows
      when the scrollbar gets too small, but shows them otherwise.

### `table[<X>,<Y>;<W>,<H>;<name>;<cell 1>,<cell 2>,...,<cell n>;<selected idx>]`

* Show scrollable table using options defined by the previous `tableoptions[]`
* Displays cells as defined by the previous `tablecolumns[]`
* `name`: fieldname sent to server on row select or doubleclick
* `cell 1`...`cell n`: cell contents given in row-major order
* `selected idx`: index of row to be selected within table (first row = `1`)
* See also `minetest.explode_table_event`
  (main menu: `core.explode_table_event`).

### `tableoptions[<opt 1>;<opt 2>;...]`

* Sets options for `table[]`
* `color=#RRGGBB`
    * default text color (`ColorString`), defaults to `#FFFFFF`
* `background=#RRGGBB`
    * table background color (`ColorString`), defaults to `#000000`
* `border=<true/false>`
    * should the table be drawn with a border? (default: `true`)
* `highlight=#RRGGBB`
    * highlight background color (`ColorString`), defaults to `#466432`
* `highlight_text=#RRGGBB`
    * highlight text color (`ColorString`), defaults to `#FFFFFF`
* `opendepth=<value>`
    * all subtrees up to `depth < value` are open (default value = `0`)
    * only useful when there is a column of type "tree"

### `tablecolumns[<type 1>,<opt 1a>,<opt 1b>,...;<type 2>,<opt 2a>,<opt 2b>;...]`

* Sets columns for `table[]`
* Types: `text`, `image`, `color`, `indent`, `tree`
    * `text`:   show cell contents as text
    * `image`:  cell contents are an image index, use column options to define
                images.
    * `color`:  cell contents are a ColorString and define color of following
                cell.
    * `indent`: cell contents are a number and define indentation of following
                cell.
    * `tree`:   same as indent, but user can open and close subtrees
                (treeview-like).
* Column options:
    * `align=<value>`
        * for `text` and `image`: content alignment within cells.
          Available values: `left` (default), `center`, `right`, `inline`
    * `width=<value>`
        * for `text` and `image`: minimum width in em (default: `0`)
        * for `indent` and `tree`: indent width in em (default: `1.5`)
    * `padding=<value>`: padding left of the column, in em (default `0.5`).
      Exception: defaults to 0 for indent columns
    * `tooltip=<value>`: tooltip text (default: empty)
    * `image` column options:
        * `0=<value>` sets image for image index 0
        * `1=<value>` sets image for image index 1
        * `2=<value>` sets image for image index 2
        * and so on; defined indices need not be contiguous empty or
          non-numeric cells are treated as `0`.
    * `color` column options:
        * `span=<value>`: number of following columns to affect
          (default: infinite).

### `style[<selector 1>,<selector 2>,...;<prop1>;<prop2>;...]`

* Set the style for the element(s) matching `selector` by name.
* `selector` can be one of:
    * `<name>` - An element name. Includes `*`, which represents every element.
    * `<name>:<state>` - An element name, a colon, and one or more states.
* `state` is a list of states separated by the `+` character.
    * If a state is provided, the style will only take effect when the element is in that state.
    * All provided states must be active for the style to apply.
* Note: this **must** be before the element is defined.
* See [Styling Formspecs].


### `style_type[<selector 1>,<selector 2>,...;<prop1>;<prop2>;...]`

* Set the style for the element(s) matching `selector` by type.
* `selector` can be one of:
    * `<type>` - An element type. Includes `*`, which represents every element.
    * `<type>:<state>` - An element type, a colon, and one or more states.
* `state` is a list of states separated by the `+` character.
    * If a state is provided, the style will only take effect when the element is in that state.
    * All provided states must be active for the style to apply.
* See [Styling Formspecs].

### `set_focus[<name>;<force>]`

* Sets the focus to the element with the same `name` parameter.
* **Note**: This element must be placed before the element it focuses.
* `force` (optional, default `false`): By default, focus is not applied for
  re-sent formspecs with the same name so that player-set focus is kept.
  `true` sets the focus to the specified element for every sent formspec.
* The following elements have the ability to be focused:
    * checkbox
    * button
    * button_exit
    * image_button
    * image_button_exit
    * item_image_button
    * table
    * textlist
    * dropdown
    * field
    * pwdfield
    * textarea
    * scrollbar

Migrating to Real Coordinates
-----------------------------

In the old system, positions included padding and spacing. Padding is a gap between
the formspec window edges and content, and spacing is the gaps between items. For
example, two `1x1` elements at `0,0` and `1,1` would have a spacing of `5/4` between them,
and a padding of `3/8` from the formspec edge. It may be easiest to recreate old layouts
in the new coordinate system from scratch.

To recreate an old layout with padding, you'll need to pass the positions and sizes
through the following formula to re-introduce padding:

```
pos = (oldpos + 1)*spacing + padding
where
    padding = 3/8
    spacing = 5/4
```

You'll need to change the `size[]` tag like this:

```
size = (oldsize-1)*spacing + padding*2 + 1
```

A few elements had random offsets in the old system. Here is a table which shows these
offsets when migrating:

| Element |  Position  |  Size   | Notes
|---------|------------|---------|-------
| box     | +0.3, +0.1 | 0, -0.4 |
| button  |            |         | Buttons now support height, so set h = 2 * 15/13 * 0.35, and reposition if h ~= 15/13 * 0.35 before
| list    |            |         | Spacing is now 0.25 for both directions, meaning lists will be taller in height
| label   | 0, +0.3    |         | The first line of text is now positioned centered exactly at the position specified

Styling Formspecs
-----------------

Formspec elements can be themed using the style elements:

    style[<name 1>,<name 2>,...;<prop1>;<prop2>;...]
    style[<name 1>:<state>,<name 2>:<state>,...;<prop1>;<prop2>;...]
    style_type[<type 1>,<type 2>,...;<prop1>;<prop2>;...]
    style_type[<type 1>:<state>,<type 2>:<state>,...;<prop1>;<prop2>;...]

Where a prop is:

    property_name=property_value

For example:

    style_type[button;bgcolor=#006699]
    style[world_delete;bgcolor=red;textcolor=yellow]
    button[4,3.95;2.6,1;world_delete;Delete]

A name/type can optionally be a comma separated list of names/types, like so:

    world_delete,world_create,world_configure
    button,image_button

A `*` type can be used to select every element in the formspec.

Any name/type in the list can also be accompanied by a `+`-separated list of states, like so:

    world_delete:hovered+pressed
    button:pressed

States allow you to apply styles in response to changes in the element, instead of applying at all times.

Setting a property to nothing will reset it to the default value. For example:

    style_type[button;bgimg=button.png;bgimg_pressed=button_pressed.png;border=false]
    style[btn_exit;bgimg=;bgimg_pressed=;border=;bgcolor=red]


### Supported Element Types

Some types may inherit styles from parent types.

* animated_image, inherits from image
* box
* button
* button_exit, inherits from button
* checkbox
* dropdown
* field
* image
* image_button
* item_image_button
* label
* list
* model
* pwdfield, inherits from field
* scrollbar
* tabheader
* table
* textarea
* textlist
* vertlabel, inherits from label


### Valid Properties

* animated_image
    * noclip - boolean, set to true to allow the element to exceed formspec bounds.
* box
    * noclip - boolean, set to true to allow the element to exceed formspec bounds.
        * Defaults to false in formspec_version version 3 or higher
    * **Note**: `colors`, `bordercolors`, and `borderwidths` accept multiple input types:
        * Single value (e.g. `#FF0`): All corners/borders.
        * Two values (e.g. `red,#FFAAFF`): top-left and bottom-right,top-right and bottom-left/
          top and bottom,left and right.
        * Four values (e.g. `blue,#A0F,green,#FFFA`): top-left/top and rotates clockwise.
        * These work similarly to CSS borders.
    * colors - `ColorString`. Sets the color(s) of the box corners. Default `black`.
    * bordercolors - `ColorString`. Sets the color(s) of the borders. Default `black`.
    * borderwidths - Integer. Sets the width(s) of the borders in pixels. If the width is
      negative, the border will extend inside the box, whereas positive extends outside
      the box. A width of zero results in no border; this is default.
* button, button_exit, image_button, item_image_button
    * alpha - boolean, whether to draw alpha in bgimg. Default true.
    * bgcolor - color, sets button tint.
    * bgcolor_hovered - color when hovered. Defaults to a lighter bgcolor when not provided.
        * This is deprecated, use states instead.
    * bgcolor_pressed - color when pressed. Defaults to a darker bgcolor when not provided.
        * This is deprecated, use states instead.
    * bgimg - standard background image. Defaults to none.
    * bgimg_hovered - background image when hovered. Defaults to bgimg when not provided.
        * This is deprecated, use states instead.
    * bgimg_middle - Makes the bgimg textures render in 9-sliced mode and defines the middle rect.
                     See background9[] documentation for more details. This property also pads the
                     button's content when set.
    * bgimg_pressed - background image when pressed. Defaults to bgimg when not provided.
        * This is deprecated, use states instead.
    * font - Sets font type. This is a comma separated list of options. Valid options:
      * Main font type options. These cannot be combined with each other:
        * `normal`: Default font
        * `mono`: Monospaced font
      * Font modification options. If used without a main font type, `normal` is used:
        * `bold`: Makes font bold.
        * `italic`: Makes font italic.
      Default `normal`.
    * font_size - Sets font size. Default is user-set. Can have multiple values:
      * `<number>`: Sets absolute font size to `number`.
      * `+<number>`/`-<number>`: Offsets default font size by `number` points.
      * `*<number>`: Multiplies default font size by `number`, similar to CSS `em`.
    * border - boolean, draw border. Set to false to hide the bevelled button pane. Default true.
    * content_offset - 2d vector, shifts the position of the button's content without resizing it.
    * noclip - boolean, set to true to allow the element to exceed formspec bounds.
    * padding - rect, adds space between the edges of the button and the content. This value is
                relative to bgimg_middle.
    * sound - a sound to be played when triggered.
    * textcolor - color, default white.
* checkbox
    * noclip - boolean, set to true to allow the element to exceed formspec bounds.
    * sound - a sound to be played when triggered.
* dropdown
    * noclip - boolean, set to true to allow the element to exceed formspec bounds.
    * sound - a sound to be played when the entry is changed.
* field, pwdfield, textarea
    * border - set to false to hide the textbox background and border. Default true.
    * font - Sets font type. See button `font` property for more information.
    * font_size - Sets font size. See button `font_size` property for more information.
    * noclip - boolean, set to true to allow the element to exceed formspec bounds.
    * textcolor - color. Default white.
* model
    * bgcolor - color, sets background color.
    * noclip - boolean, set to true to allow the element to exceed formspec bounds.
        * Default to false in formspec_version version 3 or higher
* image
    * noclip - boolean, set to true to allow the element to exceed formspec bounds.
        * Default to false in formspec_version version 3 or higher
* item_image
    * noclip - boolean, set to true to allow the element to exceed formspec bounds. Default to false.
* label, vertlabel
    * font - Sets font type. See button `font` property for more information.
    * font_size - Sets font size. See button `font_size` property for more information.
    * noclip - boolean, set to true to allow the element to exceed formspec bounds.
* list
    * noclip - boolean, set to true to allow the element to exceed formspec bounds.
    * size - 2d vector, sets the size of inventory slots in coordinates.
    * spacing - 2d vector, sets the space between inventory slots in coordinates.
* image_button (additional properties)
    * fgimg - standard image. Defaults to none.
    * fgimg_hovered - image when hovered. Defaults to fgimg when not provided.
        * This is deprecated, use states instead.
    * fgimg_pressed - image when pressed. Defaults to fgimg when not provided.
        * This is deprecated, use states instead.
    * NOTE: The parameters of any given image_button will take precedence over fgimg/fgimg_pressed
    * sound - a sound to be played when triggered.
* scrollbar
    * noclip - boolean, set to true to allow the element to exceed formspec bounds.
* tabheader
    * noclip - boolean, set to true to allow the element to exceed formspec bounds.
    * sound - a sound to be played when a different tab is selected.
    * textcolor - color. Default white.
* table, textlist
    * font - Sets font type. See button `font` property for more information.
    * font_size - Sets font size. See button `font_size` property for more information.
    * noclip - boolean, set to true to allow the element to exceed formspec bounds.

### Valid States

* *all elements*
    * default - Equivalent to providing no states
* button, button_exit, image_button, item_image_button
    * hovered - Active when the mouse is hovering over the element
    * pressed - Active when the button is pressed

Markup Language
---------------

Markup language used in `hypertext[]` elements uses tags that look like HTML tags.
The markup language is currently unstable and subject to change. Use with caution.
Some tags can enclose text, they open with `<tagname>` and close with `</tagname>`.
Tags can have attributes, in that case, attributes are in the opening tag in
form of a key/value separated with equal signs. Attribute values should not be quoted.

If you want to insert a literal greater-than sign or a backslash into the text,
you must escape it by preceding it with a backslash.

These are the technically basic tags but see below for usual tags. Base tags are:

`<style color=... font=... size=...>...</style>`

Changes the style of the text.

* `color`: Text color. Given color is a `colorspec`.
* `size`: Text size.
* `font`: Text font (`mono` or `normal`).

`<global background=... margin=... valign=... color=... hovercolor=... size=... font=... halign=... >`

Sets global style.

Global only styles:
* `background`: Text background, a `colorspec` or `none`.
* `margin`: Page margins in pixel.
* `valign`: Text vertical alignment (`top`, `middle`, `bottom`).

Inheriting styles (affects child elements):
* `color`: Default text color. Given color is a `colorspec`.
* `hovercolor`: Color of <action> tags when mouse is over.
* `size`: Default text size.
* `font`: Default text font (`mono` or `normal`).
* `halign`: Default text horizontal alignment (`left`, `right`, `center`, `justify`).

This tag needs to be placed only once as it changes the global settings of the
text. Anyway, if several tags are placed, each changed will be made in the order
tags appear.

`<tag name=... color=... hovercolor=... font=... size=...>`

Defines or redefines tag style. This can be used to define new tags.
* `name`: Name of the tag to define or change.
* `color`: Text color. Given color is a `colorspec`.
* `hovercolor`: Text color when element hovered (only for `action` tags). Given color is a `colorspec`.
* `size`: Text size.
* `font`: Text font (`mono` or `normal`).

Following tags are the usual tags for text layout. They are defined by default.
Other tags can be added using `<tag ...>` tag.

`<normal>...</normal>`: Normal size text

`<big>...</big>`: Big text

`<bigger>...</bigger>`: Bigger text

`<center>...</center>`: Centered text

`<left>...</left>`: Left-aligned text

`<right>...</right>`: Right-aligned text

`<justify>...</justify>`: Justified text

`<mono>...</mono>`: Monospaced font

`<b>...</b>`, `<i>...</i>`, `<u>...</u>`: Bold, italic, underline styles.

`<action name=...>...</action>`

Make that text a clickable text triggering an action.

* `name`: Name of the action (mandatory).

When clicked, the formspec is send to the server. The value of the text field
sent to `on_player_receive_fields` will be "action:" concatenated to the action
name.

`<img name=... float=... width=... height=...>`

Draws an image which is present in the client media cache.

* `name`: Name of the texture (mandatory).
* `float`: If present, makes the image floating (`left` or `right`).
* `width`: Force image width instead of taking texture width.
* `height`: Force image height instead of taking texture height.

If only width or height given, texture aspect is kept.

`<item name=... float=... width=... height=... rotate=...>`

Draws an item image.

* `name`: Item string of the item to draw (mandatory).
* `float`: If present, makes the image floating (`left` or `right`).
* `width`: Item image width.
* `height`: Item image height.
* `rotate`: Rotate item image if set to `yes` or `X,Y,Z`. X, Y and Z being
rotation speeds in percent of standard speed (-1000 to 1000). Works only if
`inventory_items_animations` is set to true.
* `angle`: Angle in which the item image is shown. Value has `X,Y,Z` form.
X, Y and Z being angles around each three axes. Works only if
`inventory_items_animations` is set to true.

Inventory
=========

Inventory locations
-------------------

* `"context"`: Selected node metadata (deprecated: `"current_name"`)
* `"current_player"`: Player to whom the menu is shown
* `"player:<name>"`: Any player
* `"nodemeta:<X>,<Y>,<Z>"`: Any node metadata
* `"detached:<name>"`: A detached inventory

Player Inventory lists
----------------------

* `main`: list containing the default inventory
* `craft`: list containing the craft input
* `craftpreview`: list containing the craft prediction
* `craftresult`: list containing the crafted output
* `hand`: list containing an override for the empty hand
    * Is not created automatically, use `InvRef:set_size`
    * Is only used to enhance the empty hand's tool capabilities

Colors
======

`ColorString`
-------------

`#RGB` defines a color in hexadecimal format.

`#RGBA` defines a color in hexadecimal format and alpha channel.

`#RRGGBB` defines a color in hexadecimal format.

`#RRGGBBAA` defines a color in hexadecimal format and alpha channel.

Named colors are also supported and are equivalent to
[CSS Color Module Level 4](https://www.w3.org/TR/css-color-4/#named-color).
To specify the value of the alpha channel, append `#A` or `#AA` to the end of
the color name (e.g. `colorname#08`).

`ColorSpec`
-----------

A ColorSpec specifies a 32-bit color. It can be written in any of the following
forms:

* table form: Each element ranging from 0..255 (a, if absent, defaults to 255):
    * `colorspec = {a=255, r=0, g=255, b=0}`
* numerical form: The raw integer value of an ARGB8 quad:
    * `colorspec = 0xFF00FF00`
* string form: A ColorString (defined above):
    * `colorspec = "green"`




Escape sequences
================

Most text can contain escape sequences, that can for example color the text.
There are a few exceptions: tab headers, dropdowns and vertical labels can't.
The following functions provide escape sequences:

* `minetest.get_color_escape_sequence(color)`:
    * `color` is a ColorString
    * The escape sequence sets the text color to `color`
* `minetest.colorize(color, message)`:
    * Equivalent to:
      `minetest.get_color_escape_sequence(color) ..
      message ..
      minetest.get_color_escape_sequence("#ffffff")`
* `minetest.get_background_escape_sequence(color)`
    * `color` is a ColorString
    * The escape sequence sets the background of the whole text element to
      `color`. Only defined for item descriptions and tooltips.
* `minetest.strip_foreground_colors(str)`
    * Removes foreground colors added by `get_color_escape_sequence`.
* `minetest.strip_background_colors(str)`
    * Removes background colors added by `get_background_escape_sequence`.
* `minetest.strip_colors(str)`
    * Removes all color escape sequences.




Spatial Vectors
===============

Minetest stores 3-dimensional spatial vectors in Lua as tables of 3 coordinates,
and has a class to represent them (`vector.*`), which this chapter is about.
For details on what a spatial vectors is, please refer to Wikipedia:
https://en.wikipedia.org/wiki/Euclidean_vector.

Spatial vectors are used for various things, including, but not limited to:

* any 3D spatial vector (x/y/z-directions)
* Euler angles (pitch/yaw/roll in radians) (Spatial vectors have no real semantic
  meaning here. Therefore, most vector operations make no sense in this use case.)

Note that they are *not* used for:

* n-dimensional vectors where n is not 3 (ie. n=2)
* arrays of the form `{num, num, num}`

The API documentation may refer to spatial vectors, as produced by `vector.new`,
by any of the following notations:

* `(x, y, z)` (Used rarely, and only if it's clear that it's a vector.)
* `vector.new(x, y, z)`
* `{x=num, y=num, z=num}` (Even here you are still supposed to use `vector.new`.)

Compatibility notes
-------------------

Vectors used to be defined as tables of the form `{x = num, y = num, z = num}`.
Since Minetest 5.5.0, vectors additionally have a metatable to enable easier use.
Note: Those old-style vectors can still be found in old mod code. Hence, mod and
engine APIs still need to be able to cope with them in many places.

Manually constructed tables are deprecated and highly discouraged. This interface
should be used to ensure seamless compatibility between mods and the Minetest API.
This is especially important to callback function parameters and functions overwritten
by mods.
Also, though not likely, the internal implementation of a vector might change in
the future.
In your own code, or if you define your own API, you can, of course, still use
other representations of vectors.

Vectors provided by API functions will provide an instance of this class if not
stated otherwise. Mods should adapt this for convenience reasons.

Special properties of the class
-------------------------------

Vectors can be indexed with numbers and allow method and operator syntax.

All these forms of addressing a vector `v` are valid:
`v[1]`, `v[3]`, `v.x`, `v[1] = 42`, `v.y = 13`
Note: Prefer letter over number indexing for performance and compatibility reasons.

Where `v` is a vector and `foo` stands for any function name, `v:foo(...)` does
the same as `vector.foo(v, ...)`, apart from deprecated functionality.

`tostring` is defined for vectors, see `vector.to_string`.

The metatable that is used for vectors can be accessed via `vector.metatable`.
Do not modify it!

All `vector.*` functions allow vectors `{x = X, y = Y, z = Z}` without metatables.
Returned vectors always have a metatable set.

Common functions and methods
----------------------------

For the following functions (and subchapters),
`v`, `v1`, `v2` are vectors,
`p1`, `p2` are position vectors,
`s` is a scalar (a number),
vectors are written like this: `(x, y, z)`:

* `vector.new([a[, b, c]])`:
    * Returns a new vector `(a, b, c)`.
    * Deprecated: `vector.new()` does the same as `vector.zero()` and
      `vector.new(v)` does the same as `vector.copy(v)`
* `vector.zero()`:
    * Returns a new vector `(0, 0, 0)`.
* `vector.copy(v)`:
    * Returns a copy of the vector `v`.
* `vector.from_string(s[, init])`:
    * Returns `v, np`, where `v` is a vector read from the given string `s` and
      `np` is the next position in the string after the vector.
    * Returns `nil` on failure.
    * `s`: Has to begin with a substring of the form `"(x, y, z)"`. Additional
           spaces, leaving away commas and adding an additional comma to the end
           is allowed.
    * `init`: If given starts looking for the vector at this string index.
* `vector.to_string(v)`:
    * Returns a string of the form `"(x, y, z)"`.
    *  `tostring(v)` does the same.
* `vector.direction(p1, p2)`:
    * Returns a vector of length 1 with direction `p1` to `p2`.
    * If `p1` and `p2` are identical, returns `(0, 0, 0)`.
* `vector.distance(p1, p2)`:
    * Returns zero or a positive number, the distance between `p1` and `p2`.
* `vector.length(v)`:
    * Returns zero or a positive number, the length of vector `v`.
* `vector.normalize(v)`:
    * Returns a vector of length 1 with direction of vector `v`.
    * If `v` has zero length, returns `(0, 0, 0)`.
* `vector.floor(v)`:
    * Returns a vector, each dimension rounded down.
* `vector.round(v)`:
    * Returns a vector, each dimension rounded to nearest integer.
    * At a multiple of 0.5, rounds away from zero.
* `vector.apply(v, func)`:
    * Returns a vector where the function `func` has been applied to each
      component.
* `vector.combine(v, w, func)`:
	* Returns a vector where the function `func` has combined both components of `v` and `w`
	  for each component
* `vector.equals(v1, v2)`:
    * Returns a boolean, `true` if the vectors are identical.
* `vector.sort(v1, v2)`:
    * Returns in order minp, maxp vectors of the cuboid defined by `v1`, `v2`.
* `vector.angle(v1, v2)`:
    * Returns the angle between `v1` and `v2` in radians.
* `vector.dot(v1, v2)`:
    * Returns the dot product of `v1` and `v2`.
* `vector.cross(v1, v2)`:
    * Returns the cross product of `v1` and `v2`.
* `vector.offset(v, x, y, z)`:
    * Returns the sum of the vectors `v` and `(x, y, z)`.
* `vector.check(v)`:
    * Returns a boolean value indicating whether `v` is a real vector, eg. created
      by a `vector.*` function.
    * Returns `false` for anything else, including tables like `{x=3,y=1,z=4}`.

For the following functions `x` can be either a vector or a number:

* `vector.add(v, x)`:
    * Returns a vector.
    * If `x` is a vector: Returns the sum of `v` and `x`.
    * If `x` is a number: Adds `x` to each component of `v`.
* `vector.subtract(v, x)`:
    * Returns a vector.
    * If `x` is a vector: Returns the difference of `v` subtracted by `x`.
    * If `x` is a number: Subtracts `x` from each component of `v`.
* `vector.multiply(v, s)`:
    * Returns a scaled vector.
    * Deprecated: If `s` is a vector: Returns the Schur product.
* `vector.divide(v, s)`:
    * Returns a scaled vector.
    * Deprecated: If `s` is a vector: Returns the Schur quotient.

Operators
---------

Operators can be used if all of the involved vectors have metatables:
* `v1 == v2`:
    * Returns whether `v1` and `v2` are identical.
* `-v`:
    * Returns the additive inverse of v.
* `v1 + v2`:
    * Returns the sum of both vectors.
    * Note: `+` can not be used together with scalars.
* `v1 - v2`:
    * Returns the difference of `v1` subtracted by `v2`.
    * Note: `-` can not be used together with scalars.
* `v * s` or `s * v`:
    * Returns `v` scaled by `s`.
* `v / s`:
    * Returns `v` scaled by `1 / s`.

Rotation-related functions
--------------------------

For the following functions `a` is an angle in radians and `r` is a rotation
vector (`{x = <pitch>, y = <yaw>, z = <roll>}`) where pitch, yaw and roll are
angles in radians.

* `vector.rotate(v, r)`:
    * Applies the rotation `r` to `v` and returns the result.
    * `vector.rotate(vector.new(0, 0, 1), r)` and
      `vector.rotate(vector.new(0, 1, 0), r)` return vectors pointing
      forward and up relative to an entity's rotation `r`.
* `vector.rotate_around_axis(v1, v2, a)`:
    * Returns `v1` rotated around axis `v2` by `a` radians according to
      the right hand rule.
* `vector.dir_to_rotation(direction[, up])`:
    * Returns a rotation vector for `direction` pointing forward using `up`
      as the up vector.
    * If `up` is omitted, the roll of the returned vector defaults to zero.
    * Otherwise `direction` and `up` need to be vectors in a 90 degree angle to each other.

Further helpers
---------------

There are more helper functions involving vectors, but they are listed elsewhere
because they only work on specific sorts of vectors or involve things that are not
vectors.

For example:

* `minetest.hash_node_position` (Only works on node positions.)
* `minetest.dir_to_wallmounted` (Involves wallmounted param2 values.)




Helper functions
================

* `dump2(obj, name, dumped)`: returns a string which makes `obj`
  human-readable, handles reference loops.
    * `obj`: arbitrary variable
    * `name`: string, default: `"_"`
    * `dumped`: table, default: `{}`
* `dump(obj, dumped)`: returns a string which makes `obj` human-readable
    * `obj`: arbitrary variable
    * `dumped`: table, default: `{}`
* `math.hypot(x, y)`
    * Get the hypotenuse of a triangle with legs x and y.
      Useful for distance calculation.
* `math.sign(x, tolerance)`: returns `-1`, `0` or `1`
    * Get the sign of a number.
    * tolerance: number, default: `0.0`
    * If the absolute value of `x` is within the `tolerance` or `x` is NaN,
      `0` is returned.
* `math.factorial(x)`: returns the factorial of `x`
* `math.round(x)`: Returns `x` rounded to the nearest integer.
    * At a multiple of 0.5, rounds away from zero.
* `string.split(str, separator, include_empty, max_splits, sep_is_pattern)`
    * `separator`: string, default: `","`
    * `include_empty`: boolean, default: `false`
    * `max_splits`: number, if it's negative, splits aren't limited,
      default: `-1`
    * `sep_is_pattern`: boolean, it specifies whether separator is a plain
      string or a pattern (regex), default: `false`
    * e.g. `"a,b":split","` returns `{"a","b"}`
* `string:trim()`: returns the string without whitespace pre- and suffixes
    * e.g. `"\n \t\tfoo bar\t ":trim()` returns `"foo bar"`
* `minetest.wrap_text(str, limit, as_table)`: returns a string or table
    * Adds newlines to the string to keep it within the specified character
      limit
    * Note that the returned lines may be longer than the limit since it only
      splits at word borders.
    * `limit`: number, maximal amount of characters in one line
    * `as_table`: boolean, if set to true, a table of lines instead of a string
      is returned, default: `false`
* `minetest.pos_to_string(pos, decimal_places)`: returns string `"(X,Y,Z)"`
    * `pos`: table {x=X, y=Y, z=Z}
    * Converts the position `pos` to a human-readable, printable string
    * `decimal_places`: number, if specified, the x, y and z values of
      the position are rounded to the given decimal place.
* `minetest.string_to_pos(string)`: returns a position or `nil`
    * Same but in reverse.
    * If the string can't be parsed to a position, nothing is returned.
* `minetest.string_to_area("(X1, Y1, Z1) (X2, Y2, Z2)", relative_to)`:
    * returns two positions
    * Converts a string representing an area box into two positions
    * X1, Y1, ... Z2 are coordinates
    * `relative_to`: Optional. If set to a position, each coordinate
      can use the tilde notation for relative positions
    * Tilde notation: "~": Relative coordinate
                      "~<number>": Relative coordinate plus <number>
    * Example: `minetest.string_to_area("(1,2,3) (~5,~-5,~)", {x=10,y=10,z=10})`
      returns `{x=1,y=2,z=3}, {x=15,y=5,z=10}`
* `minetest.formspec_escape(string)`: returns a string
    * escapes the characters "[", "]", "\", "," and ";", which can not be used
      in formspecs.
* `minetest.is_yes(arg)`
    * returns true if passed 'y', 'yes', 'true' or a number that isn't zero.
* `minetest.is_nan(arg)`
    * returns true when the passed number represents NaN.
* `minetest.get_us_time()`
    * returns time with microsecond precision. May not return wall time.
* `table.copy(table)`: returns a table
    * returns a deep copy of `table`
* `table.indexof(list, val)`: returns the smallest numerical index containing
      the value `val` in the table `list`. Non-numerical indices are ignored.
      If `val` could not be found, `-1` is returned. `list` must not have
      negative indices.
* `table.insert_all(table, other_table)`:
    * Appends all values in `other_table` to `table` - uses `#table + 1` to
      find new indices.
* `table.key_value_swap(t)`: returns a table with keys and values swapped
    * If multiple keys in `t` map to the same value, it is unspecified which
      value maps to that key.
* `table.shuffle(table, [from], [to], [random_func])`:
    * Shuffles elements `from` to `to` in `table` in place
    * `from` defaults to `1`
    * `to` defaults to `#table`
    * `random_func` defaults to `math.random`. This function receives two
      integers as arguments and should return a random integer inclusively
      between them.
* `minetest.pointed_thing_to_face_pos(placer, pointed_thing)`: returns a
  position.
    * returns the exact position on the surface of a pointed node
* `minetest.get_tool_wear_after_use(uses [, initial_wear])`
    * Simulates a tool being used once and returns the added wear,
      such that, if only this function is used to calculate wear,
      the tool will break exactly after `uses` times of uses
    * `uses`: Number of times the tool can be used
    * `initial_wear`: The initial wear the tool starts with (default: 0)
* `minetest.get_dig_params(groups, tool_capabilities [, wear])`:
    Simulates an item that digs a node.
    Returns a table with the following fields:
    * `diggable`: `true` if node can be dug, `false` otherwise.
    * `time`: Time it would take to dig the node.
    * `wear`: How much wear would be added to the tool (ignored for non-tools).
    `time` and `wear` are meaningless if node's not diggable
    Parameters:
    * `groups`: Table of the node groups of the node that would be dug
    * `tool_capabilities`: Tool capabilities table of the item
    * `wear`: Amount of wear the tool starts with (default: 0)
* `minetest.get_hit_params(groups, tool_capabilities [, time_from_last_punch [, wear]])`:
    Simulates an item that punches an object.
    Returns a table with the following fields:
    * `hp`: How much damage the punch would cause (between -65535 and 65535).
    * `wear`: How much wear would be added to the tool (ignored for non-tools).
    Parameters:
    * `groups`: Damage groups of the object
    * `tool_capabilities`: Tool capabilities table of the item
    * `time_from_last_punch`: time in seconds since last punch action
    * `wear`: Amount of wear the item starts with (default: 0)




Translations
============

Texts can be translated client-side with the help of `minetest.translate` and
translation files.

Translating a string
--------------------

Two functions are provided to translate strings: `minetest.translate` and
`minetest.get_translator`.

* `minetest.get_translator(textdomain)` is a simple wrapper around
  `minetest.translate`, and `minetest.get_translator(textdomain)(str, ...)` is
  equivalent to `minetest.translate(textdomain, str, ...)`.
  It is intended to be used in the following way, so that it avoids verbose
  repetitions of `minetest.translate`:

      local S = minetest.get_translator(textdomain)
      S(str, ...)

  As an extra commodity, if `textdomain` is nil, it is assumed to be "" instead.

* `minetest.translate(textdomain, str, ...)` translates the string `str` with
  the given `textdomain` for disambiguation. The textdomain must match the
  textdomain specified in the translation file in order to get the string
  translated. This can be used so that a string is translated differently in
  different contexts.
  It is advised to use the name of the mod as textdomain whenever possible, to
  avoid clashes with other mods.
  This function must be given a number of arguments equal to the number of
  arguments the translated string expects.
  Arguments are literal strings -- they will not be translated, so if you want
  them to be, they need to come as outputs of `minetest.translate` as well.

  For instance, suppose we want to translate "@1 Wool" with "@1" being replaced
  by the translation of "Red". We can do the following:

      local S = minetest.get_translator()
      S("@1 Wool", S("Red"))

  This will be displayed as "Red Wool" on old clients and on clients that do
  not have localization enabled. However, if we have for instance a translation
  file named `wool.fr.tr` containing the following:

      @1 Wool=Laine @1
      Red=Rouge

  this will be displayed as "Laine Rouge" on clients with a French locale.

Operations on translated strings
--------------------------------

The output of `minetest.translate` is a string, with escape sequences adding
additional information to that string so that it can be translated on the
different clients. In particular, you can't expect operations like string.length
to work on them like you would expect them to, or string.gsub to work in the
expected manner. However, string concatenation will still work as expected
(note that you should only use this for things like formspecs; do not translate
sentences by breaking them into parts; arguments should be used instead), and
operations such as `minetest.colorize` which are also concatenation.

Translation file format
-----------------------

A translation file has the suffix `.[lang].tr`, where `[lang]` is the language
it corresponds to. It must be put into the `locale` subdirectory of the mod.
The file should be a text file, with the following format:

* Lines beginning with `# textdomain:` (the space is significant) can be used
  to specify the text domain of all following translations in the file.
* All other empty lines or lines beginning with `#` are ignored.
* Other lines should be in the format `original=translated`. Both `original`
  and `translated` can contain escape sequences beginning with `@` to insert
  arguments, literal `@`, `=` or newline (See [Escapes] below).
  There must be no extraneous whitespace around the `=` or at the beginning or
  the end of the line.

Escapes
-------

Strings that need to be translated can contain several escapes, preceded by `@`.

* `@@` acts as a literal `@`.
* `@n`, where `n` is a digit between 1 and 9, is an argument for the translated
  string that will be inlined when translated. Due to how translations are
  implemented, the original translation string **must** have its arguments in
  increasing order, without gaps or repetitions, starting from 1.
* `@=` acts as a literal `=`. It is not required in strings given to
  `minetest.translate`, but is in translation files to avoid being confused
  with the `=` separating the original from the translation.
* `@\n` (where the `\n` is a literal newline) acts as a literal newline.
  As with `@=`, this escape is not required in strings given to
  `minetest.translate`, but is in translation files.
* `@n` acts as a literal newline as well.

Server side translations
------------------------

On some specific cases, server translation could be useful. For example, filter
a list on labels and send results to client. A method is supplied to achieve
that:

`minetest.get_translated_string(lang_code, string)`: Translates `string` using
translations for `lang_code` language. It gives the same result as if the string
was translated by the client.

The `lang_code` to use for a given player can be retrieved from
the table returned by `minetest.get_player_information(name)`.

IMPORTANT: This functionality should only be used for sorting, filtering or similar purposes.
You do not need to use this to get translated strings to show up on the client.

Perlin noise
============

Perlin noise creates a continuously-varying value depending on the input values.
Usually in Minetest the input values are either 2D or 3D co-ordinates in nodes.
The result is used during map generation to create the terrain shape, vary heat
and humidity to distribute biomes, vary the density of decorations or vary the
structure of ores.

Structure of perlin noise
-------------------------

An 'octave' is a simple noise generator that outputs a value between -1 and 1.
The smooth wavy noise it generates has a single characteristic scale, almost
like a 'wavelength', so on its own does not create fine detail.
Due to this perlin noise combines several octaves to create variation on
multiple scales. Each additional octave has a smaller 'wavelength' than the
previous.

This combination results in noise varying very roughly between -2.0 and 2.0 and
with an average value of 0.0, so `scale` and `offset` are then used to multiply
and offset the noise variation.

The final perlin noise variation is created as follows:

noise = offset + scale * (octave1 +
                          octave2 * persistence +
                          octave3 * persistence ^ 2 +
                          octave4 * persistence ^ 3 +
                          ...)

Noise Parameters
----------------

Noise Parameters are commonly called `NoiseParams`.

### `offset`

After the multiplication by `scale` this is added to the result and is the final
step in creating the noise value.
Can be positive or negative.

### `scale`

Once all octaves have been combined, the result is multiplied by this.
Can be positive or negative.

### `spread`

For octave1, this is roughly the change of input value needed for a very large
variation in the noise value generated by octave1. It is almost like a
'wavelength' for the wavy noise variation.
Each additional octave has a 'wavelength' that is smaller than the previous
octave, to create finer detail. `spread` will therefore roughly be the typical
size of the largest structures in the final noise variation.

`spread` is a vector with values for x, y, z to allow the noise variation to be
stretched or compressed in the desired axes.
Values are positive numbers.

### `seed`

This is a whole number that determines the entire pattern of the noise
variation. Altering it enables different noise patterns to be created.
With other parameters equal, different seeds produce different noise patterns
and identical seeds produce identical noise patterns.

For this parameter you can randomly choose any whole number. Usually it is
preferable for this to be different from other seeds, but sometimes it is useful
to be able to create identical noise patterns.

In some noise APIs the world seed is added to the seed specified in noise
parameters. This is done to make the resulting noise pattern vary in different
worlds, and be 'world-specific'.

### `octaves`

The number of simple noise generators that are combined.
A whole number, 1 or more.
Each additional octave adds finer detail to the noise but also increases the
noise calculation load.
3 is a typical minimum for a high quality, complex and natural-looking noise
variation. 1 octave has a slight 'gridlike' appearance.

Choose the number of octaves according to the `spread` and `lacunarity`, and the
size of the finest detail you require. For example:
if `spread` is 512 nodes, `lacunarity` is 2.0 and finest detail required is 16
nodes, octaves will be 6 because the 'wavelengths' of the octaves will be
512, 256, 128, 64, 32, 16 nodes.
Warning: If the 'wavelength' of any octave falls below 1 an error will occur.

### `persistence`

Each additional octave has an amplitude that is the amplitude of the previous
octave multiplied by `persistence`, to reduce the amplitude of finer details,
as is often helpful and natural to do so.
Since this controls the balance of fine detail to large-scale detail
`persistence` can be thought of as the 'roughness' of the noise.

A positive or negative non-zero number, often between 0.3 and 1.0.
A common medium value is 0.5, such that each octave has half the amplitude of
the previous octave.
This may need to be tuned when altering `lacunarity`; when doing so consider
that a common medium value is 1 / lacunarity.

### `lacunarity`

Each additional octave has a 'wavelength' that is the 'wavelength' of the
previous octave multiplied by 1 / lacunarity, to create finer detail.
'lacunarity' is often 2.0 so 'wavelength' often halves per octave.

A positive number no smaller than 1.0.
Values below 2.0 create higher quality noise at the expense of requiring more
octaves to cover a paticular range of 'wavelengths'.

### `flags`

Leave this field unset for no special handling.
Currently supported are `defaults`, `eased` and `absvalue`:

#### `defaults`

Specify this if you would like to keep auto-selection of eased/not-eased while
specifying some other flags.

#### `eased`

Maps noise gradient values onto a quintic S-curve before performing
interpolation. This results in smooth, rolling noise.
Disable this (`noeased`) for sharp-looking noise with a slightly gridded
appearence.
If no flags are specified (or defaults is), 2D noise is eased and 3D noise is
not eased.
Easing a 3D noise significantly increases the noise calculation load, so use
with restraint.

#### `absvalue`

The absolute value of each octave's noise variation is used when combining the
octaves. The final perlin noise variation is created as follows:

noise = offset + scale * (abs(octave1) +
                          abs(octave2) * persistence +
                          abs(octave3) * persistence ^ 2 +
                          abs(octave4) * persistence ^ 3 +
                          ...)

### Format example

For 2D or 3D perlin noise or perlin noise maps:

    np_terrain = {
        offset = 0,
        scale = 1,
        spread = {x = 500, y = 500, z = 500},
        seed = 571347,
        octaves = 5,
        persistence = 0.63,
        lacunarity = 2.0,
        flags = "defaults, absvalue",
    }

For 2D noise the Z component of `spread` is still defined but is ignored.
A single noise parameter table can be used for 2D or 3D noise.




Ores
====

Ore types
---------

These tell in what manner the ore is generated.

All default ores are of the uniformly-distributed scatter type.

### `scatter`

Randomly chooses a location and generates a cluster of ore.

If `noise_params` is specified, the ore will be placed if the 3D perlin noise
at that point is greater than the `noise_threshold`, giving the ability to
create a non-equal distribution of ore.

### `sheet`

Creates a sheet of ore in a blob shape according to the 2D perlin noise
described by `noise_params` and `noise_threshold`. This is essentially an
improved version of the so-called "stratus" ore seen in some unofficial mods.

This sheet consists of vertical columns of uniform randomly distributed height,
varying between the inclusive range `column_height_min` and `column_height_max`.
If `column_height_min` is not specified, this parameter defaults to 1.
If `column_height_max` is not specified, this parameter defaults to `clust_size`
for reverse compatibility. New code should prefer `column_height_max`.

The `column_midpoint_factor` parameter controls the position of the column at
which ore emanates from.
If 1, columns grow upward. If 0, columns grow downward. If 0.5, columns grow
equally starting from each direction.
`column_midpoint_factor` is a decimal number ranging in value from 0 to 1. If
this parameter is not specified, the default is 0.5.

The ore parameters `clust_scarcity` and `clust_num_ores` are ignored for this
ore type.

### `puff`

Creates a sheet of ore in a cloud-like puff shape.

As with the `sheet` ore type, the size and shape of puffs are described by
`noise_params` and `noise_threshold` and are placed at random vertical
positions within the currently generated chunk.

The vertical top and bottom displacement of each puff are determined by the
noise parameters `np_puff_top` and `np_puff_bottom`, respectively.

### `blob`

Creates a deformed sphere of ore according to 3d perlin noise described by
`noise_params`. The maximum size of the blob is `clust_size`, and
`clust_scarcity` has the same meaning as with the `scatter` type.

### `vein`

Creates veins of ore varying in density by according to the intersection of two
instances of 3d perlin noise with different seeds, both described by
`noise_params`.

`random_factor` varies the influence random chance has on placement of an ore
inside the vein, which is `1` by default. Note that modifying this parameter
may require adjusting `noise_threshold`.

The parameters `clust_scarcity`, `clust_num_ores`, and `clust_size` are ignored
by this ore type.

This ore type is difficult to control since it is sensitive to small changes.
The following is a decent set of parameters to work from:

    noise_params = {
        offset  = 0,
        scale   = 3,
        spread  = {x=200, y=200, z=200},
        seed    = 5390,
        octaves = 4,
        persistence = 0.5,
        lacunarity = 2.0,
        flags = "eased",
    },
    noise_threshold = 1.6

**WARNING**: Use this ore type *very* sparingly since it is ~200x more
computationally expensive than any other ore.

### `stratum`

Creates a single undulating ore stratum that is continuous across mapchunk
borders and horizontally spans the world.

The 2D perlin noise described by `noise_params` defines the Y co-ordinate of
the stratum midpoint. The 2D perlin noise described by `np_stratum_thickness`
defines the stratum's vertical thickness (in units of nodes). Due to being
continuous across mapchunk borders the stratum's vertical thickness is
unlimited.

If the noise parameter `noise_params` is omitted the ore will occur from y_min
to y_max in a simple horizontal stratum.

A parameter `stratum_thickness` can be provided instead of the noise parameter
`np_stratum_thickness`, to create a constant thickness.

Leaving out one or both noise parameters makes the ore generation less
intensive, useful when adding multiple strata.

`y_min` and `y_max` define the limits of the ore generation and for performance
reasons should be set as close together as possible but without clipping the
stratum's Y variation.

Each node in the stratum has a 1-in-`clust_scarcity` chance of being ore, so a
solid-ore stratum would require a `clust_scarcity` of 1.

The parameters `clust_num_ores`, `clust_size`, `noise_threshold` and
`random_factor` are ignored by this ore type.

Ore attributes
--------------

See section [Flag Specifier Format].

Currently supported flags:
`puff_cliffs`, `puff_additive_composition`.

### `puff_cliffs`

If set, puff ore generation will not taper down large differences in
displacement when approaching the edge of a puff. This flag has no effect for
ore types other than `puff`.

### `puff_additive_composition`

By default, when noise described by `np_puff_top` or `np_puff_bottom` results
in a negative displacement, the sub-column at that point is not generated. With
this attribute set, puff ore generation will instead generate the absolute
difference in noise displacement values. This flag has no effect for ore types
other than `puff`.




Decoration types
================

The varying types of decorations that can be placed.

`simple`
--------

Creates a 1 times `H` times 1 column of a specified node (or a random node from
a list, if a decoration list is specified). Can specify a certain node it must
spawn next to, such as water or lava, for example. Can also generate a
decoration of random height between a specified lower and upper bound.
This type of decoration is intended for placement of grass, flowers, cacti,
papyri, waterlilies and so on.

`schematic`
-----------

Copies a box of `MapNodes` from a specified schematic file (or raw description).
Can specify a probability of a node randomly appearing when placed.
This decoration type is intended to be used for multi-node sized discrete
structures, such as trees, cave spikes, rocks, and so on.




Schematics
==========

Schematic specifier
--------------------

A schematic specifier identifies a schematic by either a filename to a
Minetest Schematic file (`.mts`) or through raw data supplied through Lua,
in the form of a table.  This table specifies the following fields:

* The `size` field is a 3D vector containing the dimensions of the provided
  schematic. (required field)
* The `yslice_prob` field is a table of {ypos, prob} slice tables. A slice table
  sets the probability of a particular horizontal slice of the schematic being
  placed. (optional field)
  `ypos` = 0 for the lowest horizontal slice of a schematic.
  The default of `prob` is 255.
* The `data` field is a flat table of MapNode tables making up the schematic,
  in the order of `[z [y [x]]]`. (required field)
  Each MapNode table contains:
    * `name`: the name of the map node to place (required)
    * `prob` (alias `param1`): the probability of this node being placed
      (default: 255)
    * `param2`: the raw param2 value of the node being placed onto the map
      (default: 0)
    * `force_place`: boolean representing if the node should forcibly overwrite
      any previous contents (default: false)

About probability values:

* A probability value of `0` or `1` means that node will never appear
  (0% chance).
* A probability value of `254` or `255` means the node will always appear
  (100% chance).
* If the probability value `p` is greater than `1`, then there is a
  `(p / 256 * 100)` percent chance that node will appear when the schematic is
  placed on the map.

Schematic attributes
--------------------

See section [Flag Specifier Format].

Currently supported flags: `place_center_x`, `place_center_y`, `place_center_z`,
                           `force_placement`.

* `place_center_x`: Placement of this decoration is centered along the X axis.
* `place_center_y`: Placement of this decoration is centered along the Y axis.
* `place_center_z`: Placement of this decoration is centered along the Z axis.
* `force_placement`: Schematic nodes other than "ignore" will replace existing
  nodes.




Lua Voxel Manipulator
=====================

About VoxelManip
----------------

VoxelManip is a scripting interface to the internal 'Map Voxel Manipulator'
facility. The purpose of this object is for fast, low-level, bulk access to
reading and writing Map content. As such, setting map nodes through VoxelManip
will lack many of the higher level features and concepts you may be used to
with other methods of setting nodes. For example, nodes will not have their
construction and destruction callbacks run, and no rollback information is
logged.

It is important to note that VoxelManip is designed for speed, and *not* ease
of use or flexibility. If your mod requires a map manipulation facility that
will handle 100% of all edge cases, or the use of high level node placement
features, perhaps `minetest.set_node()` is better suited for the job.

In addition, VoxelManip might not be faster, or could even be slower, for your
specific use case. VoxelManip is most effective when setting large areas of map
at once - for example, if only setting a 3x3x3 node area, a
`minetest.set_node()` loop may be more optimal. Always profile code using both
methods of map manipulation to determine which is most appropriate for your
usage.

A recent simple test of setting cubic areas showed that `minetest.set_node()`
is faster than a VoxelManip for a 3x3x3 node cube or smaller.

Using VoxelManip
----------------

A VoxelManip object can be created any time using either:
`VoxelManip([p1, p2])`, or `minetest.get_voxel_manip([p1, p2])`.

If the optional position parameters are present for either of these routines,
the specified region will be pre-loaded into the VoxelManip object on creation.
Otherwise, the area of map you wish to manipulate must first be loaded into the
VoxelManip object using `VoxelManip:read_from_map()`.

Note that `VoxelManip:read_from_map()` returns two position vectors. The region
formed by these positions indicate the minimum and maximum (respectively)
positions of the area actually loaded in the VoxelManip, which may be larger
than the area requested. For convenience, the loaded area coordinates can also
be queried any time after loading map data with `VoxelManip:get_emerged_area()`.

Now that the VoxelManip object is populated with map data, your mod can fetch a
copy of this data using either of two methods. `VoxelManip:get_node_at()`,
which retrieves an individual node in a MapNode formatted table at the position
requested is the simplest method to use, but also the slowest.

Nodes in a VoxelManip object may also be read in bulk to a flat array table
using:

* `VoxelManip:get_data()` for node content (in Content ID form, see section
  [Content IDs]),
* `VoxelManip:get_light_data()` for node light levels, and
* `VoxelManip:get_param2_data()` for the node type-dependent "param2" values.

See section [Flat array format] for more details.

It is very important to understand that the tables returned by any of the above
three functions represent a snapshot of the VoxelManip's internal state at the
time of the call. This copy of the data will not magically update itself if
another function modifies the internal VoxelManip state.
Any functions that modify a VoxelManip's contents work on the VoxelManip's
internal state unless otherwise explicitly stated.

Once the bulk data has been edited to your liking, the internal VoxelManip
state can be set using:

* `VoxelManip:set_data()` for node content (in Content ID form, see section
  [Content IDs]),
* `VoxelManip:set_light_data()` for node light levels, and
* `VoxelManip:set_param2_data()` for the node type-dependent `param2` values.

The parameter to each of the above three functions can use any table at all in
the same flat array format as produced by `get_data()` etc. and is not required
to be a table retrieved from `get_data()`.

Once the internal VoxelManip state has been modified to your liking, the
changes can be committed back to the map by calling `VoxelManip:write_to_map()`

### Flat array format

Let
    `Nx = p2.X - p1.X + 1`,
    `Ny = p2.Y - p1.Y + 1`, and
    `Nz = p2.Z - p1.Z + 1`.

Then, for a loaded region of p1..p2, this array ranges from `1` up to and
including the value of the expression `Nx * Ny * Nz`.

Positions offset from p1 are present in the array with the format of:

    [
        (0, 0, 0),   (1, 0, 0),   (2, 0, 0),   ... (Nx, 0, 0),
        (0, 1, 0),   (1, 1, 0),   (2, 1, 0),   ... (Nx, 1, 0),
        ...
        (0, Ny, 0),  (1, Ny, 0),  (2, Ny, 0),  ... (Nx, Ny, 0),
        (0, 0, 1),   (1, 0, 1),   (2, 0, 1),   ... (Nx, 0, 1),
        ...
        (0, Ny, 2),  (1, Ny, 2),  (2, Ny, 2),  ... (Nx, Ny, 2),
        ...
        (0, Ny, Nz), (1, Ny, Nz), (2, Ny, Nz), ... (Nx, Ny, Nz)
    ]

and the array index for a position p contained completely in p1..p2 is:

`(p.Z - p1.Z) * Ny * Nx + (p.Y - p1.Y) * Nx + (p.X - p1.X) + 1`

Note that this is the same "flat 3D array" format as
`PerlinNoiseMap:get3dMap_flat()`.
VoxelArea objects (see section [`VoxelArea`]) can be used to simplify calculation
of the index for a single point in a flat VoxelManip array.

### Content IDs

A Content ID is a unique integer identifier for a specific node type.
These IDs are used by VoxelManip in place of the node name string for
`VoxelManip:get_data()` and `VoxelManip:set_data()`. You can use
`minetest.get_content_id()` to look up the Content ID for the specified node
name, and `minetest.get_name_from_content_id()` to look up the node name string
for a given Content ID.
After registration of a node, its Content ID will remain the same throughout
execution of the mod.
Note that the node being queried needs to have already been been registered.

The following builtin node types have their Content IDs defined as constants:

* `minetest.CONTENT_UNKNOWN`: ID for "unknown" nodes
* `minetest.CONTENT_AIR`:     ID for "air" nodes
* `minetest.CONTENT_IGNORE`:  ID for "ignore" nodes

### Mapgen VoxelManip objects

Inside of `on_generated()` callbacks, it is possible to retrieve the same
VoxelManip object used by the core's Map Generator (commonly abbreviated
Mapgen). Most of the rules previously described still apply but with a few
differences:

* The Mapgen VoxelManip object is retrieved using:
  `minetest.get_mapgen_object("voxelmanip")`
* This VoxelManip object already has the region of map just generated loaded
  into it; it's not necessary to call `VoxelManip:read_from_map()` before using
  a Mapgen VoxelManip.
* The `on_generated()` callbacks of some mods may place individual nodes in the
  generated area using non-VoxelManip map modification methods. Because the
  same Mapgen VoxelManip object is passed through each `on_generated()`
  callback, it becomes necessary for the Mapgen VoxelManip object to maintain
  consistency with the current map state. For this reason, calling any of the
  following functions:
  `minetest.add_node()`, `minetest.set_node()`, or `minetest.swap_node()`
  will also update the Mapgen VoxelManip object's internal state active on the
  current thread.
* After modifying the Mapgen VoxelManip object's internal buffer, it may be
  necessary to update lighting information using either:
  `VoxelManip:calc_lighting()` or `VoxelManip:set_lighting()`.

### Other API functions operating on a VoxelManip

If any VoxelManip contents were set to a liquid node (`liquidtype ~= "none"`),
`VoxelManip:update_liquids()` must be called for these liquid nodes to begin
flowing. It is recommended to call this function only after having written all
buffered data back to the VoxelManip object, save for special situations where
the modder desires to only have certain liquid nodes begin flowing.

The functions `minetest.generate_ores()` and `minetest.generate_decorations()`
will generate all registered decorations and ores throughout the full area
inside of the specified VoxelManip object.

`minetest.place_schematic_on_vmanip()` is otherwise identical to
`minetest.place_schematic()`, except instead of placing the specified schematic
directly on the map at the specified position, it will place the schematic
inside the VoxelManip.

### Notes

* Attempting to read data from a VoxelManip object before map is read will
  result in a zero-length array table for `VoxelManip:get_data()`, and an
  "ignore" node at any position for `VoxelManip:get_node_at()`.
* If either a region of map has not yet been generated or is out-of-bounds of
  the map, that region is filled with "ignore" nodes.
* Other mods, or the core itself, could possibly modify the area of map
  currently loaded into a VoxelManip object. With the exception of Mapgen
  VoxelManips (see above section), the internal buffers are not updated. For
  this reason, it is strongly encouraged to complete the usage of a particular
  VoxelManip object in the same callback it had been created.
* If a VoxelManip object will be used often, such as in an `on_generated()`
  callback, consider passing a file-scoped table as the optional parameter to
  `VoxelManip:get_data()`, which serves as a static buffer the function can use
  to write map data to instead of returning a new table each call. This greatly
  enhances performance by avoiding unnecessary memory allocations.

Methods
-------

* `read_from_map(p1, p2)`:  Loads a chunk of map into the VoxelManip object
  containing the region formed by `p1` and `p2`.
    * returns actual emerged `pmin`, actual emerged `pmax`
* `write_to_map([light])`: Writes the data loaded from the `VoxelManip` back to
  the map.
    * **important**: data must be set using `VoxelManip:set_data()` before
      calling this.
    * if `light` is true, then lighting is automatically recalculated.
      The default value is true.
      If `light` is false, no light calculations happen, and you should correct
      all modified blocks with `minetest.fix_light()` as soon as possible.
      Keep in mind that modifying the map where light is incorrect can cause
      more lighting bugs.
* `get_node_at(pos)`: Returns a `MapNode` table of the node currently loaded in
  the `VoxelManip` at that position
* `set_node_at(pos, node)`: Sets a specific `MapNode` in the `VoxelManip` at
  that position.
* `get_data([buffer])`: Retrieves the node content data loaded into the
  `VoxelManip` object.
    * returns raw node data in the form of an array of node content IDs
    * if the param `buffer` is present, this table will be used to store the
      result instead.
* `set_data(data)`: Sets the data contents of the `VoxelManip` object
* `update_map()`: Does nothing, kept for compatibility.
* `set_lighting(light, [p1, p2])`: Set the lighting within the `VoxelManip` to
  a uniform value.
    * `light` is a table, `{day=<0...15>, night=<0...15>}`
    * To be used only by a `VoxelManip` object from
      `minetest.get_mapgen_object`.
    * (`p1`, `p2`) is the area in which lighting is set, defaults to the whole
      area if left out.
* `get_light_data()`: Gets the light data read into the `VoxelManip` object
    * Returns an array (indices 1 to volume) of integers ranging from `0` to
      `255`.
    * Each value is the bitwise combination of day and night light values
      (`0` to `15` each).
    * `light = day + (night * 16)`
* `set_light_data(light_data)`: Sets the `param1` (light) contents of each node
  in the `VoxelManip`.
    * expects lighting data in the same format that `get_light_data()` returns
* `get_param2_data([buffer])`: Gets the raw `param2` data read into the
  `VoxelManip` object.
    * Returns an array (indices 1 to volume) of integers ranging from `0` to
      `255`.
    * If the param `buffer` is present, this table will be used to store the
      result instead.
* `set_param2_data(param2_data)`: Sets the `param2` contents of each node in
  the `VoxelManip`.
* `calc_lighting([p1, p2], [propagate_shadow])`:  Calculate lighting within the
  `VoxelManip`.
    * To be used only by a `VoxelManip` object from
      `minetest.get_mapgen_object`.
    * (`p1`, `p2`) is the area in which lighting is set, defaults to the whole
      area if left out or nil. For almost all uses these should be left out
      or nil to use the default.
    * `propagate_shadow` is an optional boolean deciding whether shadows in a
      generated mapchunk above are propagated down into the mapchunk, defaults
      to `true` if left out.
* `update_liquids()`: Update liquid flow
* `was_modified()`: Returns `true` or `false` if the data in the voxel
  manipulator had been modified since the last read from map, due to a call to
  `minetest.set_data()` on the loaded area elsewhere.
* `get_emerged_area()`: Returns actual emerged minimum and maximum positions.

`VoxelArea`
-----------

A helper class for voxel areas.
It can be created via `VoxelArea:new{MinEdge = pmin, MaxEdge = pmax}`.
The coordinates are *inclusive*, like most other things in Minetest.

### Methods

* `getExtent()`: returns a 3D vector containing the size of the area formed by
  `MinEdge` and `MaxEdge`.
* `getVolume()`: returns the volume of the area formed by `MinEdge` and
  `MaxEdge`.
* `index(x, y, z)`: returns the index of an absolute position in a flat array
  starting at `1`.
    * `x`, `y` and `z` must be integers to avoid an incorrect index result.
    * The position (x, y, z) is not checked for being inside the area volume,
      being outside can cause an incorrect index result.
    * Useful for things like `VoxelManip`, raw Schematic specifiers,
      `PerlinNoiseMap:get2d`/`3dMap`, and so on.
* `indexp(p)`: same functionality as `index(x, y, z)` but takes a vector.
    * As with `index(x, y, z)`, the components of `p` must be integers, and `p`
      is not checked for being inside the area volume.
* `position(i)`: returns the absolute position vector corresponding to index
  `i`.
* `contains(x, y, z)`: check if (`x`,`y`,`z`) is inside area formed by
  `MinEdge` and `MaxEdge`.
* `containsp(p)`: same as above, except takes a vector
* `containsi(i)`: same as above, except takes an index `i`
* `iter(minx, miny, minz, maxx, maxy, maxz)`: returns an iterator that returns
  indices.
    * from (`minx`,`miny`,`minz`) to (`maxx`,`maxy`,`maxz`) in the order of
      `[z [y [x]]]`.
* `iterp(minp, maxp)`: same as above, except takes a vector

### Y stride and z stride of a flat array

For a particular position in a voxel area, whose flat array index is known,
it is often useful to know the index of a neighboring or nearby position.
The table below shows the changes of index required for 1 node movements along
the axes in a voxel area:

    Movement    Change of index
    +x          +1
    -x          -1
    +y          +ystride
    -y          -ystride
    +z          +zstride
    -z          -zstride

If, for example:

    local area = VoxelArea:new{MinEdge = emin, MaxEdge = emax}

The values of `ystride` and `zstride` can be obtained using `area.ystride` and
`area.zstride`.




Mapgen objects
==============

A mapgen object is a construct used in map generation. Mapgen objects can be
used by an `on_generate` callback to speed up operations by avoiding
unnecessary recalculations, these can be retrieved using the
`minetest.get_mapgen_object()` function. If the requested Mapgen object is
unavailable, or `get_mapgen_object()` was called outside of an `on_generate()`
callback, `nil` is returned.

The following Mapgen objects are currently available:

### `voxelmanip`

This returns three values; the `VoxelManip` object to be used, minimum and
maximum emerged position, in that order. All mapgens support this object.

### `heightmap`

Returns an array containing the y coordinates of the ground levels of nodes in
the most recently generated chunk by the current mapgen.

### `biomemap`

Returns an array containing the biome IDs of nodes in the most recently
generated chunk by the current mapgen.

### `heatmap`

Returns an array containing the temperature values of nodes in the most
recently generated chunk by the current mapgen.

### `humiditymap`

Returns an array containing the humidity values of nodes in the most recently
generated chunk by the current mapgen.

### `gennotify`

Returns a table mapping requested generation notification types to arrays of
positions at which the corresponding generated structures are located within
the current chunk. To set the capture of positions of interest to be recorded
on generate, use `minetest.set_gen_notify()`.
For decorations, the returned positions are the ground surface 'place_on'
nodes, not the decorations themselves. A 'simple' type decoration is often 1
node above the returned position and possibly displaced by 'place_offset_y'.

Possible fields of the table returned are:

* `dungeon`
* `temple`
* `cave_begin`
* `cave_end`
* `large_cave_begin`
* `large_cave_end`
* `decoration`

Decorations have a key in the format of `"decoration#id"`, where `id` is the
numeric unique decoration ID as returned by `minetest.get_decoration_id`.




Registered entities
===================

Functions receive a "luaentity" as `self`:

* It has the member `.name`, which is the registered name `("mod:thing")`
* It has the member `.object`, which is an `ObjectRef` pointing to the object
* The original prototype stuff is visible directly via a metatable

Callbacks:

* `on_activate(self, staticdata, dtime_s)`
    * Called when the object is instantiated.
    * `dtime_s` is the time passed since the object was unloaded, which can be
      used for updating the entity state.
* `on_deactivate(self)
    * Called when the object is about to get removed or unloaded.
* `on_step(self, dtime)`
    * Called on every server tick, after movement and collision processing.
      `dtime` is usually 0.1 seconds, as per the `dedicated_server_step` setting
      in `minetest.conf`.
* `on_punch(self, puncher, time_from_last_punch, tool_capabilities, dir, damage)`
    * Called when somebody punches the object.
    * Note that you probably want to handle most punches using the automatic
      armor group system.
    * `puncher`: an `ObjectRef` (can be `nil`)
    * `time_from_last_punch`: Meant for disallowing spamming of clicks
      (can be `nil`).
    * `tool_capabilities`: capability table of used item (can be `nil`)
    * `dir`: unit vector of direction of punch. Always defined. Points from the
      puncher to the punched.
    * `damage`: damage that will be done to entity.
    * Can return `true` to prevent the default damage mechanism.
* `on_death(self, killer)`
    * Called when the object dies.
    * `killer`: an `ObjectRef` (can be `nil`)
* `on_rightclick(self, clicker)`
    * Called when `clicker` pressed the 'place/use' key while pointing
      to the object (not neccessarily an actual rightclick)
    * `clicker`: an `ObjectRef` (may or may not be a player)
* `on_attach_child(self, child)`
    * `child`: an `ObjectRef` of the child that attaches
* `on_detach_child(self, child)`
    * `child`: an `ObjectRef` of the child that detaches
* `on_detach(self, parent)`
    * `parent`: an `ObjectRef` (can be `nil`) from where it got detached
    * This happens before the parent object is removed from the world
* `get_staticdata(self)`
    * Should return a string that will be passed to `on_activate` when the
      object is instantiated the next time.




L-system trees
==============

Tree definition
---------------

    treedef={
        axiom,         --string  initial tree axiom
        rules_a,       --string  rules set A
        rules_b,       --string  rules set B
        rules_c,       --string  rules set C
        rules_d,       --string  rules set D
        trunk,         --string  trunk node name
        leaves,        --string  leaves node name
        leaves2,       --string  secondary leaves node name
        leaves2_chance,--num     chance (0-100) to replace leaves with leaves2
        angle,         --num     angle in deg
        iterations,    --num     max # of iterations, usually 2 -5
        random_level,  --num     factor to lower nr of iterations, usually 0 - 3
        trunk_type,    --string  single/double/crossed) type of trunk: 1 node,
                       --        2x2 nodes or 3x3 in cross shape
        thin_branches, --boolean true -> use thin (1 node) branches
        fruit,         --string  fruit node name
        fruit_chance,  --num     chance (0-100) to replace leaves with fruit node
        seed,          --num     random seed, if no seed is provided, the engine
                                 will create one.
    }

Key for special L-System symbols used in axioms
-----------------------------------------------

* `G`: move forward one unit with the pen up
* `F`: move forward one unit with the pen down drawing trunks and branches
* `f`: move forward one unit with the pen down drawing leaves (100% chance)
* `T`: move forward one unit with the pen down drawing trunks only
* `R`: move forward one unit with the pen down placing fruit
* `A`: replace with rules set A
* `B`: replace with rules set B
* `C`: replace with rules set C
* `D`: replace with rules set D
* `a`: replace with rules set A, chance 90%
* `b`: replace with rules set B, chance 80%
* `c`: replace with rules set C, chance 70%
* `d`: replace with rules set D, chance 60%
* `+`: yaw the turtle right by `angle` parameter
* `-`: yaw the turtle left by `angle` parameter
* `&`: pitch the turtle down by `angle` parameter
* `^`: pitch the turtle up by `angle` parameter
* `/`: roll the turtle to the right by `angle` parameter
* `*`: roll the turtle to the left by `angle` parameter
* `[`: save in stack current state info
* `]`: recover from stack state info

Example
-------

Spawn a small apple tree:

    pos = {x=230,y=20,z=4}
    apple_tree={
        axiom="FFFFFAFFBF",
        rules_a="[&&&FFFFF&&FFFF][&&&++++FFFFF&&FFFF][&&&----FFFFF&&FFFF]",
        rules_b="[&&&++FFFFF&&FFFF][&&&--FFFFF&&FFFF][&&&------FFFFF&&FFFF]",
        trunk="default:tree",
        leaves="default:leaves",
        angle=30,
        iterations=2,
        random_level=0,
        trunk_type="single",
        thin_branches=true,
        fruit_chance=10,
        fruit="default:apple"
    }
    minetest.spawn_tree(pos,apple_tree)




'minetest' namespace reference
==============================

Utilities
---------

* `minetest.get_current_modname()`: returns the currently loading mod's name,
  when loading a mod.
* `minetest.get_modpath(modname)`: returns the directory path for a mod,
  e.g. `"/home/user/.minetest/usermods/modname"`.
    * Returns nil if the mod is not enabled or does not exist (not installed).
    * Works regardless of whether the mod has been loaded yet.
    * Useful for loading additional `.lua` modules or static data from a mod,
  or checking if a mod is enabled.
* `minetest.get_modnames()`: returns a list of enabled mods, sorted alphabetically.
    * Does not include disabled mods, even if they are installed.
* `minetest.get_worldpath()`: returns e.g. `"/home/user/.minetest/world"`
    * Useful for storing custom data
* `minetest.is_singleplayer()`
* `minetest.features`: Table containing API feature flags

      {
          glasslike_framed = true,  -- 0.4.7
          nodebox_as_selectionbox = true,  -- 0.4.7
          get_all_craft_recipes_works = true,  -- 0.4.7
          -- The transparency channel of textures can optionally be used on
          -- nodes (0.4.7)
          use_texture_alpha = true,
          -- Tree and grass ABMs are no longer done from C++ (0.4.8)
          no_legacy_abms = true,
          -- Texture grouping is possible using parentheses (0.4.11)
          texture_names_parens = true,
          -- Unique Area ID for AreaStore:insert_area (0.4.14)
          area_store_custom_ids = true,
          -- add_entity supports passing initial staticdata to on_activate
          -- (0.4.16)
          add_entity_with_staticdata = true,
          -- Chat messages are no longer predicted (0.4.16)
          no_chat_message_prediction = true,
          -- The transparency channel of textures can optionally be used on
          -- objects (ie: players and lua entities) (5.0.0)
          object_use_texture_alpha = true,
          -- Object selectionbox is settable independently from collisionbox
          -- (5.0.0)
          object_independent_selectionbox = true,
          -- Specifies whether binary data can be uploaded or downloaded using
          -- the HTTP API (5.1.0)
          httpfetch_binary_data = true,
          -- Whether formspec_version[<version>] may be used (5.1.0)
          formspec_version_element = true,
          -- Whether AreaStore's IDs are kept on save/load (5.1.0)
          area_store_persistent_ids = true,
          -- Whether minetest.find_path is functional (5.2.0)
          pathfinder_works = true,
          -- Whether Collision info is available to an objects' on_step (5.3.0)
          object_step_has_moveresult = true,
          -- Whether get_velocity() and add_velocity() can be used on players (5.4.0)
          direct_velocity_on_players = true,
          -- nodedef's use_texture_alpha accepts new string modes (5.4.0)
          use_texture_alpha_string_modes = true,
          -- degrotate param2 rotates in units of 1.5° instead of 2°
          -- thus changing the range of values from 0-179 to 0-240 (5.5.0)
          degrotate_240_steps = true,
          -- ABM supports min_y and max_y fields in definition (5.5.0)
          abm_min_max_y = true,
          -- dynamic_add_media supports passing a table with options (5.5.0)
          dynamic_add_media_table = true,
          -- allows get_sky to return a table instead of separate values (5.6.0)
          get_sky_as_table = true,
      }

* `minetest.has_feature(arg)`: returns `boolean, missing_features`
    * `arg`: string or table in format `{foo=true, bar=true}`
    * `missing_features`: `{foo=true, bar=true}`
* `minetest.get_player_information(player_name)`: Table containing information
  about a player. Example return value:

      {
          address = "127.0.0.1",     -- IP address of client
          ip_version = 4,            -- IPv4 / IPv6
          connection_uptime = 200,   -- seconds since client connected
          protocol_version = 32,     -- protocol version used by client
          formspec_version = 2,      -- supported formspec version
          lang_code = "fr"           -- Language code used for translation
          -- the following keys can be missing if no stats have been collected yet
          min_rtt = 0.01,            -- minimum round trip time
          max_rtt = 0.2,             -- maximum round trip time
          avg_rtt = 0.02,            -- average round trip time
          min_jitter = 0.01,         -- minimum packet time jitter
          max_jitter = 0.5,          -- maximum packet time jitter
          avg_jitter = 0.03,         -- average packet time jitter
          -- the following information is available in a debug build only!!!
          -- DO NOT USE IN MODS
          --ser_vers = 26,             -- serialization version used by client
          --major = 0,                 -- major version number
          --minor = 4,                 -- minor version number
          --patch = 10,                -- patch version number
          --vers_string = "0.4.9-git", -- full version string
          --state = "Active"           -- current client state
      }

* `minetest.mkdir(path)`: returns success.
    * Creates a directory specified by `path`, creating parent directories
      if they don't exist.
* `minetest.rmdir(path, recursive)`: returns success.
    * Removes a directory specified by `path`.
    * If `recursive` is set to `true`, the directory is recursively removed.
      Otherwise, the directory will only be removed if it is empty.
    * Returns true on success, false on failure.
* `minetest.cpdir(source, destination)`: returns success.
    * Copies a directory specified by `path` to `destination`
    * Any files in `destination` will be overwritten if they already exist.
    * Returns true on success, false on failure.
* `minetest.mvdir(source, destination)`: returns success.
    * Moves a directory specified by `path` to `destination`.
    * If the `destination` is a non-empty directory, then the move will fail.
    * Returns true on success, false on failure.
* `minetest.get_dir_list(path, [is_dir])`: returns list of entry names
    * is_dir is one of:
        * nil: return all entries,
        * true: return only subdirectory names, or
        * false: return only file names.
* `minetest.safe_file_write(path, content)`: returns boolean indicating success
    * Replaces contents of file at path with new contents in a safe (atomic)
      way. Use this instead of below code when writing e.g. database files:
      `local f = io.open(path, "wb"); f:write(content); f:close()`
* `minetest.get_version()`: returns a table containing components of the
   engine version.  Components:
    * `project`: Name of the project, eg, "Minetest"
    * `string`: Simple version, eg, "1.2.3-dev"
    * `hash`: Full git version (only set if available),
      eg, "1.2.3-dev-01234567-dirty".
  Use this for informational purposes only. The information in the returned
  table does not represent the capabilities of the engine, nor is it
  reliable or verifiable. Compatible forks will have a different name and
  version entirely. To check for the presence of engine features, test
  whether the functions exported by the wanted features exist. For example:
  `if minetest.check_for_falling then ... end`.
* `minetest.sha1(data, [raw])`: returns the sha1 hash of data
    * `data`: string of data to hash
    * `raw`: return raw bytes instead of hex digits, default: false
* `minetest.colorspec_to_colorstring(colorspec)`: Converts a ColorSpec to a
  ColorString. If the ColorSpec is invalid, returns `nil`.
    * `colorspec`: The ColorSpec to convert
* `minetest.colorspec_to_bytes(colorspec)`: Converts a ColorSpec to a raw
  string of four bytes in an RGBA layout, returned as a string.
  * `colorspec`: The ColorSpec to convert
* `minetest.encode_png(width, height, data, [compression])`: Encode a PNG
  image and return it in string form.
    * `width`: Width of the image
    * `height`: Height of the image
    * `data`: Image data, one of:
        * array table of ColorSpec, length must be width*height
        * string with raw RGBA pixels, length must be width*height*4
    * `compression`: Optional zlib compression level, number in range 0 to 9.
  The data is one-dimensional, starting in the upper left corner of the image
  and laid out in scanlines going from left to right, then top to bottom.
  Please note that it's not safe to use string.char to generate raw data,
  use `colorspec_to_bytes` to generate raw RGBA values in a predictable way.
  The resulting PNG image is always 32-bit. Palettes are not supported at the moment.
  You may use this to procedurally generate textures during server init.

Logging
-------

* `minetest.debug(...)`
    * Equivalent to `minetest.log(table.concat({...}, "\t"))`
* `minetest.log([level,] text)`
    * `level` is one of `"none"`, `"error"`, `"warning"`, `"action"`,
      `"info"`, or `"verbose"`.  Default is `"none"`.

Registration functions
----------------------

Call these functions only at load time!

### Environment

* `minetest.register_node(name, node definition)`
* `minetest.register_craftitem(name, item definition)`
* `minetest.register_tool(name, item definition)`
* `minetest.override_item(name, redefinition)`
    * Overrides fields of an item registered with register_node/tool/craftitem.
    * Note: Item must already be defined, (opt)depend on the mod defining it.
    * Example: `minetest.override_item("default:mese",
      {light_source=minetest.LIGHT_MAX})`
* `minetest.unregister_item(name)`
    * Unregisters the item from the engine, and deletes the entry with key
      `name` from `minetest.registered_items` and from the associated item table
      according to its nature: `minetest.registered_nodes`, etc.
* `minetest.register_entity(name, entity definition)`
* `minetest.register_abm(abm definition)`
* `minetest.register_lbm(lbm definition)`
* `minetest.register_alias(alias, original_name)`
    * Also use this to set the 'mapgen aliases' needed in a game for the core
      mapgens. See [Mapgen aliases] section above.
* `minetest.register_alias_force(alias, original_name)`
* `minetest.register_ore(ore definition)`
    * Returns an integer object handle uniquely identifying the registered
      ore on success.
    * The order of ore registrations determines the order of ore generation.
* `minetest.register_biome(biome definition)`
    * Returns an integer object handle uniquely identifying the registered
      biome on success. To get the biome ID, use `minetest.get_biome_id`.
* `minetest.unregister_biome(name)`
    * Unregisters the biome from the engine, and deletes the entry with key
      `name` from `minetest.registered_biomes`.
    * Warning: This alters the biome to biome ID correspondences, so any
      decorations or ores using the 'biomes' field must afterwards be cleared
      and re-registered.
* `minetest.register_decoration(decoration definition)`
    * Returns an integer object handle uniquely identifying the registered
      decoration on success. To get the decoration ID, use
      `minetest.get_decoration_id`.
    * The order of decoration registrations determines the order of decoration
      generation.
* `minetest.register_schematic(schematic definition)`
    * Returns an integer object handle uniquely identifying the registered
      schematic on success.
    * If the schematic is loaded from a file, the `name` field is set to the
      filename.
    * If the function is called when loading the mod, and `name` is a relative
      path, then the current mod path will be prepended to the schematic
      filename.
* `minetest.clear_registered_biomes()`
    * Clears all biomes currently registered.
    * Warning: Clearing and re-registering biomes alters the biome to biome ID
      correspondences, so any decorations or ores using the 'biomes' field must
      afterwards be cleared and re-registered.
* `minetest.clear_registered_decorations()`
    * Clears all decorations currently registered.
* `minetest.clear_registered_ores()`
    * Clears all ores currently registered.
* `minetest.clear_registered_schematics()`
    * Clears all schematics currently registered.

### Gameplay

* `minetest.register_craft(recipe)`
    * Check recipe table syntax for different types below.
* `minetest.clear_craft(recipe)`
    * Will erase existing craft based either on output item or on input recipe.
    * Specify either output or input only. If you specify both, input will be
      ignored. For input use the same recipe table syntax as for
      `minetest.register_craft(recipe)`. For output specify only the item,
      without a quantity.
    * Returns false if no erase candidate could be found, otherwise returns true.
    * **Warning**! The type field ("shaped", "cooking" or any other) will be
      ignored if the recipe contains output. Erasing is then done independently
      from the crafting method.
* `minetest.register_chatcommand(cmd, chatcommand definition)`
* `minetest.override_chatcommand(name, redefinition)`
    * Overrides fields of a chatcommand registered with `register_chatcommand`.
* `minetest.unregister_chatcommand(name)`
    * Unregisters a chatcommands registered with `register_chatcommand`.
* `minetest.register_privilege(name, definition)`
    * `definition` can be a description or a definition table (see [Privilege
      definition]).
    * If it is a description, the priv will be granted to singleplayer and admin
      by default.
    * To allow players with `basic_privs` to grant, see the `basic_privs`
      minetest.conf setting.
* `minetest.register_authentication_handler(authentication handler definition)`
    * Registers an auth handler that overrides the builtin one.
    * This function can be called by a single mod once only.

Global callback registration functions
--------------------------------------

Call these functions only at load time!

* `minetest.register_globalstep(function(dtime))`
    * Called every server step, usually interval of 0.1s
* `minetest.register_on_mods_loaded(function())`
    * Called after mods have finished loading and before the media is cached or the
      aliases handled.
* `minetest.register_on_shutdown(function())`
    * Called before server shutdown
    * **Warning**: If the server terminates abnormally (i.e. crashes), the
      registered callbacks **will likely not be run**. Data should be saved at
      semi-frequent intervals as well as on server shutdown.
* `minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing))`
    * Called when a node has been placed
    * If return `true` no item is taken from `itemstack`
    * `placer` may be any valid ObjectRef or nil.
    * **Not recommended**; use `on_construct` or `after_place_node` in node
      definition whenever possible.
* `minetest.register_on_dignode(function(pos, oldnode, digger))`
    * Called when a node has been dug.
    * **Not recommended**; Use `on_destruct` or `after_dig_node` in node
      definition whenever possible.
* `minetest.register_on_punchnode(function(pos, node, puncher, pointed_thing))`
    * Called when a node is punched
* `minetest.register_on_generated(function(minp, maxp, blockseed))`
    * Called after generating a piece of world. Modifying nodes inside the area
      is a bit faster than usually.
* `minetest.register_on_newplayer(function(ObjectRef))`
    * Called when a new player enters the world for the first time
* `minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage))`
    * Called when a player is punched
    * Note: This callback is invoked even if the punched player is dead.
    * `player`: ObjectRef - Player that was punched
    * `hitter`: ObjectRef - Player that hit
    * `time_from_last_punch`: Meant for disallowing spamming of clicks
      (can be nil).
    * `tool_capabilities`: Capability table of used item (can be nil)
    * `dir`: Unit vector of direction of punch. Always defined. Points from
      the puncher to the punched.
    * `damage`: Number that represents the damage calculated by the engine
    * should return `true` to prevent the default damage mechanism
* `minetest.register_on_rightclickplayer(function(player, clicker))`
    * Called when the 'place/use' key was used while pointing a player
      (not neccessarily an actual rightclick)
    * `player`: ObjectRef - Player that is acted upon
    * `clicker`: ObjectRef - Object that acted upon `player`, may or may not be a player
* `minetest.register_on_player_hpchange(function(player, hp_change, reason), modifier)`
    * Called when the player gets damaged or healed
    * `player`: ObjectRef of the player
    * `hp_change`: the amount of change. Negative when it is damage.
    * `reason`: a PlayerHPChangeReason table.
        * The `type` field will have one of the following values:
            * `set_hp`: A mod or the engine called `set_hp` without
                        giving a type - use this for custom damage types.
            * `punch`: Was punched. `reason.object` will hold the puncher, or nil if none.
            * `fall`
            * `node_damage`: `damage_per_second` from a neighbouring node.
                             `reason.node` will hold the node name or nil.
            * `drown`
            * `respawn`
        * Any of the above types may have additional fields from mods.
        * `reason.from` will be `mod` or `engine`.
    * `modifier`: when true, the function should return the actual `hp_change`.
       Note: modifiers only get a temporary `hp_change` that can be modified by later modifiers.
       Modifiers can return true as a second argument to stop the execution of further functions.
       Non-modifiers receive the final HP change calculated by the modifiers.
* `minetest.register_on_dieplayer(function(ObjectRef, reason))`
    * Called when a player dies
    * `reason`: a PlayerHPChangeReason table, see register_on_player_hpchange
* `minetest.register_on_respawnplayer(function(ObjectRef))`
    * Called when player is to be respawned
    * Called _before_ repositioning of player occurs
    * return true in func to disable regular player placement
* `minetest.register_on_prejoinplayer(function(name, ip))`
    * Called when a client connects to the server, prior to authentication
    * If it returns a string, the client is disconnected with that string as
      reason.
* `minetest.register_on_joinplayer(function(ObjectRef, last_login))`
    * Called when a player joins the game
    * `last_login`: The timestamp of the previous login, or nil if player is new
* `minetest.register_on_leaveplayer(function(ObjectRef, timed_out))`
    * Called when a player leaves the game
    * `timed_out`: True for timeout, false for other reasons.
* `minetest.register_on_authplayer(function(name, ip, is_success))`
    * Called when a client attempts to log into an account.
    * `name`: The name of the account being authenticated.
    * `ip`: The IP address of the client
    * `is_success`: Whether the client was successfully authenticated
    * For newly registered accounts, `is_success` will always be true
* `minetest.register_on_auth_fail(function(name, ip))`
    * Deprecated: use `minetest.register_on_authplayer(name, ip, is_success)` instead.
* `minetest.register_on_cheat(function(ObjectRef, cheat))`
    * Called when a player cheats
    * `cheat`: `{type=<cheat_type>}`, where `<cheat_type>` is one of:
        * `moved_too_fast`
        * `interacted_too_far`
        * `interacted_with_self`
        * `interacted_while_dead`
        * `finished_unknown_dig`
        * `dug_unbreakable`
        * `dug_too_fast`
* `minetest.register_on_chat_message(function(name, message))`
    * Called always when a player says something
    * Return `true` to mark the message as handled, which means that it will
      not be sent to other players.
* `minetest.register_on_chatcommand(function(name, command, params))`
    * Called always when a chatcommand is triggered, before `minetest.registered_chatcommands`
      is checked to see if the command exists, but after the input is parsed.
    * Return `true` to mark the command as handled, which means that the default
      handlers will be prevented.
* `minetest.register_on_player_receive_fields(function(player, formname, fields))`
    * Called when the server received input from `player` in a formspec with
      the given `formname`. Specifically, this is called on any of the
      following events:
          * a button was pressed,
          * Enter was pressed while the focus was on a text field
          * a checkbox was toggled,
          * something was selected in a dropdown list,
          * a different tab was selected,
          * selection was changed in a textlist or table,
          * an entry was double-clicked in a textlist or table,
          * a scrollbar was moved, or
          * the form was actively closed by the player.
    * Fields are sent for formspec elements which define a field. `fields`
      is a table containing each formspecs element value (as string), with
      the `name` parameter as index for each. The value depends on the
      formspec element type:
        * `animated_image`: Returns the index of the current frame.
        * `button` and variants: If pressed, contains the user-facing button
          text as value. If not pressed, is `nil`
        * `field`, `textarea` and variants: Text in the field
        * `dropdown`: Either the index or value, depending on the `index event`
          dropdown argument.
        * `tabheader`: Tab index, starting with `"1"` (only if tab changed)
        * `checkbox`: `"true"` if checked, `"false"` if unchecked
        * `textlist`: See `minetest.explode_textlist_event`
        * `table`: See `minetest.explode_table_event`
        * `scrollbar`: See `minetest.explode_scrollbar_event`
        * Special case: `["quit"]="true"` is sent when the user actively
          closed the form by mouse click, keypress or through a button_exit[]
          element.
        * Special case: `["key_enter"]="true"` is sent when the user pressed
          the Enter key and the focus was either nowhere (causing the formspec
          to be closed) or on a button. If the focus was on a text field,
          additionally, the index `key_enter_field` contains the name of the
          text field. See also: `field_close_on_enter`.
    * Newest functions are called first
    * If function returns `true`, remaining functions are not called
* `minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv))`
    * Called when `player` crafts something
    * `itemstack` is the output
    * `old_craft_grid` contains the recipe (Note: the one in the inventory is
      cleared).
    * `craft_inv` is the inventory with the crafting grid
    * Return either an `ItemStack`, to replace the output, or `nil`, to not
      modify it.
* `minetest.register_craft_predict(function(itemstack, player, old_craft_grid, craft_inv))`
    * The same as before, except that it is called before the player crafts, to
      make craft prediction, and it should not change anything.
* `minetest.register_allow_player_inventory_action(function(player, action, inventory, inventory_info))`
    * Determines how much of a stack may be taken, put or moved to a
      player inventory.
    * `player` (type `ObjectRef`) is the player who modified the inventory
      `inventory` (type `InvRef`).
    * List of possible `action` (string) values and their
      `inventory_info` (table) contents:
        * `move`: `{from_list=string, to_list=string, from_index=number, to_index=number, count=number}`
        * `put`:  `{listname=string, index=number, stack=ItemStack}`
        * `take`: Same as `put`
    * Return a numeric value to limit the amount of items to be taken, put or
      moved. A value of `-1` for `take` will make the source stack infinite.
* `minetest.register_on_player_inventory_action(function(player, action, inventory, inventory_info))`
    * Called after a take, put or move event from/to/in a player inventory
    * Function arguments: see `minetest.register_allow_player_inventory_action`
    * Does not accept or handle any return value.
* `minetest.register_on_protection_violation(function(pos, name))`
    * Called by `builtin` and mods when a player violates protection at a
      position (eg, digs a node or punches a protected entity).
    * The registered functions can be called using
      `minetest.record_protection_violation`.
    * The provided function should check that the position is protected by the
      mod calling this function before it prints a message, if it does, to
      allow for multiple protection mods.
* `minetest.register_on_item_eat(function(hp_change, replace_with_item, itemstack, user, pointed_thing))`
    * Called when an item is eaten, by `minetest.item_eat`
    * Return `itemstack` to cancel the default item eat response (i.e.: hp increase).
* `minetest.register_on_priv_grant(function(name, granter, priv))`
    * Called when `granter` grants the priv `priv` to `name`.
    * Note that the callback will be called twice if it's done by a player,
      once with granter being the player name, and again with granter being nil.
* `minetest.register_on_priv_revoke(function(name, revoker, priv))`
    * Called when `revoker` revokes the priv `priv` from `name`.
    * Note that the callback will be called twice if it's done by a player,
      once with revoker being the player name, and again with revoker being nil.
* `minetest.register_can_bypass_userlimit(function(name, ip))`
    * Called when `name` user connects with `ip`.
    * Return `true` to by pass the player limit
* `minetest.register_on_modchannel_message(function(channel_name, sender, message))`
    * Called when an incoming mod channel message is received
    * You should have joined some channels to receive events.
    * If message comes from a server mod, `sender` field is an empty string.
* `minetest.register_on_liquid_transformed(function(pos_list, node_list))`
    * Called after liquid nodes (`liquidtype ~= "none"`) are modified by the
      engine's liquid transformation process.
    * `pos_list` is an array of all modified positions.
    * `node_list` is an array of the old node that was previously at the position
      with the corresponding index in pos_list.

Setting-related
---------------

* `minetest.settings`: Settings object containing all of the settings from the
  main config file (`minetest.conf`).
* `minetest.setting_get_pos(name)`: Loads a setting from the main settings and
  parses it as a position (in the format `(1,2,3)`). Returns a position or nil.

Authentication
--------------

* `minetest.string_to_privs(str[, delim])`:
    * Converts string representation of privs into table form
    * `delim`: String separating the privs. Defaults to `","`.
    * Returns `{ priv1 = true, ... }`
* `minetest.privs_to_string(privs[, delim])`:
    * Returns the string representation of `privs`
    * `delim`: String to delimit privs. Defaults to `","`.
* `minetest.get_player_privs(name) -> {priv1=true,...}`
* `minetest.check_player_privs(player_or_name, ...)`:
  returns `bool, missing_privs`
    * A quickhand for checking privileges.
    * `player_or_name`: Either a Player object or the name of a player.
    * `...` is either a list of strings, e.g. `"priva", "privb"` or
      a table, e.g. `{ priva = true, privb = true }`.

* `minetest.check_password_entry(name, entry, password)`
    * Returns true if the "password entry" for a player with name matches given
      password, false otherwise.
    * The "password entry" is the password representation generated by the
      engine as returned as part of a `get_auth()` call on the auth handler.
    * Only use this function for making it possible to log in via password from
      external protocols such as IRC, other uses are frowned upon.
* `minetest.get_password_hash(name, raw_password)`
    * Convert a name-password pair to a password hash that Minetest can use.
    * The returned value alone is not a good basis for password checks based
      on comparing the password hash in the database with the password hash
      from the function, with an externally provided password, as the hash
      in the db might use the new SRP verifier format.
    * For this purpose, use `minetest.check_password_entry` instead.
* `minetest.get_player_ip(name)`: returns an IP address string for the player
  `name`.
    * The player needs to be online for this to be successful.

* `minetest.get_auth_handler()`: Return the currently active auth handler
    * See the [Authentication handler definition]
    * Use this to e.g. get the authentication data for a player:
      `local auth_data = minetest.get_auth_handler().get_auth(playername)`
* `minetest.notify_authentication_modified(name)`
    * Must be called by the authentication handler for privilege changes.
    * `name`: string; if omitted, all auth data should be considered modified
* `minetest.set_player_password(name, password_hash)`: Set password hash of
  player `name`.
* `minetest.set_player_privs(name, {priv1=true,...})`: Set privileges of player
  `name`.
* `minetest.auth_reload()`
    * See `reload()` in authentication handler definition

`minetest.set_player_password`, `minetest.set_player_privs`,
`minetest.get_player_privs` and `minetest.auth_reload` call the authentication
handler.

Chat
----

* `minetest.chat_send_all(text)`
* `minetest.chat_send_player(name, text)`
* `minetest.format_chat_message(name, message)`
    * Used by the server to format a chat message, based on the setting `chat_message_format`.
      Refer to the documentation of the setting for a list of valid placeholders.
    * Takes player name and message, and returns the formatted string to be sent to players.
    * Can be redefined by mods if required, for things like colored names or messages.
    * **Only** the first occurrence of each placeholder will be replaced.

Environment access
------------------

* `minetest.set_node(pos, node)`
* `minetest.add_node(pos, node)`: alias to `minetest.set_node`
    * Set node at position `pos`
    * `node`: table `{name=string, param1=number, param2=number}`
    * If param1 or param2 is omitted, it's set to `0`.
    * e.g. `minetest.set_node({x=0, y=10, z=0}, {name="default:wood"})`
* `minetest.bulk_set_node({pos1, pos2, pos3, ...}, node)`
    * Set node on all positions set in the first argument.
    * e.g. `minetest.bulk_set_node({{x=0, y=1, z=1}, {x=1, y=2, z=2}}, {name="default:stone"})`
    * For node specification or position syntax see `minetest.set_node` call
    * Faster than set_node due to single call, but still considerably slower
      than Lua Voxel Manipulators (LVM) for large numbers of nodes.
      Unlike LVMs, this will call node callbacks. It also allows setting nodes
      in spread out positions which would cause LVMs to waste memory.
      For setting a cube, this is 1.3x faster than set_node whereas LVM is 20
      times faster.
* `minetest.swap_node(pos, node)`
    * Set node at position, but don't remove metadata
* `minetest.remove_node(pos)`
    * By default it does the same as `minetest.set_node(pos, {name="air"})`
* `minetest.get_node(pos)`
    * Returns the node at the given position as table in the format
      `{name="node_name", param1=0, param2=0}`,
      returns `{name="ignore", param1=0, param2=0}` for unloaded areas.
* `minetest.get_node_or_nil(pos)`
    * Same as `get_node` but returns `nil` for unloaded areas.
* `minetest.get_node_light(pos, timeofday)`
    * Gets the light value at the given position. Note that the light value
      "inside" the node at the given position is returned, so you usually want
      to get the light value of a neighbor.
    * `pos`: The position where to measure the light.
    * `timeofday`: `nil` for current time, `0` for night, `0.5` for day
    * Returns a number between `0` and `15` or `nil`
    * `nil` is returned e.g. when the map isn't loaded at `pos`
* `minetest.get_natural_light(pos[, timeofday])`
    * Figures out the sunlight (or moonlight) value at pos at the given time of
      day.
    * `pos`: The position of the node
    * `timeofday`: `nil` for current time, `0` for night, `0.5` for day
    * Returns a number between `0` and `15` or `nil`
    * This function tests 203 nodes in the worst case, which happens very
      unlikely
* `minetest.get_artificial_light(param1)`
    * Calculates the artificial light (light from e.g. torches) value from the
      `param1` value.
    * `param1`: The param1 value of a `paramtype = "light"` node.
    * Returns a number between `0` and `15`
    * Currently it's the same as `math.floor(param1 / 16)`, except that it
      ensures compatibility.
* `minetest.place_node(pos, node)`
    * Place node with the same effects that a player would cause
* `minetest.dig_node(pos)`
    * Dig node with the same effects that a player would cause
    * Returns `true` if successful, `false` on failure (e.g. protected location)
* `minetest.punch_node(pos)`
    * Punch node with the same effects that a player would cause
* `minetest.spawn_falling_node(pos)`
    * Change node into falling node
    * Returns `true` and the ObjectRef of the spawned entity if successful, `false` on failure

* `minetest.find_nodes_with_meta(pos1, pos2)`
    * Get a table of positions of nodes that have metadata within a region
      {pos1, pos2}.
* `minetest.get_meta(pos)`
    * Get a `NodeMetaRef` at that position
* `minetest.get_node_timer(pos)`
    * Get `NodeTimerRef`

* `minetest.add_entity(pos, name, [staticdata])`: Spawn Lua-defined entity at
  position.
    * Returns `ObjectRef`, or `nil` if failed
* `minetest.add_item(pos, item)`: Spawn item
    * Returns `ObjectRef`, or `nil` if failed
* `minetest.get_player_by_name(name)`: Get an `ObjectRef` to a player
* `minetest.get_objects_inside_radius(pos, radius)`: returns a list of
  ObjectRefs.
    * `radius`: using an euclidean metric
* `minetest.get_objects_in_area(pos1, pos2)`: returns a list of
  ObjectRefs.
     * `pos1` and `pos2` are the min and max positions of the area to search.
* `minetest.set_timeofday(val)`
    * `val` is between `0` and `1`; `0` for midnight, `0.5` for midday
* `minetest.get_timeofday()`
* `minetest.get_gametime()`: returns the time, in seconds, since the world was
  created.
* `minetest.get_day_count()`: returns number days elapsed since world was
  created.
    * accounts for time changes.
* `minetest.find_node_near(pos, radius, nodenames, [search_center])`: returns
  pos or `nil`.
    * `radius`: using a maximum metric
    * `nodenames`: e.g. `{"ignore", "group:tree"}` or `"default:dirt"`
    * `search_center` is an optional boolean (default: `false`)
      If true `pos` is also checked for the nodes
* `minetest.find_nodes_in_area(pos1, pos2, nodenames, [grouped])`
    * `pos1` and `pos2` are the min and max positions of the area to search.
    * `nodenames`: e.g. `{"ignore", "group:tree"}` or `"default:dirt"`
    * If `grouped` is true the return value is a table indexed by node name
      which contains lists of positions.
    * If `grouped` is false or absent the return values are as follows:
      first value: Table with all node positions
      second value: Table with the count of each node with the node name
      as index
    * Area volume is limited to 4,096,000 nodes
* `minetest.find_nodes_in_area_under_air(pos1, pos2, nodenames)`: returns a
  list of positions.
    * `nodenames`: e.g. `{"ignore", "group:tree"}` or `"default:dirt"`
    * Return value: Table with all node positions with a node air above
    * Area volume is limited to 4,096,000 nodes
* `minetest.get_perlin(noiseparams)`
    * Return world-specific perlin noise.
    * The actual seed used is the noiseparams seed plus the world seed.
* `minetest.get_perlin(seeddiff, octaves, persistence, spread)`
    * Deprecated: use `minetest.get_perlin(noiseparams)` instead.
    * Return world-specific perlin noise.
* `minetest.get_voxel_manip([pos1, pos2])`
    * Return voxel manipulator object.
    * Loads the manipulator from the map if positions are passed.
* `minetest.set_gen_notify(flags, {deco_ids})`
    * Set the types of on-generate notifications that should be collected.
    * `flags` is a flag field with the available flags:
        * dungeon
        * temple
        * cave_begin
        * cave_end
        * large_cave_begin
        * large_cave_end
        * decoration
    * The second parameter is a list of IDs of decorations which notification
      is requested for.
* `minetest.get_gen_notify()`
    * Returns a flagstring and a table with the `deco_id`s.
* `minetest.get_decoration_id(decoration_name)`
    * Returns the decoration ID number for the provided decoration name string,
      or `nil` on failure.
* `minetest.get_mapgen_object(objectname)`
    * Return requested mapgen object if available (see [Mapgen objects])
* `minetest.get_heat(pos)`
    * Returns the heat at the position, or `nil` on failure.
* `minetest.get_humidity(pos)`
    * Returns the humidity at the position, or `nil` on failure.
* `minetest.get_biome_data(pos)`
    * Returns a table containing:
        * `biome` the biome id of the biome at that position
        * `heat` the heat at the position
        * `humidity` the humidity at the position
    * Or returns `nil` on failure.
* `minetest.get_biome_id(biome_name)`
    * Returns the biome id, as used in the biomemap Mapgen object and returned
      by `minetest.get_biome_data(pos)`, for a given biome_name string.
* `minetest.get_biome_name(biome_id)`
    * Returns the biome name string for the provided biome id, or `nil` on
      failure.
    * If no biomes have been registered, such as in mgv6, returns `default`.
* `minetest.get_mapgen_params()`
    * Deprecated: use `minetest.get_mapgen_setting(name)` instead.
    * Returns a table containing:
        * `mgname`
        * `seed`
        * `chunksize`
        * `water_level`
        * `flags`
* `minetest.set_mapgen_params(MapgenParams)`
    * Deprecated: use `minetest.set_mapgen_setting(name, value, override)`
      instead.
    * Set map generation parameters.
    * Function cannot be called after the registration period; only
      initialization and `on_mapgen_init`.
    * Takes a table as an argument with the fields:
        * `mgname`
        * `seed`
        * `chunksize`
        * `water_level`
        * `flags`
    * Leave field unset to leave that parameter unchanged.
    * `flags` contains a comma-delimited string of flags to set, or if the
      prefix `"no"` is attached, clears instead.
    * `flags` is in the same format and has the same options as `mg_flags` in
      `minetest.conf`.
* `minetest.get_mapgen_setting(name)`
    * Gets the *active* mapgen setting (or nil if none exists) in string
      format with the following order of precedence:
        1) Settings loaded from map_meta.txt or overrides set during mod
           execution.
        2) Settings set by mods without a metafile override
        3) Settings explicitly set in the user config file, minetest.conf
        4) Settings set as the user config default
* `minetest.get_mapgen_setting_noiseparams(name)`
    * Same as above, but returns the value as a NoiseParams table if the
      setting `name` exists and is a valid NoiseParams.
* `minetest.set_mapgen_setting(name, value, [override_meta])`
    * Sets a mapgen param to `value`, and will take effect if the corresponding
      mapgen setting is not already present in map_meta.txt.
    * `override_meta` is an optional boolean (default: `false`). If this is set
      to true, the setting will become the active setting regardless of the map
      metafile contents.
    * Note: to set the seed, use `"seed"`, not `"fixed_map_seed"`.
* `minetest.set_mapgen_setting_noiseparams(name, value, [override_meta])`
    * Same as above, except value is a NoiseParams table.
* `minetest.set_noiseparams(name, noiseparams, set_default)`
    * Sets the noiseparams setting of `name` to the noiseparams table specified
      in `noiseparams`.
    * `set_default` is an optional boolean (default: `true`) that specifies
      whether the setting should be applied to the default config or current
      active config.
* `minetest.get_noiseparams(name)`
    * Returns a table of the noiseparams for name.
* `minetest.generate_ores(vm, pos1, pos2)`
    * Generate all registered ores within the VoxelManip `vm` and in the area
      from `pos1` to `pos2`.
    * `pos1` and `pos2` are optional and default to mapchunk minp and maxp.
* `minetest.generate_decorations(vm, pos1, pos2)`
    * Generate all registered decorations within the VoxelManip `vm` and in the
      area from `pos1` to `pos2`.
    * `pos1` and `pos2` are optional and default to mapchunk minp and maxp.
* `minetest.clear_objects([options])`
    * Clear all objects in the environment
    * Takes an optional table as an argument with the field `mode`.
        * mode = `"full"` : Load and go through every mapblock, clearing
                            objects (default).
        * mode = `"quick"`: Clear objects immediately in loaded mapblocks,
                            clear objects in unloaded mapblocks only when the
                            mapblocks are next activated.
* `minetest.load_area(pos1[, pos2])`
    * Load the mapblocks containing the area from `pos1` to `pos2`.
      `pos2` defaults to `pos1` if not specified.
    * This function does not trigger map generation.
* `minetest.emerge_area(pos1, pos2, [callback], [param])`
    * Queue all blocks in the area from `pos1` to `pos2`, inclusive, to be
      asynchronously fetched from memory, loaded from disk, or if inexistent,
      generates them.
    * If `callback` is a valid Lua function, this will be called for each block
      emerged.
    * The function signature of callback is:
      `function EmergeAreaCallback(blockpos, action, calls_remaining, param)`
        * `blockpos` is the *block* coordinates of the block that had been
          emerged.
        * `action` could be one of the following constant values:
            * `minetest.EMERGE_CANCELLED`
            * `minetest.EMERGE_ERRORED`
            * `minetest.EMERGE_FROM_MEMORY`
            * `minetest.EMERGE_FROM_DISK`
            * `minetest.EMERGE_GENERATED`
        * `calls_remaining` is the number of callbacks to be expected after
          this one.
        * `param` is the user-defined parameter passed to emerge_area (or
          nil if the parameter was absent).
* `minetest.delete_area(pos1, pos2)`
    * delete all mapblocks in the area from pos1 to pos2, inclusive
* `minetest.line_of_sight(pos1, pos2)`: returns `boolean, pos`
    * Checks if there is anything other than air between pos1 and pos2.
    * Returns false if something is blocking the sight.
    * Returns the position of the blocking node when `false`
    * `pos1`: First position
    * `pos2`: Second position
* `minetest.raycast(pos1, pos2, objects, liquids)`: returns `Raycast`
    * Creates a `Raycast` object.
    * `pos1`: start of the ray
    * `pos2`: end of the ray
    * `objects`: if false, only nodes will be returned. Default is `true`.
    * `liquids`: if false, liquid nodes (`liquidtype ~= "none"`) won't be
                 returned. Default is `false`.
* `minetest.find_path(pos1,pos2,searchdistance,max_jump,max_drop,algorithm)`
    * returns table containing path that can be walked on
    * returns a table of 3D points representing a path from `pos1` to `pos2` or
      `nil` on failure.
    * Reasons for failure:
        * No path exists at all
        * No path exists within `searchdistance` (see below)
        * Start or end pos is buried in land
    * `pos1`: start position
    * `pos2`: end position
    * `searchdistance`: maximum distance from the search positions to search in.
      In detail: Path must be completely inside a cuboid. The minimum
      `searchdistance` of 1 will confine search between `pos1` and `pos2`.
      Larger values will increase the size of this cuboid in all directions
    * `max_jump`: maximum height difference to consider walkable
    * `max_drop`: maximum height difference to consider droppable
    * `algorithm`: One of `"A*_noprefetch"` (default), `"A*"`, `"Dijkstra"`.
      Difference between `"A*"` and `"A*_noprefetch"` is that
      `"A*"` will pre-calculate the cost-data, the other will calculate it
      on-the-fly
* `minetest.spawn_tree (pos, {treedef})`
    * spawns L-system tree at given `pos` with definition in `treedef` table
* `minetest.transforming_liquid_add(pos)`
    * add node to liquid flow update queue
* `minetest.get_node_max_level(pos)`
    * get max available level for leveled node
* `minetest.get_node_level(pos)`
    * get level of leveled node (water, snow)
* `minetest.set_node_level(pos, level)`
    * set level of leveled node, default `level` equals `1`
    * if `totallevel > maxlevel`, returns rest (`total-max`).
* `minetest.add_node_level(pos, level)`
    * increase level of leveled node by level, default `level` equals `1`
    * if `totallevel > maxlevel`, returns rest (`total-max`)
    * `level` must be between -127 and 127
* `minetest.fix_light(pos1, pos2)`: returns `true`/`false`
    * resets the light in a cuboid-shaped part of
      the map and removes lighting bugs.
    * Loads the area if it is not loaded.
    * `pos1` is the corner of the cuboid with the least coordinates
      (in node coordinates), inclusive.
    * `pos2` is the opposite corner of the cuboid, inclusive.
    * The actual updated cuboid might be larger than the specified one,
      because only whole map blocks can be updated.
      The actual updated area consists of those map blocks that intersect
      with the given cuboid.
    * However, the neighborhood of the updated area might change
      as well, as light can spread out of the cuboid, also light
      might be removed.
    * returns `false` if the area is not fully generated,
      `true` otherwise
* `minetest.check_single_for_falling(pos)`
    * causes an unsupported `group:falling_node` node to fall and causes an
      unattached `group:attached_node` node to fall.
    * does not spread these updates to neighbours.
* `minetest.check_for_falling(pos)`
    * causes an unsupported `group:falling_node` node to fall and causes an
      unattached `group:attached_node` node to fall.
    * spread these updates to neighbours and can cause a cascade
      of nodes to fall.
* `minetest.get_spawn_level(x, z)`
    * Returns a player spawn y co-ordinate for the provided (x, z)
      co-ordinates, or `nil` for an unsuitable spawn point.
    * For most mapgens a 'suitable spawn point' is one with y between
      `water_level` and `water_level + 16`, and in mgv7 well away from rivers,
      so `nil` will be returned for many (x, z) co-ordinates.
    * The spawn level returned is for a player spawn in unmodified terrain.
    * The spawn level is intentionally above terrain level to cope with
      full-node biome 'dust' nodes.

Mod channels
------------

You can find mod channels communication scheme in `doc/mod_channels.png`.

* `minetest.mod_channel_join(channel_name)`
    * Server joins channel `channel_name`, and creates it if necessary. You
      should listen for incoming messages with
      `minetest.register_on_modchannel_message`

Inventory
---------

`minetest.get_inventory(location)`: returns an `InvRef`

* `location` = e.g.
    * `{type="player", name="celeron55"}`
    * `{type="node", pos={x=, y=, z=}}`
    * `{type="detached", name="creative"}`
* `minetest.create_detached_inventory(name, callbacks, [player_name])`: returns
  an `InvRef`.
    * `callbacks`: See [Detached inventory callbacks]
    * `player_name`: Make detached inventory available to one player
      exclusively, by default they will be sent to every player (even if not
      used).
      Note that this parameter is mostly just a workaround and will be removed
      in future releases.
    * Creates a detached inventory. If it already exists, it is cleared.
* `minetest.remove_detached_inventory(name)`
    * Returns a `boolean` indicating whether the removal succeeded.
* `minetest.do_item_eat(hp_change, replace_with_item, itemstack, user, pointed_thing)`:
  returns leftover ItemStack or nil to indicate no inventory change
    * See `minetest.item_eat` and `minetest.register_on_item_eat`

Formspec
--------

* `minetest.show_formspec(playername, formname, formspec)`
    * `playername`: name of player to show formspec
    * `formname`: name passed to `on_player_receive_fields` callbacks.
      It should follow the `"modname:<whatever>"` naming convention
    * `formspec`: formspec to display
* `minetest.close_formspec(playername, formname)`
    * `playername`: name of player to close formspec
    * `formname`: has to exactly match the one given in `show_formspec`, or the
      formspec will not close.
    * calling `show_formspec(playername, formname, "")` is equal to this
      expression.
    * to close a formspec regardless of the formname, call
      `minetest.close_formspec(playername, "")`.
      **USE THIS ONLY WHEN ABSOLUTELY NECESSARY!**
* `minetest.formspec_escape(string)`: returns a string
    * escapes the characters "[", "]", "\", "," and ";", which can not be used
      in formspecs.
* `minetest.explode_table_event(string)`: returns a table
    * returns e.g. `{type="CHG", row=1, column=2}`
    * `type` is one of:
        * `"INV"`: no row selected
        * `"CHG"`: selected
        * `"DCL"`: double-click
* `minetest.explode_textlist_event(string)`: returns a table
    * returns e.g. `{type="CHG", index=1}`
    * `type` is one of:
        * `"INV"`: no row selected
        * `"CHG"`: selected
        * `"DCL"`: double-click
* `minetest.explode_scrollbar_event(string)`: returns a table
    * returns e.g. `{type="CHG", value=500}`
    * `type` is one of:
        * `"INV"`: something failed
        * `"CHG"`: has been changed
        * `"VAL"`: not changed

Item handling
-------------

* `minetest.inventorycube(img1, img2, img3)`
    * Returns a string for making an image of a cube (useful as an item image)
* `minetest.get_pointed_thing_position(pointed_thing, above)`
    * Returns the position of a `pointed_thing` or `nil` if the `pointed_thing`
      does not refer to a node or entity.
    * If the optional `above` parameter is true and the `pointed_thing` refers
      to a node, then it will return the `above` position of the `pointed_thing`.
* `minetest.dir_to_facedir(dir, is6d)`
    * Convert a vector to a facedir value, used in `param2` for
      `paramtype2="facedir"`.
    * passing something non-`nil`/`false` for the optional second parameter
      causes it to take the y component into account.
* `minetest.facedir_to_dir(facedir)`
    * Convert a facedir back into a vector aimed directly out the "back" of a
      node.
* `minetest.dir_to_wallmounted(dir)`
    * Convert a vector to a wallmounted value, used for
      `paramtype2="wallmounted"`.
* `minetest.wallmounted_to_dir(wallmounted)`
    * Convert a wallmounted value back into a vector aimed directly out the
      "back" of a node.
* `minetest.dir_to_yaw(dir)`
    * Convert a vector into a yaw (angle)
* `minetest.yaw_to_dir(yaw)`
    * Convert yaw (angle) to a vector
* `minetest.is_colored_paramtype(ptype)`
    * Returns a boolean. Returns `true` if the given `paramtype2` contains
      color information (`color`, `colorwallmounted` or `colorfacedir`).
* `minetest.strip_param2_color(param2, paramtype2)`
    * Removes everything but the color information from the
      given `param2` value.
    * Returns `nil` if the given `paramtype2` does not contain color
      information.
* `minetest.get_node_drops(node, toolname)`
    * Returns list of itemstrings that are dropped by `node` when dug
      with the item `toolname` (not limited to tools).
    * `node`: node as table or node name
    * `toolname`: name of the item used to dig (can be `nil`)
* `minetest.get_craft_result(input)`: returns `output, decremented_input`
    * `input.method` = `"normal"` or `"cooking"` or `"fuel"`
    * `input.width` = for example `3`
    * `input.items` = for example
      `{stack1, stack2, stack3, stack4, stack 5, stack 6, stack 7, stack 8, stack 9}`
    * `output.item` = `ItemStack`, if unsuccessful: empty `ItemStack`
    * `output.time` = a number, if unsuccessful: `0`
    * `output.replacements` = List of replacement `ItemStack`s that couldn't be
      placed in `decremented_input.items`. Replacements can be placed in
      `decremented_input` if the stack of the replaced item has a count of 1.
    * `decremented_input` = like `input`
* `minetest.get_craft_recipe(output)`: returns input
    * returns last registered recipe for output item (node)
    * `output` is a node or item type such as `"default:torch"`
    * `input.method` = `"normal"` or `"cooking"` or `"fuel"`
    * `input.width` = for example `3`
    * `input.items` = for example
      `{stack1, stack2, stack3, stack4, stack 5, stack 6, stack 7, stack 8, stack 9}`
        * `input.items` = `nil` if no recipe found
* `minetest.get_all_craft_recipes(query item)`: returns a table or `nil`
    * returns indexed table with all registered recipes for query item (node)
      or `nil` if no recipe was found.
    * recipe entry table:
        * `method`: 'normal' or 'cooking' or 'fuel'
        * `width`: 0-3, 0 means shapeless recipe
        * `items`: indexed [1-9] table with recipe items
        * `output`: string with item name and quantity
    * Example query for `"default:gold_ingot"` will return table:

          {
              [1]={method = "cooking", width = 3, output = "default:gold_ingot",
              items = {1 = "default:gold_lump"}},
              [2]={method = "normal", width = 1, output = "default:gold_ingot 9",
              items = {1 = "default:goldblock"}}
          }
* `minetest.handle_node_drops(pos, drops, digger)`
    * `drops`: list of itemstrings
    * Handles drops from nodes after digging: Default action is to put them
      into digger's inventory.
    * Can be overridden to get different functionality (e.g. dropping items on
      ground)
* `minetest.itemstring_with_palette(item, palette_index)`: returns an item
  string.
    * Creates an item string which contains palette index information
      for hardware colorization. You can use the returned string
      as an output in a craft recipe.
    * `item`: the item stack which becomes colored. Can be in string,
      table and native form.
    * `palette_index`: this index is added to the item stack
* `minetest.itemstring_with_color(item, colorstring)`: returns an item string
    * Creates an item string which contains static color information
      for hardware colorization. Use this method if you wish to colorize
      an item that does not own a palette. You can use the returned string
      as an output in a craft recipe.
    * `item`: the item stack which becomes colored. Can be in string,
      table and native form.
    * `colorstring`: the new color of the item stack

Rollback
--------

* `minetest.rollback_get_node_actions(pos, range, seconds, limit)`:
  returns `{{actor, pos, time, oldnode, newnode}, ...}`
    * Find who has done something to a node, or near a node
    * `actor`: `"player:<name>"`, also `"liquid"`.
* `minetest.rollback_revert_actions_by(actor, seconds)`: returns
  `boolean, log_messages`.
    * Revert latest actions of someone
    * `actor`: `"player:<name>"`, also `"liquid"`.

Defaults for the `on_place` and `on_drop` item definition functions
-------------------------------------------------------------------

* `minetest.item_place_node(itemstack, placer, pointed_thing[, param2, prevent_after_place])`
    * Place item as a node
    * `param2` overrides `facedir` and wallmounted `param2`
    * `prevent_after_place`: if set to `true`, `after_place_node` is not called
      for the newly placed node to prevent a callback and placement loop
    * returns `itemstack, position`
      * `position`: the location the node was placed to. `nil` if nothing was placed.
* `minetest.item_place_object(itemstack, placer, pointed_thing)`
    * Place item as-is
    * returns the leftover itemstack
    * **Note**: This function is deprecated and will never be called.
* `minetest.item_place(itemstack, placer, pointed_thing[, param2])`
    * Wrapper that calls `minetest.item_place_node` if appropriate
    * Calls `on_rightclick` of `pointed_thing.under` if defined instead
    * **Note**: is not called when wielded item overrides `on_place`
    * `param2` overrides facedir and wallmounted `param2`
    * returns `itemstack, position`
      * `position`: the location the node was placed to. `nil` if nothing was placed.
* `minetest.item_drop(itemstack, dropper, pos)`
    * Drop the item
    * returns the leftover itemstack
* `minetest.item_eat(hp_change[, replace_with_item])`
    * Returns `function(itemstack, user, pointed_thing)` as a
      function wrapper for `minetest.do_item_eat`.
    * `replace_with_item` is the itemstring which is added to the inventory.
      If the player is eating a stack, then replace_with_item goes to a
      different spot.

Defaults for the `on_punch` and `on_dig` node definition callbacks
------------------------------------------------------------------

* `minetest.node_punch(pos, node, puncher, pointed_thing)`
    * Calls functions registered by `minetest.register_on_punchnode()`
* `minetest.node_dig(pos, node, digger)`
    * Checks if node can be dug, puts item into inventory, removes node
    * Calls functions registered by `minetest.registered_on_dignodes()`

Sounds
------

* `minetest.sound_play(spec, parameters, [ephemeral])`: returns a handle
    * `spec` is a `SimpleSoundSpec`
    * `parameters` is a sound parameter table
    * `ephemeral` is a boolean (default: false)
      Ephemeral sounds will not return a handle and can't be stopped or faded.
      It is recommend to use this for short sounds that happen in response to
      player actions (e.g. door closing).
* `minetest.sound_stop(handle)`
    * `handle` is a handle returned by `minetest.sound_play`
* `minetest.sound_fade(handle, step, gain)`
    * `handle` is a handle returned by `minetest.sound_play`
    * `step` determines how fast a sound will fade.
      The gain will change by this much per second,
      until it reaches the target gain.
      Note: Older versions used a signed step. This is deprecated, but old
      code will still work. (the client uses abs(step) to correct it)
    * `gain` the target gain for the fade.
      Fading to zero will delete the sound.

Timing
------

* `minetest.after(time, func, ...)` : returns job table to use as below.
    * Call the function `func` after `time` seconds, may be fractional
    * Optional: Variable number of arguments that are passed to `func`

* `job:cancel()`
    * Cancels the job function from being called

Async environment
-----------------

The engine allows you to submit jobs to be ran in an isolated environment
concurrently with normal server operation.
A job consists of a function to be ran in the async environment, any amount of
arguments (will be serialized) and a callback that will be called with the return
value of the job function once it is finished.

The async environment does *not* have access to the map, entities, players or any
globals defined in the 'usual' environment. Consequently, functions like
`minetest.get_node()` or `minetest.get_player_by_name()` simply do not exist in it.

Arguments and return values passed through this can contain certain userdata
objects that will be seamlessly copied (not shared) to the async environment.
This allows you easy interoperability for delegating work to jobs.

* `minetest.handle_async(func, callback, ...)`:
    * Queue the function `func` to be ran in an async environment.
      Note that there are multiple persistent workers and any of them may
      end up running a given job. The engine will scale the amount of
      worker threads automatically.
    * When `func` returns the callback is called (in the normal environment)
      with all of the return values as arguments.
    * Optional: Variable number of arguments that are passed to `func`
* `minetest.register_async_dofile(path)`:
    * Register a path to a Lua file to be imported when an async environment
      is initialized. You can use this to preload code which you can then call
      later using `minetest.handle_async()`.

### List of APIs available in an async environment

Classes:
* `ItemStack`
* `PerlinNoise`
* `PerlinNoiseMap`
* `PseudoRandom`
* `PcgRandom`
* `SecureRandom`
* `VoxelArea`
* `VoxelManip`
    * only if transferred into environment; can't read/write to map
* `Settings`

Class instances that can be transferred between environments:
* `ItemStack`
* `PerlinNoise`
* `PerlinNoiseMap`
* `VoxelManip`

Functions:
* Standalone helpers such as logging, filesystem, encoding,
  hashing or compression APIs
* `minetest.request_insecure_environment` (same restrictions apply)

Variables:
* `minetest.settings`
* `minetest.registered_items`, `registered_nodes`, `registered_tools`,
  `registered_craftitems` and `registered_aliases`
    * with all functions and userdata values replaced by `true`, calling any
      callbacks here is obviously not possible

Server
------

* `minetest.request_shutdown([message],[reconnect],[delay])`: request for
  server shutdown. Will display `message` to clients.
    * `reconnect` == true displays a reconnect button
    * `delay` adds an optional delay (in seconds) before shutdown.
      Negative delay cancels the current active shutdown.
      Zero delay triggers an immediate shutdown.
* `minetest.cancel_shutdown_requests()`: cancel current delayed shutdown
* `minetest.get_server_status(name, joined)`
    * Returns the server status string when a player joins or when the command
      `/status` is called. Returns `nil` or an empty string when the message is
      disabled.
    * `joined`: Boolean value, indicates whether the function was called when
      a player joined.
    * This function may be overwritten by mods to customize the status message.
* `minetest.get_server_uptime()`: returns the server uptime in seconds
* `minetest.get_server_max_lag()`: returns the current maximum lag
  of the server in seconds or nil if server is not fully loaded yet
* `minetest.remove_player(name)`: remove player from database (if they are not
  connected).
    * As auth data is not removed, minetest.player_exists will continue to
      return true. Call the below method as well if you want to remove auth
      data too.
    * Returns a code (0: successful, 1: no such player, 2: player is connected)
* `minetest.remove_player_auth(name)`: remove player authentication data
    * Returns boolean indicating success (false if player nonexistant)
* `minetest.dynamic_add_media(options, callback)`
    * `options`: table containing the following parameters
        * `filepath`: path to a media file on the filesystem
        * `to_player`: name of the player the media should be sent to instead of
                       all players (optional)
        * `ephemeral`: boolean that marks the media as ephemeral,
                       it will not be cached on the client (optional, default false)
    * `callback`: function with arguments `name`, which is a player name
    * Pushes the specified media file to client(s). (details below)
      The file must be a supported image, sound or model format.
      Dynamically added media is not persisted between server restarts.
    * Returns false on error, true if the request was accepted
    * The given callback will be called for every player as soon as the
      media is available on the client.
    * Details/Notes:
      * If `ephemeral`=false and `to_player` is unset the file is added to the media
        sent to clients on startup, this means the media will appear even on
        old clients if they rejoin the server.
      * If `ephemeral`=false the file must not be modified, deleted, moved or
        renamed after calling this function.
      * Regardless of any use of `ephemeral`, adding media files with the same
        name twice is not possible/guaranteed to work. An exception to this is the
        use of `to_player` to send the same, already existent file to multiple
        chosen players.
    * Clients will attempt to fetch files added this way via remote media,
      this can make transfer of bigger files painless (if set up). Nevertheless
      it is advised not to use dynamic media for big media files.

Bans
----

* `minetest.get_ban_list()`: returns a list of all bans formatted as string
* `minetest.get_ban_description(ip_or_name)`: returns list of bans matching
  IP address or name formatted as string
* `minetest.ban_player(name)`: ban the IP of a currently connected player
    * Returns boolean indicating success
* `minetest.unban_player_or_ip(ip_or_name)`: remove ban record matching
  IP address or name
* `minetest.kick_player(name, [reason])`: disconnect a player with an optional
  reason.
    * Returns boolean indicating success (false if player nonexistant)
* `minetest.disconnect_player(name, [reason])`: disconnect a player with an
  optional reason, this will not prefix with 'Kicked: ' like kick_player.
  If no reason is given, it will default to 'Disconnected.'
    * Returns boolean indicating success (false if player nonexistant)

Particles
---------

* `minetest.add_particle(particle definition)`
    * Deprecated: `minetest.add_particle(pos, velocity, acceleration,
      expirationtime, size, collisiondetection, texture, playername)`

* `minetest.add_particlespawner(particlespawner definition)`
    * Add a `ParticleSpawner`, an object that spawns an amount of particles
      over `time` seconds.
    * Returns an `id`, and -1 if adding didn't succeed
    * Deprecated: `minetest.add_particlespawner(amount, time,
      minpos, maxpos,
      minvel, maxvel,
      minacc, maxacc,
      minexptime, maxexptime,
      minsize, maxsize,
      collisiondetection, texture, playername)`

* `minetest.delete_particlespawner(id, player)`
    * Delete `ParticleSpawner` with `id` (return value from
      `minetest.add_particlespawner`).
    * If playername is specified, only deletes on the player's client,
      otherwise on all clients.

Schematics
----------

* `minetest.create_schematic(p1, p2, probability_list, filename, slice_prob_list)`
    * Create a schematic from the volume of map specified by the box formed by
      p1 and p2.
    * Apply the specified probability and per-node force-place to the specified
      nodes according to the `probability_list`.
        * `probability_list` is an array of tables containing two fields, `pos`
          and `prob`.
            * `pos` is the 3D vector specifying the absolute coordinates of the
              node being modified,
            * `prob` is an integer value from `0` to `255` that encodes
              probability and per-node force-place. Probability has levels
              0-127, then 128 may be added to encode per-node force-place.
              For probability stated as 0-255, divide by 2 and round down to
              get values 0-127, then add 128 to apply per-node force-place.
            * If there are two or more entries with the same pos value, the
              last entry is used.
            * If `pos` is not inside the box formed by `p1` and `p2`, it is
              ignored.
            * If `probability_list` equals `nil`, no probabilities are applied.
    * Apply the specified probability to the specified horizontal slices
      according to the `slice_prob_list`.
        * `slice_prob_list` is an array of tables containing two fields, `ypos`
          and `prob`.
            * `ypos` indicates the y position of the slice with a probability
              applied, the lowest slice being `ypos = 0`.
            * If slice probability list equals `nil`, no slice probabilities
              are applied.
    * Saves schematic in the Minetest Schematic format to filename.

* `minetest.place_schematic(pos, schematic, rotation, replacements, force_placement, flags)`
    * Place the schematic specified by schematic (see [Schematic specifier]) at
      `pos`.
    * `rotation` can equal `"0"`, `"90"`, `"180"`, `"270"`, or `"random"`.
    * If the `rotation` parameter is omitted, the schematic is not rotated.
    * `replacements` = `{["old_name"] = "convert_to", ...}`
    * `force_placement` is a boolean indicating whether nodes other than `air`
      and `ignore` are replaced by the schematic.
    * Returns nil if the schematic could not be loaded.
    * **Warning**: Once you have loaded a schematic from a file, it will be
      cached. Future calls will always use the cached version and the
      replacement list defined for it, regardless of whether the file or the
      replacement list parameter have changed. The only way to load the file
      anew is to restart the server.
    * `flags` is a flag field with the available flags:
        * place_center_x
        * place_center_y
        * place_center_z

* `minetest.place_schematic_on_vmanip(vmanip, pos, schematic, rotation, replacement, force_placement, flags)`:
    * This function is analogous to minetest.place_schematic, but places a
      schematic onto the specified VoxelManip object `vmanip` instead of the
      map.
    * Returns false if any part of the schematic was cut-off due to the
      VoxelManip not containing the full area required, and true if the whole
      schematic was able to fit.
    * Returns nil if the schematic could not be loaded.
    * After execution, any external copies of the VoxelManip contents are
      invalidated.
    * `flags` is a flag field with the available flags:
        * place_center_x
        * place_center_y
        * place_center_z

* `minetest.serialize_schematic(schematic, format, options)`
    * Return the serialized schematic specified by schematic
      (see [Schematic specifier])
    * in the `format` of either "mts" or "lua".
    * "mts" - a string containing the binary MTS data used in the MTS file
      format.
    * "lua" - a string containing Lua code representing the schematic in table
      format.
    * `options` is a table containing the following optional parameters:
        * If `lua_use_comments` is true and `format` is "lua", the Lua code
          generated will have (X, Z) position comments for every X row
          generated in the schematic data for easier reading.
        * If `lua_num_indent_spaces` is a nonzero number and `format` is "lua",
          the Lua code generated will use that number of spaces as indentation
          instead of a tab character.

* `minetest.read_schematic(schematic, options)`
    * Returns a Lua table representing the schematic (see: [Schematic specifier])
    * `schematic` is the schematic to read (see: [Schematic specifier])
    * `options` is a table containing the following optional parameters:
        * `write_yslice_prob`: string value:
            * `none`: no `write_yslice_prob` table is inserted,
            * `low`: only probabilities that are not 254 or 255 are written in
              the `write_ylisce_prob` table,
            * `all`: write all probabilities to the `write_yslice_prob` table.
            * The default for this option is `all`.
            * Any invalid value will be interpreted as `all`.

HTTP Requests
-------------

* `minetest.request_http_api()`:
    * returns `HTTPApiTable` containing http functions if the calling mod has
      been granted access by being listed in the `secure.http_mods` or
      `secure.trusted_mods` setting, otherwise returns `nil`.
    * The returned table contains the functions `fetch`, `fetch_async` and
      `fetch_async_get` described below.
    * Only works at init time and must be called from the mod's main scope
      (not from a function).
    * Function only exists if minetest server was built with cURL support.
    * **DO NOT ALLOW ANY OTHER MODS TO ACCESS THE RETURNED TABLE, STORE IT IN
      A LOCAL VARIABLE!**
* `HTTPApiTable.fetch(HTTPRequest req, callback)`
    * Performs given request asynchronously and calls callback upon completion
    * callback: `function(HTTPRequestResult res)`
    * Use this HTTP function if you are unsure, the others are for advanced use
* `HTTPApiTable.fetch_async(HTTPRequest req)`: returns handle
    * Performs given request asynchronously and returns handle for
      `HTTPApiTable.fetch_async_get`
* `HTTPApiTable.fetch_async_get(handle)`: returns HTTPRequestResult
    * Return response data for given asynchronous HTTP request

Storage API
-----------

* `minetest.get_mod_storage()`:
    * returns reference to mod private `StorageRef`
    * must be called during mod load time

Misc.
-----

* `minetest.get_connected_players()`: returns list of `ObjectRefs`
* `minetest.is_player(obj)`: boolean, whether `obj` is a player
* `minetest.player_exists(name)`: boolean, whether player exists
  (regardless of online status)
* `minetest.hud_replace_builtin(name, hud_definition)`
    * Replaces definition of a builtin hud element
    * `name`: `"breath"` or `"health"`
    * `hud_definition`: definition to replace builtin definition
* `minetest.send_join_message(player_name)`
    * This function can be overridden by mods to change the join message.
* `minetest.send_leave_message(player_name, timed_out)`
    * This function can be overridden by mods to change the leave message.
* `minetest.hash_node_position(pos)`: returns an 48-bit integer
    * `pos`: table {x=number, y=number, z=number},
    * Gives a unique hash number for a node position (16+16+16=48bit)
* `minetest.get_position_from_hash(hash)`: returns a position
    * Inverse transform of `minetest.hash_node_position`
* `minetest.get_item_group(name, group)`: returns a rating
    * Get rating of a group of an item. (`0` means: not in group)
* `minetest.get_node_group(name, group)`: returns a rating
    * Deprecated: An alias for the former.
* `minetest.raillike_group(name)`: returns a rating
    * Returns rating of the connect_to_raillike group corresponding to name
    * If name is not yet the name of a connect_to_raillike group, a new group
      id is created, with that name.
* `minetest.get_content_id(name)`: returns an integer
    * Gets the internal content ID of `name`
* `minetest.get_name_from_content_id(content_id)`: returns a string
    * Gets the name of the content with that content ID
* `minetest.parse_json(string[, nullvalue])`: returns something
    * Convert a string containing JSON data into the Lua equivalent
    * `nullvalue`: returned in place of the JSON null; defaults to `nil`
    * On success returns a table, a string, a number, a boolean or `nullvalue`
    * On failure outputs an error message and returns `nil`
    * Example: `parse_json("[10, {\"a\":false}]")`, returns `{10, {a = false}}`
* `minetest.write_json(data[, styled])`: returns a string or `nil` and an error
  message.
    * Convert a Lua table into a JSON string
    * styled: Outputs in a human-readable format if this is set, defaults to
      false.
    * Unserializable things like functions and userdata will cause an error.
    * **Warning**: JSON is more strict than the Lua table format.
        1. You can only use strings and positive integers of at least one as
           keys.
        2. You can not mix string and integer keys.
           This is due to the fact that JSON has two distinct array and object
           values.
    * Example: `write_json({10, {a = false}})`,
      returns `'[10, {"a": false}]'`
* `minetest.serialize(table)`: returns a string
    * Convert a table containing tables, strings, numbers, booleans and `nil`s
      into string form readable by `minetest.deserialize`
    * Example: `serialize({foo="bar"})`, returns `'return { ["foo"] = "bar" }'`
* `minetest.deserialize(string[, safe])`: returns a table
    * Convert a string returned by `minetest.serialize` into a table
    * `string` is loaded in an empty sandbox environment.
    * Will load functions if safe is false or omitted. Although these functions
      cannot directly access the global environment, they could bypass this
      restriction with maliciously crafted Lua bytecode if mod security is
      disabled.
    * This function should not be used on untrusted data, regardless of the
     value of `safe`. It is fine to serialize then deserialize user-provided
     data, but directly providing user input to deserialize is always unsafe.
    * Example: `deserialize('return { ["foo"] = "bar" }')`,
      returns `{foo="bar"}`
    * Example: `deserialize('print("foo")')`, returns `nil`
      (function call fails), returns
      `error:[string "print("foo")"]:1: attempt to call global 'print' (a nil value)`
* `minetest.compress(data, method, ...)`: returns `compressed_data`
    * Compress a string of data.
    * `method` is a string identifying the compression method to be used.
    * Supported compression methods:
        * Deflate (zlib): `"deflate"`
    * `...` indicates method-specific arguments. Currently defined arguments
      are:
        * Deflate: `level` - Compression level, `0`-`9` or `nil`.
* `minetest.decompress(compressed_data, method, ...)`: returns data
    * Decompress a string of data (using ZLib).
    * See documentation on `minetest.compress()` for supported compression
      methods.
    * `...` indicates method-specific arguments. Currently, no methods use this
* `minetest.rgba(red, green, blue[, alpha])`: returns a string
    * Each argument is a 8 Bit unsigned integer
    * Returns the ColorString from rgb or rgba values
    * Example: `minetest.rgba(10, 20, 30, 40)`, returns `"#0A141E28"`
* `minetest.encode_base64(string)`: returns string encoded in base64
    * Encodes a string in base64.
* `minetest.decode_base64(string)`: returns string or nil on failure
    * Padding characters are only supported starting at version 5.4.0, where
      5.5.0 and newer perform proper checks.
    * Decodes a string encoded in base64.
* `minetest.is_protected(pos, name)`: returns boolean
    * Returning `true` restricts the player `name` from modifying (i.e. digging,
       placing) the node at position `pos`.
    * `name` will be `""` for non-players or unknown players.
    * This function should be overridden by protection mods. It is highly
      recommended to grant access to players with the `protection_bypass` privilege.
    * Cache and call the old version of this function if the position is
      not protected by the mod. This will allow using multiple protection mods.
    * Example:

          local old_is_protected = minetest.is_protected
          function minetest.is_protected(pos, name)
              if mymod:position_protected_from(pos, name) then
                  return true
              end
              return old_is_protected(pos, name)
          end
* `minetest.record_protection_violation(pos, name)`
    * This function calls functions registered with
      `minetest.register_on_protection_violation`.
* `minetest.is_creative_enabled(name)`: returns boolean
    * Returning `true` means that Creative Mode is enabled for player `name`.
    * `name` will be `""` for non-players or if the player is unknown.
    * This function should be overridden by Creative Mode-related mods to
      implement a per-player Creative Mode.
    * By default, this function returns `true` if the setting
      `creative_mode` is `true` and `false` otherwise.
* `minetest.is_area_protected(pos1, pos2, player_name, interval)`
    * Returns the position of the first node that `player_name` may not modify
      in the specified cuboid between `pos1` and `pos2`.
    * Returns `false` if no protections were found.
    * Applies `is_protected()` to a 3D lattice of points in the defined volume.
      The points are spaced evenly throughout the volume and have a spacing
      similar to, but no larger than, `interval`.
    * All corners and edges of the defined volume are checked.
    * `interval` defaults to 4.
    * `interval` should be carefully chosen and maximised to avoid an excessive
      number of points being checked.
    * Like `minetest.is_protected`, this function may be extended or
      overwritten by mods to provide a faster implementation to check the
      cuboid for intersections.
* `minetest.rotate_and_place(itemstack, placer, pointed_thing[, infinitestacks,
  orient_flags, prevent_after_place])`
    * Attempt to predict the desired orientation of the facedir-capable node
      defined by `itemstack`, and place it accordingly (on-wall, on the floor,
      or hanging from the ceiling).
    * `infinitestacks`: if `true`, the itemstack is not changed. Otherwise the
      stacks are handled normally.
    * `orient_flags`: Optional table containing extra tweaks to the placement code:
        * `invert_wall`:   if `true`, place wall-orientation on the ground and
          ground-orientation on the wall.
        * `force_wall` :   if `true`, always place the node in wall orientation.
        * `force_ceiling`: if `true`, always place on the ceiling.
        * `force_floor`:   if `true`, always place the node on the floor.
        * `force_facedir`: if `true`, forcefully reset the facedir to north
          when placing on the floor or ceiling.
        * The first four options are mutually-exclusive; the last in the list
          takes precedence over the first.
    * `prevent_after_place` is directly passed to `minetest.item_place_node`
    * Returns the new itemstack after placement
* `minetest.rotate_node(itemstack, placer, pointed_thing)`
    * calls `rotate_and_place()` with `infinitestacks` set according to the state
      of the creative mode setting, checks for "sneak" to set the `invert_wall`
      parameter and `prevent_after_place` set to `true`.

* `minetest.calculate_knockback(player, hitter, time_from_last_punch,
  tool_capabilities, dir, distance, damage)`
    * Returns the amount of knockback applied on the punched player.
    * Arguments are equivalent to `register_on_punchplayer`, except the following:
        * `distance`: distance between puncher and punched player
    * This function can be overriden by mods that wish to modify this behaviour.
    * You may want to cache and call the old function to allow multiple mods to
      change knockback behaviour.

* `minetest.forceload_block(pos[, transient])`
    * forceloads the position `pos`.
    * returns `true` if area could be forceloaded
    * If `transient` is `false` or absent, the forceload will be persistent
      (saved between server runs). If `true`, the forceload will be transient
      (not saved between server runs).

* `minetest.forceload_free_block(pos[, transient])`
    * stops forceloading the position `pos`
    * If `transient` is `false` or absent, frees a persistent forceload.
      If `true`, frees a transient forceload.

* `minetest.compare_block_status(pos, condition)`
    * Checks whether the mapblock at positition `pos` is in the wanted condition.
    * `condition` may be one of the following values:
        * `"unknown"`: not in memory
        * `"emerging"`: in the queue for loading from disk or generating
        * `"loaded"`: in memory but inactive (no ABMs are executed)
        * `"active"`: in memory and active
        * Other values are reserved for future functionality extensions
    * Return value, the comparison status:
        * `false`: Mapblock does not fulfil the wanted condition
        * `true`: Mapblock meets the requirement
        * `nil`: Unsupported `condition` value

* `minetest.request_insecure_environment()`: returns an environment containing
  insecure functions if the calling mod has been listed as trusted in the
  `secure.trusted_mods` setting or security is disabled, otherwise returns
  `nil`.
    * Only works at init time and must be called from the mod's main scope
      (ie: the init.lua of the mod, not from another Lua file or within a function).
    * **DO NOT ALLOW ANY OTHER MODS TO ACCESS THE RETURNED ENVIRONMENT, STORE
      IT IN A LOCAL VARIABLE!**

* `minetest.global_exists(name)`
    * Checks if a global variable has been set, without triggering a warning.

Global objects
--------------

* `minetest.env`: `EnvRef` of the server environment and world.
    * Any function in the minetest namespace can be called using the syntax
      `minetest.env:somefunction(somearguments)`
      instead of `minetest.somefunction(somearguments)`
    * Deprecated, but support is not to be dropped soon

Global tables
-------------

### Registered definition tables

* `minetest.registered_items`
    * Map of registered items, indexed by name
* `minetest.registered_nodes`
    * Map of registered node definitions, indexed by name
* `minetest.registered_craftitems`
    * Map of registered craft item definitions, indexed by name
* `minetest.registered_tools`
    * Map of registered tool definitions, indexed by name
* `minetest.registered_entities`
    * Map of registered entity prototypes, indexed by name
    * Values in this table may be modified directly.
      Note: changes to initial properties will only affect entities spawned afterwards,
      as they are only read when spawning.
* `minetest.object_refs`
    * Map of object references, indexed by active object id
* `minetest.luaentities`
    * Map of Lua entities, indexed by active object id
* `minetest.registered_abms`
    * List of ABM definitions
* `minetest.registered_lbms`
    * List of LBM definitions
* `minetest.registered_aliases`
    * Map of registered aliases, indexed by name
* `minetest.registered_ores`
    * Map of registered ore definitions, indexed by the `name` field.
    * If `name` is nil, the key is the object handle returned by
      `minetest.register_ore`.
* `minetest.registered_biomes`
    * Map of registered biome definitions, indexed by the `name` field.
    * If `name` is nil, the key is the object handle returned by
      `minetest.register_biome`.
* `minetest.registered_decorations`
    * Map of registered decoration definitions, indexed by the `name` field.
    * If `name` is nil, the key is the object handle returned by
      `minetest.register_decoration`.
* `minetest.registered_schematics`
    * Map of registered schematic definitions, indexed by the `name` field.
    * If `name` is nil, the key is the object handle returned by
      `minetest.register_schematic`.
* `minetest.registered_chatcommands`
    * Map of registered chat command definitions, indexed by name
* `minetest.registered_privileges`
    * Map of registered privilege definitions, indexed by name
    * Registered privileges can be modified directly in this table.

### Registered callback tables

All callbacks registered with [Global callback registration functions] are added
to corresponding `minetest.registered_*` tables.




Class reference
===============

Sorted alphabetically.

`AreaStore`
-----------

AreaStore is a data structure to calculate intersections of 3D cuboid volumes
and points. The `data` field (string) may be used to store and retrieve any
mod-relevant information to the specified area.

Despite its name, mods must take care of persisting AreaStore data. They may
use the provided load and write functions for this.


### Methods

* `AreaStore(type_name)`
    * Returns a new AreaStore instance
    * `type_name`: optional, forces the internally used API.
        * Possible values: `"LibSpatial"` (default).
        * When other values are specified, or SpatialIndex is not available,
          the custom Minetest functions are used.
* `get_area(id, include_corners, include_data)`
    * Returns the area information about the specified ID.
    * Returned values are either of these:

            nil  -- Area not found
            true -- Without `include_corners` and `include_data`
            {
                min = pos, max = pos -- `include_corners == true`
                data = string        -- `include_data == true`
            }

* `get_areas_for_pos(pos, include_corners, include_data)`
    * Returns all areas as table, indexed by the area ID.
    * Table values: see `get_area`.
* `get_areas_in_area(corner1, corner2, accept_overlap, include_corners, include_data)`
    * Returns all areas that contain all nodes inside the area specified by`
      `corner1 and `corner2` (inclusive).
    * `accept_overlap`: if `true`, areas are returned that have nodes in
      common (intersect) with the specified area.
    * Returns the same values as `get_areas_for_pos`.
* `insert_area(corner1, corner2, data, [id])`: inserts an area into the store.
    * Returns the new area's ID, or nil if the insertion failed.
    * The (inclusive) positions `corner1` and `corner2` describe the area.
    * `data` is a string stored with the area.
    * `id` (optional): will be used as the internal area ID if it is an unique
      number between 0 and 2^32-2.
* `reserve(count)`
    * Requires SpatialIndex, no-op function otherwise.
    * Reserves resources for `count` many contained areas to improve
      efficiency when working with many area entries. Additional areas can still
      be inserted afterwards at the usual complexity.
* `remove_area(id)`: removes the area with the given id from the store, returns
  success.
* `set_cache_params(params)`: sets params for the included prefiltering cache.
  Calling invalidates the cache, so that its elements have to be newly
  generated.
    * `params` is a table with the following fields:

          enabled = boolean,   -- Whether to enable, default true
          block_radius = int,  -- The radius (in nodes) of the areas the cache
                               -- generates prefiltered lists for, minimum 16,
                               -- default 64
          limit = int,         -- The cache size, minimum 20, default 1000
* `to_string()`: Experimental. Returns area store serialized as a (binary)
  string.
* `to_file(filename)`: Experimental. Like `to_string()`, but writes the data to
  a file.
* `from_string(str)`: Experimental. Deserializes string and loads it into the
  AreaStore.
  Returns success and, optionally, an error message.
* `from_file(filename)`: Experimental. Like `from_string()`, but reads the data
  from a file.

`InvRef`
--------

An `InvRef` is a reference to an inventory.

### Methods

* `is_empty(listname)`: return `true` if list is empty
* `get_size(listname)`: get size of a list
* `set_size(listname, size)`: set size of a list
    * returns `false` on error (e.g. invalid `listname` or `size`)
* `get_width(listname)`: get width of a list
* `set_width(listname, width)`: set width of list; currently used for crafting
* `get_stack(listname, i)`: get a copy of stack index `i` in list
* `set_stack(listname, i, stack)`: copy `stack` to index `i` in list
* `get_list(listname)`: return full list (list of `ItemStack`s)
* `set_list(listname, list)`: set full list (size will not change)
* `get_lists()`: returns table that maps listnames to inventory lists
* `set_lists(lists)`: sets inventory lists (size will not change)
* `add_item(listname, stack)`: add item somewhere in list, returns leftover
  `ItemStack`.
* `room_for_item(listname, stack):` returns `true` if the stack of items
  can be fully added to the list
* `contains_item(listname, stack, [match_meta])`: returns `true` if
  the stack of items can be fully taken from the list.
  If `match_meta` is false, only the items' names are compared
  (default: `false`).
* `remove_item(listname, stack)`: take as many items as specified from the
  list, returns the items that were actually removed (as an `ItemStack`)
  -- note that any item metadata is ignored, so attempting to remove a specific
  unique item this way will likely remove the wrong one -- to do that use
  `set_stack` with an empty `ItemStack`.
* `get_location()`: returns a location compatible to
  `minetest.get_inventory(location)`.
    * returns `{type="undefined"}` in case location is not known

### Callbacks

Detached & nodemeta inventories provide the following callbacks for move actions:

#### Before

The `allow_*` callbacks return how many items can be moved.

* `allow_move`/`allow_metadata_inventory_move`: Moving items in the inventory
* `allow_take`/`allow_metadata_inventory_take`: Taking items from the inventory
* `allow_put`/`allow_metadata_inventory_put`: Putting items to the inventory

#### After

The `on_*` callbacks are called after the items have been placed in the inventories.

* `on_move`/`on_metadata_inventory_move`: Moving items in the inventory
* `on_take`/`on_metadata_inventory_take`: Taking items from the inventory
* `on_put`/`on_metadata_inventory_put`: Putting items to the inventory

#### Swapping

When a player tries to put an item to a place where another item is, the items are *swapped*.
This means that all callbacks will be called twice (once for each action).

`ItemStack`
-----------

An `ItemStack` is a stack of items.

It can be created via `ItemStack(x)`, where x is an `ItemStack`,
an itemstring, a table or `nil`.

### Methods

* `is_empty()`: returns `true` if stack is empty.
* `get_name()`: returns item name (e.g. `"default:stone"`).
* `set_name(item_name)`: returns a boolean indicating whether the item was
  cleared.
* `get_count()`: Returns number of items on the stack.
* `set_count(count)`: returns a boolean indicating whether the item was cleared
    * `count`: number, unsigned 16 bit integer
* `get_wear()`: returns tool wear (`0`-`65535`), `0` for non-tools.
* `set_wear(wear)`: returns boolean indicating whether item was cleared
    * `wear`: number, unsigned 16 bit integer
* `get_meta()`: returns ItemStackMetaRef. See section for more details
* `get_metadata()`: (DEPRECATED) Returns metadata (a string attached to an item
  stack).
* `set_metadata(metadata)`: (DEPRECATED) Returns true.
* `get_description()`: returns the description shown in inventory list tooltips.
    * The engine uses this when showing item descriptions in tooltips.
    * Fields for finding the description, in order:
        * `description` in item metadata (See [Item Metadata].)
        * `description` in item definition
        * item name
* `get_short_description()`: returns the short description or nil.
    * Unlike the description, this does not include new lines.
    * Fields for finding the short description, in order:
        * `short_description` in item metadata (See [Item Metadata].)
        * `short_description` in item definition
        * first line of the description (From item meta or def, see `get_description()`.)
        * Returns nil if none of the above are set
* `clear()`: removes all items from the stack, making it empty.
* `replace(item)`: replace the contents of this stack.
    * `item` can also be an itemstring or table.
* `to_string()`: returns the stack in itemstring form.
* `to_table()`: returns the stack in Lua table form.
* `get_stack_max()`: returns the maximum size of the stack (depends on the
  item).
* `get_free_space()`: returns `get_stack_max() - get_count()`.
* `is_known()`: returns `true` if the item name refers to a defined item type.
* `get_definition()`: returns the item definition table.
* `get_tool_capabilities()`: returns the digging properties of the item,
  or those of the hand if none are defined for this item type
* `add_wear(amount)`
    * Increases wear by `amount` if the item is a tool, otherwise does nothing
    * Valid `amount` range is [0,65536]
    * `amount`: number, integer
* `add_wear_by_uses(max_uses)`
    * Increases wear in such a way that, if only this function is called,
      the item breaks after `max_uses` times
    * Valid `max_uses` range is [0,65536]
    * Does nothing if item is not a tool or if `max_uses` is 0
* `add_item(item)`: returns leftover `ItemStack`
    * Put some item or stack onto this stack
* `item_fits(item)`: returns `true` if item or stack can be fully added to
  this one.
* `take_item(n)`: returns taken `ItemStack`
    * Take (and remove) up to `n` items from this stack
    * `n`: number, default: `1`
* `peek_item(n)`: returns taken `ItemStack`
    * Copy (don't remove) up to `n` items from this stack
    * `n`: number, default: `1`

`ItemStackMetaRef`
------------------

ItemStack metadata: reference extra data and functionality stored in a stack.
Can be obtained via `item:get_meta()`.

### Methods

* All methods in MetaDataRef
* `set_tool_capabilities([tool_capabilities])`
    * Overrides the item's tool capabilities
    * A nil value will clear the override data and restore the original
      behavior.

`MetaDataRef`
-------------

Base class used by [`StorageRef`], [`NodeMetaRef`], [`ItemStackMetaRef`],
and [`PlayerMetaRef`].

### Methods

* `contains(key)`: Returns true if key present, otherwise false.
    * Returns `nil` when the MetaData is inexistent.
* `get(key)`: Returns `nil` if key not present, else the stored string.
* `set_string(key, value)`: Value of `""` will delete the key.
* `get_string(key)`: Returns `""` if key not present.
* `set_int(key, value)`
* `get_int(key)`: Returns `0` if key not present.
* `set_float(key, value)`
* `get_float(key)`: Returns `0` if key not present.
* `to_table()`: returns `nil` or a table with keys:
    * `fields`: key-value storage
    * `inventory`: `{list1 = {}, ...}}` (NodeMetaRef only)
* `from_table(nil or {})`
    * Any non-table value will clear the metadata
    * See [Node Metadata] for an example
    * returns `true` on success
* `equals(other)`
    * returns `true` if this metadata has the same key-value pairs as `other`

`ModChannel`
------------

An interface to use mod channels on client and server

### Methods

* `leave()`: leave the mod channel.
    * Server leaves channel `channel_name`.
    * No more incoming or outgoing messages can be sent to this channel from
      server mods.
    * This invalidate all future object usage.
    * Ensure you set mod_channel to nil after that to free Lua resources.
* `is_writeable()`: returns true if channel is writeable and mod can send over
  it.
* `send_all(message)`: Send `message` though the mod channel.
    * If mod channel is not writeable or invalid, message will be dropped.
    * Message size is limited to 65535 characters by protocol.

`NodeMetaRef`
-------------

Node metadata: reference extra data and functionality stored in a node.
Can be obtained via `minetest.get_meta(pos)`.

### Methods

* All methods in MetaDataRef
* `get_inventory()`: returns `InvRef`
* `mark_as_private(name or {name1, name2, ...})`: Mark specific vars as private
  This will prevent them from being sent to the client. Note that the "private"
  status will only be remembered if an associated key-value pair exists,
  meaning it's best to call this when initializing all other meta (e.g.
  `on_construct`).

`NodeTimerRef`
--------------

Node Timers: a high resolution persistent per-node timer.
Can be gotten via `minetest.get_node_timer(pos)`.

### Methods

* `set(timeout,elapsed)`
    * set a timer's state
    * `timeout` is in seconds, and supports fractional values (0.1 etc)
    * `elapsed` is in seconds, and supports fractional values (0.1 etc)
    * will trigger the node's `on_timer` function after `(timeout - elapsed)`
      seconds.
* `start(timeout)`
    * start a timer
    * equivalent to `set(timeout,0)`
* `stop()`
    * stops the timer
* `get_timeout()`: returns current timeout in seconds
    * if `timeout` equals `0`, timer is inactive
* `get_elapsed()`: returns current elapsed time in seconds
    * the node's `on_timer` function will be called after `(timeout - elapsed)`
      seconds.
* `is_started()`: returns boolean state of timer
    * returns `true` if timer is started, otherwise `false`

`ObjectRef`
-----------

Moving things in the game are generally these.
This is basically a reference to a C++ `ServerActiveObject`.

### Advice on handling `ObjectRefs`

When you receive an `ObjectRef` as a callback argument or from another API
function, it is possible to store the reference somewhere and keep it around.
It will keep functioning until the object is unloaded or removed.

However, doing this is **NOT** recommended as there is (intentionally) no method
to test if a previously acquired `ObjectRef` is still valid.
Instead, `ObjectRefs` should be "let go" of as soon as control is returned from
Lua back to the engine.
Doing so is much less error-prone and you will never need to wonder if the
object you are working with still exists.


### Methods

* `get_pos()`: returns `{x=num, y=num, z=num}`
* `set_pos(pos)`: `pos`=`{x=num, y=num, z=num}`
* `get_velocity()`: returns the velocity, a vector.
* `add_velocity(vel)`
    * `vel` is a vector, e.g. `{x=0.0, y=2.3, z=1.0}`
    * In comparison to using get_velocity, adding the velocity and then using
      set_velocity, add_velocity is supposed to avoid synchronization problems.
      Additionally, players also do not support set_velocity.
    * If a player:
        * Does not apply during free_move.
        * Note that since the player speed is normalized at each move step,
          increasing e.g. Y velocity beyond what would usually be achieved
          (see: physics overrides) will cause existing X/Z velocity to be reduced.
        * Example: `add_velocity({x=0, y=6.5, z=0})` is equivalent to
          pressing the jump key (assuming default settings)
* `move_to(pos, continuous=false)`
    * Does an interpolated move for Lua entities for visually smooth transitions.
    * If `continuous` is true, the Lua entity will not be moved to the current
      position before starting the interpolated move.
    * For players this does the same as `set_pos`,`continuous` is ignored.
* `punch(puncher, time_from_last_punch, tool_capabilities, direction)`
    * `puncher` = another `ObjectRef`,
    * `time_from_last_punch` = time since last punch action of the puncher
    * `direction`: can be `nil`
* `right_click(clicker)`; `clicker` is another `ObjectRef`
* `get_hp()`: returns number of health points
* `set_hp(hp, reason)`: set number of health points
    * See reason in register_on_player_hpchange
    * Is limited to the range of 0 ... 65535 (2^16 - 1)
    * For players: HP are also limited by `hp_max` specified in the player's
      object properties
* `get_inventory()`: returns an `InvRef` for players, otherwise returns `nil`
* `get_wield_list()`: returns the name of the inventory list the wielded item
   is in.
* `get_wield_index()`: returns the index of the wielded item
* `get_wielded_item()`: returns an `ItemStack`
* `set_wielded_item(item)`: replaces the wielded item, returns `true` if
  successful.
* `set_armor_groups({group1=rating, group2=rating, ...})`
* `get_armor_groups()`: returns a table with the armor group ratings
* `set_animation(frame_range, frame_speed, frame_blend, frame_loop)`
    * `frame_range`: table {x=num, y=num}, default: `{x=1, y=1}`
    * `frame_speed`: number, default: `15.0`
    * `frame_blend`: number, default: `0.0`
    * `frame_loop`: boolean, default: `true`
* `get_animation()`: returns `range`, `frame_speed`, `frame_blend` and
  `frame_loop`.
* `set_animation_frame_speed(frame_speed)`
    * `frame_speed`: number, default: `15.0`
* `set_attach(parent[, bone, position, rotation, forced_visible])`
    * `bone`: string. Default is `""`, the root bone
    * `position`: `{x=num, y=num, z=num}`, relative, default `{x=0, y=0, z=0}`
    * `rotation`: `{x=num, y=num, z=num}` = Rotation on each axis, in degrees.
      Default `{x=0, y=0, z=0}`
    * `forced_visible`: Boolean to control whether the attached entity
       should appear in first person. Default `false`.
    * This command may fail silently (do nothing) when it would result
      in circular attachments.
* `get_attach()`: returns parent, bone, position, rotation, forced_visible,
    or nil if it isn't attached.
* `get_children()`: returns a list of ObjectRefs that are attached to the
    object.
* `set_detach()`
* `set_bone_position([bone, position, rotation])`
    * `bone`: string. Default is `""`, the root bone
    * `position`: `{x=num, y=num, z=num}`, relative, `default {x=0, y=0, z=0}`
    * `rotation`: `{x=num, y=num, z=num}`, default `{x=0, y=0, z=0}`
* `get_bone_position(bone)`: returns position and rotation of the bone
* `set_properties(object property table)`
* `get_properties()`: returns object property table
* `is_player()`: returns true for players, false otherwise
* `get_nametag_attributes()`
    * returns a table with the attributes of the nametag of an object
    * {
        text = "",
        color = {a=0..255, r=0..255, g=0..255, b=0..255},
        bgcolor = {a=0..255, r=0..255, g=0..255, b=0..255},
      }
* `set_nametag_attributes(attributes)`
    * sets the attributes of the nametag of an object
    * `attributes`:
      {
        text = "My Nametag",
        color = ColorSpec,
        -- ^ Text color
        bgcolor = ColorSpec or false,
        -- ^ Sets background color of nametag
        -- `false` will cause the background to be set automatically based on user settings
        -- Default: false
      }

#### Lua entity only (no-op for other objects)

* `remove()`: remove object
    * The object is removed after returning from Lua. However the `ObjectRef`
      itself instantly becomes unusable with all further method calls having
      no effect and returning `nil`.
* `set_velocity(vel)`
    * `vel` is a vector, e.g. `{x=0.0, y=2.3, z=1.0}`
* `set_acceleration(acc)`
    * `acc` is a vector
* `get_acceleration()`: returns the acceleration, a vector
* `set_rotation(rot)`
    * `rot` is a vector (radians). X is pitch (elevation), Y is yaw (heading)
      and Z is roll (bank).
* `get_rotation()`: returns the rotation, a vector (radians)
* `set_yaw(yaw)`: sets the yaw in radians (heading).
* `get_yaw()`: returns number in radians
* `set_texture_mod(mod)`
    * Set a texture modifier to the base texture, for sprites and meshes.
    * When calling `set_texture_mod` again, the previous one is discarded.
    * `mod` the texture modifier. See [Texture modifiers].
* `get_texture_mod()` returns current texture modifier
* `set_sprite(start_frame, num_frames, framelength, select_x_by_camera)`
    * Specifies and starts a sprite animation
    * Animations iterate along the frame `y` position.
    * `start_frame`: {x=column number, y=row number}, the coordinate of the
      first frame, default: `{x=0, y=0}`
    * `num_frames`: Total frames in the texture, default: `1`
    * `framelength`: Time per animated frame in seconds, default: `0.2`
    * `select_x_by_camera`: Only for visual = `sprite`. Changes the frame `x`
      position according to the view direction. default: `false`.
        * First column:  subject facing the camera
        * Second column: subject looking to the left
        * Third column:  subject backing the camera
        * Fourth column: subject looking to the right
        * Fifth column:  subject viewed from above
        * Sixth column:  subject viewed from below
* `get_entity_name()` (**Deprecated**: Will be removed in a future version, use the field `self.name` instead)
* `get_luaentity()`

#### Player only (no-op for other objects)

* `get_player_name()`: returns `""` if is not a player
* `get_player_velocity()`: **DEPRECATED**, use get_velocity() instead.
  table {x, y, z} representing the player's instantaneous velocity in nodes/s
* `add_player_velocity(vel)`: **DEPRECATED**, use add_velocity(vel) instead.
* `get_look_dir()`: get camera direction as a unit vector
* `get_look_vertical()`: pitch in radians
    * Angle ranges between -pi/2 and pi/2, which are straight up and down
      respectively.
* `get_look_horizontal()`: yaw in radians
    * Angle is counter-clockwise from the +z direction.
* `set_look_vertical(radians)`: sets look pitch
    * radians: Angle from looking forward, where positive is downwards.
* `set_look_horizontal(radians)`: sets look yaw
    * radians: Angle from the +z direction, where positive is counter-clockwise.
* `get_look_pitch()`: pitch in radians - Deprecated as broken. Use
  `get_look_vertical`.
    * Angle ranges between -pi/2 and pi/2, which are straight down and up
      respectively.
* `get_look_yaw()`: yaw in radians - Deprecated as broken. Use
  `get_look_horizontal`.
    * Angle is counter-clockwise from the +x direction.
* `set_look_pitch(radians)`: sets look pitch - Deprecated. Use
  `set_look_vertical`.
* `set_look_yaw(radians)`: sets look yaw - Deprecated. Use
  `set_look_horizontal`.
* `get_breath()`: returns player's breath
* `set_breath(value)`: sets player's breath
    * values:
        * `0`: player is drowning
        * max: bubbles bar is not shown
        * See [Object properties] for more information
    * Is limited to range 0 ... 65535 (2^16 - 1)
* `set_fov(fov, is_multiplier, transition_time)`: Sets player's FOV
    * `fov`: FOV value.
    * `is_multiplier`: Set to `true` if the FOV value is a multiplier.
      Defaults to `false`.
    * `transition_time`: If defined, enables smooth FOV transition.
      Interpreted as the time (in seconds) to reach target FOV.
      If set to 0, FOV change is instantaneous. Defaults to 0.
    * Set `fov` to 0 to clear FOV override.
* `get_fov()`: Returns the following:
    * Server-sent FOV value. Returns 0 if an FOV override doesn't exist.
    * Boolean indicating whether the FOV value is a multiplier.
    * Time (in seconds) taken for the FOV transition. Set by `set_fov`.
* `set_attribute(attribute, value)`:  DEPRECATED, use get_meta() instead
    * Sets an extra attribute with value on player.
    * `value` must be a string, or a number which will be converted to a
      string.
    * If `value` is `nil`, remove attribute from player.
* `get_attribute(attribute)`:  DEPRECATED, use get_meta() instead
    * Returns value (a string) for extra attribute.
    * Returns `nil` if no attribute found.
* `get_meta()`: Returns a PlayerMetaRef.
* `set_inventory_formspec(formspec)`
    * Redefine player's inventory form
    * Should usually be called in `on_joinplayer`
    * If `formspec` is `""`, the player's inventory is disabled.
* `get_inventory_formspec()`: returns a formspec string
* `set_formspec_prepend(formspec)`:
    * the formspec string will be added to every formspec shown to the user,
      except for those with a no_prepend[] tag.
    * This should be used to set style elements such as background[] and
      bgcolor[], any non-style elements (eg: label) may result in weird behaviour.
    * Only affects formspecs shown after this is called.
* `get_formspec_prepend(formspec)`: returns a formspec string.
* `get_player_control()`: returns table with player pressed keys
    * The table consists of fields with the following boolean values
      representing the pressed keys: `up`, `down`, `left`, `right`, `jump`,
      `aux1`, `sneak`, `dig`, `place`, `LMB`, `RMB`, and `zoom`.
    * The fields `LMB` and `RMB` are equal to `dig` and `place` respectively,
      and exist only to preserve backwards compatibility.
    * Returns an empty table `{}` if the object is not a player.
* `get_player_control_bits()`: returns integer with bit packed player pressed
  keys.
    * Bits:
        * 0 - up
        * 1 - down
        * 2 - left
        * 3 - right
        * 4 - jump
        * 5 - aux1
        * 6 - sneak
        * 7 - dig
        * 8 - place
        * 9 - zoom
    * Returns `0` (no bits set) if the object is not a player.
* `set_physics_override(override_table)`
    * `override_table` is a table with the following fields:
        * `speed`: multiplier to default walking speed value (default: `1`)
        * `jump`: multiplier to default jump value (default: `1`)
        * `gravity`: multiplier to default gravity value (default: `1`)
        * `sneak`: whether player can sneak (default: `true`)
        * `sneak_glitch`: whether player can use the new move code replications
          of the old sneak side-effects: sneak ladders and 2 node sneak jump
          (default: `false`)
        * `new_move`: use new move/sneak code. When `false` the exact old code
          is used for the specific old sneak behaviour (default: `true`)
* `get_physics_override()`: returns the table given to `set_physics_override`
* `hud_add(hud definition)`: add a HUD element described by HUD def, returns ID
   number on success
* `hud_remove(id)`: remove the HUD element of the specified id
* `hud_change(id, stat, value)`: change a value of a previously added HUD
  element.
    * element `stat` values:
      `position`, `name`, `scale`, `text`, `number`, `item`, `dir`
* `hud_get(id)`: gets the HUD element definition structure of the specified ID
* `hud_set_flags(flags)`: sets specified HUD flags of player.
    * `flags`: A table with the following fields set to boolean values
        * `hotbar`
        * `healthbar`
        * `crosshair`
        * `wielditem`
        * `breathbar`
        * `minimap`: Modifies the client's permission to view the minimap.
          The client may locally elect to not view the minimap.
        * `minimap_radar`: is only usable when `minimap` is true
        * `basic_debug`: Allow showing basic debug info that might give a gameplay advantage.
          This includes map seed, player position, look direction, the pointed node and block bounds.
          Does not affect players with the `debug` privilege.
    * If a flag equals `nil`, the flag is not modified
* `hud_get_flags()`: returns a table of player HUD flags with boolean values.
    * See `hud_set_flags` for a list of flags that can be toggled.
* `hud_set_hotbar_itemcount(count)`: sets number of items in builtin hotbar
    * `count`: number of items, must be between `1` and `32`
* `hud_get_hotbar_itemcount`: returns number of visible items
* `hud_set_hotbar_image(texturename)`
    * sets background image for hotbar
* `hud_get_hotbar_image`: returns texturename
* `hud_set_hotbar_selected_image(texturename)`
    * sets image for selected item of hotbar
* `hud_get_hotbar_selected_image`: returns texturename
* `set_minimap_modes({mode, mode, ...}, selected_mode)`
    * Overrides the available minimap modes (and toggle order), and changes the
    selected mode.
    * `mode` is a table consisting of up to four fields:
        * `type`: Available type:
            * `off`: Minimap off
            * `surface`: Minimap in surface mode
            * `radar`: Minimap in radar mode
            * `texture`: Texture to be displayed instead of terrain map
              (texture is centered around 0,0 and can be scaled).
              Texture size is limited to 512 x 512 pixel.
        * `label`: Optional label to display on minimap mode toggle
          The translation must be handled within the mod.
        * `size`: Sidelength or diameter, in number of nodes, of the terrain
          displayed in minimap
        * `texture`: Only for texture type, name of the texture to display
        * `scale`: Only for texture type, scale of the texture map in nodes per
          pixel (for example a `scale` of 2 means each pixel represents a 2x2
          nodes square)
    * `selected_mode` is the mode index to be selected after modes have been changed
    (0 is the first mode).
* `set_sky(sky_parameters)`
    * The presence of the function `set_sun`, `set_moon` or `set_stars` indicates
      whether `set_sky` accepts this format. Check the legacy format otherwise.
    * Passing no arguments resets the sky to its default values.
    * `sky_parameters` is a table with the following optional fields:
        * `base_color`: ColorSpec, changes fog in "skybox" and "plain".
          (default: `#ffffff`)
        * `type`: Available types:
            * `"regular"`: Uses 0 textures, `base_color` ignored
            * `"skybox"`: Uses 6 textures, `base_color` used as fog.
            * `"plain"`: Uses 0 textures, `base_color` used as both fog and sky.
            (default: `"regular"`)
        * `textures`: A table containing up to six textures in the following
            order: Y+ (top), Y- (bottom), X- (west), X+ (east), Z+ (north), Z- (south).
        * `clouds`: Boolean for whether clouds appear. (default: `true`)
        * `sky_color`: A table used in `"regular"` type only, containing the
          following values (alpha is ignored):
            * `day_sky`: ColorSpec, for the top half of the sky during the day.
              (default: `#61b5f5`)
            * `day_horizon`: ColorSpec, for the bottom half of the sky during the day.
              (default: `#90d3f6`)
            * `dawn_sky`: ColorSpec, for the top half of the sky during dawn/sunset.
              (default: `#b4bafa`)
              The resulting sky color will be a darkened version of the ColorSpec.
              Warning: The darkening of the ColorSpec is subject to change.
            * `dawn_horizon`: ColorSpec, for the bottom half of the sky during dawn/sunset.
              (default: `#bac1f0`)
              The resulting sky color will be a darkened version of the ColorSpec.
              Warning: The darkening of the ColorSpec is subject to change.
            * `night_sky`: ColorSpec, for the top half of the sky during the night.
              (default: `#006bff`)
              The resulting sky color will be a dark version of the ColorSpec.
              Warning: The darkening of the ColorSpec is subject to change.
            * `night_horizon`: ColorSpec, for the bottom half of the sky during the night.
              (default: `#4090ff`)
              The resulting sky color will be a dark version of the ColorSpec.
              Warning: The darkening of the ColorSpec is subject to change.
            * `indoors`: ColorSpec, for when you're either indoors or underground.
              (default: `#646464`)
            * `fog_sun_tint`: ColorSpec, changes the fog tinting for the sun
              at sunrise and sunset. (default: `#f47d1d`)
            * `fog_moon_tint`: ColorSpec, changes the fog tinting for the moon
              at sunrise and sunset. (default: `#7f99cc`)
            * `fog_tint_type`: string, changes which mode the directional fog
                abides by, `"custom"` uses `sun_tint` and `moon_tint`, while
                `"default"` uses the classic Minetest sun and moon tinting.
                Will use tonemaps, if set to `"default"`. (default: `"default"`)
* `set_sky(base_color, type, {texture names}, clouds)`
    * Deprecated. Use `set_sky(sky_parameters)`
    * `base_color`: ColorSpec, defaults to white
    * `type`: Available types:
        * `"regular"`: Uses 0 textures, `bgcolor` ignored
        * `"skybox"`: Uses 6 textures, `bgcolor` used
        * `"plain"`: Uses 0 textures, `bgcolor` used
    * `clouds`: Boolean for whether clouds appear in front of `"skybox"` or
      `"plain"` custom skyboxes (default: `true`)
* `get_sky(as_table)`:
    * `as_table`: boolean that determines whether the deprecated version of this
    function is being used.
        * `true` returns a table containing sky parameters as defined in `set_sky(sky_parameters)`.
        * Deprecated: `false` or `nil` returns base_color, type, table of textures,
        clouds.
* `get_sky_color()`:
    * Deprecated: Use `get_sky(as_table)` instead.
    * returns a table with the `sky_color` parameters as in `set_sky`.
* `set_sun(sun_parameters)`:
    * Passing no arguments resets the sun to its default values.
    * `sun_parameters` is a table with the following optional fields:
        * `visible`: Boolean for whether the sun is visible.
            (default: `true`)
        * `texture`: A regular texture for the sun. Setting to `""`
            will re-enable the mesh sun. (default: "sun.png", if it exists)
        * `tonemap`: A 512x1 texture containing the tonemap for the sun
            (default: `"sun_tonemap.png"`)
        * `sunrise`: A regular texture for the sunrise texture.
            (default: `"sunrisebg.png"`)
        * `sunrise_visible`: Boolean for whether the sunrise texture is visible.
            (default: `true`)
        * `scale`: Float controlling the overall size of the sun. (default: `1`)
* `get_sun()`: returns a table with the current sun parameters as in
    `set_sun`.
* `set_moon(moon_parameters)`:
    * Passing no arguments resets the moon to its default values.
    * `moon_parameters` is a table with the following optional fields:
        * `visible`: Boolean for whether the moon is visible.
            (default: `true`)
        * `texture`: A regular texture for the moon. Setting to `""`
            will re-enable the mesh moon. (default: `"moon.png"`, if it exists)
            Note: Relative to the sun, the moon texture is rotated by 180°.
            You can use the `^[transformR180` texture modifier to achieve the same orientation.
        * `tonemap`: A 512x1 texture containing the tonemap for the moon
            (default: `"moon_tonemap.png"`)
        * `scale`: Float controlling the overall size of the moon (default: `1`)
* `get_moon()`: returns a table with the current moon parameters as in
    `set_moon`.
* `set_stars(star_parameters)`:
    * Passing no arguments resets stars to their default values.
    * `star_parameters` is a table with the following optional fields:
        * `visible`: Boolean for whether the stars are visible.
            (default: `true`)
        * `count`: Integer number to set the number of stars in
            the skybox. Only applies to `"skybox"` and `"regular"` sky types.
            (default: `1000`)
        * `star_color`: ColorSpec, sets the colors of the stars,
            alpha channel is used to set overall star brightness.
            (default: `#ebebff69`)
        * `scale`: Float controlling the overall size of the stars (default: `1`)
* `get_stars()`: returns a table with the current stars parameters as in
    `set_stars`.
* `set_clouds(cloud_parameters)`: set cloud parameters
    * Passing no arguments resets clouds to their default values.
    * `cloud_parameters` is a table with the following optional fields:
        * `density`: from `0` (no clouds) to `1` (full clouds) (default `0.4`)
        * `color`: basic cloud color with alpha channel, ColorSpec
          (default `#fff0f0e5`).
        * `ambient`: cloud color lower bound, use for a "glow at night" effect.
          ColorSpec (alpha ignored, default `#000000`)
        * `height`: cloud height, i.e. y of cloud base (default per conf,
          usually `120`)
        * `thickness`: cloud thickness in nodes (default `16`)
        * `speed`: 2D cloud speed + direction in nodes per second
          (default `{x=0, z=-2}`).
* `get_clouds()`: returns a table with the current cloud parameters as in
  `set_clouds`.
* `override_day_night_ratio(ratio or nil)`
    * `0`...`1`: Overrides day-night ratio, controlling sunlight to a specific
      amount.
    * `nil`: Disables override, defaulting to sunlight based on day-night cycle
* `get_day_night_ratio()`: returns the ratio or nil if it isn't overridden
* `set_local_animation(idle, walk, dig, walk_while_dig, frame_speed)`:
  set animation for player model in third person view.
    * Every animation equals to a `{x=starting frame, y=ending frame}` table.
    * `frame_speed` sets the animations frame speed. Default is 30.
* `get_local_animation()`: returns idle, walk, dig, walk_while_dig tables and
  `frame_speed`.
* `set_eye_offset([firstperson, thirdperson])`: defines offset vectors for
  camera per player. An argument defaults to `{x=0, y=0, z=0}` if unspecified.
    * in first person view
    * in third person view (max. values `{x=-10/10,y=-10,15,z=-5/5}`)
* `get_eye_offset()`: returns first and third person offsets.
* `send_mapblock(blockpos)`:
    * Sends a server-side loaded mapblock to the player.
    * Returns `false` if failed.
    * Resource intensive - use sparsely
    * To get blockpos, integer divide pos by 16
* `set_lighting(light_definition)`: sets lighting for the player
    * `light_definition` is a table with the following optional fields:
      * `shadows` is a table that controls ambient shadows
        * `intensity` sets the intensity of the shadows from 0 (no shadows, default) to 1 (blackness)
* `get_lighting()`: returns the current state of lighting for the player.
    * Result is a table with the same fields as `light_definition` in `set_lighting`.
* `respawn()`: Respawns the player using the same mechanism as the death screen,
  including calling on_respawnplayer callbacks.

`PcgRandom`
-----------

A 32-bit pseudorandom number generator.
Uses PCG32, an algorithm of the permuted congruential generator family,
offering very strong randomness.

It can be created via `PcgRandom(seed)` or `PcgRandom(seed, sequence)`.

### Methods

* `next()`: return next integer random number [`-2147483648`...`2147483647`]
* `next(min, max)`: return next integer random number [`min`...`max`]
* `rand_normal_dist(min, max, num_trials=6)`: return normally distributed
  random number [`min`...`max`].
    * This is only a rough approximation of a normal distribution with:
    * `mean = (max - min) / 2`, and
    * `variance = (((max - min + 1) ^ 2) - 1) / (12 * num_trials)`
    * Increasing `num_trials` improves accuracy of the approximation

`PerlinNoise`
-------------

A perlin noise generator.
It can be created via `PerlinNoise()` or `minetest.get_perlin()`.
For `minetest.get_perlin()`, the actual seed used is the noiseparams seed
plus the world seed, to create world-specific noise.

`PerlinNoise(noiseparams)`
`PerlinNoise(seed, octaves, persistence, spread)` (Deprecated).

`minetest.get_perlin(noiseparams)`
`minetest.get_perlin(seeddiff, octaves, persistence, spread)` (Deprecated).

### Methods

* `get_2d(pos)`: returns 2D noise value at `pos={x=,y=}`
* `get_3d(pos)`: returns 3D noise value at `pos={x=,y=,z=}`

`PerlinNoiseMap`
----------------

A fast, bulk perlin noise generator.

It can be created via `PerlinNoiseMap(noiseparams, size)` or
`minetest.get_perlin_map(noiseparams, size)`.
For `minetest.get_perlin_map()`, the actual seed used is the noiseparams seed
plus the world seed, to create world-specific noise.

Format of `size` is `{x=dimx, y=dimy, z=dimz}`. The `z` component is omitted
for 2D noise, and it must be must be larger than 1 for 3D noise (otherwise
`nil` is returned).

For each of the functions with an optional `buffer` parameter: If `buffer` is
not nil, this table will be used to store the result instead of creating a new
table.

### Methods

* `get_2d_map(pos)`: returns a `<size.x>` times `<size.y>` 2D array of 2D noise
  with values starting at `pos={x=,y=}`
* `get_3d_map(pos)`: returns a `<size.x>` times `<size.y>` times `<size.z>`
  3D array of 3D noise with values starting at `pos={x=,y=,z=}`.
* `get_2d_map_flat(pos, buffer)`: returns a flat `<size.x * size.y>` element
  array of 2D noise with values starting at `pos={x=,y=}`
* `get_3d_map_flat(pos, buffer)`: Same as `get2dMap_flat`, but 3D noise
* `calc_2d_map(pos)`: Calculates the 2d noise map starting at `pos`. The result
  is stored internally.
* `calc_3d_map(pos)`: Calculates the 3d noise map starting at `pos`. The result
  is stored internally.
* `get_map_slice(slice_offset, slice_size, buffer)`: In the form of an array,
  returns a slice of the most recently computed noise results. The result slice
  begins at coordinates `slice_offset` and takes a chunk of `slice_size`.
  E.g. to grab a 2-slice high horizontal 2d plane of noise starting at buffer
  offset y = 20:
  `noisevals = noise:get_map_slice({y=20}, {y=2})`
  It is important to note that `slice_offset` offset coordinates begin at 1,
  and are relative to the starting position of the most recently calculated
  noise.
  To grab a single vertical column of noise starting at map coordinates
  x = 1023, y=1000, z = 1000:
  `noise:calc_3d_map({x=1000, y=1000, z=1000})`
  `noisevals = noise:get_map_slice({x=24, z=1}, {x=1, z=1})`

`PlayerMetaRef`
---------------

Player metadata.
Uses the same method of storage as the deprecated player attribute API, so
data there will also be in player meta.
Can be obtained using `player:get_meta()`.

### Methods

* All methods in MetaDataRef

`PseudoRandom`
--------------

A 16-bit pseudorandom number generator.
Uses a well-known LCG algorithm introduced by K&R.

It can be created via `PseudoRandom(seed)`.

### Methods

* `next()`: return next integer random number [`0`...`32767`]
* `next(min, max)`: return next integer random number [`min`...`max`]
    * `((max - min) == 32767) or ((max-min) <= 6553))` must be true
      due to the simple implementation making bad distribution otherwise.

`Raycast`
---------

A raycast on the map. It works with selection boxes.
Can be used as an iterator in a for loop as:

    local ray = Raycast(...)
    for pointed_thing in ray do
        ...
    end

The map is loaded as the ray advances. If the map is modified after the
`Raycast` is created, the changes may or may not have an effect on the object.

It can be created via `Raycast(pos1, pos2, objects, liquids)` or
`minetest.raycast(pos1, pos2, objects, liquids)` where:

* `pos1`: start of the ray
* `pos2`: end of the ray
* `objects`: if false, only nodes will be returned. Default is true.
* `liquids`: if false, liquid nodes (`liquidtype ~= "none"`) won't be
             returned. Default is false.

### Methods

* `next()`: returns a `pointed_thing` with exact pointing location
    * Returns the next thing pointed by the ray or nil.

`SecureRandom`
--------------

Interface for the operating system's crypto-secure PRNG.

It can be created via `SecureRandom()`.  The constructor returns nil if a
secure random device cannot be found on the system.

### Methods

* `next_bytes([count])`: return next `count` (default 1, capped at 2048) many
  random bytes, as a string.

`Settings`
----------

An interface to read config files in the format of `minetest.conf`.

It can be created via `Settings(filename)`.

### Methods

* `get(key)`: returns a value
* `get_bool(key, [default])`: returns a boolean
    * `default` is the value returned if `key` is not found.
    * Returns `nil` if `key` is not found and `default` not specified.
* `get_np_group(key)`: returns a NoiseParams table
* `get_flags(key)`:
    * Returns `{flag = true/false, ...}` according to the set flags.
    * Is currently limited to mapgen flags `mg_flags` and mapgen-specific
      flags like `mgv5_spflags`.
* `set(key, value)`
    * Setting names can't contain whitespace or any of `="{}#`.
    * Setting values can't contain the sequence `\n"""`.
    * Setting names starting with "secure." can't be set on the main settings
      object (`minetest.settings`).
* `set_bool(key, value)`
    * See documentation for set() above.
* `set_np_group(key, value)`
    * `value` is a NoiseParams table.
    * Also, see documentation for set() above.
* `remove(key)`: returns a boolean (`true` for success)
* `get_names()`: returns `{key1,...}`
* `write()`: returns a boolean (`true` for success)
    * Writes changes to file.
* `to_table()`: returns `{[key1]=value1,...}`

### Format

The settings have the format `key = value`. Example:

    foo = example text
    bar = """
    Multiline
    value
    """


`StorageRef`
------------

Mod metadata: per mod metadata, saved automatically.
Can be obtained via `minetest.get_mod_storage()` during load time.

WARNING: This storage backend is incaptable to save raw binary data due
to restrictions of JSON.

### Methods

* All methods in MetaDataRef




Definition tables
=================

Object properties
-----------------

Used by `ObjectRef` methods. Part of an Entity definition.
These properties are not persistent, but are applied automatically to the
corresponding Lua entity using the given registration fields.
Player properties need to be saved manually.

    {
        hp_max = 1,
        -- For players only. Defaults to `minetest.PLAYER_MAX_HP_DEFAULT`.

        breath_max = 0,
        -- For players only. Defaults to `minetest.PLAYER_MAX_BREATH_DEFAULT`.

        zoom_fov = 0.0,
        -- For players only. Zoom FOV in degrees.
        -- Note that zoom loads and/or generates world beyond the server's
        -- maximum send and generate distances, so acts like a telescope.
        -- Smaller zoom_fov values increase the distance loaded/generated.
        -- Defaults to 15 in creative mode, 0 in survival mode.
        -- zoom_fov = 0 disables zooming for the player.

        eye_height = 1.625,
        -- For players only. Camera height above feet position in nodes.
        -- Defaults to 1.625.

        physical = true,
        -- Collide with `walkable` nodes.

        collide_with_objects = true,
        -- Collide with other objects if physical = true

        collisionbox = {-0.5, 0.0, -0.5, 0.5, 1.0, 0.5},  -- Default
        selectionbox = {-0.5, 0.0, -0.5, 0.5, 1.0, 0.5},
        -- Selection box uses collision box dimensions when not set.
        -- For both boxes: {xmin, ymin, zmin, xmax, ymax, zmax} in nodes from
        -- object position.

        pointable = true,
        -- Overrides selection box when false

        visual = "cube" / "sprite" / "upright_sprite" / "mesh" / "wielditem" / "item",
        -- "cube" is a node-sized cube.
        -- "sprite" is a flat texture always facing the player.
        -- "upright_sprite" is a vertical flat texture.
        -- "mesh" uses the defined mesh model.
        -- "wielditem" is used for dropped items.
        --   (see builtin/game/item_entity.lua).
        --   For this use 'wield_item = itemname' (Deprecated: 'textures = {itemname}').
        --   If the item has a 'wield_image' the object will be an extrusion of
        --   that, otherwise:
        --   If 'itemname' is a cubic node or nodebox the object will appear
        --   identical to 'itemname'.
        --   If 'itemname' is a plantlike node the object will be an extrusion
        --   of its texture.
        --   Otherwise for non-node items, the object will be an extrusion of
        --   'inventory_image'.
        --   If 'itemname' contains a ColorString or palette index (e.g. from
        --   `minetest.itemstring_with_palette()`), the entity will inherit the color.
        -- "item" is similar to "wielditem" but ignores the 'wield_image' parameter.

        visual_size = {x = 1, y = 1, z = 1},
        -- Multipliers for the visual size. If `z` is not specified, `x` will be used
        -- to scale the entity along both horizontal axes.

        mesh = "model.obj",
        -- File name of mesh when using "mesh" visual

        textures = {},
        -- Number of required textures depends on visual.
        -- "cube" uses 6 textures just like a node, but all 6 must be defined.
        -- "sprite" uses 1 texture.
        -- "upright_sprite" uses 2 textures: {front, back}.
        -- "wielditem" expects 'textures = {itemname}' (see 'visual' above).
        -- "mesh" requires one texture for each mesh buffer/material (in order)

        colors = {},
        -- Number of required colors depends on visual

        use_texture_alpha = false,
        -- Use texture's alpha channel.
        -- Excludes "upright_sprite" and "wielditem".
        -- Note: currently causes visual issues when viewed through other
        -- semi-transparent materials such as water.

        spritediv = {x = 1, y = 1},
        -- Used with spritesheet textures for animation and/or frame selection
        -- according to position relative to player.
        -- Defines the number of columns and rows in the spritesheet:
        -- {columns, rows}.

        initial_sprite_basepos = {x = 0, y = 0},
        -- Used with spritesheet textures.
        -- Defines the {column, row} position of the initially used frame in the
        -- spritesheet.

        is_visible = true,
        -- If false, object is invisible and can't be pointed.

        makes_footstep_sound = false,
        -- If true, is able to make footstep sounds of nodes
        -- (see node sound definition for details).

        automatic_rotate = 0,
        -- Set constant rotation in radians per second, positive or negative.
        -- Object rotates along the local Y-axis, and works with set_rotation.
        -- Set to 0 to disable constant rotation.

        stepheight = 0,
        -- If positive number, object will climb upwards when it moves
        -- horizontally against a `walkable` node, if the height difference
        -- is within `stepheight`.

        automatic_face_movement_dir = 0.0,
        -- Automatically set yaw to movement direction, offset in degrees.
        -- 'false' to disable.

        automatic_face_movement_max_rotation_per_sec = -1,
        -- Limit automatic rotation to this value in degrees per second.
        -- No limit if value <= 0.

        backface_culling = true,
        -- Set to false to disable backface_culling for model

        glow = 0,
        -- Add this much extra lighting when calculating texture color.
        -- Value < 0 disables light's effect on texture color.
        -- For faking self-lighting, UI style entities, or programmatic coloring
        -- in mods.

        nametag = "",
        -- The name to display on the head of the object. By default empty.
        -- If the object is a player, a nil or empty nametag is replaced by the player's name.
        -- For all other objects, a nil or empty string removes the nametag.
        -- To hide a nametag, set its color alpha to zero. That will disable it entirely.

        nametag_color = <ColorSpec>,
        -- Sets text color of nametag

        nametag_bgcolor = <ColorSpec>,
        -- Sets background color of nametag
        -- `false` will cause the background to be set automatically based on user settings.
        -- Default: false

        infotext = "",
        -- Same as infotext for nodes. Empty by default

        static_save = true,
        -- If false, never save this object statically. It will simply be
        -- deleted when the block gets unloaded.
        -- The get_staticdata() callback is never called then.
        -- Defaults to 'true'.

        damage_texture_modifier = "^[brighten",
        -- Texture modifier to be applied for a short duration when object is hit

        shaded = true,
        -- Setting this to 'false' disables diffuse lighting of entity

        show_on_minimap = false,
        -- Defaults to true for players, false for other entities.
        -- If set to true the entity will show as a marker on the minimap.
    }

Entity definition
-----------------

Used by `minetest.register_entity`.

    {
        initial_properties = {
            visual = "mesh",
            mesh = "boats_boat.obj",
            ...,
        },
        -- A table of object properties, see the `Object properties` section.
        -- Object properties being read directly from the entity definition
        -- table is deprecated. Define object properties in this
        -- `initial_properties` table instead.

        on_activate = function(self, staticdata, dtime_s),

        on_step = function(self, dtime, moveresult),
        -- Called every server step
        -- dtime: Elapsed time
        -- moveresult: Table with collision info (only available if physical=true)

        on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir),

        on_rightclick = function(self, clicker),

        get_staticdata = function(self),
        -- Called sometimes; the string returned is passed to on_activate when
        -- the entity is re-activated from static state

        _custom_field = whatever,
        -- You can define arbitrary member variables here (see Item definition
        -- for more info) by using a '_' prefix
    }

Collision info passed to `on_step` (`moveresult` argument):

    {
        touching_ground = boolean,
        collides = boolean,
        standing_on_object = boolean,
        collisions = {
            {
                type = string, -- "node" or "object",
                axis = string, -- "x", "y" or "z"
                node_pos = vector, -- if type is "node"
                object = ObjectRef, -- if type is "object"
                old_velocity = vector,
                new_velocity = vector,
            },
            ...
        }
        -- `collisions` does not contain data of unloaded mapblock collisions
        -- or when the velocity changes are negligibly small
    }

ABM (ActiveBlockModifier) definition
------------------------------------

Used by `minetest.register_abm`.

    {
        label = "Lava cooling",
        -- Descriptive label for profiling purposes (optional).
        -- Definitions with identical labels will be listed as one.

        nodenames = {"default:lava_source"},
        -- Apply `action` function to these nodes.
        -- `group:groupname` can also be used here.

        neighbors = {"default:water_source", "default:water_flowing"},
        -- Only apply `action` to nodes that have one of, or any
        -- combination of, these neighbors.
        -- If left out or empty, any neighbor will do.
        -- `group:groupname` can also be used here.

        interval = 1.0,
        -- Operation interval in seconds

        chance = 1,
        -- Chance of triggering `action` per-node per-interval is 1.0 / this
        -- value

        min_y = -32768,
        max_y = 32767,
        -- min and max height levels where ABM will be processed
        -- can be used to reduce CPU usage

        catch_up = true,
        -- If true, catch-up behaviour is enabled: The `chance` value is
        -- temporarily reduced when returning to an area to simulate time lost
        -- by the area being unattended. Note that the `chance` value can often
        -- be reduced to 1.

        action = function(pos, node, active_object_count, active_object_count_wider),
        -- Function triggered for each qualifying node.
        -- `active_object_count` is number of active objects in the node's
        -- mapblock.
        -- `active_object_count_wider` is number of active objects in the node's
        -- mapblock plus all 26 neighboring mapblocks. If any neighboring
        -- mapblocks are unloaded an estmate is calculated for them based on
        -- loaded mapblocks.
    }

LBM (LoadingBlockModifier) definition
-------------------------------------

Used by `minetest.register_lbm`.

A loading block modifier (LBM) is used to define a function that is called for
specific nodes (defined by `nodenames`) when a mapblock which contains such nodes
gets loaded.

    {
        label = "Upgrade legacy doors",
        -- Descriptive label for profiling purposes (optional).
        -- Definitions with identical labels will be listed as one.

        name = "modname:replace_legacy_door",

        nodenames = {"default:lava_source"},
        -- List of node names to trigger the LBM on.
        -- Also non-registered nodes will work.
        -- Groups (as of group:groupname) will work as well.

        run_at_every_load = false,
        -- Whether to run the LBM's action every time a block gets loaded,
        -- and not only the first time the block gets loaded after the LBM
        -- was introduced.

        action = function(pos, node),
    }

Tile definition
---------------

* `"image.png"`
* `{name="image.png", animation={Tile Animation definition}}`
* `{name="image.png", backface_culling=bool, align_style="node"/"world"/"user", scale=int}`
    * backface culling enabled by default for most nodes
    * align style determines whether the texture will be rotated with the node
      or kept aligned with its surroundings. "user" means that client
      setting will be used, similar to `glasslike_framed_optional`.
      Note: supported by solid nodes and nodeboxes only.
    * scale is used to make texture span several (exactly `scale`) nodes,
      instead of just one, in each direction. Works for world-aligned
      textures only.
      Note that as the effect is applied on per-mapblock basis, `16` should
      be equally divisible by `scale` or you may get wrong results.
* `{name="image.png", color=ColorSpec}`
    * the texture's color will be multiplied with this color.
    * the tile's color overrides the owning node's color in all cases.
* deprecated, yet still supported field names:
    * `image` (name)

Tile animation definition
-------------------------

    {
        type = "vertical_frames",

        aspect_w = 16,
        -- Width of a frame in pixels

        aspect_h = 16,
        -- Height of a frame in pixels

        length = 3.0,
        -- Full loop length
    }

    {
        type = "sheet_2d",

        frames_w = 5,
        -- Width in number of frames

        frames_h = 3,
        -- Height in number of frames

        frame_length = 0.5,
        -- Length of a single frame
    }

Item definition
---------------

Used by `minetest.register_node`, `minetest.register_craftitem`, and
`minetest.register_tool`.

    {
        description = "Steel Axe",
        -- Can contain new lines. "\n" has to be used as new line character.
        -- See also: `get_description` in [`ItemStack`]

        short_description = "Steel Axe",
        -- Must not contain new lines.
        -- Defaults to nil.
        -- Use an [`ItemStack`] to get the short description, eg:
        --   ItemStack(itemname):get_short_description()

        groups = {},
        -- key = name, value = rating; rating = 1..3.
        -- If rating not applicable, use 1.
        -- e.g. {wool = 1, fluffy = 3}
        --      {soil = 2, outerspace = 1, crumbly = 1}
        --      {bendy = 2, snappy = 1},
        --      {hard = 1, metal = 1, spikes = 1}

        inventory_image = "default_tool_steelaxe.png",

        inventory_overlay = "overlay.png",
        -- An overlay which does not get colorized

        wield_image = "",

        wield_overlay = "",

        palette = "",
        -- An image file containing the palette of a node.
        -- You can set the currently used color as the "palette_index" field of
        -- the item stack metadata.
        -- The palette is always stretched to fit indices between 0 and 255, to
        -- ensure compatibility with "colorfacedir" and "colorwallmounted" nodes.

        color = "0xFFFFFFFF",
        -- The color of the item. The palette overrides this.

        wield_scale = {x = 1, y = 1, z = 1},

        -- The default value of 99 may be configured by
        -- users using the setting "default_stack_max"
        stack_max = 99,

        range = 4.0,

        liquids_pointable = false,
        -- If true, item points to all liquid nodes (`liquidtype ~= "none"`),
        -- even those for which `pointable = false`

        light_source = 0,
        -- When used for nodes: Defines amount of light emitted by node.
        -- Otherwise: Defines texture glow when viewed as a dropped item
        -- To set the maximum (14), use the value 'minetest.LIGHT_MAX'.
        -- A value outside the range 0 to minetest.LIGHT_MAX causes undefined
        -- behavior.

        -- See "Tool Capabilities" section for an example including explanation
        tool_capabilities = {
            full_punch_interval = 1.0,
            max_drop_level = 0,
            groupcaps = {
                -- For example:
                choppy = {times = {[1] = 2.50, [2] = 1.40, [3] = 1.00},
                         uses = 20, maxlevel = 2},
            },
            damage_groups = {groupname = damage},
            -- Damage values must be between -32768 and 32767 (2^15)

            punch_attack_uses = nil,
            -- Amount of uses this tool has for attacking players and entities
            -- by punching them (0 = infinite uses).
            -- For compatibility, this is automatically set from the first
            -- suitable groupcap using the forumla "uses * 3^(maxlevel - 1)".
            -- It is recommend to set this explicitly instead of relying on the
            -- fallback behavior.
        },

        node_placement_prediction = nil,
        -- If nil and item is node, prediction is made automatically.
        -- If nil and item is not a node, no prediction is made.
        -- If "" and item is anything, no prediction is made.
        -- Otherwise should be name of node which the client immediately places
        -- on ground when the player places the item. Server will always update
        -- actual result to client in a short moment.

        node_dig_prediction = "air",
        -- if "", no prediction is made.
        -- if "air", node is removed.
        -- Otherwise should be name of node which the client immediately places
        -- upon digging. Server will always update actual result shortly.

        sound = {
            -- Definition of items sounds to be played at various events.
            -- All fields in this table are optional.

            breaks = <SimpleSoundSpec>,
            -- When tool breaks due to wear. Ignored for non-tools

            eat = <SimpleSoundSpec>,
            -- When item is eaten with `minetest.do_item_eat`
        },

        on_place = function(itemstack, placer, pointed_thing),
        -- When the 'place' key was pressed with the item in hand
        -- and a node was pointed at.
        -- Shall place item and return the leftover itemstack
        -- or nil to not modify the inventory.
        -- The placer may be any ObjectRef or nil.
        -- default: minetest.item_place

        on_secondary_use = function(itemstack, user, pointed_thing),
        -- Same as on_place but called when not pointing at a node.
        -- Function must return either nil if inventory shall not be modified,
        -- or an itemstack to replace the original itemstack.
        -- The user may be any ObjectRef or nil.
        -- default: nil

        on_drop = function(itemstack, dropper, pos),
        -- Shall drop item and return the leftover itemstack.
        -- The dropper may be any ObjectRef or nil.
        -- default: minetest.item_drop

        on_use = function(itemstack, user, pointed_thing),
        -- default: nil
        -- When user pressed the 'punch/mine' key with the item in hand.
        -- Function must return either nil if inventory shall not be modified,
        -- or an itemstack to replace the original itemstack.
        -- e.g. itemstack:take_item(); return itemstack
        -- Otherwise, the function is free to do what it wants.
        -- The user may be any ObjectRef or nil.
        -- The default functions handle regular use cases.

        after_use = function(itemstack, user, node, digparams),
        -- default: nil
        -- If defined, should return an itemstack and will be called instead of
        -- wearing out the item (if tool). If returns nil, does nothing.
        -- If after_use doesn't exist, it is the same as:
        --   function(itemstack, user, node, digparams)
        --     itemstack:add_wear(digparams.wear)
        --     return itemstack
        --   end
        -- The user may be any ObjectRef or nil.

        _custom_field = whatever,
        -- Add your own custom fields. By convention, all custom field names
        -- should start with `_` to avoid naming collisions with future engine
        -- usage.
    }

Node definition
---------------

Used by `minetest.register_node`.

    {
        -- <all fields allowed in item definitions>,

        drawtype = "normal",  -- See "Node drawtypes"

        visual_scale = 1.0,
        -- Supported for drawtypes "plantlike", "signlike", "torchlike",
        -- "firelike", "mesh", "nodebox", "allfaces".
        -- For plantlike and firelike, the image will start at the bottom of the
        -- node. For torchlike, the image will start at the surface to which the
        -- node "attaches". For the other drawtypes the image will be centered
        -- on the node.

        tiles = {tile definition 1, def2, def3, def4, def5, def6},
        -- Textures of node; +Y, -Y, +X, -X, +Z, -Z
        -- Old field name was 'tile_images'.
        -- List can be shortened to needed length.

        overlay_tiles = {tile definition 1, def2, def3, def4, def5, def6},
        -- Same as `tiles`, but these textures are drawn on top of the base
        -- tiles. You can use this to colorize only specific parts of your
        -- texture. If the texture name is an empty string, that overlay is not
        -- drawn. Since such tiles are drawn twice, it is not recommended to use
        -- overlays on very common nodes.

        special_tiles = {tile definition 1, Tile definition 2},
        -- Special textures of node; used rarely.
        -- Old field name was 'special_materials'.
        -- List can be shortened to needed length.

        color = ColorSpec,
        -- The node's original color will be multiplied with this color.
        -- If the node has a palette, then this setting only has an effect in
        -- the inventory and on the wield item.

        use_texture_alpha = ...,
        -- Specifies how the texture's alpha channel will be used for rendering.
        -- possible values:
        -- * "opaque": Node is rendered opaque regardless of alpha channel
        -- * "clip": A given pixel is either fully see-through or opaque
        --           depending on the alpha channel being below/above 50% in value
        -- * "blend": The alpha channel specifies how transparent a given pixel
        --            of the rendered node is
        -- The default is "opaque" for drawtypes normal, liquid and flowingliquid;
        -- "clip" otherwise.
        -- If set to a boolean value (deprecated): true either sets it to blend
        -- or clip, false sets it to clip or opaque mode depending on the drawtype.

        palette = "palette.png",
        -- The node's `param2` is used to select a pixel from the image.
        -- Pixels are arranged from left to right and from top to bottom.
        -- The node's color will be multiplied with the selected pixel's color.
        -- Tiles can override this behavior.
        -- Only when `paramtype2` supports palettes.

        post_effect_color = "green#0F",
        -- Screen tint if player is inside node, see "ColorSpec"

        paramtype = "none",  -- See "Nodes"

        paramtype2 = "none",  -- See "Nodes"

        place_param2 = nil,  -- Force value for param2 when player places node

        is_ground_content = true,
        -- If false, the cave generator and dungeon generator will not carve
        -- through this node.
        -- Specifically, this stops mod-added nodes being removed by caves and
        -- dungeons when those generate in a neighbor mapchunk and extend out
        -- beyond the edge of that mapchunk.

        sunlight_propagates = false,
        -- If true, sunlight will go infinitely through this node

        walkable = true,  -- If true, objects collide with node

        pointable = true,  -- If true, can be pointed at

        diggable = true,  -- If false, can never be dug

        climbable = false,  -- If true, can be climbed on (ladder)

        move_resistance = 0,
        -- Slows down movement of players through this node (max. 7).
        -- If this is nil, it will be equal to liquid_viscosity.
        -- Note: If liquid movement physics apply to the node
        -- (see `liquid_move_physics`), the movement speed will also be
        -- affected by the `movement_liquid_*` settings.

        buildable_to = false,  -- If true, placed nodes can replace this node

        floodable = false,
        -- If true, liquids flow into and replace this node.
        -- Warning: making a liquid node 'floodable' will cause problems.

        liquidtype = "none",  -- specifies liquid flowing physics
        -- * "none":    no liquid flowing physics
        -- * "source":  spawns flowing liquid nodes at all 4 sides and below;
        --              recommended drawtype: "liquid".
        -- * "flowing": spawned from source, spawns more flowing liquid nodes
        --              around it until `liquid_range` is reached;
        --              will drain out without a source;
        --              recommended drawtype: "flowingliquid".
        -- If it's "source" or "flowing" and `liquid_range > 0`, then
        -- both `liquid_alternative_*` fields must be specified

        liquid_alternative_flowing = "",  -- Flowing version of source liquid

        liquid_alternative_source = "",  -- Source version of flowing liquid

        liquid_viscosity = 0,
        -- Controls speed at which the liquid spreads/flows (max. 7).
        -- 0 is fastest, 7 is slowest.
        -- By default, this also slows down movement of players inside the node
        -- (can be overridden using `move_resistance`)

        liquid_renewable = true,
        -- If true, a new liquid source can be created by placing two or more
        -- sources nearby

        liquid_move_physics = nil, -- specifies movement physics if inside node
        -- * false: No liquid movement physics apply.
        -- * true: Enables liquid movement physics. Enables things like
        --   ability to "swim" up/down, sinking slowly if not moving,
        --   smoother speed change when falling into, etc. The `movement_liquid_*`
        --   settings apply.
        -- * nil: Will be treated as true if `liquidype ~= "none"`
        --   and as false otherwise.
        -- Default: nil

        leveled = 0,
        -- Only valid for "nodebox" drawtype with 'type = "leveled"'.
        -- Allows defining the nodebox height without using param2.
        -- The nodebox height is 'leveled' / 64 nodes.
        -- The maximum value of 'leveled' is `leveled_max`.

        leveled_max = 127,
        -- Maximum value for `leveled` (0-127), enforced in
        -- `minetest.set_node_level` and `minetest.add_node_level`.
        -- Values above 124 might causes collision detection issues.

        liquid_range = 8,
        -- Maximum distance that flowing liquid nodes can spread around
        -- source on flat land;
        -- maximum = 8; set to 0 to disable liquid flow

        drowning = 0,
        -- Player will take this amount of damage if no bubbles are left

        damage_per_second = 0,
        -- If player is inside node, this damage is caused

        node_box = {type="regular"},  -- See "Node boxes"

        connects_to = nodenames,
        -- Used for nodebox nodes with the type == "connected".
        -- Specifies to what neighboring nodes connections will be drawn.
        -- e.g. `{"group:fence", "default:wood"}` or `"default:stone"`

        connect_sides = { "top", "bottom", "front", "left", "back", "right" },
        -- Tells connected nodebox nodes to connect only to these sides of this
        -- node

        mesh = "model.obj",
        -- File name of mesh when using "mesh" drawtype

        selection_box = {
            type = "fixed",
            fixed = {
                {-2 / 16, -0.5, -2 / 16, 2 / 16, 3 / 16, 2 / 16},
                -- Node box format: see [Node boxes]
            },
        },
        -- Custom selection box definition. Multiple boxes can be defined.
        -- If "nodebox" drawtype is used and selection_box is nil, then node_box
        -- definition is used for the selection box.

        collision_box = {
            type = "fixed",
            fixed = {
                {-2 / 16, -0.5, -2 / 16, 2 / 16, 3 / 16, 2 / 16},
                -- Node box format: see [Node boxes]
            },
        },
        -- Custom collision box definition. Multiple boxes can be defined.
        -- If "nodebox" drawtype is used and collision_box is nil, then node_box
        -- definition is used for the collision box.

        -- Support maps made in and before January 2012
        legacy_facedir_simple = false,
        legacy_wallmounted = false,

        waving = 0,
        -- Valid for drawtypes:
        -- mesh, nodebox, plantlike, allfaces_optional, liquid, flowingliquid.
        -- 1 - wave node like plants (node top moves side-to-side, bottom is fixed)
        -- 2 - wave node like leaves (whole node moves side-to-side)
        -- 3 - wave node like liquids (whole node moves up and down)
        -- Not all models will properly wave.
        -- plantlike drawtype can only wave like plants.
        -- allfaces_optional drawtype can only wave like leaves.
        -- liquid, flowingliquid drawtypes can only wave like liquids.

        sounds = {
            -- Definition of node sounds to be played at various events.
            -- All fields in this table are optional.

            footstep = <SimpleSoundSpec>,
            -- If walkable, played when object walks on it. If node is
            -- climbable or a liquid, played when object moves through it

            dig = <SimpleSoundSpec> or "__group",
            -- While digging node.
            -- If `"__group"`, then the sound will be
            -- `default_dig_<groupname>`, where `<groupname>` is the
            -- name of the item's digging group with the fastest digging time.
            -- In case of a tie, one of the sounds will be played (but we
            -- cannot predict which one)
            -- Default value: `"__group"`

            dug = <SimpleSoundSpec>,
            -- Node was dug

            place = <SimpleSoundSpec>,
            -- Node was placed. Also played after falling

            place_failed = <SimpleSoundSpec>,
            -- When node placement failed.
            -- Note: This happens if the _built-in_ node placement failed.
            -- This sound will still be played if the node is placed in the
            -- `on_place` callback manually.

            fall = <SimpleSoundSpec>,
            -- When node starts to fall or is detached
        },

        drop = "",
        -- Name of dropped item when dug.
        -- Default dropped item is the node itself.
        -- Using a table allows multiple items, drop chances and item filtering.
        -- Item filtering by string matching is deprecated.
        drop = {
            max_items = 1,
            -- Maximum number of item lists to drop.
            -- The entries in 'items' are processed in order. For each:
            -- Item filtering is applied, chance of drop is applied, if both are
            -- successful the entire item list is dropped.
            -- Entry processing continues until the number of dropped item lists
            -- equals 'max_items'.
            -- Therefore, entries should progress from low to high drop chance.
            items = {
                -- Entry examples.
                {
                    -- 1 in 1000 chance of dropping a diamond.
                    -- Default rarity is '1'.
                    rarity = 1000,
                    items = {"default:diamond"},
                },
                {
                    -- Only drop if using an item whose name is identical to one
                    -- of these.
                    tools = {"default:shovel_mese", "default:shovel_diamond"},
                    rarity = 5,
                    items = {"default:dirt"},
                    -- Whether all items in the dropped item list inherit the
                    -- hardware coloring palette color from the dug node.
                    -- Default is 'false'.
                    inherit_color = true,
                },
                {
                    -- Only drop if using an item whose name contains
                    -- "default:shovel_" (this item filtering by string matching
                    -- is deprecated, use tool_groups instead).
                    tools = {"~default:shovel_"},
                    rarity = 2,
                    -- The item list dropped.
                    items = {"default:sand", "default:desert_sand"},
                },
                {
                    -- Only drop if using an item in the "magicwand" group, or
                    -- an item that is in both the "pickaxe" and the "lucky"
                    -- groups.
                    tool_groups = {
                        "magicwand",
                        {"pickaxe", "lucky"}
                    },
                    items = {"default:coal_lump"},
                },
            },
        },

        on_construct = function(pos),
        -- Node constructor; called after adding node.
        -- Can set up metadata and stuff like that.
        -- Not called for bulk node placement (i.e. schematics and VoxelManip).
        -- default: nil

        on_destruct = function(pos),
        -- Node destructor; called before removing node.
        -- Not called for bulk node placement.
        -- default: nil

        after_destruct = function(pos, oldnode),
        -- Node destructor; called after removing node.
        -- Not called for bulk node placement.
        -- default: nil

        on_flood = function(pos, oldnode, newnode),
        -- Called when a liquid (newnode) is about to flood oldnode, if it has
        -- `floodable = true` in the nodedef. Not called for bulk node placement
        -- (i.e. schematics and VoxelManip) or air nodes. If return true the
        -- node is not flooded, but on_flood callback will most likely be called
        -- over and over again every liquid update interval.
        -- Default: nil
        -- Warning: making a liquid node 'floodable' will cause problems.

        preserve_metadata = function(pos, oldnode, oldmeta, drops),
        -- Called when oldnode is about be converted to an item, but before the
        -- node is deleted from the world or the drops are added. This is
        -- generally the result of either the node being dug or an attached node
        -- becoming detached.
        -- oldmeta is the NodeMetaRef of the oldnode before deletion.
        -- drops is a table of ItemStacks, so any metadata to be preserved can
        -- be added directly to one or more of the dropped items. See
        -- "ItemStackMetaRef".
        -- default: nil

        after_place_node = function(pos, placer, itemstack, pointed_thing),
        -- Called after constructing node when node was placed using
        -- minetest.item_place_node / minetest.place_node.
        -- If return true no item is taken from itemstack.
        -- `placer` may be any valid ObjectRef or nil.
        -- default: nil

        after_dig_node = function(pos, oldnode, oldmetadata, digger),
        -- oldmetadata is in table format.
        -- Called after destructing node when node was dug using
        -- minetest.node_dig / minetest.dig_node.
        -- default: nil

        can_dig = function(pos, [player]),
        -- Returns true if node can be dug, or false if not.
        -- default: nil

        on_punch = function(pos, node, puncher, pointed_thing),
        -- default: minetest.node_punch
        -- Called when puncher (an ObjectRef) punches the node at pos.
        -- By default calls minetest.register_on_punchnode callbacks.

        on_rightclick = function(pos, node, clicker, itemstack, pointed_thing),
        -- default: nil
        -- Called when clicker (an ObjectRef) used the 'place/build' key
        -- (not neccessarily an actual rightclick)
        -- while pointing at the node at pos with 'node' being the node table.
        -- itemstack will hold clicker's wielded item.
        -- Shall return the leftover itemstack.
        -- Note: pointed_thing can be nil, if a mod calls this function.
        -- This function does not get triggered by clients <=0.4.16 if the
        -- "formspec" node metadata field is set.

        on_dig = function(pos, node, digger),
        -- default: minetest.node_dig
        -- By default checks privileges, wears out item (if tool) and removes node.
        -- return true if the node was dug successfully, false otherwise.
        -- Deprecated: returning nil is the same as returning true.

        on_timer = function(pos, elapsed),
        -- default: nil
        -- called by NodeTimers, see minetest.get_node_timer and NodeTimerRef.
        -- elapsed is the total time passed since the timer was started.
        -- return true to run the timer for another cycle with the same timeout
        -- value.

        on_receive_fields = function(pos, formname, fields, sender),
        -- fields = {name1 = value1, name2 = value2, ...}
        -- Called when an UI form (e.g. sign text input) returns data.
        -- See minetest.register_on_player_receive_fields for more info.
        -- default: nil

        allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player),
        -- Called when a player wants to move items inside the inventory.
        -- Return value: number of items allowed to move.

        allow_metadata_inventory_put = function(pos, listname, index, stack, player),
        -- Called when a player wants to put something into the inventory.
        -- Return value: number of items allowed to put.
        -- Return value -1: Allow and don't modify item count in inventory.

        allow_metadata_inventory_take = function(pos, listname, index, stack, player),
        -- Called when a player wants to take something out of the inventory.
        -- Return value: number of items allowed to take.
        -- Return value -1: Allow and don't modify item count in inventory.

        on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player),
        on_metadata_inventory_put = function(pos, listname, index, stack, player),
        on_metadata_inventory_take = function(pos, listname, index, stack, player),
        -- Called after the actual action has happened, according to what was
        -- allowed.
        -- No return value.

        on_blast = function(pos, intensity),
        -- intensity: 1.0 = mid range of regular TNT.
        -- If defined, called when an explosion touches the node, instead of
        -- removing the node.

        mod_origin = "modname",
        -- stores which mod actually registered a node
        -- if it can not find a source, returns "??"
        -- useful for getting what mod truly registered something
        -- example: if a node is registered as ":othermodname:nodename",
        -- nodename will show "othermodname", but mod_orgin will say "modname"
    }

Crafting recipes
----------------

Used by `minetest.register_craft`.

### Shaped

    {
        output = "default:pick_stone",
        recipe = {
            {"default:cobble", "default:cobble", "default:cobble"},
            {"", "default:stick", ""},
            {"", "default:stick", ""},  -- Also groups; e.g. "group:crumbly"
        },
        replacements = <list of item pairs>,
        -- replacements: replace one input item with another item on crafting
        -- (optional).
    }

### Shapeless

    {
        type = "shapeless",
        output = "mushrooms:mushroom_stew",
        recipe = {
            "mushrooms:bowl",
            "mushrooms:mushroom_brown",
            "mushrooms:mushroom_red",
        },
        replacements = <list of item pairs>,
    }

### Tool repair

    {
        type = "toolrepair",
        additional_wear = -0.02, -- multiplier of 65536
    }

Adds a shapeless recipe for *every* tool that doesn't have the `disable_repair=1`
group. Player can put 2 equal tools in the craft grid to get one "repaired" tool
back.
The wear of the output is determined by the wear of both tools, plus a
'repair bonus' given by `additional_wear`. To reduce the wear (i.e. 'repair'),
you want `additional_wear` to be negative.

The formula used to calculate the resulting wear is:

    65536 - ( (65536 - tool_1_wear) + (65536 - tool_2_wear) + 65536 * additional_wear )

The result is rounded and can't be lower than 0. If the result is 65536 or higher,
no crafting is possible.

### Cooking

    {
        type = "cooking",
        output = "default:glass",
        recipe = "default:sand",
        cooktime = 3,
    }

### Furnace fuel

    {
        type = "fuel",
        recipe = "bucket:bucket_lava",
        burntime = 60,
        replacements = {{"bucket:bucket_lava", "bucket:bucket_empty"}},
    }

Ore definition
--------------

Used by `minetest.register_ore`.

See [Ores] section above for essential information.

    {
        ore_type = "scatter",

        ore = "default:stone_with_coal",

        ore_param2 = 3,
        -- Facedir rotation. Default is 0 (unchanged rotation)

        wherein = "default:stone",
        -- A list of nodenames is supported too

        clust_scarcity = 8 * 8 * 8,
        -- Ore has a 1 out of clust_scarcity chance of spawning in a node.
        -- If the desired average distance between ores is 'd', set this to
        -- d * d * d.

        clust_num_ores = 8,
        -- Number of ores in a cluster

        clust_size = 3,
        -- Size of the bounding box of the cluster.
        -- In this example, there is a 3 * 3 * 3 cluster where 8 out of the 27
        -- nodes are coal ore.

        y_min = -31000,
        y_max = 64,
        -- Lower and upper limits for ore

        flags = "",
        -- Attributes for the ore generation, see 'Ore attributes' section above

        noise_threshold = 0.5,
        -- If noise is above this threshold, ore is placed. Not needed for a
        -- uniform distribution.

        noise_params = {
            offset = 0,
            scale = 1,
            spread = {x = 100, y = 100, z = 100},
            seed = 23,
            octaves = 3,
            persistence = 0.7
        },
        -- NoiseParams structure describing one of the perlin noises used for
        -- ore distribution.
        -- Needed by "sheet", "puff", "blob" and "vein" ores.
        -- Omit from "scatter" ore for a uniform ore distribution.
        -- Omit from "stratum" ore for a simple horizontal strata from y_min to
        -- y_max.

        biomes = {"desert", "rainforest"},
        -- List of biomes in which this ore occurs.
        -- Occurs in all biomes if this is omitted, and ignored if the Mapgen
        -- being used does not support biomes.
        -- Can be a list of (or a single) biome names, IDs, or definitions.

        -- Type-specific parameters

        -- sheet
        column_height_min = 1,
        column_height_max = 16,
        column_midpoint_factor = 0.5,

        -- puff
        np_puff_top = {
            offset = 4,
            scale = 2,
            spread = {x = 100, y = 100, z = 100},
            seed = 47,
            octaves = 3,
            persistence = 0.7
        },
        np_puff_bottom = {
            offset = 4,
            scale = 2,
            spread = {x = 100, y = 100, z = 100},
            seed = 11,
            octaves = 3,
            persistence = 0.7
        },

        -- vein
        random_factor = 1.0,

        -- stratum
        np_stratum_thickness = {
            offset = 8,
            scale = 4,
            spread = {x = 100, y = 100, z = 100},
            seed = 17,
            octaves = 3,
            persistence = 0.7
        },
        stratum_thickness = 8,
    }

Biome definition
----------------

Used by `minetest.register_biome`.

The maximum number of biomes that can be used is 65535. However, using an
excessive number of biomes will slow down map generation. Depending on desired
performance and computing power the practical limit is much lower.

    {
        name = "tundra",

        node_dust = "default:snow",
        -- Node dropped onto upper surface after all else is generated

        node_top = "default:dirt_with_snow",
        depth_top = 1,
        -- Node forming surface layer of biome and thickness of this layer

        node_filler = "default:permafrost",
        depth_filler = 3,
        -- Node forming lower layer of biome and thickness of this layer

        node_stone = "default:bluestone",
        -- Node that replaces all stone nodes between roughly y_min and y_max.

        node_water_top = "default:ice",
        depth_water_top = 10,
        -- Node forming a surface layer in seawater with the defined thickness

        node_water = "",
        -- Node that replaces all seawater nodes not in the surface layer

        node_river_water = "default:ice",
        -- Node that replaces river water in mapgens that use
        -- default:river_water

        node_riverbed = "default:gravel",
        depth_riverbed = 2,
        -- Node placed under river water and thickness of this layer

        node_cave_liquid = "default:lava_source",
        node_cave_liquid = {"default:water_source", "default:lava_source"},
        -- Nodes placed inside 50% of the medium size caves.
        -- Multiple nodes can be specified, each cave will use a randomly
        -- chosen node from the list.
        -- If this field is left out or 'nil', cave liquids fall back to
        -- classic behaviour of lava and water distributed using 3D noise.
        -- For no cave liquid, specify "air".

        node_dungeon = "default:cobble",
        -- Node used for primary dungeon structure.
        -- If absent, dungeon nodes fall back to the 'mapgen_cobble' mapgen
        -- alias, if that is also absent, dungeon nodes fall back to the biome
        -- 'node_stone'.
        -- If present, the following two nodes are also used.

        node_dungeon_alt = "default:mossycobble",
        -- Node used for randomly-distributed alternative structure nodes.
        -- If alternative structure nodes are not wanted leave this absent for
        -- performance reasons.

        node_dungeon_stair = "stairs:stair_cobble",
        -- Node used for dungeon stairs.
        -- If absent, stairs fall back to 'node_dungeon'.

        y_max = 31000,
        y_min = 1,
        -- Upper and lower limits for biome.
        -- Alternatively you can use xyz limits as shown below.

        max_pos = {x = 31000, y = 128, z = 31000},
        min_pos = {x = -31000, y = 9, z = -31000},
        -- xyz limits for biome, an alternative to using 'y_min' and 'y_max'.
        -- Biome is limited to a cuboid defined by these positions.
        -- Any x, y or z field left undefined defaults to -31000 in 'min_pos' or
        -- 31000 in 'max_pos'.

        vertical_blend = 8,
        -- Vertical distance in nodes above 'y_max' over which the biome will
        -- blend with the biome above.
        -- Set to 0 for no vertical blend. Defaults to 0.

        heat_point = 0,
        humidity_point = 50,
        -- Characteristic temperature and humidity for the biome.
        -- These values create 'biome points' on a voronoi diagram with heat and
        -- humidity as axes. The resulting voronoi cells determine the
        -- distribution of the biomes.
        -- Heat and humidity have average values of 50, vary mostly between
        -- 0 and 100 but can exceed these values.
    }

Decoration definition
---------------------

See [Decoration types]. Used by `minetest.register_decoration`.

    {
        deco_type = "simple",

        place_on = "default:dirt_with_grass",
        -- Node (or list of nodes) that the decoration can be placed on

        sidelen = 8,
        -- Size of the square divisions of the mapchunk being generated.
        -- Determines the resolution of noise variation if used.
        -- If the chunk size is not evenly divisible by sidelen, sidelen is made
        -- equal to the chunk size.

        fill_ratio = 0.02,
        -- The value determines 'decorations per surface node'.
        -- Used only if noise_params is not specified.
        -- If >= 10.0 complete coverage is enabled and decoration placement uses
        -- a different and much faster method.

        noise_params = {
            offset = 0,
            scale = 0.45,
            spread = {x = 100, y = 100, z = 100},
            seed = 354,
            octaves = 3,
            persistence = 0.7,
            lacunarity = 2.0,
            flags = "absvalue"
        },
        -- NoiseParams structure describing the perlin noise used for decoration
        -- distribution.
        -- A noise value is calculated for each square division and determines
        -- 'decorations per surface node' within each division.
        -- If the noise value >= 10.0 complete coverage is enabled and
        -- decoration placement uses a different and much faster method.

        biomes = {"Oceanside", "Hills", "Plains"},
        -- List of biomes in which this decoration occurs. Occurs in all biomes
        -- if this is omitted, and ignored if the Mapgen being used does not
        -- support biomes.
        -- Can be a list of (or a single) biome names, IDs, or definitions.

        y_min = -31000,
        y_max = 31000,
        -- Lower and upper limits for decoration.
        -- These parameters refer to the Y co-ordinate of the 'place_on' node.

        spawn_by = "default:water",
        -- Node (or list of nodes) that the decoration only spawns next to.
        -- Checks the 8 neighbouring nodes on the same Y, and also the ones
        -- at Y+1, excluding both center nodes.

        num_spawn_by = 1,
        -- Number of spawn_by nodes that must be surrounding the decoration
        -- position to occur.
        -- If absent or -1, decorations occur next to any nodes.

        flags = "liquid_surface, force_placement, all_floors, all_ceilings",
        -- Flags for all decoration types.
        -- "liquid_surface": Instead of placement on the highest solid surface
        --   in a mapchunk column, placement is on the highest liquid surface.
        --   Placement is disabled if solid nodes are found above the liquid
        --   surface.
        -- "force_placement": Nodes other than "air" and "ignore" are replaced
        --   by the decoration.
        -- "all_floors", "all_ceilings": Instead of placement on the highest
        --   surface in a mapchunk the decoration is placed on all floor and/or
        --   ceiling surfaces, for example in caves and dungeons.
        --   Ceiling decorations act as an inversion of floor decorations so the
        --   effect of 'place_offset_y' is inverted.
        --   Y-slice probabilities do not function correctly for ceiling
        --   schematic decorations as the behaviour is unchanged.
        --   If a single decoration registration has both flags the floor and
        --   ceiling decorations will be aligned vertically.

        ----- Simple-type parameters

        decoration = "default:grass",
        -- The node name used as the decoration.
        -- If instead a list of strings, a randomly selected node from the list
        -- is placed as the decoration.

        height = 1,
        -- Decoration height in nodes.
        -- If height_max is not 0, this is the lower limit of a randomly
        -- selected height.

        height_max = 0,
        -- Upper limit of the randomly selected height.
        -- If absent, the parameter 'height' is used as a constant.

        param2 = 0,
        -- Param2 value of decoration nodes.
        -- If param2_max is not 0, this is the lower limit of a randomly
        -- selected param2.

        param2_max = 0,
        -- Upper limit of the randomly selected param2.
        -- If absent, the parameter 'param2' is used as a constant.

        place_offset_y = 0,
        -- Y offset of the decoration base node relative to the standard base
        -- node position.
        -- Can be positive or negative. Default is 0.
        -- Effect is inverted for "all_ceilings" decorations.
        -- Ignored by 'y_min', 'y_max' and 'spawn_by' checks, which always refer
        -- to the 'place_on' node.

        ----- Schematic-type parameters

        schematic = "foobar.mts",
        -- If schematic is a string, it is the filepath relative to the current
        -- working directory of the specified Minetest schematic file.
        -- Could also be the ID of a previously registered schematic.

        schematic = {
            size = {x = 4, y = 6, z = 4},
            data = {
                {name = "default:cobble", param1 = 255, param2 = 0},
                {name = "default:dirt_with_grass", param1 = 255, param2 = 0},
                {name = "air", param1 = 255, param2 = 0},
                 ...
            },
            yslice_prob = {
                {ypos = 2, prob = 128},
                {ypos = 5, prob = 64},
                 ...
            },
        },
        -- Alternative schematic specification by supplying a table. The fields
        -- size and data are mandatory whereas yslice_prob is optional.
        -- See 'Schematic specifier' for details.

        replacements = {["oldname"] = "convert_to", ...},

        flags = "place_center_x, place_center_y, place_center_z",
        -- Flags for schematic decorations. See 'Schematic attributes'.

        rotation = "90",
        -- Rotation can be "0", "90", "180", "270", or "random"

        place_offset_y = 0,
        -- If the flag 'place_center_y' is set this parameter is ignored.
        -- Y offset of the schematic base node layer relative to the 'place_on'
        -- node.
        -- Can be positive or negative. Default is 0.
        -- Effect is inverted for "all_ceilings" decorations.
        -- Ignored by 'y_min', 'y_max' and 'spawn_by' checks, which always refer
        -- to the 'place_on' node.
    }

Chat command definition
-----------------------

Used by `minetest.register_chatcommand`.

    {
        params = "<name> <privilege>",  -- Short parameter description

        description = "Remove privilege from player",  -- Full description

        privs = {privs=true},  -- Require the "privs" privilege to run

        func = function(name, param),
        -- Called when command is run. Returns boolean success and text output.
        -- Special case: The help message is shown to the player if `func`
        -- returns false without a text output.
    }

Note that in params, use of symbols is as follows:

* `<>` signifies a placeholder to be replaced when the command is used. For
  example, when a player name is needed: `<name>`
* `[]` signifies param is optional and not required when the command is used.
  For example, if you require param1 but param2 is optional:
  `<param1> [<param2>]`
* `|` signifies exclusive or. The command requires one param from the options
  provided. For example: `<param1> | <param2>`
* `()` signifies grouping. For example, when param1 and param2 are both
  required, or only param3 is required: `(<param1> <param2>) | <param3>`

Privilege definition
--------------------

Used by `minetest.register_privilege`.

    {
        description = "",
        -- Privilege description

        give_to_singleplayer = true,
        -- Whether to grant the privilege to singleplayer.

        give_to_admin = true,
        -- Whether to grant the privilege to the server admin.
        -- Uses value of 'give_to_singleplayer' by default.

        on_grant = function(name, granter_name),
        -- Called when given to player 'name' by 'granter_name'.
        -- 'granter_name' will be nil if the priv was granted by a mod.

        on_revoke = function(name, revoker_name),
        -- Called when taken from player 'name' by 'revoker_name'.
        -- 'revoker_name' will be nil if the priv was revoked by a mod.

        -- Note that the above two callbacks will be called twice if a player is
        -- responsible, once with the player name, and then with a nil player
        -- name.
        -- Return true in the above callbacks to stop register_on_priv_grant or
        -- revoke being called.
    }

Detached inventory callbacks
----------------------------

Used by `minetest.create_detached_inventory`.

    {
        allow_move = function(inv, from_list, from_index, to_list, to_index, count, player),
        -- Called when a player wants to move items inside the inventory.
        -- Return value: number of items allowed to move.

        allow_put = function(inv, listname, index, stack, player),
        -- Called when a player wants to put something into the inventory.
        -- Return value: number of items allowed to put.
        -- Return value -1: Allow and don't modify item count in inventory.

        allow_take = function(inv, listname, index, stack, player),
        -- Called when a player wants to take something out of the inventory.
        -- Return value: number of items allowed to take.
        -- Return value -1: Allow and don't modify item count in inventory.

        on_move = function(inv, from_list, from_index, to_list, to_index, count, player),
        on_put = function(inv, listname, index, stack, player),
        on_take = function(inv, listname, index, stack, player),
        -- Called after the actual action has happened, according to what was
        -- allowed.
        -- No return value.
    }

HUD Definition
--------------

See [HUD] section.

Used by `Player:hud_add`. Returned by `Player:hud_get`.

    {
        hud_elem_type = "image",  -- See HUD element types
        -- Type of element, can be "image", "text", "statbar", "inventory",
        -- "compass" or "minimap"

        position = {x=0.5, y=0.5},
        -- Left corner position of element

        name = "<name>",

        scale = {x = 2, y = 2},

        text = "<text>",

        text2 = "<text>",

        number = 2,

        item = 3,
        -- Selected item in inventory. 0 for no item selected.

        direction = 0,
        -- Direction: 0: left-right, 1: right-left, 2: top-bottom, 3: bottom-top

        alignment = {x=0, y=0},

        offset = {x=0, y=0},

        size = { x=100, y=100 },
        -- Size of element in pixels

        z_index = 0,
        -- Z index : lower z-index HUDs are displayed behind higher z-index HUDs

        style = 0,
        -- For "text" elements sets font style: bitfield with 1 = bold, 2 = italic, 4 = monospace
    }

Particle definition
-------------------

Used by `minetest.add_particle`.

    {
        pos = {x=0, y=0, z=0},
        velocity = {x=0, y=0, z=0},
        acceleration = {x=0, y=0, z=0},
        -- Spawn particle at pos with velocity and acceleration

        expirationtime = 1,
        -- Disappears after expirationtime seconds

        size = 1,
        -- Scales the visual size of the particle texture.
        -- If `node` is set, size can be set to 0 to spawn a randomly-sized
        -- particle (just like actual node dig particles).

        collisiondetection = false,
        -- If true collides with `walkable` nodes and, depending on the
        -- `object_collision` field, objects too.

        collision_removal = false,
        -- If true particle is removed when it collides.
        -- Requires collisiondetection = true to have any effect.

        object_collision = false,
        -- If true particle collides with objects that are defined as
        -- `physical = true,` and `collide_with_objects = true,`.
        -- Requires collisiondetection = true to have any effect.

        vertical = false,
        -- If true faces player using y axis only

        texture = "image.png",
        -- The texture of the particle

        playername = "singleplayer",
        -- Optional, if specified spawns particle only on the player's client

        animation = {Tile Animation definition},
        -- Optional, specifies how to animate the particle texture

        glow = 0
        -- Optional, specify particle self-luminescence in darkness.
        -- Values 0-14.

        node = {name = "ignore", param2 = 0},
        -- Optional, if specified the particle will have the same appearance as
        -- node dig particles for the given node.
        -- `texture` and `animation` will be ignored if this is set.

        node_tile = 0,
        -- Optional, only valid in combination with `node`
        -- If set to a valid number 1-6, specifies the tile from which the
        -- particle texture is picked.
        -- Otherwise, the default behavior is used. (currently: any random tile)
    }


`ParticleSpawner` definition
----------------------------

Used by `minetest.add_particlespawner`.

    {
        amount = 1,
        -- Number of particles spawned over the time period `time`.

        time = 1,
        -- Lifespan of spawner in seconds.
        -- If time is 0 spawner has infinite lifespan and spawns the `amount` on
        -- a per-second basis.

        minpos = {x=0, y=0, z=0},
        maxpos = {x=0, y=0, z=0},
        minvel = {x=0, y=0, z=0},
        maxvel = {x=0, y=0, z=0},
        minacc = {x=0, y=0, z=0},
        maxacc = {x=0, y=0, z=0},
        minexptime = 1,
        maxexptime = 1,
        minsize = 1,
        maxsize = 1,
        -- The particles' properties are random values between the min and max
        -- values.
        -- applies to: pos, velocity, acceleration, expirationtime, size
        -- If `node` is set, min and maxsize can be set to 0 to spawn
        -- randomly-sized particles (just like actual node dig particles).

        collisiondetection = false,
        -- If true collide with `walkable` nodes and, depending on the
        -- `object_collision` field, objects too.

        collision_removal = false,
        -- If true particles are removed when they collide.
        -- Requires collisiondetection = true to have any effect.

        object_collision = false,
        -- If true particles collide with objects that are defined as
        -- `physical = true,` and `collide_with_objects = true,`.
        -- Requires collisiondetection = true to have any effect.

        attached = ObjectRef,
        -- If defined, particle positions, velocities and accelerations are
        -- relative to this object's position and yaw

        vertical = false,
        -- If true face player using y axis only

        texture = "image.png",
        -- The texture of the particle

        playername = "singleplayer",
        -- Optional, if specified spawns particles only on the player's client

        animation = {Tile Animation definition},
        -- Optional, specifies how to animate the particles' texture

        glow = 0
        -- Optional, specify particle self-luminescence in darkness.
        -- Values 0-14.

        node = {name = "ignore", param2 = 0},
        -- Optional, if specified the particles will have the same appearance as
        -- node dig particles for the given node.
        -- `texture` and `animation` will be ignored if this is set.

        node_tile = 0,
        -- Optional, only valid in combination with `node`
        -- If set to a valid number 1-6, specifies the tile from which the
        -- particle texture is picked.
        -- Otherwise, the default behavior is used. (currently: any random tile)
    }

`HTTPRequest` definition
------------------------

Used by `HTTPApiTable.fetch` and `HTTPApiTable.fetch_async`.

    {
        url = "http://example.org",

        timeout = 10,
        -- Timeout for request to be completed in seconds. Default depends on engine settings.

        method = "GET", "POST", "PUT" or "DELETE"
        -- The http method to use. Defaults to "GET".

        data = "Raw request data string" OR {field1 = "data1", field2 = "data2"},
        -- Data for the POST, PUT or DELETE request.
        -- Accepts both a string and a table. If a table is specified, encodes
        -- table as x-www-form-urlencoded key-value pairs.

        user_agent = "ExampleUserAgent",
        -- Optional, if specified replaces the default minetest user agent with
        -- given string

        extra_headers = { "Accept-Language: en-us", "Accept-Charset: utf-8" },
        -- Optional, if specified adds additional headers to the HTTP request.
        -- You must make sure that the header strings follow HTTP specification
        -- ("Key: Value").

        multipart = boolean
        -- Optional, if true performs a multipart HTTP request.
        -- Default is false.
        -- Post only, data must be array

        post_data = "Raw POST request data string" OR {field1 = "data1", field2 = "data2"},
        -- Deprecated, use `data` instead. Forces `method = "POST"`.
    }

`HTTPRequestResult` definition
------------------------------

Passed to `HTTPApiTable.fetch` callback. Returned by
`HTTPApiTable.fetch_async_get`.

    {
        completed = true,
        -- If true, the request has finished (either succeeded, failed or timed
        -- out)

        succeeded = true,
        -- If true, the request was successful

        timeout = false,
        -- If true, the request timed out

        code = 200,
        -- HTTP status code

        data = "response"
    }

Authentication handler definition
---------------------------------

Used by `minetest.register_authentication_handler`.

    {
        get_auth = function(name),
        -- Get authentication data for existing player `name` (`nil` if player
        -- doesn't exist).
        -- Returns following structure:
        -- `{password=<string>, privileges=<table>, last_login=<number or nil>}`

        create_auth = function(name, password),
        -- Create new auth data for player `name`.
        -- Note that `password` is not plain-text but an arbitrary
        -- representation decided by the engine.

        delete_auth = function(name),
        -- Delete auth data of player `name`.
        -- Returns boolean indicating success (false if player is nonexistent).

        set_password = function(name, password),
        -- Set password of player `name` to `password`.
        -- Auth data should be created if not present.

        set_privileges = function(name, privileges),
        -- Set privileges of player `name`.
        -- `privileges` is in table form, auth data should be created if not
        -- present.

        reload = function(),
        -- Reload authentication data from the storage location.
        -- Returns boolean indicating success.

        record_login = function(name),
        -- Called when player joins, used for keeping track of last_login

        iterate = function(),
        -- Returns an iterator (use with `for` loops) for all player names
        -- currently in the auth database
    }

Bit Library
-----------

Functions: bit.tobit, bit.tohex, bit.bnot, bit.band, bit.bor, bit.bxor, bit.lshift, bit.rshift, bit.arshift, bit.rol, bit.ror, bit.bswap

See http://bitop.luajit.org/ for advanced information.
]=]

dofile("init.lua")
-- print(md2f.header()..md2f.md2f(1,1,18,18,[[
-- # Level 1
-- ## Level 2
-- ### Level 3
-- #### Level 4
-- ##### Level 5
-- ###### Level 6




-- Paragraph 1 is a test paragaph, hopefully this is long enough to justify going to the next few lines.




-- This is another paragraph, should have worked.

--     Testing
--     This is a test


-- ```
-- int a = 5;
-- std::cout << a << std::endl;
-- ```

-- **Bold Text**

-- *Italics Text*

-- ***Bold and Italics***

-- ****Ultra Bold and Italics****

-- > Block quote attempt
-- > Multiline, and multi paragraph attemping to at least test test test test test test test test test
-- >
-- > Block Quote

-- 1. Numbers will
-- 3. Be Somewhat difficult
-- 2. To support

-- - Unordered
-- - Lists
-- - Should be a breeze, hopefully
-- * Personally, 
-- * I think this should start a new 
-- * list set


-- `test`
-- `test`

-- ![24,24,l](text)
-- ![36,36,r](text2)
-- ![48,48](item:///text3)

-- Nested `code text` should be monospaced

-- These

-- --- 

-- Should

-- *** 

-- All be lines

-- _______

-- <htts://www.google.com>

-- ----------

-- ----------

-- ]],nil))

-- For Stress Testing, ensuring nothing can error out the program
-- math.randomseed(1)
-- for i=1,20000,1 do
--     local str = {}
--     for j=1,5000,1 do
--         str[j] = string.char(math.random(1,255))
--         if j % 10 == 0 then
--             str[j] = "\n"
--         end
--     end
--     str = table.concat(str)
--     str = str:gsub(string.char(13),"")
--     md2f.md2f(1,1,18,18,str,nil)
-- end

print(md2f.header()..md2f.md2f(1,1,18,18,to_parse,nil))
