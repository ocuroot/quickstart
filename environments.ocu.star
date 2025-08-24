ocuroot("0.3.0")

register_environment(environment(
    name="staging",
    attributes={
        "type": "staging",
        "frontend_port": "8080",
    }
))