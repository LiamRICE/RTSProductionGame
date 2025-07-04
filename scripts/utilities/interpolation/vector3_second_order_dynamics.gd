## Variables
var xp:Vector3 ## The previous instruction for position (X previous)
var yd:Vector3 ## The response velocity of the interpolation (Y derivative)
var y:Vector3 ## The response position (Y)

## Parameters
var k1:float
var k2:float
var k3:float

## Initialise the second order dynamics class with a resonant frequency, a damping coeficient and a response coeficient.
func _init(frequency:float, damping:float, response:float, position_instruction:Vector3) -> void:
	## Compute constants
	self.k1 = damping / (PI * frequency)
	self.k2 = 1 / ((TAU * frequency) ** 2)
	self.k3 = response * damping / (TAU * frequency)
	## Initialise variables
	self.xp = position_instruction
	self.y = position_instruction
	self.yd = Vector3.ZERO

## Ticks the second order dynamic response by one with a specified delta
## x is the position instruction which will be compared to the previous instruction
## xd is the optional velocity instruction
func update(delta:float, x:Vector3, xd:Vector3 = Vector3.ZERO) -> Vector3:
	if xd == Vector3.ZERO:
		xd = (x - self.xp) / delta
		self.xp = x
	var k2_stable:float = max(self.k2, 1.1 * (delta ** 2 / 4 + delta * self.k1 / 2)) ## Clamp k2 to guarantee stability
	self.y += delta * self.yd ## Integrate position using velocity
	self.yd += delta * (x + k3 * xd - self.y - self.k1 * self.yd) / k2_stable ## Integrate velocity from acceleration
	return self.y

## Update the parameters for the second order dynamics
func modify_parameters(frequency:float, damping:float, response:float) -> void:
	## Compute constants
	self.k1 = damping / (PI * frequency)
	self.k2 = 1 / ((TAU * frequency) ** 2)
	self.k3 = response * damping / (TAU * frequency)
