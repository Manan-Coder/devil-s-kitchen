extends CharacterBody2D
class_name friends

const SPEED = 150            # Increased speed for snappier movement
const STOP_DISTANCE = 10     # Distance at which the friend stops moving toward the player
var current_dir = "front"    # Remembers last direction for idle animation
var player_follow = false
var player: Node2D = null

func _ready():
	$AnimatedSprite2D.play("front-idle")

func _physics_process(delta: float) -> void:
	if player_follow and player:
		var to_target: Vector2 = player.position - position
		var distance = to_target.length()
		if distance > STOP_DISTANCE:
			var direction = to_target.normalized()
			velocity = direction * SPEED
			move_and_slide()
			
			# Determine which axis is dominant using the normalized direction vector.
			if abs(direction.x) > abs(direction.y):
				$AnimatedSprite2D.play("side-walk")
				$AnimatedSprite2D.flip_h = direction.x < 0  # Flip sprite if moving left.
				current_dir = "side"
			else:
				if direction.y > 0:
					$AnimatedSprite2D.play("front-walk")
					current_dir = "front"
				else:
					$AnimatedSprite2D.play("back-walk")
					current_dir = "back"
		else:
			# When very close, stop and switch to the corresponding idle animation.
			velocity = Vector2.ZERO
			move_and_slide()
			match current_dir:
				"side":
					$AnimatedSprite2D.play("side-idle")
				"back":
					$AnimatedSprite2D.play("back-idle")
				"front":
					$AnimatedSprite2D.play("front-idle")
				_:
					$AnimatedSprite2D.play("front-idle")
	else:
		velocity = Vector2.ZERO
		move_and_slide()
		$AnimatedSprite2D.play("front-idle")

func _on_detection_body_entered(body: Node2D) -> void:
	player = body
	player_follow = true

func _on_detection_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		player_follow = false
