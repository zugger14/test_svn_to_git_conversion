<?php
include_once '../Rest.inc.php';
include_once '../lib/Db.php';

class DB_Functions extends Db {
 
    private $db_connect;
    
    // constructor
    function __construct() {
        require_once '../config.php';
        require_once '../../' . $farrms_client_dir . '/farrms.client.config.ini.php';

        if ($CLOUD_MODE == 1)
            $check_cloud_mode_login = 1;
        
        require_once '../../' . $farrms_client_dir . '/adiha.config.ini.rec.php';
        // connecting to database
        $this->db_connect = new DB($db_servername, $connection_info);
    }
    
    // destructor
    function __destruct() {
         
    }
    
    public function listDevice() {
        $query = "EXEC spa_mobile_login 's'";
        return $this->db_connect->query($query);
    }
    
    public function getDeviceIds($user_login_id) {
        $query = "EXEC spa_mobile_login @flag = 'a', @user_login_id = '$user_login_id'";
        return $this->db_connect->query($query);
    }
}
?>