<?php

class LocationController extends REST {
    public function index() {
        $results = Location::find();
        $this->response($this->json($results));
    }

    public function get($templateId) {
        $results = Location::findOne($templateId);
        $this->response($this->json($results[0]), 200);
    }
}
