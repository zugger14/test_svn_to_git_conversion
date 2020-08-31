<?php
/** 
 * Handles the TRMTracker Session
 * @copyright Pioneer Solutions
 */
class TRMSession implements SessionHandlerInterface {
    /**
     * Database connection resource
     */
    private static $_ip;
    private static $_machine_name;
    private static $_database_name;
    function __construct($table_name = "") {
        require_once("lib/adiha_dhtmlx/AdihaClasses/DataCache.php");
        global $database_name; 
        self::$_database_name = strtolower(isset($database_name) ? $database_name : 'TRMTracker_Release');

        /*
          Client IP from POST should be given priority, which will be sent by cURL request. Otherwise 
          reading $_SERVER['REMOTE_ADDR'] in application side from cURL request gives web server IP, not client IP as request is generated from web server, not from client browser and session data is not saved due to IP mismatch.
        */
        if (isset($_POST['client_ip'])) {
           self::$_ip = $_POST['client_ip'];
        } else if (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
           self::$_ip = $_SERVER['HTTP_X_FORWARDED_FOR'];
        } else {
           self::$_ip = $_SERVER['REMOTE_ADDR'];
        }
        self::$_machine_name = self::$_ip;
	}

	/**
	 * [open_connection Open Connection]
	 * @return [type] [description]
	 */
	private static function open_connection() {
		global $db_servername, $connection_info;
		$_sess_db = sqlsrv_connect($db_servername, $connection_info);

		return $_sess_db;
	}

	/**
	 * [close_connection Close connection]
	 * @param  [type] $_sess_db [DB Connection]
	 */
	private static function close_connection($_sess_db) {
		sqlsrv_close($_sess_db);
	}

	/**
     * [open_data_cache Open connection to memory cache server]
     */
    private static function open_data_cache() {
        global $ENABLE_DATA_CACHING;
        
        if ($ENABLE_DATA_CACHING) {
            $data_cache = new DataCache(); 
            if ($data_cache->is_cache_server_exists()) return $data_cache;
            else return false;      
            
        } else return false;
    }

	/**
	 * [close_data_cache Close cache server open connection]
	 * @param  [type] $_cache_handler [data_cache connection]
	 */
	private static function close_data_cache($_cache_handler) {
		$_cache_handler->close_conn();
	}

	/**
	 * sqlsrv_escape Escape string for mssql query
	 * @param string $data
	 * @return string
	 */
	private static function sqlsrv_escape($data) {
    	return str_replace("'","''",$data);
	}

    /**
     * open Open the session
     * @return bool
     */
    public function open($savePath, $sessionName) {
        return true;
    }

    /**
     * close Close the session
     * @return boolean
     */
    public function close() {
        return true;
    }

    /**
     * read Read the session
     * @param string $id
     * @return string 
     */
    public function read($id) {		
    	$_cache_handler = self::open_data_cache();
        $cached_result = false;

        if ($_cache_handler) {
            $key = $_cache_handler->get_key($id, '', true);
            $cached_result = $_cache_handler->get_data($key);
        } 

    	if ($cached_result) {
    		self::close_data_cache($_cache_handler);
    		return $cached_result;
    	} else {
    		$_sess_db = self::open_connection();
            $sql = self::add_session_context("EXEC spa_trm_session @flag='a', @trm_session_id=?, @machine_name=?");

			$params = array(self::sqlsrv_escape($id), self::sqlsrv_escape(self::$_machine_name)); 

			$stmt = sqlsrv_query($_sess_db,$sql,$params);

	        if (!empty($stmt)) {
	        	$return_data = '';
	        	$row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC);
	        	$return_data = $row['session_data'];

	        	sqlsrv_free_stmt($stmt);
	        	self::close_connection($_sess_db);

                if ($_cache_handler) {
                    $_cache_handler->set_data($key, $row['session_data']);
                    self::close_data_cache($_cache_handler);
                }
				
				if (is_null($return_data)) {
					$return_data = '';  //use empty string instead of null!
				}

	        	return $return_data;
	        }
    	}
        
        return '';
    }

    /**
     * write Write the session
     * @param string $id
     * @param string $value
     * @return boolean
     */
    public function write($id, $value) {    	
    	$_cache_handler = self::open_data_cache();        
        $cached_result = false;

        if ($_cache_handler) {
            $key = $_cache_handler->get_key($id, '', true);
            $cached_result = $_cache_handler->get_data($key);
        }        

    	if ($cached_result) {
    		if ($cached_result == $value) {
    			self::close_data_cache($_cache_handler);
    			return true;
    		}
		}

        $sql = self::add_session_context("EXEC spa_trm_session @flag='i', @trm_session_id=?, @session_data=?, @machine_name=?, @machine_address=?");
        
        $_sess_db = self::open_connection();
        $params = array(self::sqlsrv_escape($id), $value, self::sqlsrv_escape(self::$_machine_name), self::sqlsrv_escape(self::$_ip));
		$stmt = sqlsrv_query($_sess_db,$sql,$params);


		if (!empty($stmt)) {
			$row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC);
        	$status = $row['ErrorCode'];

        	sqlsrv_free_stmt($stmt);
        	self::close_connection($_sess_db);
            if ($_cache_handler) {
                $_cache_handler->delete_key($key);              
                self::close_data_cache($_cache_handler);
            }
        	if ($status == 'Success') {
        		return true;
        	} else {
        		return true;
        	}
		}

    	return true;
		## return false is changed to true, to fix session_write_close issue. Don't know what's happening in PHP 7
    }
    
    /**
     * destroy Destroy the session
     * @param string $id
     * @return boolean
     */
    public function destroy($id) {
        $_cache_handler = self::open_data_cache(); 

        if ($_cache_handler) {
            $key = $_cache_handler->get_key($id, '', true);
            $cached_result = $_cache_handler->get_data($key);
        }  
        
        $sql = self::add_session_context("EXEC spa_trm_session @flag='d', @trm_session_id=?, @machine_name=?");

		$params = array(self::sqlsrv_escape($id), self::sqlsrv_escape(self::$_machine_name)); 
		$_sess_db = self::open_connection();
        $stmt = sqlsrv_query($_sess_db,$sql,$params);

        $_cache_handler = self::open_data_cache();

        if ($_cache_handler) {
            // delete key from cache server
            $_cache_handler->delete_key($key);
            self::close_data_cache($_cache_handler);
        }

		if (!empty($stmt)) {
			sqlsrv_free_stmt($stmt);
        	self::close_connection($_sess_db);
        	return true;
		}

		return false;
    }

    /**
     * gc Garbage Collector
     * @param integer $max
     * @return boolean
     */
    public function gc($max) {
        $_sess_db = self::open_connection();
        $sql = self::add_session_context("EXEC spa_trm_session @flag='x',@max_session_time=?");

		$params = array($max);

        $stmt = sqlsrv_query($_sess_db,$sql,$params);

		if (!empty($stmt)) {
			sqlsrv_free_stmt($stmt);
        	self::close_connection($_sess_db);
        	return true;
		}

		return false;
    }

    /**
     * Adds Session Context to SQL Query
     * @param String $sql SQL Query
     */
    private function add_session_context($sql) {
        global $app_user_name;
        return "EXEC sys.sp_set_session_context @key = N'DB_USER', @value = '" . $app_user_name . "';" . $sql;
    }
}

// to prevent problem of session write after close
register_shutdown_function('session_write_close');

$handler = new TRMSession();
session_set_save_handler($handler, true);

?>