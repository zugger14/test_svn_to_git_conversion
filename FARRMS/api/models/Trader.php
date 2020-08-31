<?php

class Trader {
    public static function find() {
        global $app_user_name;
        $query = "EXEC spa_mobile_deal 'r', @runtime_user = '$app_user_name'";
        return DB::query($query);
    }

    public static function findOne($trader_id) {
        global $app_user_name;
        $trader_id = (int)$trader_id;
        $query = "EXEC spa_mobile_deal 'r', @trader = $trader_id, @runtime_user = '$app_user_name'";
        return DB::query($query);
    }
}
