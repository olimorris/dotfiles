; extends
(function_call
  name: (dot_index_expression
    table: (identifier) @_table
    field: (identifier) @_field)
  arguments: (arguments
    (string
      content: (string_content) @injection.content))
  (#eq? @_table child)
  (#any-of? @_field lua lua_get)
  (#set! injection.language "lua"))
