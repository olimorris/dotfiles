; Endwise queries for Lua
; Automatically insert "end" for these constructs

; Function declarations
((function_declaration parameters: (_) @cursor) @endable @indent)
((function_definition parameters: (_) @cursor) @endable @indent)

; Control structures
((while_statement "do" @cursor) @endable @indent)
((for_statement "do" @cursor) @endable @indent)
((if_statement "then" @cursor) @endable @indent)
((do_statement "do" @cursor) @endable @indent)

; Error recovery patterns (for incomplete syntax trees)
((ERROR ("function" . (_)? . (parameters) @cursor) @indent))
((ERROR ("do" @cursor @indent)))
((ERROR ("while" @indent . (_) . "do" @cursor)))
((ERROR ("for" @indent . [(for_generic_clause) (for_numeric_clause)] . "do" @cursor)))
((ERROR ("if" @indent . (_) . "then" @cursor)))
