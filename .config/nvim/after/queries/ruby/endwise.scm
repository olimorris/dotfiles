; Endwise queries for Ruby
; Automatically insert "end" for these constructs

; Module and class definitions
((module name: (_) @cursor) @endable @indent )
((class name: (_) @cursor superclass: (_)? @cursor) @endable @indent )
((singleton_class "class" . "<<" . value: (_) @cursor) @endable @indent )

; Method definitions
((method name: (_) @cursor parameters: (_)? @cursor) @endable @indent )
((singleton_method name: (_) @cursor parameters: (_)? @cursor) @endable @indent )

; Control structures
((while condition: (_) @cursor body: (do ("do")? @cursor) @endable) @indent )
((until condition: (_) @cursor body: (do ("do")? @cursor) @endable) @indent )
((for value: (_) @cursor body: (do ("do")? @cursor) @endable) @indent )
((do_block "do" @cursor parameters: (_)? @cursor) @endable @indent )

; Conditionals
((if condition: (_) @cursor) @endable @indent )
((unless condition: (_) @cursor) @endable @indent )
((case value: (_) @cursor) @endable @indent)
((case) @cursor @endable @indent)

; Exception handling
((begin "begin" @cursor . (rescue "rescue" @cursor exceptions: (_)? @cursor)? . (ensure "ensure" @cursor)?) @endable @indent )

; Heredocs
((heredoc_beginning) @cursor @endable @indent)

; Error recovery patterns (for incomplete syntax trees)
((ERROR ("module" @indent . [(constant) (scope_resolution)] @cursor)) )
((ERROR ("class" @indent . [(constant) (scope_resolution)] @cursor . (superclass)? @cursor)) )
((ERROR ("class" @indent . "<<" . (_) @cursor)) )
((ERROR ("def" @indent . (identifier) @cursor . (method_parameters)? @cursor)) )
((ERROR ("def" @indent . (identifier) . "." . (identifier) @cursor . (method_parameters)? @cursor)) )
((ERROR ("while" @indent . (_) @cursor . "do"? @cursor)) )
((ERROR ("until" @indent . (_) @cursor . "do"? @cursor)) )
((ERROR ("for" @indent . (_) . (in . "in" . (_) @cursor) . "do"? @cursor)) )
((ERROR ("do" @cursor @indent . (block_parameters)? @cursor)) )
((ERROR ("begin" @cursor @indent . ["rescue" @cursor (rescue "rescue" @cursor exceptions: (_)? @cursor)]? . ["ensure" (ensure "ensure" @cursor)]?)) )
((ERROR ("if" @indent . (_) @cursor . (then)? @cursor)) )
((ERROR ("unless" @indent . (_) @cursor . (then)? @cursor)) )
