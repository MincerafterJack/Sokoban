# Sokoban

This is a little speed-coding (kinda) project I did way back in February 2024, made in the [Godot Engine](https://godotengine.org/).

It is able to load levels supplied by an external .skb file, create .skb files via an in-game level editor, and play levels to your heart's content.

This is my first ever finished godot project so plz don't laugh at my coding style too hard.

## Manual

```
Sokoban 1.0.1.0
(c) 2025 Cryonia
Published under the MIT No Attribution license.
More info in LICENSE.txt.

This is a Sokoban game made in Godot engine.
Push the crates to the circle target.
Push only, no pulling.
Push only one crate at a time.
If multiple players are present, their movement will be synchronized.

"classic.skb" is the level data file so you'd better not lose it.
It currently only has twenty levels or so because I'm lazy. Deal with it.


Keybinds:
Mouse wheel	Zoom in/out
Mouse drag	Move the viewfield

Page Up		Zoom in
Page Down	Zoom out
Arrow keys	Move the viewfield

W		Move up
A		Move left
S		Move down
D		Move right
R		Undo
Backspace	Reset level

Esc		Pause

Hard-coded, I know. Bite me.
```

## .skb file technical info

.skb files rely on godot's native serialization. [This section](https://docs.godotengine.org/en/4.2/tutorials/io/binary_serialization_api.html) in godot docs has more info about that.

Note that this link describes the 4.2 version of the engine which is an old version, though the site should tell you that.

All levels contain two layers of tile map, one for ground tiles and target tiles, one for crates, walls and the players, known as "stuff layer".

The data of the levels is written sequentially, each starting with the string "Sokoban", followed by two Dictionaries.

Dictionaries are basically an array of key:value pairs. If provided with a key, the engine can fetch a value.

The first dictionary is for the ground layer, the second is for the stuff layer.

The key describes the position of a tile, the value describes the type of said tile.

The types of tiles is presented in the following constants.

```
const DO_NOT_DRAW = Vector2i(-114, -514) // Only used in the level editor to simplify the code.
const NONE = Vector2i(-1, -1) // Only used in the level editor to erase stuff because it's a feature of godot
const FLOOR = Vector2i(0, 0)
const WALL = Vector2i(1, 0)
const TARGET = Vector2i(0, 1)
const CRATE = Vector2i(1, 1)
const PLAYER_DOWN = Vector2i(2, 0)
const PLAYER_RIGHT = Vector2i(3, 0)
const PLAYER_LEFT = Vector2i(2, 1)
const PLAYER_UP = Vector2i(3, 1)
```

Note that the Vector2i represents the position of the tile in the terrain.png texture. This position info is called atlas coordinate.

### Handling the .skb file

The game scans the entire selected file, trying to find any string stored in the format recognizable by the godot engine. It will take any string regardless of the actual content so YOU CAN RIGHT A FULL-BLOWN NOVEL IN THE LEVEL DATA!

The scanning uses godot's `get_var()` function, which finds the next variable, scans through it to fetch the data and returns it. It also leave the cursor at the end of said data.

Because of this, the cursor is parked right at the end of the string, and at the start of the ground layer dictionary.

It is at this time when the game stores the position of the cursor into an array, serving as a lookup table. Thus, each element in the array is an entry for an level.

Then the process is repeated until it reaches the end of the file, at which the lookup table is completed.

Upon starting the game, the lookup table is used to quickly find the location of each level.

Then the dictionary for each layer is checked and read. The game iterates through every element, filling the tilemap, forming the level.

## Trivia

- Due to the game ignoring the string's content, technically you can bake some copyright info into the .skb level file itself.
- The game's implementation of the undo function is entirely bonkers. It stores the state of *THE ENTIRE MAP* whenever you make a move. When you undo you're effectively overwriting the entire tilemap with this information.
- The game handles multiple player entities on the map by moving all of them simultaneously, each trying to move in the same direction. The included multitest.skb demonstrates it perfectly.
  - This is achieved by storing the player position in an array, and sorting them with a custom function depending on the movement direction to avoid movement conflicts.
- The game was originally license with "All rights reserved". It wasn't until this specific publication that it was changed to MIT No Attribution license.
- On the mac the game will probably be blocked by the gatekeeper. The entire reason why I complied for mac is because of a friend of mine uses a mac.
- The level selection box is broken. You can't unfocus it. The game will function anyways but you'll end up with lots of wasd characters in the box.
- The game was developed in 6 days, from Feb 22, 2024 to Feb 28, 2024. It received some minor updates:
  - Originally the level editor did not have any interpolation for the discrete mouse movement.
  - Originally the first click in the level editor will always start drawing at the origin point of the tilemap, regardless where you click at.
  - The match statement in draw_tile() of level_editor.gd was originally much more hard to read. Every condition had a set_cell() function which requires a bazillion arguments.
- During development it was incredibly difficult to keep track of time. Debugging all the way to 2 am was not a rare sight.
- There is a instant_export.tscn that is used to make levels before the level editor was created.
- As a Godot 4.2 project, it uses the TileMap node extensively. TileMap was deprecated in Godot 4.3 in favor of the TileMapLayer node.
  - Some changes was made in Godot 4.3 as it kept TileMap as a relic. It was not converted to TileMapLayers to avoid a complete rewrite of the code.
  - Thus, copy the source code with discretion.
- The levels in classic.skb was copied from a sokoban website. It was all hand-drawn, compared and verified by plain eye sight, which is why only twenty levels are present currently.
  - There is apparently several "classic" level sets avaliable. The one chosen here is from the my childhood memories of the sokoban game on a TV box.
  - On a personal note: the TV box and its TV was located in my grandma's house, which is empty for years now. The TV box had stock markets, tetris, gomoku, among other things.
    - My grandma and grandpa moved to my house to live with my mother since 2019 due to COVID-19 becuase Grandpa's mobility and health condition was declining.
    - Grandpa passed away in 2023. He was a biologist with considerable agricultural contributions. Grandma is still here asking me to please go to bed earlier every night.
