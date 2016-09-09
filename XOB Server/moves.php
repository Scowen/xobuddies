<?php
// If a request to find the moves of a room is executed.

include 'utilities.php';

$mysqli = new mysqli("localhost", "xobuddies", "xobuddies", "xobuddies");
// Check Connection
if ($mysqli->connect_errno) {
    printf("Connection failed: %s <br />", $mysqli->connect_error);
    exit();
}
// Init. needed variables.
$return = array();
$room = 0;
$time = time();
$debug = false;
$grid = array(
	array(0,0,0),
	array(0,0,0),
	array(0,0,0),
);


// For testing purposes so I can see what's going on, include a debug mode.
if (isset($_GET['debug'])) $debug = true;

// If the find request has also sent a room ID, use it.
if (isset($_GET['room']) && $_GET['room'] != 0) {
	debug($debug, "Room param supplied, using ID " . $_GET['room'] . ".");

	// Filter the string for invalid characters and only capture the ID.
	$room = intval($_GET['room']);
} 

$sqlSelectMoved = "SELECT * FROM moves WHERE
	room = $room";
// Execute the query.
$result = mysqliQuery($mysqli, $sqlSelectMoved);

while ($row = $result->fetch_assoc()) {
	$grid[$row['x']][$row['y']] = $row['player'];
}

// Display the grid in text form if debug mode is active.
if ($debug) {
	for ($x = 0; $x < 3; $x++) {
		for ($y = 0; $y < 3; $y++) {
			if ($grid[$x][$y] == 1) echo "X";
			elseif ($grid[$x][$y] == 2) echo "Y";
			else echo "&nbsp;&nbsp;";

			if ($y < 2)
				echo "&nbsp;|&nbsp;";
		}
		if ($x < 2)
			echo "<br />-----------<br />";
	}
	echo "<br /><br />";
}

$return['p00'] = $grid[0][0];
$return['p01'] = $grid[0][1];
$return['p02'] = $grid[0][2];

$return['p10'] = $grid[1][0];
$return['p11'] = $grid[1][1];
$return['p12'] = $grid[1][2];

$return['p20'] = $grid[2][0];
$return['p21'] = $grid[2][1];
$return['p22'] = $grid[2][2];

// JSON encode the return data.
$json = json_encode($return);

// Finally, echo the JSON data to be read by the Java.
echo $json;