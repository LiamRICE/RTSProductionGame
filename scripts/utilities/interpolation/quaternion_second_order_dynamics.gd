## Variables
var xp:Quaternion ## The previous instruction for position (X previous)
var yd:Quaternion ## The response velocity of the interpolation (Y derivative)
var y:Quaternion ## The response position (Y)

## Parameters
var k1:float
var k2:float
var k3:float

## Initialise the second order dynamics class with a resonant frequency, a damping coeficient and a response coeficient.
func _init(frequency:float, damping:float, response:float, position_instruction:Quaternion) -> void:
	## Compute constants
	self.k1 = damping / (PI * frequency)
	self.k2 = 1 / ((TAU * frequency) ** 2)
	self.k3 = response * damping / (TAU * frequency)
	## Initialise variables
	self.xp = position_instruction
	self.y = position_instruction
	self.yd = Quaternion.IDENTITY

## Ticks the second order dynamic response by one with a specified delta
## x is the position instruction which will be compared to the previous instruction
## xd is the optional velocity instruction
func update(delta:float, x:Quaternion, xd:Quaternion = Quaternion.IDENTITY) -> Quaternion:
	## Make sure the quaternion is rotated along the same axis
	if x.dot(self.xp) < 0.0:
		x = -x
	if xd == Quaternion.IDENTITY:
		xd = (x - self.xp) / delta
		self.xp = x
	var k2_stable:float = max(self.k2, 1.1 * (delta ** 2 / 4 + delta * self.k1 / 2)) ## Clamp k2 to guarantee stability
	self.y += delta * self.yd ## Integrate position using velocity
	self.yd += delta * (x + k3 * xd - self.y - self.k1 * self.yd) / k2_stable ## Integrate velocity from acceleration
	return self.y.normalized()

## Update the parameters for the second order dynamics
func modify_parameters(frequency:float, damping:float, response:float) -> void:
	## Compute constants
	self.k1 = damping / (PI * frequency)
	self.k2 = 1 / ((TAU * frequency) ** 2)
	self.k3 = response * damping / (TAU * frequency)
