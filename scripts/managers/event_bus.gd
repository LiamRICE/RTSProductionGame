extends Node

## Constants
const Selection:Script = preload("uid://cj0c8liafc0fd")
const RESOURCE := preload("res://scripts/utilities/resource_utils.gd").RESOURCE
const ORDER_REQUEST := preload("uid://dki6gr7rrru2p").ORDER_REQUEST


""" STARTUP SIGNALS """

## Navigation
signal on_navigation_map_created(map_rid:RID)


""" ENTITY SIGNALS """

## Production signals
signal on_entity_produced(entity:Entity, position:Vector3, rally_point:Vector3)

## Order signals
signal on_entity_move(entity:Entity, path:PackedVector3Array) ## Emitted when an entity receives it's movement path.
signal on_entity_destroyed(entity:Entity) ## Emitted when an entity is destroyed. Cleanup functions should listen to this event.
signal on_entity_order(order:Order) ## Emitted when an entity executes an order.
signal on_ui_order_dispatch(selection:Selection, order:Script, index:int, order_request:ORDER_REQUEST) ## Emitted when the ui wants to pass an order to a unit

## Resource signals
signal on_resource_deposited(amount:Dictionary[RESOURCE, int])
signal on_resource_spent(amount:Dictionary[RESOURCE, int], verification_callback:Callable)
