<?php

class Workflow {
    public static function find() {
        global $app_user_name;
        //$query = "EXEC spa_mobile_alert 'w', @user_name = '$this->app_user_name'";
        $query = "EXEC spa_mobile_alert 'w', @user_name = '$app_user_name'";
        return DB::query($query);
    }

    public static function findOne($message_id) {
        global $app_user_name;
        $message_id = (int)$message_id;
        //$query = "EXEC spa_mobile_alert 'v', @user_name = '$this->app_user_name', @message_id = '$message_id'";
        $query = "EXEC spa_mobile_alert 'v',  @message_id = '$message_id', @user_name = '$app_user_name'";
        return DB::query($query);
    }
    
    public static function deleteOne($message_id) {
        global $app_user_name;
        $message_id = (int)$message_id;
        //$query = "EXEC spa_mobile_alert 'd', @user_name = '$this->app_user_name', @message_id = '$message_id'";
        $query = "EXEC spa_mobile_alert 'd', @message_id = '$message_id', @user_name = '$app_user_name'";
        return DB::query($query);
    }
    /*
    public static function action1($activity_id, $action) {
        global $app_user_name;
        if ($action == 'approve')
            $action_flag = 'x';
        else if ($action == 'unapprove')
            $action_flag = 'y';
        else 
            $action_flag = 'z';
            
        $query = "EXEC spa_mobile_alert '$action_flag', @user_name = '$app_user_name', @message_id = $activity_id";
        return DB::query($query);
    }
    */
    
     public static function delete($workflow_ids) {
        global $app_user_name;
        
        if (is_array($workflow_ids)) {
            $workflow_ids = implode(',',$workflow_ids);
        }
            
        $query = "EXEC spa_mobile_alert 'd', @user_name = '$app_user_name', @message_id = '$workflow_ids'";
        return DB::query($query);
    }
    
    public static function action($workflow_action, $workflow_ids) {
        global $app_user_name;
        
        if (is_array($workflow_ids)) {
            $workflow_ids = implode(',',$workflow_ids);
        }
        
        if ($workflow_action == 'seen')
           $action_flag = 's';
        else if ($workflow_action == 'unseen')
            $action_flag = 'u';
        else if ($workflow_action == 'approve')
            $action_flag = 'x';
        else if ($workflow_action == 'unapprove')
            $action_flag = 'y';
        else 
            $action_flag = 'z';
            
        $query = "EXEC spa_mobile_alert '$action_flag', @user_name = '$app_user_name', @message_id = '$workflow_ids'";
        return DB::query($query);
    }
}
