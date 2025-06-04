extends RefCounted
class_name CategoryConfig

# Category metadata configuration
# This is the single source of truth for category information
static var CATEGORY_METADATA = {
	"animation": {
		"title": "Animation Systems",
		"description": "Learn animation techniques for dynamic visual feedback",
		"icon": "🎬"
	},
	"audio": {
		"title": "Audio Systems", 
		"description": "Master audio playback, effects, and spatial sound",
		"icon": "🔊"
	},
	"input": {
		"title": "Input Handling",
		"description": "Master different input methods and player controls",
		"icon": "🎮"
	},
	"movement": {
		"title": "Movement Techniques",
		"description": "Learn different movement techniques in game development",
		"icon": "🏃"
	},
	"physics": {
		"title": "Physics Simulation",
		"description": "Explore physics-based interactions and simulations",
		"icon": "⚡"
	}
}

# Default scene metadata fallbacks
static var SCENE_METADATA_FALLBACKS = {
	"basic_animation": {
		"title": "Basic Animation",
		"description": "Fundamental animation concepts and keyframes"
	},
	"tweening": {
		"title": "Tweening & Easing", 
		"description": "Smooth transitions and easing functions"
	},
	"state_machines": {
		"title": "Animation State Machines",
		"description": "Complex animation logic with state transitions"
	},
	"advance_audio": {
		"title": "Advance Audio",
		"description": "WAV file loading and playback controls"
	},
	"ogg_playback": {
		"title": "OGG Playback",
		"description": "Compressed audio with seeking and loop controls"
	},
	"positional_audio": {
		"title": "Positional Audio",
		"description": "2D spatial audio with distance and panning"
	},
	"audio_mixing": {
		"title": "Audio Mixing",
		"description": "Multiple audio sources and bus routing"
	},
	"audio_synthesis": {
		"title": "Audio Synthesis",
		"description": "Basic waveform generation and synthesis"
	},
	"keyboard_input": {
		"title": "Keyboard Input",
		"description": "Handle keyboard events and key combinations"
	},
	"mouse_input": {
		"title": "Mouse Input", 
		"description": "Mouse clicks, movements, and interactions"
	},
	"gamepad_input": {
		"title": "Gamepad Input",
		"description": "Controller support and gamepad handling"
	},
	"basic_movement": {
		"title": "Basic Movement",
		"description": "Simple directional movement and controls"
	},
	"platformer_movement": {
		"title": "Platformer Movement",
		"description": "Jump mechanics and gravity for platform games"
	},
	"top_down_movement": {
		"title": "Top-Down Movement",
		"description": "8-directional movement for top-down games"
	},
	"basic_physics": {
		"title": "Basic Physics",
		"description": "Fundamental physics concepts and forces"
	},
	"collision_detection": {
		"title": "Collision Detection",
		"description": "Detecting and responding to collisions"
	},
	"rigid_bodies": {
		"title": "Rigid Bodies",
		"description": "Realistic physics with rigid body dynamics"
	}
}
