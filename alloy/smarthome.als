

abstract sig ZigbeeDevice {}
abstract sig EndDevice extends ZigbeeDevice {}
sig Router extends ZigbeeDevice {}
sig Camera, Thermostat, Alarm extends EndDevice {}


sig ZigbeeNetwork {
	// All devices in the network
	devices: set ZigbeeDevice,
	// A network has exactly one router acting as a coordinator
	coordinator: Router & devices,
	// Each router is connected to one or more routers
	connections: Router -> set Router,
	// Each end device is connected to a single router
	parent: EndDevice -> one Router,
	
	// The devices that are sleeping
	sleeping: set ZigbeeDevice
}{
	// Connection is a symmetric relation. Exclude identity relations.
	connections = ~connections - iden
	// All routers and all devices reachable from coordinator
	devices = coordinator.*connections.*~parent
	// Only the connected devices that aren't routers are allowed to sleep
	sleeping in devices - Router
}

fact eachDeviceIsInOneNetwork {
	all d: ZigbeeDevice | one n: ZigbeeNetwork | d in n.devices
}

pred sleepDevice [n, n_: ZigbeeNetwork, d: ZigbeeDevice] {
	d in n.devices - n.sleeping
	n_.parent = n.parent
	n_.coordinator = n.coordinator
	n_.devices = n.devices
	n_.connections = n.connections
	n_.sleeping = n.sleeping + d
}

pred awakeDevice [n, n_: ZigbeeNetwork, d: ZigbeeDevice] {
	d in n.sleeping
	n_.parent = n.parent
	n_.coordinator = n.coordinator
	n_.devices = n.devices
	n_.connections = n.connections
	n_.sleeping = n.sleeping - d
}

// Network-related checks
awakeDoesntRemoveFromNetwork: check {
	all n, n_: ZigbeeNetwork | all d: ZigbeeDevice |
		d in n.devices implies awakeDevice[n, n_, d] => d in n_.devices
} for 5

routersCannotSleep: check {
	all n : ZigbeeNetwork | all r: Router | r not in n.sleeping
} for 5

sleepingDevicesAreConnectedToNetwork: check {
	all d: ZigbeeDevice | all n: ZigbeeNetwork | d in n.sleeping implies d in n.devices
} for 5


// Features a room can have
abstract sig Feature {}
sig Outlet, Door, Radiator, Window extends Feature {}

abstract sig Room {
	features: set Feature,
}
sig Corridor extends Room {} {
	// A corridor can have only outlets
	features = Outlet
	#(features) = 1
	#(features - Outlet) = 0
}

sig Entrance extends Room {} {
	// Entrance room can have only entrance doors
	features = Door
	#(features) = 1
	#(features - Door) = 0
}

sig LivingRoom extends Room {} {
	// Living room can have only radiators and outlets
	features = Radiator + Outlet
	// This is a (maybe hacky?) way to force exactly one Outlet and exactly one Radiator
	#(features - Outlet) = 1
	#(features - Radiator) = 1
	#(features) = 2
}

sig Bedroom extends Room {} {
	// Bedroom can have only radiators and windows
	features = Radiator + Window
	#(features - Window ) = 1
	#(features - Radiator) = 1
	#(features) = 2
}

check bedroomHasRadiatorAndWindow {
	all b: Bedroom | Radiator in b.features and Window in b.features
} for 5

check livingRoomsShareOutlets {
	all l: LivingRoom | all l_: LivingRoom | one o: Outlet | (Outlet in l.features and Outlet in l_.features) implies o in l.features & l_.features
} for 5

sig House {
	// A house has multiple rooms
	rooms: set Room,
	// The (physical) connection between rooms
	connections: Room -> set Room,
	// A house has exactly one smart device network
	network: one ZigbeeNetwork,
	// A house has one entrance
	entrance: Entrance & rooms,
	// Each room contains some smart devices
	placements: Room -> set ZigbeeDevice

}{
	connections = ~connections - iden
	// All rooms are reachable from the entrance
	rooms = entrance.*connections
	
	// All devices are connected to the network
	network.devices = entrance.*connections.placements

	// Each device is placed in a single room
	all d: ZigbeeDevice | one r: Room | r in rooms and d in network.devices implies (r -> d) in placements
	
	// Requirements of each room
	all r: Room | some c: Camera | Door in r.features iff (r -> c) in placements
	all r: Room | some t: Thermostat | Radiator in r.features iff (r -> t) in placements
	all r: Room | some a: Alarm | Window in r.features iff (r -> a) in placements

	// Each router must be powered from an outlet
	all room: Room | (room -> Router) in placements implies Outlet in room.features

	// A room with a device must be adjacent to a room with a router, so the device can connect to the ZigbeeNetwork
	all r: Room | #(r.placements) > 0 implies (Router in r.placements or Router in r.connections.placements)
	
	// A corridor can connect to at most 4 rooms
	// Each other room can connect to at most only two other rooms
	all r: Room | r = Corridor implies #(connections[r]) <= 4
	all r: Room | r != Corridor implies #(connections[r]) <= 2
}

fact eachRoomIsInOneHouse {
	all r: Room | one h: House | r in h.rooms
}

check livingRoomsHaveRadiatorsAndThermostats {
	all l: LivingRoom | all h: House | some t: Thermostat | l in h.rooms and (Radiator in l.features and (l -> t) in h.placements)
} for 5

check allDevicesInHomeAreConnectedToHomeNetwork {
	all h: House | all r: Room | all d: ZigbeeDevice | r in h.rooms and (r -> d) in h.placements implies d in h.network.devices
} for 5

check noDeviceIsInMoreThanOneRoom {
	all d: ZigbeeDevice | lone r: Room | one h: House | r in h.rooms and (r -> d) in h.placements
} for 5

check noNonCorridorRoomIsConnectedToMoreThanThreeRooms {
	all r: Room | all h: House | r != Corridor implies #(h.connections[r]) <= 2
} for 5

check networksCoverOnlyOverOneHouse {
	all h: House | all h_: House | h != h_ implies h.network != h_.network
} for 5


// The final example of a house with a smart device network
// Feel free to experiment with larger numbers, but it will take a longer time to execute
pred example {}
run example for 20 but exactly 1 House, exactly 1 ZigbeeNetwork, exactly 2 Router, exactly 1 Corridor, exactly 1 Entrance, exactly 1 LivingRoom, exactly 1 Bedroom, exactly 1 Alarm, exactly 2 Thermostat, exactly 1 Camera

