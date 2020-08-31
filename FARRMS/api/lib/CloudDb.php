<?php
/**
*  @brief Cloud Database Class
*
*  @par Description
*  This Class that connect and executes Database Queries for Cloud Application
*  @copyright Pioneer Solutions.
*/
class CloudDb {
	public static $db = NULL;
	private $main_db = NULL;
    private $connection_info = NULL;
    private $db_server_name = NULL;

    /**
     * Initiate Constructor
     */
    public function __construct() {
        global $CLOUD_MODE;
        if ($CLOUD_MODE) {
            global $cloud_db_servername, $connection_info_cloud;
            if (isset($cloud_db_servername) && isset($connection_info_cloud)) {
                $this->db_server_name = $cloud_db_servername;
                $this->connection_info = $connection_info_cloud;
            } else {
                global $farrms_client_dir;
                require '../' . $farrms_client_dir . '/farrms.client.config.ini.php';
                require '../' . $farrms_client_dir . '/license.php';
                $this->db_server_name = $db_servername;
                $this->connection_info = array(
                    "Database" => $database_name,
                    "UID" => $cloud_db_user,
                    "PWD" => $cloud_db_pwd,
                    "CharacterSet" => "UTF-8",
                    'ReturnDatesAsStrings'=> true);
            }
            ## Initiate Database connection
            $this->adihaDbConnect();
        }
    }

    /**
     * Connect Adiha Cloud Database Server
     */
    public function adihaDbConnect() {
        if (!self::$db) {
            sqlsrv_configure('WarningsReturnAsErrors',0);
            self::$db = @sqlsrv_connect($this->db_server_name, $this->connection_info);
            if (!self::$db) {
                self::errorMessage('Could not establish connection to cloud database');
            }
        }        
    }
    
    /**
     * Close Database connection
     */
    public function adihaDbClose() {
        if (self::$db) {
            sqlsrv_close(self::$db);            
        }        
    }

    /**
     * Executes provided SQL Query
     * 
     * @param   String  $xmlFile  Sql Query
     * 
     * @return  Array  Recordset as query result
     */
    public static function adihaDbQuery($xmlFile) {
        if (is_resource(self::$db)) {
            $sql_result = sqlsrv_query(self::$db, $xmlFile);

            $result = array();
            if ($sql_result && sqlsrv_has_rows($sql_result)) {
                while ($row = sqlsrv_fetch_array($sql_result, SQLSRV_FETCH_ASSOC)) {
                    $result[] = $row;
                }
                sqlsrv_free_stmt($sql_result);
            }
            
            if(isset($result[0])) {
                return $result[0];
            } else {
                return $result;
            }
        } else {
            self::errorMessage('Could not establish connection to cloud database');
        }        
    }

    /**
     * Connects Main Application Database
     *
     * @param   String  $db_servername  Server Name
     * @param   String  $db_name        Database Name
     * @param   String  $db_user        User Name
     * @param   String  $db_pwd         User Password
     *
     * @return  Object                  Connection Object
     */
    public function connectMainAppDb($db_servername, $db_name, $db_user, $db_pwd) {
        $connection_info_main_db = array(
            "Database" => $db_name,
            "UID" => $db_user,
            "PWD" => $db_pwd,
            "CharacterSet" => "UTF-8",
            'ReturnDatesAsStrings'=> true
        );
        $this->main_db = @sqlsrv_connect($db_servername, $connection_info_main_db);
        
        $connection = ($this->main_db) ? true : false;

        return $connection;
    }

    /**
     * Executes Main Database Query
     *
     * @param   String  $xmlFile  SQL Query
     *
     * @return  Array            Result Recordset
     */
    public function mainDbQuery($xmlFile) {
    	$sql_result = sqlsrv_query($this->main_db, $xmlFile);
        
        $result = array();
        if ($sql_result && sqlsrv_has_rows($sql_result)) {
            while ($row = sqlsrv_fetch_array($sql_result, SQLSRV_FETCH_ASSOC)) {
                $result[] = $row;
            }
            sqlsrv_free_stmt($sql_result);
        }

        if(isset($result[0])) {
            return $result[0];
        } else {
            return $result;
        }
    }

    /**
     * Print Error Message
     *
     * @param   String  $msg        Error Message
     * @param   Integer  $errorcode     Error Code
     * @param   String  $status     Error Status
     *
     * @return  String              Error Message
     */
    public static function errorMessage($msg, $errorcode = 500, $status = 'Internal Server Error') {
        header("HTTP/1.1 " . $errorcode . " " . $status);
        header("Content-Type: application/json");
        $return_message['message'] = isset($msg) ? $msg : 'Could not establish connection to cloud database';
        
        echo json_encode($return_message);
        die;
    }
}