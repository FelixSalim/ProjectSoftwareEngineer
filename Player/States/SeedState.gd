extends InteractingState

# Declares a class
class_name SeedState

# When player interact with the land, tile the land
func interact(tile, tileState, collision):
	if tileState == "Tilled" or tileState == "Watered":
		if Input.is_action_pressed("ui_accept"):
			tile.tileState = "Planted"
