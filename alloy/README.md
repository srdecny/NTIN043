# Model description
Because I have no idea what a smart home actually is, I approximated a real-life smart home network, Zigbee. See the links for a more detailed description of Zigbee:

- // https://www.zigbee2mqtt.io/advanced/zigbee/01_zigbee_network.html#device-types
- // https://www.smarthomebit.com/a-beginners-guide-to-zigbee/ 

The main features are:
- A smart home network consists of Devices and Routers
- Devices connect to Routers
- Routers connect to each other, and one router is the Communicator
- Each network has exactly one Communicator
- Each device is reachable from the Communicator
- The end devices can be in a sleep state to save battery life

I also decided to model a home using some constraints:
- A home consists of multiple rooms
- Rooms are connected to each other, number of connections depends on the room type
- Each smart network device can be placed into exactly one room
- Each room has some features, like radiator, that dictate what kind of a sensor will be deployed there
    - e.g. for a radiator, a thermostat is deployed
- One of the features is a power outlet. Routers require constant power, as they do not have a battery and must be always online
    - Thus, a router must be placed only in a room with an outlet
- To account for a signal strength, a device must be placed in a room that is adjacent to a room with a router
- Of course, all devices inside a home must be connected to a single network

The source file also contains a lot of comments about the model constraints.

# Alloy features
I am using implicit facts (facts about a signature that are implicitly "over" all instances of that signature) a lot, as well as abstract signatures. Notably, I am using Alloy 4, because that's the version I found most resources for. Alloy 6 seems to have some breaking syntax changes, like the absence of `all` etc.

# How to run it
Execute the `./run.sh` script. It is assumed you have a sufficiently modern version of Java installed. After the script execution, press "Execute all" and then "Show" to see an example of a model home. You might want to increase the memory limit. When inspecting the model home, it is recommended to set a Projection over a Home and a Network.
