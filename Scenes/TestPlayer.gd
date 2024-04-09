extends Node2D

@onready var tile_map = $"../TileMap"

var astar_grid: AStarGrid2D
var current_id_path: Array[Vector2i]
var move_speed: int = 1

func _ready():
	astar_grid = AStarGrid2D.new()
	astar_grid.region = tile_map.get_used_rect()
	astar_grid.cell_size = Vector2(16, 16)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER #consider changing this (does not allow diagonal movement)
	astar_grid.update()
	
	#the rest of this function is currently not working correctly, it should be going through each tile to detect if it is set as "walkable" and if not, make it solid
	#it might be better to just find a way to do it directly in the tile set
	for x in tile_map.get_used_rect().size.x:
		for y in tile_map.get_used_rect().size.y:
			var tile_position = Vector2i(
				x, 
				y
			)
			
			var tile_data = tile_map.get_cell_tile_data(0, tile_position)
			
			if tile_data == null or tile_data.get_custom_data("walkable") == false:
				astar_grid.set_point_solid(tile_position)
				

func _input(event):
	if event.is_action_pressed("move") == false:
		return
	
	var player_pos = tile_map.local_to_map(global_position)
	var cursor_pos = tile_map.local_to_map(get_global_mouse_position())
	
	var id_path = astar_grid.get_id_path(player_pos, cursor_pos).slice(1)
	
	if !id_path.is_empty():
		current_id_path = id_path

func _physics_process(delta):
	if current_id_path.is_empty():
		return
	
	var target_position = tile_map.map_to_local(current_id_path.front())
	
	global_position = global_position.move_toward(target_position, move_speed)
	
	if global_position == target_position:
		current_id_path.pop_front()
