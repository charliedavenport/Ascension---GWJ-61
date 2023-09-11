extends Area2D
class_name Star

func _ready():
	body_entered.connect(on_body_entered)

func on_body_entered(body) -> void:
	Events.player_reached_star.emit()
	queue_free()
