<html>
    <head>
        <link href="../main.menu.new/bootstrap-3.3.1/dist/css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body style="background-color: #333!important;">
        <div style="width: 60%; margin: 0px auto !important; padding: 100px;">
            <div class="panel panel-primary">
                <div class="panel-heading">
                    <h3 class="panel-title">Account Recovery</h3>
                </div>
                <div class="panel-body">
                    <?php
                    if (isset($_GET['message'])) {
                        $message = ($_GET['message']);
                    } else {
                        $message = "";
                    }
            
                    switch ($message) {
                        case "YES":
                            echo 'Your password has been successfully reset. Please check your email.';
                            break;
                        case "NO":
                            echo 'Your password reset request could not be completed. Please try again or consult your Database Administrator.';
                            break;
                        case "ERROR":
                            echo '<span style="color: red; font-weight: bold;">Invalid Request:</span><br/>The password reset process has already been completed. Refer to your previous email for login credential.';                
                            break;
                        default:
                            echo 'Account Information is not available. <br/><br/> Thank you.';
                    }
                    ?>
                </div>
            </div>
        </div>
    </body>
</html>