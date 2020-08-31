<?php
    include 'farrms.client.config.ini.php';
    require_once 'product.global.vars.php';

    $args = $_SERVER['QUERY_STRING'];
    $args = (isset($args)) ? $args : '';

    if (isset($AAD_ENABLED) && $AAD_ENABLED) {
        # Require Magium Active Directory Library for Authentication
        require_once __DIR__ . '/../trm/adiha.php.scripts/components/lib/vendor/autoload.php';

        # Need to start session as Magium AD library uses session variables during authentication
        if (ini_get('session.auto_start') !== '1') {
            session_start();
        }

		# Resolve HTTP/HTTPS request protocol
        $isSecure = false;
        if (
            isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on' || 
            !empty($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https' || 
            !empty($_SERVER['HTTP_X_FORWARDED_SSL']) && $_SERVER['HTTP_X_FORWARDED_SSL'] == 'on'
        ) {
            $isSecure = true;
        }
        $request_protocol = $isSecure ? 'https' : 'http';

		# Redirect URL after active directory authentication
		$AAD_RETURN_URL = $request_protocol . '://' . $_SERVER['SERVER_NAME'] . explode('?', $_SERVER['REQUEST_URI'])[0];

        # Configuration for Azure Active Directory Authentication
        $config = [
            'authentication' => [
                'ad' => [
                    'client_id' => $AAD_CLIENT_ID,
                    'client_secret' => $AAD_CLIENT_SECRET,
                    'enabled' => $AAD_ENABLED,
                    'directory' => $AAD_TENANT_ID,
                    'return_url' => strtolower($AAD_RETURN_URL)
                ]
            ]
        ];

        $request = new \Zend\Http\PhpEnvironment\Request();

        $ad = new \Magium\ActiveDirectory\ActiveDirectory(
            new \Magium\Configuration\Config\Repository\ArrayConfigurationRepository($config),
            Zend\Psr7Bridge\Psr7ServerRequest::fromZend(new \Zend\Http\PhpEnvironment\Request())
        );

        if (isset($_GET['action']) && $_GET['action'] == 'logout') {
            $ad->forget();
        } else {
            # Initiates Active Directory Authentication
            $entity = $ad->authenticate();
            $azure_user_email = $entity->getData()['email'];
            $args =  $args . '&azure_user_email=' . $azure_user_email;
            $_SESSION['AZURE_AD'] = $entity->getData();
        }
    }

    $html = "
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset='UTF-8' />
            <meta name='viewport' content='width=device-width, initial-scale=1.0' />
            <meta http-equiv='X-UA-Compatible' content='IE=edge,chrome=1' />
            <link type='image/x-icon' href='../trm/main.menu/favicon.ico' rel='shortcut icon' />
            <title>" . $farrms_product_name . ": Login</title>
        </head>
        <html>
            <frameset cols='100%' frameborder='0' framespacing='0'>
                <frame src='../" . $farrms_root . "/index_login_farrms.php?" . $args . "&loaded_from=" . $farrms_client_dir . "' noresize>
            </frameset>
            <noframes></noframes>
        </html>";

    echo $html;
?>