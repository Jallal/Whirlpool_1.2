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
processDelete($_GET['user'], $_GET['pw'], $_GET['id']);

/**
 * Process the query
 * @param $user the user to look for
 * @param $password the user password
 * @param $id the id in the hatting table
 */
function processDelete($user, $password, $id){
    // Connect to the database

    $pdo = pdo_connect();

    $idQ = $pdo->quote($id);
    getUser($pdo, $user, $password);
    $query = "DELETE from hatting where id=$idQ";
    if(!$pdo->query($query)) {
        echo '<hatter status="no" msg="deletefail">' . $query . '</hatter>';
        exit;
    }

    echo '<hatter status="yes"/>';

    $pdo = null;

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