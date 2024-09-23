use clap::Parser as ArgParser;
use tree_sitter::{Language, Parser, Point, TreeCursor};

/// Find the nushell AST node of given type at position, code is read from stdin
#[derive(ArgParser, Debug)]
#[command(version, about, long_about = None)]
struct Args {
    /// node type to find
    #[arg(short, long, default_value_t = String::from("command"))]
    kind: String,
    /// offset from the start of the code
    #[arg(short, long)]
    offset: usize,
    /// if set, auto insert a place taking character to the offset of src code
    #[arg(short, long, default_value_t = false)]
    insert: bool,
    /// which character to insert if auto-insert is set to true
    #[arg(short, long, default_value_t = '_')]
    char: char,
    /// if set, instead of search for node with the given type,
    /// search for the node at the other side of the parent node
    #[arg(short, long, default_value_t = false)]
    matchit: bool,
}

fn main() {
    let args = Args::parse();
    // read nu script code from pipeline input
    let mut input = String::new();
    let mut line_length: Vec<usize> = Vec::new();
    for line in std::io::stdin().lines() {
        match line {
            Ok(line) => {
                if !input.is_empty() {
                    if let Some(last_length) = line_length.last_mut() {
                        *last_length += 1; // '\n' takes space
                    }
                    input.push('\n'); // Add a newline if the string is not empty
                }
                input.push_str(&line); // Append the current line to the string
                line_length.push(line.len());
            }
            Err(error) => println!("Error reading line: {}", error),
        }
    }
    let offset = std::cmp::min(args.offset, input.len());
    if args.insert {
        // auto insert a place taking char
        input.insert(offset, args.char);
    }

    // convert offset to point
    let pos = offset_to_point(offset, &line_length);

    let nu_lang = Language::from(tree_sitter_nu::LANGUAGE);
    let mut parser = Parser::new();
    parser
        .set_language(&nu_lang)
        .expect("Error loading Nu parser");
    let parse_tree = parser.parse(&input, None).unwrap();

    // print_tree(&parse_tree);
    // println!("====================");
    let mut tree_cursor = parse_tree.walk();
    tree_node_at_position_by_kind(&mut tree_cursor, pos, Some(&args.kind));
    // find the opposite node
    // if not the first node then must be the last one
    if args.matchit && tree_cursor.goto_parent() {
        tree_cursor.goto_first_child();
        let start = tree_cursor.node().start_position();
        let end = tree_cursor.node().end_position();
        if pos > start && pos <= end {
            tree_cursor.goto_parent();
            tree_cursor.goto_last_child();
        }
    }
    let start_pos = tree_cursor.node().start_position();
    let end_pos = tree_cursor.node().end_position();
    let start_offset = point_to_offset(start_pos, &line_length);
    let end_offset = point_to_offset(end_pos, &line_length);
    println!("{start_offset}");
    println!("{end_offset}");
    // println!("{}", &input[start_offset..end_offset]);
}

fn offset_to_point(offset: usize, line_length: &Vec<usize>) -> Point {
    let mut pos = Point::new(0, offset + 1);
    for l in line_length.clone() {
        if pos.column > l + 1 {
            pos = Point::new(pos.row + 1, pos.column - l);
        } else {
            break;
        }
    }
    pos
}

pub fn print_tree(tree: &tree_sitter::Tree) {
    let mut cursor = tree.walk();
    print_cursor(&mut cursor, 0);
}

fn print_cursor(cursor: &mut TreeCursor, depth: usize) {
    loop {
        let node = cursor.node();
        println!("{}{:#?}", "  ".repeat(depth), node);

        if cursor.goto_first_child() {
            print_cursor(cursor, depth + 1);
            cursor.goto_parent();
        }

        if !cursor.goto_next_sibling() {
            break;
        }
    }
}

fn point_to_offset(pt: Point, line_length: &Vec<usize>) -> usize {
    let mut res = pt.column;
    for idx in 0..pt.row {
        res += line_length.get(idx).unwrap();
    }
    res
}

fn tree_node_at_position_by_kind(cursor: &mut TreeCursor, pos: Point, target_kind: Option<&str>) {
    // find the inner most node that contains pos
    while cursor.goto_first_child_for_point(pos).is_some() {} // do nothing
    // if target_kind is not specified, no further ops
    if target_kind.is_none() {
        return;
    }
    // reverse back to the parent of the given kind
    while cursor.node().kind().trim() != target_kind.unwrap() && cursor.goto_parent() {}
}
