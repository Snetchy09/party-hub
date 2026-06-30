class_name BaseScreen
extends Control

signal screen_entered
signal screen_exited

func enter() -> void:
	screen_entered.emit()

func exit() -> void:
	screen_exited.emit()
