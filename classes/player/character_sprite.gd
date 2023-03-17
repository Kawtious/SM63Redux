extends AnimatedSprite

const BEGIN_SLOW_SPIN_AFTER = 10
const SLOW_SPIN_START_SPEED = 1
const SLOW_SPIN_END_SPEED = 0.4

onready var parent: PlayerCharacter = $"../.."


func _ready() -> void:
	playing = true


func _physics_process(_delta):
	rotation = parent.body_rotation
	flip_h = parent.facing_direction == -1
	position.y = 0
	if parent.swimming:
		animation = "swim_idle"
	else:
		match parent.state:
			parent.S.NEUTRAL:
				if parent.grounded:
					animation = "walk_neutral"
				else:
					if parent.vel.y < 0:
						if parent.double_jump_state == 2 and !parent.double_anim_cancel:
							animation = "jump_double"
						else:
							# TODO: jump_b variant
							animation = "jump_a"
					else:
						animation = "fall"
			parent.S.TRIPLE_JUMP:
				animation = "flip"
			parent.S.CROUCH:
				animation = "crouch"
			parent.S.DIVE:
				position.y = 7
				if parent.dive_resetting and parent.dive_reset_frames > 0:
					frame = 0
					if parent.dive_reset_frames >= parent.DIVE_RESET_TIME / 2.0:
						position.y = 0
						animation = "dive_reset"
						if parent.dive_reset_frames >= parent.DIVE_RESET_TIME / 4.0 * 3.0:
							frame = 1
				elif parent.grounded:
					animation = "dive_ground"
				else:
					animation = "dive_air"
			parent.S.BACKFLIP:
				animation = "jump_a"
			parent.S.ROLLOUT:
				animation = "jump_a"
			parent.S.POUND:
				match parent.pound_state:
					parent.Pound.SPIN:
						animation = "flip"
						# TODO: use rotation angle to determine frame.
					parent.Pound.FALL:
						animation = "pound_fall"
					parent.Pound.LAND:
						animation = "pound_land"
			parent.S.SPIN:
				var spin_progress = parent.SPIN_TIME - parent.spin_frames
				# TODO: start-and-loop system not implemented yet.
				# This is a holdover from a separate branch.
				if spin_progress >= BEGIN_SLOW_SPIN_AFTER:
					animation = "spin" #"spin_slow"
				else:
					animation = "spin" #"spin_fast"
				
				if spin_progress > BEGIN_SLOW_SPIN_AFTER:
					speed_scale = lerp(SLOW_SPIN_START_SPEED, SLOW_SPIN_END_SPEED,
						float(spin_progress - BEGIN_SLOW_SPIN_AFTER) / (parent.SPIN_TIME - BEGIN_SLOW_SPIN_AFTER))
			parent.S.HURT:
				animation = "hurt"


func _anim_length_gameframes(anim_name: String) -> int:
	var frame_count: float = self.frames.get_frame_count(anim_name)
	var fps: float = self.frames.get_animation_speed(anim_name)
	
	return int((frame_count/fps) * 60)
