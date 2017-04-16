navel-collector-backend-nagios-ndo2-listener
============================================

This collector start a listener to ndomod using the NDO protocol in version 2.

Status
------

- master

[![Build Status](https://travis-ci.org/Navel-IT/navel-collector-backend-nagios-ndo2-listener.svg?branch=master)](https://travis-ci.org/Navel-IT/navel-collector-backend-nagios-ndo2-listener?branch=master)
[![Coverage Status](https://coveralls.io/repos/github/Navel-IT/navel-collector-backend-nagios-ndo2-listener/badge.svg?branch=master)](https://coveralls.io/github/Navel-IT/navel-collector-backend-nagios-ndo2-listener?branch=master)

- devel

[![Build Status](https://travis-ci.org/Navel-IT/navel-collector-backend-nagios-ndo2-listener.svg?branch=devel)](https://travis-ci.org/Navel-IT/navel-collector-backend-nagios-ndo2-listener?branch=devel)
[![Coverage Status](https://coveralls.io/repos/github/Navel-IT/navel-collector-backend-nagios-ndo2-listener/badge.svg?branch=devel)](https://coveralls.io/github/Navel-IT/navel-collector-backend-nagios-ndo2-listener?branch=devel)

Installation
------------

```bash
cpanm https://github.com/navel-it/navel-collector-backend-nagios-ndo2-listener.git
```

Configuration
-------------

```json
{
    "backend": "Navel::Collector::Backend::Nagios::NDO2::Listener",
    "backend_input": {
        "address": null,
        "port": 5668,
        "tls": 0,
        "tls_ctx": {}
    }
}
```

Copyright
---------

Copyright (C) 2015-2017 Yoann Le Garff, Nicolas Boquet and Yann Le Bras

License
-------

navel-collector-backend-nagios-ndo2-listener is licensed under the Apache License, Version 2.0
