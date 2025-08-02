extends RefCounted

# State Machine
enum ClickState {
	DEFAULT,
	SELECTING,
	SELECTED,
	CONSTRUCTING,
	ABILITY
}
enum SelectionType {
	NONE,
	UNITS,
	UNITS_ECONOMIC,
	BUILDINGS
}
enum MouseState {
	DEFAULT,
	RESOURCE,
	REPAIR,
	BUILD,
	ENEMY
}
