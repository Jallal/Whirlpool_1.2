<?php
require_once "db.inc.php";
echo '<?xml version="1.0" encoding="UTF-8" ?>';

// Ensure the xml post item exists
if(!isset($_POST['xml'])) {
    echo '<hatter status="no" msg="missing XML" />';
    exit;
}
processXml(stripslashes($_POST['xml']));

echo '<hatter status="yes"/>';

/**
 * Process the XML query
 * @param $xmltext the provided XML
 */
function processXml($xmltext) {
    // Load the XML
    $xml = new XMLReader();
    if(!$xml->XML($xmltext)) {
        echo '<hatter status="no" msg="invalid XML" />';
        exit;
    }
    // Connect to the database
    $pdo = pdo_connect();
    // Read to the start tag
    while($xml->read()) {
        if($xml->nodeType == XMLReader::ELEMENT && $xml->name == "hatter") {
            // We have the hatter tag
            $magic = $xml->getAttribute("magic");
            if($magic != "NechAtHa6RuzeR8x") {
                echo '<hatter status="no" msg="magic" />';
                exit;
            }
            $user = $xml->getAttribute("user");
            $password = $xml->getAttribute("pw");
            $userid = getUser($pdo, $user, $password);


            // Read to the hatting tag
            while($xml->read()) {
                if($xml->nodeType == XMLReader::ELEMENT && $xml->name == "hatting") {
                    $name = $xml->getAttribute("name");
                    $uri = $xml->getAttribute("uri");
                    $x = $xml->getAttribute("x");
                    $y = $xml->getAttribute("y");
                    $angle = $xml->getAttribute("angle");
                    $scale = $xml->getAttribute("scale");
                    $color = $xml->getAttribute("color");
                    $hat = $xml->getAttribute("hat");
                    $feather = $xml->getAttribute("feather") == "yes" ? 1 : 0;

                    $nameQ = $pdo->quote($name);
                    $uriQ = $pdo->quote($uri);
                    // Checks
                    if(!is_numeric($x) || !is_numeric($y) || !is_numeric($angle) ||
                        !is_numeric($scale) || !is_numeric($color) || !is_numeric($hat)) {
                        echo '<hatter status="no" msg="invalid" />';
                        exit;
                    }
                    $query = <<<QUERY
REPLACE INTO hatting(name, userid, uri, type, x, y, rotation, scale, color, feather)
VALUES($nameQ, '$userid', $uriQ, $hat, $x, $y, $angle, $scale, $color, $feather)
QUERY;
                    if(!$pdo->query($query)) {
                        echo '<hatter status="no" msg="insertfail">' . $query . '</hatter>';
                        exit;
                    }

                    echo '<hatter status="yes"/>';

                    exit;
                }
            }
        }
    }
    echo '<hatter save="no" msg="invalid XML" />';
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