<?php
// If someone is attempting to find a match.

include 'utilities.php';

$mysqli = new mysqli("localhost", "xobuddies", "xobuddies", "xobuddies");
// Check Connection
if ($mysqli->connect_errno) {
    printf("Connection failed: %s <br />", $mysqli->connect_error);
    exit();
}
// Init. needed variables.
$return = array();
$user = 0;
$room = 0;
$full = false;
$time = time();
$debug = false;

// For testing purposes so I can see what's going on, include a debug mode.
if (isset($_GET['debug'])) $debug = true;

// If the find request has also sent a user ID, use it.
if (isset($_GET['user']) && $_GET['user'] != 0) {
	debug($debug, "User param supplied, using ID " . $_GET['user'] . ".");

	// Filter the string for invalid characters and only capture the ID.
	$user = intval($_GET['user']);
} 

if (!$user) {
	// No ID was sent, assign one.
	debug($debug, "No User ID supplied, create one.");

	// Create the SQL to insert the user, most fields are handled by default.
	$sqlInsertUser = "INSERT INTO users 
		(created) 
		VALUES 
		($time)";
	// Execute the query.
	$result = mysqliQuery($mysqli, $sqlInsertUser);
 
	// Assign the user ID.
	$user = $mysqli->insert_id;

	debug($debug, "User ID created: $user.");
} else {
	// Check if the user ID supplied exists.
	$sqlSelectRoom = "SELECT * FROM users WHERE
		id = $user
		LIMIT 1";
	// Execute the query.
	$result = mysqliQuery($mysqli, $sqlSelectRoom);

	if ($result->num_rows <= 0) {
		debug($debug, "User ID does not exist, creating a new one.");
		// Create the SQL to insert the user, most fields are handled by default.
		$sqlInsertUser = "INSERT INTO users 
			(created) 
			VALUES 
			($time)";
		// Execute the query.
		$result = mysqliQuery($mysqli, $sqlInsertUser);
	 
		// Assign the user ID.
		$user = $mysqli->insert_id;

		debug($debug, "User ID created: $user.");
	}
}

// Check to see if the user has any open rooms.
$sqlFindUsersRooms = "SELECT * FROM rooms WHERE
	p1 = $user
	AND 
	p2 IS NULL
	LIMIT 1";
// Execute the query.
$result = mysqliQuery($mysqli, $sqlFindUsersRooms);

// Now see if the room exists.
if ($result->num_rows > 0) {
	debug($debug, "User has a room open already, updating the room to show active.");

	// Assign the room ID.
	$room = $result->fetch_object()->id;

	// Close the result set.
	$result->close();

	// Update the room to have the current timestamp.
	$sqlUpdateRoom = "UPDATE rooms SET 
	created = $time
	WHERE 
	p1 = $user";
	// Execute the query.
	$result = mysqliQuery($mysqli, $sqlUpdateRoom);

	debug($debug, "User room has been set to active.");
} else {
	// Check to see if the user was looking for a room, and found one.
	$sqlSelectFoundRoom = "SELECT * FROM rooms WHERE
		p1 = $user 
		AND 
		created > ($time - 100)
		LIMIT 1";
	// Execute the query.
	$result = mysqliQuery($mysqli, $sqlSelectFoundRoom);

	// If the query returned more than 0 rows.
	if ($result->num_rows > 0) {
		debug($debug, "User was looking for a room and has found an opponent.");

		$room = $result->fetch_object()->id;;
	} else {
		debug($debug, "User does not have a room open, look for one.");

		// The user does not have any open rooms, look for one.
		$sqlSelectRoom = "SELECT * FROM rooms WHERE
			p2 IS NULL 
			ORDER BY
			created DESC 
			LIMIT 1";
		// Execute the query.
		$result = mysqliQuery($mysqli, $sqlSelectRoom);

		// If the query returned more than 0 rows.
		if ($result->num_rows > 0) {
			debug($debug, "Room found! Add the user to the room.");

			// Get the ID of the returned row.
			$freeRoomId = $result->fetch_object()->id;

			// Free the result set.
			$result->close();

			// There is a room available. Assign the user to the open room.
			$sqlUpdateRoom = "UPDATE rooms SET 
			p2 = $user
			WHERE 
			id = $freeRoomId";
			// Execute the query.
			$result = mysqliQuery($mysqli, $sqlUpdateRoom);

			// Assign the room number.
			$room = $freeRoomId;

			debug($debug, "User ID $user has been added to room ID $room.");
		} else {
			debug($debug, "No rooms available, create new room.");

			// There are no rooms available, create a new room.
			$sqlInsertUser = "INSERT INTO rooms 
			(p1, created) 
			VALUES 
			($user, $time)";
			// Execute the query.
			$result = mysqliQuery($mysqli, $sqlInsertUser);

			$room = $mysqli->insert_id;

			debug($debug, "Room ID $room created.");
		}
	}
}

debug($debug, "Checking if room ID $room is full.");

// With the room, check if it is full, if so mark it as true!
$sqlSelectFullRoom = "SELECT * FROM rooms WHERE
	id = $room
	AND 
	p2 IS NOT NULL
	ORDER BY
	created DESC 
	LIMIT 1";
// Execute the query.
$result = mysqliQuery($mysqli, $sqlSelectFullRoom);

if ($result->num_rows > 0) {
	// Mark the room as full and ready!
	$full = true;

	// Free the result set.
	$result->close();

	debug($debug, "Room ID $room is full, start game!");
} else {
	debug($debug, "Room ID $room is waiting for a player..");
}

// Now add updated variables to the return array.
$return['user'] = $user;
$return['room'] = $room;
$return['full'] = $full;

// JSON encode the return data.
$json = json_encode($return);

// Finally, echo the JSON data to be read by the Java.
echo $json;