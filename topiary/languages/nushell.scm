[
  (val_string)
  (cell_path)
  (comment)
] @leaf

[
  (pipeline)
  (assignment)
  (comment)
  (stmt_const)
  (stmt_let)
] @allow_blank_line_before

[
  "mut"
  "let"
  "const"
  "where"
  "return"
  "source"
  ":"
  (parameter_pipes)
] @append_space

[
  "=>"
  "->"
  "="
  "else"
  (comment)
] @prepend_space @append_space

(expr_binary
  lhs: _ @append_space
  opr: _
  rhs: _ @prepend_space
)

(assignment
  lhs: _ @append_space
  opr: _
  rhs: _ @prepend_space
)

[
  "["
  "{"
  "("
] @append_indent_start @append_empty_softline

[
  "]"
  "}"
  ")"
] @prepend_indent_end @prepend_empty_softline

(decl_def
  "export"? @append_space
  (long_flag)? @prepend_space @append_space
  quoted_name: _? @prepend_space @append_space
  unquoted_name: _? @prepend_space @append_space
  (parameter_bracks)?
  (returns)?
  (block) @prepend_space
)

(decl_use
  module: _? @prepend_space @append_space
  import_pattern: _? @prepend_space @append_space
)

[
  (decl_def)
  (decl_use)
] @append_hardline

(pipe_element
  "|" @prepend_space @append_space
)

(ctrl_if
  "if" @append_space
  condition: _ @append_space
)

(ctrl_for
  "for" @append_space
  "in" @prepend_space @append_space
  body: _ @prepend_space
)

(match_guard
  "if" @prepend_space @append_space
)

(ctrl_match
  "match" @append_space
  scrutinee: _? @append_space
  (match_arm)? @prepend_spaced_softline
  (default_arm)? @prepend_spaced_softline
)

(list_body
  entry: _ @append_space @prepend_spaced_softline
)

(val_list
  item: _ @append_space @prepend_spaced_softline
)

(record_body
  entry: (record_entry) @append_space @prepend_spaced_softline
)

(command
  flag: _? @prepend_space
  arg_str: _? @prepend_space
  arg: _? @prepend_space
)

[
  "\n"
] @append_hardline

(
  (comment) @append_empty_softline
  .
  "\n"? @do_nothing
)

[
  (parameter)
] @prepend_empty_softline
