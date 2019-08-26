extends AStar
class_name AStarCustom

var MAP_X : int
var MAP_Y : int
var MAP_W : int
var MAP_H : int
var FIX_X : int
var FIX_Y : int
var vec_to_index = {}
var next_index := -1

func build(tile_map: TileMap, reserve_space: bool = false, init_increment_index: int = -1):
	next_index = init_increment_index
	vec_to_index.clear()
	clear()

	MAP_X = 0
	MAP_Y = 0
	MAP_W = tile_map.map_size.x
	MAP_H = tile_map.map_size.y
	FIX_X = MAP_X if MAP_X < 0 else 0
	FIX_Y = MAP_Y if MAP_Y < 0 else 0

	if reserve_space and has_method("reserve_space"):
		call("reserve_space", MAP_W * MAP_H)

	var cells = _add_walkable_cells(tile_map)
	_connect_walkable_cells(tile_map, cells)
	
func calc_weight_scale(tile_map: TileMap, cell: Vector2) -> float:
	var tile = tile_map.get_cellv(cell)
	if tile == 0:
		return -1.0
	return 1.0
	
func _add_walkable_cells(tile_map: TileMap) -> Array:
	var cells = []
	for x in range(MAP_X, MAP_X + MAP_W):
		for y in range(MAP_Y, MAP_Y + MAP_H):
			var cell = Vector2(x, y)
			var weight_scale = calc_weight_scale(tile_map, cell)
			if weight_scale >= 1.0:
				cells.append(cell)
				var index = calculate_point_index(cell)
				add_point(index, Vector3(x, y, 0), weight_scale)
	return cells

func _connect_walkable_cells(tile_map: TileMap, cells: Array) -> void:
	for cell in cells:
		var index = calculate_point_index(cell)
		var points_relative = [
			Vector2(cell.x + 1, cell.y),
			Vector2(cell.x - 1, cell.y),
			Vector2(cell.x, cell.y + 1),
			Vector2(cell.x, cell.y - 1)]
		for point_relative in points_relative:
			if point_relative.x < MAP_X or point_relative.x >= MAP_W + MAP_X or \
				point_relative.y < MAP_Y or point_relative.y >= MAP_H + MAP_Y:
				continue
			var sibling_index = calculate_point_index(point_relative)
			if not has_point(sibling_index):
				continue
			connect_points(index, sibling_index, false)
	
func calculate_point_index(cell: Vector2) -> int:
	if next_index >= 0:
		return calculate_point_index_inc(cell)
	return int(cell.x - FIX_X + MAP_W * (cell.y - FIX_Y))

func calculate_point_index_inc(cell: Vector2) -> int:
	var index = vec_to_index.get(cell, -1)
	if index == -1:
		index = next_index
		vec_to_index[cell] = index
		next_index += 1
	return index


