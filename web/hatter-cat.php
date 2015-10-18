<?php
/*
 * Hatter application catalog
 */
require_once "db.inc.php";
echo '<?xml version="1.0" encoding="UTF-8" ?>';

if(!isset($_GET['magic']) || $_GET['magic'] != "NechAtHa6RuzeR8x") {
    echo '<hatter status="no" msg="magic" />';
    exit;
}

// Process in a function
process($_GET['user'], $_GET['pw']);

/**
 * Process the query
 * @param $user the user to look for
 * @param $password the user password
 */
function process($user, $password) {

    // Connect to the database
    $pdo = pdo_connect();

    $userid = getUser($pdo, $user, $password);

    $query = "select id, name from hatting where userid='$userid'";
    $rows = $pdo->query($query);

    echo "<hatter status=\"yes\">";
    foreach($rows as $row ) {
        $id = $row['id'];
        $name = $row['name'];

        echo "<hatting id=\"$id\" name=\"$name\" />\r\n";
    }
    echo "</hatter>";
}

/**
 * Ask the database for the user ID. If the user exists, the password
 * must match.
 * @param $pdo PHP Data Object
 * @param $user The user name
 * @param $password Password
 * @return id if successful or exits if not
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

        return $row['id'];
    }

    echo '<hatter status="no" msg="user error" />';
    exit;
}
