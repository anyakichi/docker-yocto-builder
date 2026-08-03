{% if "${BBPATH:-}" -%}

Setup is already done in this shell, hence there is nothing to do.

{%- else -%}

{% include setup-$(yocto-flavor) %}

{%- endif %}
