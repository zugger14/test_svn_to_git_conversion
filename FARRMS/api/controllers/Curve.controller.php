<?php

class CurveController extends REST {
    public function index() {
        $results = Curve::find();
        $this->response($this->json($results), 200);
    }

    public function get($templateId) {
        $results = Curve::findOne($templateId);
        $this->response($this->json($results[0]), 200);
    }
}
