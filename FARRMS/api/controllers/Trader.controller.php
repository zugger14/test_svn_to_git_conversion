<?php

class TraderController extends REST {
    public function index() {
        $results = Trader::find();
        $this->response($this->json($results), 200);
    }

    public function get($templateId) {
        $results = Trader::findOne($templateId);
        $this->response($this->json($results[0]), 200);
    }
}
