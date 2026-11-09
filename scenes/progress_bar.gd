extends ProgressBar

@onready var meter_value = $MeterValue

func _ready() -> void:
	meter_value.text = str(value)
