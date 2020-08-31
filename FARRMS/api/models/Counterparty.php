<?php

class Counterparty {
    public static function find() {
        global $app_user_name;
        $query = "EXEC spa_mobile_deal 'c', @runtime_user = '$app_user_name'";
        return DB::query($query);
    }

    public static function findOne($counterparty_id) {
        global $app_user_name;
        $counterparty_id = (int)$counterparty_id;
        $query = "EXEC spa_mobile_deal 'c', @counterparty_id = $counterparty_id, @runtime_user = '$app_user_name'";
        return DB::query($query);
    }
    
    public static function findDependentCounterparty($template_id) {
        global $app_user_name;
        $template_id = (int)$template_id;
        $query = "EXEC spa_mobile_deal 'c', @deal_template_id = $template_id, @runtime_user = '$app_user_name'";
        return DB::query($query);
    }
}
