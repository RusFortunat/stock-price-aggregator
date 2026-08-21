{% macro get_s3_data_dir() %}
    {% set path_parts = model.path.split('/') %}
    {% set folder = path_parts[0] %}

    {% if folder == 'staging' %} 
        {{ return('s3://' ~ env_var('DATA_BUCKET') ~ '/staging' )}}
    {% elif folder == 'intermediate' %} 
        {{ return('s3://' ~ env_var('DATA_BUCKET') ~ '/intermediate' )}}
    {% elif folder == 'marts' %} 
        {{ return('s3://' ~ env_var('DATA_BUCKET') ~ '/marts' )}}
    {% else %}
        {{ exceptions.raise_compiler_error("Unknown folder '" ~ folder ~ "' for model '" ~ model.name ~ "'. Expected staging, intermediate, or marts.") }}
    {% endif %}
{% endmacro %}