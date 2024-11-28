# get substring from start to the given index, returns empty string if negative
export def substring_to_idx [
  index: int # end index (included)
  --grapheme (-g) # use grapheme idx instead of byte offset
]: string -> string {
  let input = $in
  match $grapheme {
    _ if $index < 0 => ''
    true => ($input | str substring -g ..$index)
    false => ($input | str substring ..$index)
  }
}

# get substring from given index to the end, returns whole string if negative
export def substring_from_idx [
  index: int # start index (included)
  --grapheme (-g) # use grapheme idx instead of byte offset
]: string -> string {
  let input = $in
  match $grapheme {
    _ if $index < 0 => $input
    true => ($input | str substring -g $index..)
    false => ($input | str substring $index..)
  }
}

# A command for cherry-picking values from a record key recursively
export def cherry-pick [
  test # The test function to run over each element
]: any -> list<any> {
  let input = $in
  let candidates = if ($input | describe | str starts-with "record") {
    $input | values
  } else $input
  mut res = []
  try {
    $res = [(do $test $input)]
    | filter {$in | is-not-empty}
  }
  if ($candidates | describe) =~ "^list|table" {
    $res
    | append (
      $candidates
      | each {$in | cherry-pick $test}
    )
    | flatten
  } else {
    $res
  }
}

def _in_span [
  span: any
]: int -> bool {
  return ($in >= $span.start and $in < $span.end)
}

def _span_calibrate [
  offset: int
]: record -> record {
  {
    start: ($in.start - $offset)
    end: ($in.end - $offset)
  }
}

# find the inner-most ast node that contains the given position
# with the correct node type
export def find_ast_node [
  position: int # the position to find
  type: string # regexp of node type to search for
]: string -> record<start: int, end: int> {
  let input_raw = $in
  let pipelines = ast -j -m $input_raw
  | get block
  | from json
  | get pipelines.elements
  let offset = $pipelines | get 0.expr.span.start.0
  let matching_spans = $pipelines
  | cherry-pick {|x|
    let span = if ($x.span | describe | str starts-with "table") {
      $x.span.0
    } else $x.span
    let node_type = $x.expr | columns | first
    if not ($position + $offset | _in_span $span) {
      return null
    }
    let ans = if $node_type =~ $type {
      $span | _span_calibrate $offset
    } else null
    match $node_type {
      'Subexpression' | 'Closure' => {
        let start_offset = ($span.start + 1 - $offset)
        # recurse into subexpressions and closures
        ($input_raw | str substring
          $start_offset..($span.end - 2 - $offset))
        | find_ast_node ($position - $start_offset) $type
        | _span_calibrate (0 - $start_offset)
        | default $ans
      }
      _ => $ans
    }
  }
  $matching_spans
  | sort-by {$in.end - $in.start}
  | get -i 0
}
