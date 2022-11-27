<?php
if (isset($_GET['passkey']) && 
hash("md5", "DYAXWCA") == $_GET['passkey'] &&
strlen(hash("md5", "DYAXWCA")) != strlen($_GET['passkey'])) {
    echo "Congrats! Here is your flag: <br>";
    echo "hology4{eZ_jUg61inG_in1_m4salAh_uD4h_S3rinG}";
} else if (isset($_GET['passkey'])) {
    echo "False Password!";
} else {
    echo '<?php <br>
    if (isset($_GET[\'passkey\']) && <br>
    hash("md5", "DYAXWCA") == $_GET[\'passkey\'] && <br>
    strlen(hash("md5", "DYAXWCA")) != strlen($_GET[\'passkey\'])) { <br>
        echo "FLAG"; <br>
    } else if (isset($_GET[\'passkey\'])) { <br>
        echo "False Password!"; <br>
    } else { <br>
        "File"; <br>
    } <br>
    ?> <br>';
}
?>