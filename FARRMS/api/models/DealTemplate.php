<?php

class DealTemplate {
    public static function find() {
        global $app_user_name;
        $query = "EXEC spa_mobile_deal 't', @runtime_user = '$app_user_name'";
        return DB::query($query);
    }

    public static function findOne($deal_template_id) {
        global $app_user_name;
        $deal_template_id = (int)$deal_template_id;
        $query = "EXEC spa_mobile_deal 't',@deal_template_id = $deal_template_id, @runtime_user = '$app_user_name'";
        return DB::query($query);
    }
}
