<?php

class Alert {
    public static function find() {
        global $app_user_name;
        //$query = "EXEC spa_mobile_alert 'a', @user_name = '$this->app_user_name'";
        $query = "EXEC spa_mobile_alert 'a', @user_name = '$app_user_name'";
        return DB::query($query);
    }

    public static function findOne($message_id) {
        global $app_user_name;
        $message_id = (int)$message_id;
        //$query = "EXEC spa_mobile_alert 'v', @user_name = '$this->app_user_name', @message_id = '$message_id'";
        $query = "EXEC spa_mobile_alert 'v',  @message_id = '$message_id', @user_name = '$app_user_name'";
        return DB::query($query);
    }
    
    public static function delete($message_ids) {
        global $app_user_name;
        
        if (is_array($message_ids)) {
            $message_ids = implode(',',$message_ids);
        }
            
        $query = "EXEC spa_mobile_alert 'e', @user_name = '$app_user_name', @message_id = '$message_ids'";
        return DB::query($query);
    }
    
    public static function action($action, $ids) {
        global $app_user_name;
        
        if (is_array($ids)) {
            $ids = implode(',',$ids);
        }
                
        if ($action == 'seen')
            $action_flag = 'f';
        else if ($action == 'unseen')
            $action_flag = 'g';
            
        $query = "EXEC spa_mobile_alert '$action_flag', @user_name = '$app_user_name', @message_id = '$ids'";
        return DB::query($query);
    }
    
    
}
