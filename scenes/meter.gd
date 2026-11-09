extends Control

func set_meter(meter_name, value):
	%MeterName.text = meter_name
	%ProgressBar.value = value
