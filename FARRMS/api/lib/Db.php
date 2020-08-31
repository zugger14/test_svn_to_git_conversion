<?php
/**
*  @brief Database Class
*
*  @par Description
*  This Class that connect and executes Database Queries extending REST
*  @copyright Pioneer Solutions.
*/
class DB extends REST {
    /**
     * Database connection Object
     *
     * @var Object
     */
    static $db = NULL;

    /**
     * Contains connection information
     *
     * @var Array
     */
    private $connection_info1 = NULL;

    /**
     * Database Server Name
     *
     * @var String
     */
    private $db_server_name = NULL;

    /**
     * Initiate Constructor
     *
     * @param   String  $db_servername    Database Server Name
     * @param   Array  $connection_info  Database connection Credentials
     */
    public function __construct($db_servername, $connection_info) {
        if ($db_servername) {
            $this->connection_info1 = $connection_info;
            $this->db_server_name = $db_servername;
            ## Initiate Database connection
            $this->dbConnect();
        }       
    }

    /**
     * Connect Database Server
     */
    public function dbConnect() {
        if (!self::$db) {
            sqlsrv_configure('WarningsReturnAsErrors',0);
            self::$db = @sqlsrv_connect($this->db_server_name, $this->connection_info1);
            if (!self::$db) {
                $this->sendError(401, 'Bad login');
                die();
            }
        }        
    }
    
    /**
     * Close Database connection
     */
    public function dbClose() {
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
    public static function query($xmlFile) {
        global $app_user_name;
        
        $sql = DB::add_session_context($xmlFile);
        $params = array();
        // Reconfigure query timeout option of SQLSRV
        $options = array(
            'QueryTimeout' => 6000
        );

        $sql_result = sqlsrv_query(self::$db, $sql, $params, $options);
        $result = array();
        // If error occured while querying database log it
        if ($sql_result === false) {
            $errors = sqlsrv_errors();
            if ($errors != null) {
                foreach ($errors as $error) {
                    $error_log_body = '{SQLSTATE: ' . $error['SQLSTATE'] . ', code: ' . $error['code'] . ', message: ' . $error['message'] . '}';
                }
                $helper = new Rest();
                $helper->writeLogFile($app_user_name, '', '', $error_log_body);
            }
        } else {
            if ($sql_result && sqlsrv_has_rows($sql_result)) {
                while ($row = sqlsrv_fetch_array($sql_result, SQLSRV_FETCH_ASSOC)) {
                    $result[] = $row;
                }
                sqlsrv_free_stmt($sql_result);
            }
        }

        return $result;
    }

    /**
     * Adds Session Context to SQL Query
     * 
     * @param String $sql SQL Query
     * 
     * @return String SQL Query with context info
     */
    private static function add_session_context($sql) {
        global $app_user_name;
        return "EXEC sys.sp_set_session_context @key = N'DB_USER', @value = '" . $app_user_name . "';" . $sql;
    }
}
?>