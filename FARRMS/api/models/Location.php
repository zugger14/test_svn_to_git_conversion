<?php

class Location {
    public static function find() {
        global $app_user_name;
        $query = "EXEC spa_mobile_deal 'l', @runtime_user = '$app_user_name'";
        return DB::query($query);
    }

    public static function findOne($location_id) {
        global $app_user_name;
        $location_id = (int)$location_id;
        $query = "EXEC spa_mobile_deal 'l', @location_id = '$location_id', @runtime_user = '$app_user_name'";
        return DB::query($query);
    }
}
