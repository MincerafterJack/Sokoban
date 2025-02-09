class_name Tile

# Layers.
enum {GROUND_LAYER = 0, STUFF_LAYER = 1}

# Atlas coords.
const DO_NOT_DRAW = Vector2i(-114, -514)
const NONE = Vector2i(-1, -1)
const FLOOR = Vector2i(0, 0)
const WALL = Vector2i(1, 0)
const TARGET = Vector2i(0, 1)
const CRATE = Vector2i(1, 1)
const PLAYER_DOWN = Vector2i(2, 0)
const PLAYER_RIGHT = Vector2i(3, 0)
const PLAYER_LEFT = Vector2i(2, 1)
const PLAYER_UP = Vector2i(3, 1)

const PLAYER_DIR:Dictionary = {
	Vector2i.UP: PLAYER_UP,
	Vector2i.DOWN: PLAYER_DOWN,
	Vector2i.LEFT: PLAYER_LEFT,
	Vector2i.RIGHT: PLAYER_RIGHT,
}
