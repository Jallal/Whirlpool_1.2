<?php
/*
 * Hatter application loading
 */
require_once "db.inc.php";

echo '<?xml version="1.0" encoding="UTF-8" ?>';

if(!isset($_GET['magic']) || $_GET['magic'] != "NechAtHa6RuzeR8x") {
    echo '<hatter status="no" msg="magic" />';
    exit;
}


// Process in a function
processLoad($_GET['user'], $_GET['pw'], $_GET['id']);

/**
 * Process the query
 * @param $user the user to look for
 * @param $password the user password
 * @param $id the id in the hatting table
 */
function processLoad($user, $password, $id) {

    // Connect to the database
    $pdo = pdo_connect();

    getUser($pdo, $user, $password);
    $idQ = $pdo->quote($id);
    $query = "SELECT name, uri, type, x, y, rotation, scale, color, feather from hatting where id=$idQ";

    $rows = $pdo->query($query);

    if($row = $rows->fetch()) {
        // We found the record in the database

        echo "<hatter status=\"yes\">";
        $uri = $row['uri'];
        $x = $row['x'];
        $y = $row['y'];
        $angle = $row['rotation'];
        $scale = $row['scale'];
        $color = $row['color'];
        $hat = $row['type'];
        $feather = $row['feather'] == 1 ? "yes" : "no";

        echo "<hatting uri=\"$uri\" x=\"$x\" y=\"$y\" angle=\"$angle\" scale=\"$scale\" color=\"$color\" type=\"$hat\" feather=\"$feather\" />\r\n";
        echo "</hatter>";
        exit;
    }

    echo '<hatter status="no" msg="image" />';
}

/**
 * Ask the database for the user ID. If the user exists, the password
 * must match.
 * @param $pdo PHP Data Object
 * @param $user The user name
 * @param $password Password
 */
function getUser($pdo, $user, $password) {
    // Does the user exist in the database?
    $userQ = $pdo->quote($user);
    $query = "SELECT id, password from hatteruser where user=$userQ";

    $rows = $pdo->query($query);
    if($row = $rows->fetch()) {
        // We found the record in the database
        // Check the password
        if($row['password'] != $password) {
            echo '<hatter status="no" msg="password error" />';
            exit;
        }
    }

}
