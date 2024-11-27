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
  mut span = $in
  $span.start -= $offset
  $span.end -= $offset
  return $span
}

# find the inner-most ast node that contains the given position
# with the correct node type
export def find_ast_node [
  position: int # the position to find
  type: string # the node type to search for
]: string -> record<start: int, end: int> {
  let pipelines = ast -j -m $in
  | get block
  | from json
  | get pipelines.elements
  let offset = $pipelines | get 0.expr.span.start.0
  let matching_nodes = $pipelines
  | cherry-pick {|x|
    let span = if ($x.span | describe | str starts-with "table") {
      $x.span.0
    } else $x.span
    if (($position + $offset | _in_span $span) and
      ($x.expr | columns | first) =~ $type) {
      $span
      | _span_calibrate $offset
    }
  }
  $matching_nodes
  | sort-by {$in.end - $in.start}
  | get -i 0
}
