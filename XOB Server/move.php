<?php
// If someone is attempting to make a move for a room.

include 'utilities.php';

$mysqli = new mysqli("localhost", "xobuddies", "xobuddies", "xobuddies");
// Check Connection
if ($mysqli->connect_errno) {
    printf("Connection failed: %s <br />", $mysqli->connect_error);
    exit();
}
// Init. needed variables.
$return = array();
$debug = false;
$room = 0;
$player = 0;
$x = null;
$y = null;
$success = true;

// For testing purposes so I can see what's going on, include a debug mode.
if (isset($_GET['debug'])) $debug = true;

// If the room request has also sent a room ID, use it.
if (isset($_GET['room']) && $_GET['room'] != 0) {
	debug($debug, "Room param supplied, using ID " . $_GET['room'] . "");

	// Filter the string for invalid characters and only capture the ID.
	$room = intval($_GET['room']);
} 

// If the room request has also sent a player, use it.
if (isset($_GET['player']) && $_GET['player'] != 0) {
	debug($debug, "Player param supplied, using ID " . $_GET['player'] . "");

	// Filter the string for invalid characters and only capture the ID.
	$player = intval($_GET['player']);
} 

// If the x co-ordinate has been sent, use it.
if (isset($_GET['x']) && $_GET['x'] < 3) {
	debug($debug, "X param supplied, using " . $_GET['x'] . "");

	// Filter the string for invalid characters.
	$x = intval($_GET['x']);
} 

// If the y co-ordinate has been sent, use it.
if (isset($_GET['y']) && $_GET['y'] < 3) {
	debug($debug, "Y param supplied, using " . $_GET['y'] . "");

	// Filter the string for invalid characters.
	$y = intval($_GET['y']);
} 

// Get the room. 
$sqlSelectRoom = "SELECT * FROM rooms WHERE
	id = $room
	LIMIT 1";
// Execute the query.
$result = mysqliQuery($mysqli, $sqlSelectRoom);

// The room has been found.
if ($result->num_rows > 0) {
	// Make sure that the turn sent matches the turn on the room.
	$match = false;

	if ($result->fetch_object()->turn == $player)
		$match = true;

	// Close the result set.
	$result->close();

	// If the turn matches, insert the move.
	if ($match) {
		$sqlInsertMove = "INSERT INTO moves 
		(room, player, x, y) 
		VALUES 
		($room, $player, $x, $y)";
		$result = mysqliQuery($mysqli, $sqlInsertMove);

		// Also update the room to say it is now the other players turn.
		$turn = 0;
		if ($player == 1) $turn = 2; else $turn = 1;
		$sqlUpdateRoom = "UPDATE rooms SET 
		turn = $turn
		WHERE 
		id = $room";
		// Execute the query.
		$result = mysqliQuery($mysqli, $sqlUpdateRoom);
	} else {
		// It is not the players turn.
		$success = false;
		$return['error'] = 1;
	}
}

$return['room'] = $room;
$return['player'] = $room;
$return['x'] = $x;
$return['y'] = $y;
$return['success'] = $success;

// JSON encode the return data.
$json = json_encode($return);

// Finally, echo the JSON data to be read by the Java.
echo $json;