# https://docs.godotengine.org/en/stable/getting_started/first_2d_game/03.coding_the_player.html
extends Area2D
signal hit # define a custom signal called 'hit', we will emit it when player collides with enemy

# $AnimatedSprite2D ---> Players animation
# $CollisionShape2D ---> Players collision

@export var speed = 400 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window

# Called when the node enters the scene tree for the first time.
func _ready():
	print('[Player] - Ready')
	screen_size = get_viewport_rect().size	
	hide() # TODO: uncomment hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed('move_right'):
		velocity.x += 1
	if Input.is_action_pressed('move_left'):
		velocity.x -= 1
	if Input.is_action_pressed('move_down'):
		velocity.y += 1
	if Input.is_action_pressed('move_up'):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

	# delta is frame length - the amount of time that previous frame took to complete
	# using this value ensures that player movement will remain consistent even if the frame rate changes
	position += velocity * delta 
	# clamping value means restricting it to a given range
	# ensures that player doesn't leave the screen
	position = position.clamp(Vector2.ZERO, screen_size) 

	# TODO: improve diagnoal movement, upside down, etc...
	if velocity.x != 0:
		$AnimatedSprite2D.animation = 'walk'
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0

	elif velocity.y != 0:
		$AnimatedSprite2D.animation = 'up'
		$AnimatedSprite2D.flip_v = velocity.y > 0

func _on_body_entered(body):
	print('[_on_body_entered]')
	hit.emit()
	hide() # Player disappears after being hit.
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred('disabled', true)

func start(pos):
	print('Start')
	position = pos
	show()
	$CollisionShape2D.disabled = false
