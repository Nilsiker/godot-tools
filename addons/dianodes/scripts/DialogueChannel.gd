@tool
extends Node

signal progressed(node: BaseNodeData)
signal ended

var dialogue: Dialogue = null
var callbacks: Dictionary = {}
var variables: Dictionary = {}
var current_node: BaseNodeData = null

func start_dialogue(dialogue: Dialogue, callbacks={}, variables={}):
	self.dialogue = dialogue
	self.callbacks = callbacks
	self.variables = variables
	if dialogue:
		current_node = _find_start_node()
		print("current_node ", current_node)
		progressed.emit(current_node)

func progress(slot: int):
	var conn = dialogue.connections.filter(func(conn):
		return conn.from_node == current_node.guid and conn.from_port == slot
	)

	if conn.size() != 1:
		print("no singular connection found for ", current_node.guid, " and slot ", slot, ", ending dialogue")
		ended.emit()
		return
	
	var to = dialogue.nodes.filter(func(n):
		return n.guid == conn[0].to_node
	)

	if to.size() != 1:
		print("no singular node found with name ", conn[0].to_node, ", ending dialogue")
		ended.emit()
		return

	current_node = to[0]
	progressed.emit(current_node)

func _find_start_node():
	var start_conn = dialogue.connections.filter(func(conn): return conn.from_node == "Start")
	var start_node = dialogue.nodes.filter(func(n): return n.guid == start_conn[0].to_node)
	return start_node[0]
