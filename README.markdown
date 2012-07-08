WHAT IS THIS?
=============

MultiPunk is a multiplayer AS3 library built on FlashPunk for the client and PlayerIO for the server. Upon receiving inputs from other players, MultiPunk rewinds the game, executes those inputs, then fast forwards to the current time. It's designed for multiplayer games that involve small groups of players (not MMOs) like fighters.

### PROS

* Minimal Server Code - Peer 2 peer style netcode with a bounce server. No server side game logic needed.
* Accurate - Rewind ensures an accurate simulation. Code without having to think about latency.
* Bandwidth - Sends player inputs instead of object state information (like position and velocity).

### CONS

* Computer Intensive - Uses double the memory and extra processing time for the rollback.
* Small Player Count - Not ideal for MMOs. On that note, not designed for players to join in on an already started game.
* No Smoothing - If someone lags badly enough, they will appear to teleport around the screen.
* Cheating - Maphacks (if your game has fog of war), command macros, and latency manipulations cannot be prevented.
* New - There will be bugs and many missing features. This is very bare bones.

HOW DOES THIS WORK?
===================

Two simulations of the game are running simultaneously.
* Perceived World - Inaccurate state information, but the information is up to date
* True World - Accurate state information, but the information is old

The Perceived World is what the player sees. Any command that the player inputs is immediately reflected on the Perceived World so he feels as if there is no delay. It is constantly updated.

The True World silently runs in the background. It is never rendered. When you receive a command from the other player, the True World is updated to the time of the command, then pauses. The Perceived World is then rewinded by rolling back to the True World (state information is now the same for both Worlds). After that, the Perceived World is fast forwarded to back the current time.

In essense, the True World contains a past state that is guaranteed to be accurate. It is used to efficiently allow the Perceived World to rewind and fix any errors caused by latency.

HOW DO I USE THIS?
==================

### Example Code

* See https://github.com/SelfPossessed/Simple-Multiplayer-Shooter
* Provides a basic working setup - just use that as a base to get started.

### PlayWorld

###### > Description

* The world you will be using as the main World

###### > Subclass and Constructor

* Subclass this and pass the appropriate values into the constructor.
* isP1:Boolean - Determines which player you are.
* frameDelay:uint - How many frames player inputs are delayed by. Higher delay makes it smoother but less responsive.
* frameMinSend:uint - How many frames before MultiPunk sends a blank message out. Lower number increases bandwidth usage but is more responsive.
* conn:GameConnection - Networking library to be used. Pass in a PlayerIOGameConnection.

###### > createGameWorld()

* Override this function.
* Pass in a new instance of your GameWorld subclass.

###### > updateInputs()

* Override this function.
* Check for player inputs here.
* Create commands based on player input by calling addMyCommand and passing an integer > 0 to it. 0 is reserved by MultiPunk.
* It is recommended that you send a command that represents a toggle for each keyboard input you want.

### PlayerIOGameConnection

* Pass this into the PlayWorld's constructor.
* isP1:Boolean - Determines which player you are.
* conn:Connection - The playerio.Connection you used to log in. Should be passed into the constructor of your PlayWorld subclass.

### GameWorld

###### > Description

* A subworld controlled by PlayWorld

###### > Subclass and Constructor

* Subclass this and pass in the framerate to the constructor.

###### > executeCommand(c:Command)

* Override this function
* Perform actions based on the commands here

### RollbackableEntity

* All entities must inherit from this.
* All entities must override rollback(e:RollbackableEntity).
* You must roll back relevant primitive values like integers and booleans. Failing to rollback a needed value will cause strange behaviors.
* Do not have one Entity referencing another one directly. You cannot rollback references.
* Sounds must use RollbackableSfx. Use the RollbackableEntity's addSound function in the constructor. You do not need to manually roll the Sfx back.

PLAYERIO SERVER PROTOCOL
========================

Note that this does not include the matchmaking system. This is the protocol used for actual gameplay. A default lobby that matches the first two players who join is provided in the Simple Shooter example. You should implement your own system on top of this protocol.

### Server to Client

* Type: "S"
* Server sends a "S" message to clients to begin the start time syncing process. Upon receiving this, the Client sets a subclass of PlayWorld as the FP.world. Note that the Simple Shooter example has the S message sent once both players have joined the "Shooter" room. In your implementation, the clients should send a message to the server that then causes the server to send this "S" message to the appropriate clients. For example, a host player picks another player to play against and sends the player id to the server. The server then sends the "S" message to the host and the selected player.

### Client to Server

* Type: "S"
* Clients sends a "S" message to the server every 250 milliseconds. The server uses 10 of these for each client to help synchronize the start time.

### Server to Client

* Type: "F"
* Parameter 1: Boolean
* Parameter 2: Unsigned Integer
* Server sends a "F" message to the clients to tell them to begin fighting. Parameter 1 tells the clients which player they are (true for player 1, false for player 2). Parameter 2 is a time in milliseconds used to calculate the game starting time. To get the starting time, the client adds Parameter 2 to the time that the client sent the first "S" message to the server.

### Client to Server

* Type: "C"
* Parameter 1: Unsigned Integer
* Parameter 2: Integer
* Parameter 3: Integer
* Parameter 4+: Integers
* Client packages up a "C" (command) message. Parameter 1 is the number of frames between the last command sent by this player and this command. Parameter 2 is the X position of the mouse. Parameter 3 is the Y position of the mouse. Parameters 4 and on each represent a custom command.

### Server to Client

* Type: "C"
* Parameter 1: Unsigned Integer
* Parameter 2: Integer
* Parameter 3: Integer
* Parameter 4+: Integers
* Server takes a received "C" message and forwards (bounces) it to the other player. It does no processing on the command.

STUFF THAT NEEDS TO BE DONE!
============================

###### Client

* Finish/Destroy game and memory management
* Rollback sounds - need to do loop/resume/stop
* Rollback camera
* Rollback Tilemap and other objects
* Box2D support
* Floating point precision checks - there may be floating point desyncs right now
* Replay system
* Observer system

###### Networking

* 3+ Players - it's only 2 player right now
* Disconnect detection
* Pausing on disconnect
* Cheatproofing - prevent sending invalid messages
* Allow for no mouse commands and occasional mouse commands - right now always sounds mouse information
* Chat
* Support for other networking libraries - like Gamooga or Cirrus
* UDP Support
* Move time sync code from server to clients
* Continuous clock synchronization - need to fix clock drift for longer games

FLASHPUNK NOTES
===============

* MultiPunk is built on a variation of FlashPunk. Not everything will be the same.
* MultiPunk expects to be using a variable timestep. Do NOT use a fixed timestep.
* Remove does not release an object from memory as MultiPunk keeps track of it. Use recycle and create often! 