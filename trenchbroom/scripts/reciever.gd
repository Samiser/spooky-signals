class_name Reciever
extends Node

func connect_senders(ID : String, funct: Callable) -> void:
	await get_tree().process_frame # silly fix as not all objects are done spawning once this is called
	
	var sender_objs := get_tree().get_nodes_in_group("sender")
	for sender in sender_objs:
		if sender.signal_ID == ID:
			sender.send_signal.connect(funct)
