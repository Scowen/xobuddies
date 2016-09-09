<?php
// Functions to help with stuff.

// A query function to handle errors, saves me replicating code.
function mysqliQuery($connection, $sql) {
	// Execute the query.
	$result = $connection->query($sql);

	// Check for errors.
	if (!$result) {
		echo $mysqli->error;
		exit;
	}

	// Return the result.
	return $result;
}

function debug($debug, $string) {
	if ($debug) echo $string . "<br />";
}