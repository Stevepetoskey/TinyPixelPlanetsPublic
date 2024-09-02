extends Control

var tips : Array = [
	"Each weapon have different stats, test each to get a feel for which playstyle works best.",
	"Short on blues? Farming is the quickest way to riches.",
	"Tiny Pixel Planets started off as a entry to the Lowres Game Jam 2022",
	"Upgrade modules can only be found in scorched and frigid dungeons",
	"Tiny Pixel Planets is open source, so even you can contribute to development!",
	"Each new save takes place in the same galaxy, just at a different location in the galaxy.",
	"Does anyone read these?",
	"To compete with modern games, space will soon require dlc to unlock.",
	"Ok.",
	"They are coming.",
	"Going to slow? Certain armors have speed debuffs that can be changed with movement+ upgrades",
	"Put on your space suit before traveling space, you may land on a planet without an atmosphere.",
	"Gold is the rarest mineral in the game.",
	"Alpha Andromedae was originally a background track, but is now a music chip.",
	"Don't play Kasino Kart, it is not very good.",
	"Have you tried Island Builder?",
	"Title update 5 takes up less space than title update 4.",
	"Please comment on the itch.io page if you find any bugs.",
]

func _ready() -> void:
	var rng = RandomNumberGenerator.new()
	$ColorRect/Tips.text = tips[rng.randi() % tips.size()]

func _process(delta: float) -> void:
	$Space.rotation_degrees += delta
	$Stars.rotation_degrees += delta
