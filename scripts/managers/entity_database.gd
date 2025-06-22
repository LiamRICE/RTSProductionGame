extends Node

## Constants
const ENTITY_LIST := preload("uid://dki6gr7rrru2p").ENTITY_LIST

## Database
@export var db:Dictionary[ENTITY_LIST, EntityStats]
