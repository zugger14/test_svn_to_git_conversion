<?php

namespace Magium\Configuration\Tests\Config;

use Magium\Configuration\Config\Storage\CallbackInterface;

class Callback implements CallbackInterface
{

    public function filter($value)
    {
        return strtoupper($value);
    }
}
