class_name Reciever
extends Node

func connect_senders(ID : String, funct: Callable) -> void:
	var timer := get_tree().create_timer(0.01) # silly fix as not all objects are done spawning once this is called
	await timer.timeout
	
	var sender_objs := get_tree().get_nodes_in_group("sender")
	for sender in sender_objs:
		if sender.signal_ID == ID:
			sender.send_signal.connect(funct)
