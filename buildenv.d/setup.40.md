{% if -z "${BBPATH:-}" -%}

{% include setup-$(yocto-flavor) %}

{% endif -%}
