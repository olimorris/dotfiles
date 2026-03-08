;; extends

((attribute
        (attribute_name) @att_name (#eq? @att_name "class")
        (quoted_attribute_value (attribute_value) @class_value)
        (#match? @class_value "^(text|bg|m|mt|mr|mb|ml|p|pt|pr|pb|pl|flex|grid)-.*$")
          (#set! @class_value conceal "…")
          (#set! @class_value @class_value)))
