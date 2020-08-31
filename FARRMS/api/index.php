<?php
/** 
 * Main entry point for API
 * @copyright Pioneer Solutions
*/
require __DIR__ . '/vendor/autoload.php';
require('config.php');
require_once("Rest.inc.php");
require_once("lib/Db.php");

$currentRoute = isset($_REQUEST['route']) ? $_REQUEST['route'] : '';
$postBody = file_get_contents("php://input");

if (isset($_SERVER["CONTENT_TYPE"]) && $_SERVER["CONTENT_TYPE"] == 'application/x-www-form-urlencoded') {
    $postBody = urldecode($postBody);
}

$decoded_body = json_decode($postBody);
$decoded_body = $decoded_body == NULL ? $postBody : $decoded_body;
## Get Farrms Client Dir from Payload if exists (Authentication Case), IF Authorization its generated from token
## In other cases it will be taken from config.php
$farrms_client_dir = (property_exists($decoded_body, 'farrms_client_dir')) ? $decoded_body->farrms_client_dir : $farrms_client_dir;

$authentication_route = ['auth/login', 'requesttoken', 'auth/verify'];
$bypass_auth_route = ['resolve-path/app', 'resolve-path/reset-log', 'resolve-path/verify-recovery-token', 'resolve-path/reset-password', 'resolve-path/license-agreement'];
// $is_bypass_auth_route is created so that it can be used in db_reference.php to avoid executing same query twice.
$authentication_route = array_merge($authentication_route, $bypass_auth_route);
$is_bypass_auth_route = in_array($currentRoute, $bypass_auth_route);

$is_auth_route = in_array($currentRoute, $authentication_route);

$http_auth_user = $_SERVER['AUTH_USER'];
$http_auth_type = $_SERVER['AUTH_TYPE'];
$win_auth = (isset($http_auth_user) && $http_auth_user != '' && isset($http_auth_type) && $http_auth_type == 'Negotiate') ? 1 : 0;

## Validate Authorization Token if is not authentication route
if (!$is_auth_route && $currentRoute != '') {
    require_once("controllers/Auth.controller.php");
    $auth_controller = new AuthController();
    ## Check if api is called from windows authentication, this value is passed from request_api function in the case of verify-token route
    $win_auth = property_exists($decoded_body, 'win_auth') ? $decoded_body->win_auth : $win_auth;
    $http_authorization_name = ($win_auth == 1) ? 'HTTP_CUSTOM_AUTHORIZATION' : 'HTTP_AUTHORIZATION';
    $authorization_code = $auth_controller->getHeader($http_authorization_name);
    $authorization_status = $auth_controller->validLogin($authorization_code);
    $app_user_name = $authorization_status['username'];
    $new_db_name = $authorization_status['database_name'];
    $new_db_server_name = $authorization_status['db_servername'];
    
    $farrms_client_dir = isset($authorization_status['farrms_client_dir']) ? $authorization_status['farrms_client_dir'] : $farrms_client_dir;
    $new_db_user = $authorization_status['db_user'];
    $new_db_pwd = $authorization_status['db_pwd'];

    ## Token validation from application returns user name
    if ($currentRoute == 'auth/verify-token') {
        $json["username"] = $app_user_name;
        $json["database_name"] = $new_db_name;
        $json["db_servername"] = $new_db_server_name;
        $json["db_user"] = $new_db_user;
        $json["db_pwd"] = $new_db_pwd;
        $auth_controller->response($auth_controller->json($json), 200);
    }
}

if ($is_auth_route) {
    //get the username from payload
    $app_user_name = $decoded_body->username;
    $password = property_exists($decoded_body, 'password') ? $decoded_body->password : '';
    $cookie_hash = property_exists($decoded_body, 'cookie_hash') ? $decoded_body->cookie_hash : '';
    $session_id = property_exists($decoded_body, 'session_id') ? $decoded_body->session_id : '';
    $call_from_wp = (property_exists($decoded_body, 'call_from_wp')) ? $decoded_body->call_from_wp : "";
    ## Azure Active Directory Tennant ID
    $aad_tenant_id = (property_exists($decoded_body, 'aad_tenant_id')) ? $decoded_body->aad_tenant_id : "";
    ## 'uti' is a property that is used to add validate user for user logging in using Azure Active Directory
    $uti = (property_exists($decoded_body, 'uti')) ? $decoded_body->uti : "";
    if ($win_auth == 1) {
        $user_login_id_array = explode("\\", $http_auth_user);
        $app_user_name = $user_login_id_array[1];
    }
    ## This will be checked in adiha.config.ini.rec.php to include db_reference.php (Cloud Login)
    ## It will be needed only in the case of cloud mode when authenticating user
    $check_cloud_mode_login = 1;
    $client_ip = (property_exists($postBody, 'ip')) ? $postBody->ip : $_SERVER['REMOTE_ADDR'];
}

require '../trm/adiha.php.scripts/components/file_path.php';
require '../' . $farrms_client_dir . '/adiha.config.ini.rec.php';

## Turn on/off display error configuration from farrms.client.config.ini.php 
if (isset($display_error)) {
    ini_set('display_errors', $display_error);
}

## Turn on/off error reporting configuration from farrms.client.config.ini.php 
if (isset($error_reporting)) {
    ini_set('error_reporting', $error_reporting);
}

## Include to get login attempts and login lock time
require '../trm/adiha.php.scripts/components/security.ini.php';

ob_start();
## CloudDb
require_once("lib/CloudDb.php");
## Models
require_once("models/Auth.php");
require_once("models/DealTemplate.php");
require_once("models/Deal.php");
require_once("models/Trader.php");
require_once("models/Counterparty.php");
require_once("models/Contract.php");
require_once("models/Curve.php");
require_once("models/Location.php");
require_once("models/Subbook.php");
require_once("models/Uom.php");
require_once("models/Alert.php");
require_once("models/Workflow.php");
require_once("models/Report.php");
require_once("models/ExcelAddin.php");
require_once("models/DataImport.php");
require_once("models/ResolveApplicationPath.php");
require_once("models/SaasApplication.php");
require_once("models/Otp.php");
## Controllers
require_once("controllers/Auth.controller.php");
require_once("controllers/DealTemplate.controller.php");
require_once("controllers/Deal.controller.php");
require_once("controllers/Trader.controller.php");
require_once("controllers/Counterparty.controller.php");
require_once("controllers/Contract.controller.php");
require_once("controllers/Curve.controller.php");
require_once("controllers/Location.controller.php");
require_once("controllers/Uom.controller.php");
require_once("controllers/Subbook.controller.php");
require_once("controllers/Alert.controller.php");
require_once("controllers/Workflow.controller.php");
require_once("controllers/Report.controller.php");
require_once("controllers/ExcelAddin.controller.php");
require_once("controllers/Otp.controller.php");
require_once("controllers/DataImport.controller.php");
require_once("controllers/FileImport.controller.php");
require_once("controllers/ResolveApplicationPath.controller.php");
require_once("controllers/SaasApplication.controller.php");


$file_import_directory = "../" . $farrms_root . "/" . $relative_temp_path . "/"; // to import from file

ob_clean();

/**
*  @brief API Class that extends REST
*
*  @par Description
*  This class is used to handle all REST API functionalities.	
*  @copyright Pioneer Solutions.
*/
class API extends REST {
    private $connection_info = NULL;
    protected $app_user_name = NULL;
    private $db_servername = NULL;

    /**
     * Constructor
     *
     * @param   String  $db_servername         Database Server Name
     * @param   Array  $connection_info        Database Connection Information
     * @param   String  $app_user_name          Application User Name
     * @param   String  $file_import_directory  File Import Directory Path
     */
    public function __construct($db_servername, $connection_info, $app_user_name, $file_import_directory) {
        parent::__construct();              // Init parent contructor
        if ($db_servername) {
            $this->connection_info = $connection_info;
            $this->app_user_name = $app_user_name;
            $this->db_servername = $db_servername;
            $this->file_import_directory = $file_import_directory;
        }
    }
    
    /**
     * Get Route Name
     *
     * @param   String  $route  Route with Slashes
     *
     * @return  String          Route Name
     */
    private function regexifyRoute($route) {
        $slashedRoute = $route;
        $slashedRoute = preg_replace("/{([^}]+)}/", "([^/]+)", $slashedRoute);
        $slashedRoute = str_replace('/', '\/', $slashedRoute);
        $slashedRoute = $slashedRoute . '$';
        return $slashedRoute;
    }

    
    /**
     * Dispatched the route to particular controller and interact based on Route
     *
     * @param   String  $method        Request Type GET, POST
     * @param   String  $currentRoute  Current Route
     * @param   Array  $body           Body description
     */
    public function dispatch($method, $currentRoute = '', $body, $is_bypass_auth_route) {
        global $db_user, $db_pwd, $file_import_directory, $cloud_login_error_msg, $cloud_data;
        
        $pattern = '/="(\w+)"/i';
        $replacement = '=\"${1}\"';
        $body1 = preg_replace($pattern, $replacement, $body);       
        $body1 = preg_replace("/>\s+</", "><", $body1); // replace line break and spaces
        $body = json_decode($body1);

        // Handle Invalid POST Body JSON
		// Also check if any file has been uploaded before throwing error. Eg; for route fileupload whose body is null and method is post
        if ($method == 'POST' && $body == null && empty($_FILES)) {
            $results[0]['ErrorCode'] = 'Error';
            $results[0]['Message'] = 'Incorrect request data.';
            $results[0]['Recommendation'] = 'Please check your request.';
            $this->response($this->json($results), 200);
        }
        
        $json = array('route' => $currentRoute);

        ## Throw exception error message if cloud user is not found
        if (isset($cloud_login_error_msg) && $cloud_login_error_msg != '') {
            $results = array();
            $results[0]["ErrorCode"] = "Error";
            $results[0]["Message"] = $cloud_login_error_msg;

            if (isset($cloud_data)) {
                $results[0]["ErrorCode"] = "CloudError";
                $results[0]["CloudError"] = $cloud_data;
            }

            $this->response($this->json($results), 200);
        }

        // Initialize the Database Connection it will be used later from Models to query database
        if (!$is_bypass_auth_route) {
            new DB($this->db_servername, $this->connection_info);
        }
        
        $currentRoute = str_replace('api/', '', $currentRoute);
        
        list($mainRouteRoot) = explode('/', $currentRoute);
        // echo $mainRouteRoot;
        
        if ($currentRoute == 'auth/login' || $currentRoute == 'requesttoken') {
            $log_body = '{username:' . $this->app_user_name . '}';
        } else {
            $log_body = $body;
        }
        
        $this->writeLogFile($this->app_user_name, $currentRoute, $method, $log_body);

        // $dealTemplateIndex = $this->dealTemplateIndex;
        $allRoutes = array(
            'auth' => array(
                'controller' => new AuthController($this->app_user_name),
                'routes' => array(
                    'auth/login' => array(
                        'POST' => 'postLogin',
                        'body' => $body
                    ),
                    'auth/logout' => array(
                        'GET' => 'logout'
                    ),
                    'auth/verify' => array(
                        'POST' => 'verifyLoginDetails',
                        'body' => $body
                    )
                )
            ),
            'deal-template' => array(
                'controller' => new DealTemplateController(),

                'routes' => array(
                    "deal-template" => array(
                        'GET' => 'index'
                    ),
                    "deal-template/{templateId}" => array(
                        'GET' => 'get'
                    ),
                    // "deal-template/{templateId}/a/{a}" => array(
                        // 'GET' => 'get'
                    // )
                )
            ),
            'trader' => array(
                'controller' => new TraderController(),
                'routes' => array(
                    "trader" => array(
                        'GET' => 'index'
                    ),
                    "trader/{traderId}" => array(
                        'GET' => 'get'
                    ),
                )
            ),
            
            'counterparty' => array(
                'controller' => new CounterpartyController(),
                'routes' => array(
                    "counterparty" => array(
                        'GET' => 'index'
                    ),
                    "counterparty/{templateId}" => array(
                        'GET' => 'getDependentCounterparty'
                    ),
                )
            ),
            'contract' => array(
                'controller' => new ContractController(),
                'routes' => array(
                    "contract" => array(
                        'GET' => 'index'
                    ),
                    "contract/{templateId}/{counterpartyId}" => array(
                        'GET' => 'getDependentContract'
                    ),
                )
            ),
            'curve' => array(
                'controller' => new CurveController(),
                'routes' => array(
                    "curve" => array(
                        'GET' => 'index'
                    ),
                    "curve/{curveId}" => array(
                        'GET' => 'get'
                    ),
                )
            ),
            'location' => array(
                'controller' => new LocationController(),
                'routes' => array(
                    "location" => array(
                        'GET' => 'index'
                    ),
                    "location/{locationId}" => array(
                        'GET' => 'get'
                    ),
                )
            ),
            'sub-book' => array(
                'controller' => new SubbookController(),
                'routes' => array(
                    "sub-book" => array(
                        'GET' => 'index'
                    ),
                    "sub-book/{subbookId}" => array(
                        'GET' => 'get'
                    ),
                )
            ),
            'uom' => array(
                'controller' => new UomController(),
                'routes' => array(
                    "uom" => array(
                        'GET' => 'index'
                    ),
                    "uom/{uomId}" => array(
                        'GET' => 'get'
                    ),
                )
            ),
            'frequency' => array(
                'controller' => new DealController(),
                'routes' => array(
                    "frequency" => array(
                        'GET' => 'listFrequency'
                    )
                )
            ),
            'deal-type' => array(
                'controller' => new DealController(),
                'routes' => array(
                    "deal-type" => array(
                        'GET' => 'listDealType'
                    )
                )
            ),
            'commodity' => array(
                'controller' => new DealController(),
                'routes' => array(
                    "commodity" => array(
                        'GET' => 'listCommodity'
                    )
                )
            ),
            'currency' => array(
                'controller' => new DealController(),
                'routes' => array(
                    "currency" => array(
                        'GET' => 'listCurrency'
                    )
                )
            ),
            
            'alert' => array(
                'controller' => new AlertController(),
                'routes' => array(
                    "alert" => array(
                        'GET' => 'index',
                        'PUT' => 'action',
                        'DELETE' => 'delete',
                        'body' => $body
                    ),
                    "alert/{messageId}" => array(
                        'GET' => 'get'
                    ),
                )
            ),
            
            'workflow' => array(
                'controller' => new WorkflowController(),
                'routes' => array(
                    "workflow" => array(
                        'GET' => 'index',
                        'PUT' => 'action',
                        'DELETE' => 'delete',
                        'body' => $body
                    ),
                    "workflow/{messageId}" => array(
                        'GET' => 'get',
                    )
                )
            ),
            
            'book-structure' => array(
                'controller' => new ReportController($this->app_user_name),
                'routes' => array(
                    "book-structure" => array(
                        'GET' => 'getBookStructure'
                    )
                )
            ),
            
            'report' => array(
                'controller' => new ReportController($this->app_user_name),
                'routes' => array(
                    "report" => array(
                        'GET' => 'index'
                    ),
                    "report/{reportId}" => array(
                        'GET' => 'get'
                    )
                )
            ),
            
            'report-paramset' => array(
                'controller' => new ReportController($this->app_user_name),
                'routes' => array(
                    "report-paramset/{reportParamId}/" => array(
                        'GET' => 'getFilter'
                    ),
                    "report-paramset/{reportParamId}/{reportId}" => array(
                        'GET' => 'getFilter'
                    )
                )
            ),
            'view-bi-report' => array(
                'controller' => new ReportController($this->app_user_name),
                'routes' => array(
                    "view-bi-report" => array(
                        'POST' => 'viewBIReport',
                        'body' => $body
                    )
                )
            ),
            'view-report' => array(
                'controller' => new ReportController($this->app_user_name),
                'routes' => array(
                    "view-report" => array(
                        'POST' => 'viewReport',
                        'body' => $body
                    )
                )
            ),
            
            'view-standard-report' => array(
                'controller' => new ReportController($this->app_user_name),
                'routes' => array(
                    "view-standard-report" => array(
                        'POST' => 'viewStandardReport',
                        'body' => $body
                    )
                )
            ),
            
            'view-excel-report' => array(
                'controller' => new ReportController($this->app_user_name),
                'routes' => array(
                    "view-excel-report" => array(
                        'POST' => 'viewExcelReport',
                        'body' => $body
                    )
                )
            ),
            'trade-ticket' => array(
                'controller' => new ReportController($this->app_user_name),
                'routes' => array(
                    "trade-ticket/{dealId}" => array(
                        'GET' => 'tradeticket'
                    ),
                    "trade-ticket/{dealId}/{screenWidth}" => array(
                        'GET' => 'tradeticketWithWidth'
                    ),
                )
            ),
            
            'confirmation' => array(
                'controller' => new ReportController($this->app_user_name),
                'routes' => array(
                    "confirmation/{dealId}" => array(
                        'GET' => 'confirmation'
                    ),
                    "confirmation/{dealId}/{screenWidth}" => array(
                        'GET' => 'confirmationWithWidth'
                    ),
                )
            ),
            
            'invoice' => array(
                'controller' => new ReportController($this->app_user_name),
                'routes' => array(
                    "invoice/{dealId}" => array(
                        'GET' => 'invoice'
                    ),
                    "invoice/{dealId}/{screenWidth}" => array(
                        'GET' => 'invoiceWithWidth'
                    )
                )
            ),
            
            'deal' => array(
                'controller' => new DealController(),
                'routes' => array(
                    "deal" => array(
                        'GET' => 'index',
                        'POST' => 'insert',
                        'body' => $body
                    ),
                    "deal/{dealId}" => array(
                        'GET' => 'get',
                        'POST' => 'update',
                        'body' => $body
                    )
                )
            ),
            'search' => array(
                'controller' => new DealController(),
                'routes' => array(
                    "search/{searchTxt}" => array(
                        'GET' => 'search'
                    )
                )
            ),
            'devices' => array(
                'controller' => new AuthController(),
                'routes' => array(
                    "devices" => array(
                        'GET' => 'getLoginDevice'
                    )
                )
            ),
            'date-format' => array(
                'controller' => new AuthController(),
                'routes' => array(
                    "date-format" => array(
                        'GET' => 'getDateFormat'
                    ),
                    "date-format/{date}" => array(
                        'GET' => 'getDateWithFormat'
                    )
                )
            ),
            'exceladdin' => array(
                'controller' => new ExcelAddinController(),
                'routes' => array(
                    "exceladdin/queryJson" => array(
                        'POST' => 'getQueryJson',
                        'body' => $body
                    )
                )
            ),
            'deal-term-start-end' => array(
                'controller' => new DealController(),
                'routes' => array(
                    "deal-term-start-end" => array(
                        'POST' => 'getTermStartEnd',
                        'body' => $body
                    )
                )
            ),
            'importdata' => array(
                'controller' => new DataImportController(),
                'routes' => array(
                    "importdata" => array(
                        'POST' => 'DataImport',
                        'body' => $body
                    )
                )
            ),
            'importdatacollection' => array(
                'controller' => new DataImportController(),
                'routes' => array(
                    "importdatacollection" => array(
                        'POST' => 'DataImportCollection',
                        'body' => $body
                    )
                )
            ),
            'fileimport' => array(
                'controller' => new FileImportController(),
                'routes' => array(
                    "fileimport" => array(
                        'POST' => 'FileImport'
                    )
                )
            ),
            'fileupload' => array(
                'controller' => new FileImportController(),
                'routes' => array(
                    "fileupload" => array(
                        'POST' => 'FileUpload'
                    )
                )
            ),
            'getimportfunctionlist' => array(
                'controller' => new DataImportController(),
                'routes' => array(
                    "getimportfunctionlist" => array(
                        'POST' => 'GetImportFunctionList'
                    )
                )
            ),
            'getimportformat' => array(
                'controller' => new DataImportController(),
                'routes' => array(
                    "getimportformat" => array(
                        'POST' => 'GetImportFormat',
                        'body' => $body
                    )
                )
            ),
            'getimportstatus' => array(
                'controller' => new DataImportController(),
                'routes' => array(
                    "getimportstatus" => array(
                        'POST' => 'GetImportStatus',
                        'body' => $body
                    )
                )
            ),
            'getreportlist' => array(
                'controller' => new ReportController(),
                'routes' => array(
                    "getreportlist" => array(
                        'POST' => 'getReportList'
                    )
                )
            ),
            'getreportparameter' => array(
                'controller' => new ReportController(),
                'routes' => array(
                    "getreportparameter" => array(
                        'POST' => 'getReportParameter',
                        'body' => $body
                    )
                )
            ),
            'getreportdata' => array(
                'controller' => new ReportController(),
                'routes' => array(
                    "getreportdata" => array(
                        'POST' => 'getReportData',
                        'body' => $body
                    )
                )
            ),
            'requesttoken' => array(
                'controller' => new AuthController($this->app_user_name),

                'routes' => array(
                    'requesttoken' => array(
                        'POST' => 'requesttoken',
                        'body' => $body
                    )
                )
            ),
            'resolve-path' => array(
                'controller' => new ResolveApplicationPathController(),
                'routes' => array(
                    'resolve-path/app' => array(
                        'POST' => 'resolveApplicationPath',
                        'body' => $body
                    ),
                    'resolve-path/reset-log' => array(
                        'POST' => 'generateRecoveryToken',
                        'body' => $body
                    ),
                    'resolve-path/verify-recovery-token' => array(
                        'POST' => 'verifyRecoveryToken',
                        'body' => $body
                    ),
                    'resolve-path/reset-password' => array(
                        'POST' => 'resetPassword',
                        'body' => $body
                    ),
                    'resolve-path/license-agreement' => array(
                        'POST' => 'updateLicenseAgreement',
                        'body' => $body
                    ),
                    'resolve-path/check-email' => array(
                        'POST' => 'checkIfEmailIsAvailable',
                        'body' => $body
                    ),
                    'resolve-path/create-user' => array(
                        'POST' => 'createUser',
                        'body' => $body
                    ),
                    'resolve-path/delete-user' => array(
                        'POST' => 'deleteUser',
                        'body' => $body
                    )
                )
            ),
            'otp' => array(
                'controller' => new OtpController(),
                'routes' => array(
                    'otp/generate' => array(
                        'GET' => 'generate'
                    ),
                    'otp/verify' => array(
                        'POST' => 'validOtp',
                        'body' => $body
                    )
                )
            ),
            'saas' => array(
                'controller' => new SaasApplicationController(),
                'routes' => array(
                    'saas/change-password' => array(
                        'POST' => 'changePassword',
                        'body' => $body
                    )
                )
            ),
        );

        if (!isset($allRoutes[$mainRouteRoot])) {
            $this->sendError(404, 'Not Found');
        }
        $mainRoute = $allRoutes[$mainRouteRoot];
        $controller = $mainRoute['controller'];
        $routes = $mainRoute['routes'];

        foreach ($routes as $route => $ca) {
            $action = isset($ca[$method]) ? $ca[$method] : '';

            if ($currentRoute == $route) {
                // call_user_func(array($controller, $action));                
                call_user_func_array(array($controller, $action), array('body' => $body));
                return;
            }

            $slashedRoute = $this->regexifyRoute($route);        
                            
            if (preg_match("/$slashedRoute/", $currentRoute, $outputArray)) {
                if (isset($outputArray[1])) {            
                    if ($method == 'POST') {
                        call_user_func_array(array($controller, $action), array($outputArray[1], $body)); 
                        break;  
                    } else {
                        if (isset($outputArray[2])) {
                            call_user_func_array(array($controller, $action), array($outputArray[1], $outputArray[2])); 
                            break;  
                        } else {
                            call_user_func_array(array($controller, $action), array($outputArray[1]));
                            break;
                        }
                    }
                } else {
                    call_user_func(array($controller, $action));
                    break;
                }
            }

        }
        $this->sendError(404, 'Not Found');
    }

    
    /**
     * Encode array into JSON
     *
     * @param   Array  $data  Data to be converted to JSON
     *
     * @return  JSON         Encode Json Data
     */
    public function json($data) {
        if(is_array($data)) {
            return json_encode($data);
        }
    }
}

// Initiiate Library
$method = $_SERVER['REQUEST_METHOD'];
$method = isset($_REQUEST['method']) ? strtoupper($_REQUEST['method']) : $method;

$api = new API($db_servername, $connection_info, $app_user_name, $file_import_directory);
$api->dispatch($method, $currentRoute, $postBody, $is_bypass_auth_route);