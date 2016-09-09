<?php
// If someone is attempting to get info regarding a room.

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
$p1 = 0;
$p2 = 0;
$p1wins = 0;
$p2wins = 0;
$turn = 0;

// For testing purposes so I can see what's going on, include a debug mode.
if (isset($_GET['debug'])) $debug = true;

// If the room request has also sent a room ID, use it.
if (isset($_GET['room']) && $_GET['room'] != 0) {
	debug($debug, "Room param supplied, using ID " . $_GET['room'] . "");

	// Filter the string for invalid characters and only capture the ID.
	$room = intval($_GET['room']);
} 

debug($debug, "Looking for room ID $room.");

$sqlSelectFullRoom = "SELECT * FROM rooms WHERE
	id = $room
	LIMIT 1";
// Execute the query.
$result = mysqliQuery($mysqli, $sqlSelectFullRoom);

if ($result->num_rows > 0) {
	debug($debug, "Room ID $room found.");

	$object = $result->fetch_object();
	$p1 = $object->p1;
	$p2 = $object->p2;
	$p1wins = $object->p1_wins;
	$p2wins = $object->p2_wins;
	$turn = $object->turn;
}
$result->close();

$return['p1'] = $p1;
$return['p2'] = $p2;
$return['p1wins'] = $p1wins;
$return['p2wins'] = $p2wins;
$return['turn'] = $turn;

// JSON encode the return data.
$json = json_encode($return);

// Finally, echo the JSON data to be read by the Java.
echo $json;