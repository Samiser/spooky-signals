extends Control

func control(caller: Node3D, value: float):
	match caller.name:
		"CourseFrequency":
			%CourseFrequencyLabel.text = str(value)
