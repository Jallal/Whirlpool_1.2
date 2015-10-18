<!DOCTYPE html>
<html>
<head>
    <title>Hello</title>
</head>
<body>
<p><?php
    $a=0; $b=1;
    for($i=2; $i<=7; $i++) {
        $c = $a + $b;
        $a = $b;
        $b = $c;
        echo "<in=\”$i\”>$c</i><br />";
    }
    ?></p>
</body>
</html>
