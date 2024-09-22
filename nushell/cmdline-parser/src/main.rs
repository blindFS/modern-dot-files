use tree_sitter::{Language, Parser, TreeCursor, Point};
use std::io;
use std::env;

fn main() {
    // read nu script code from pipeline input
    let mut input = String::new();
    let mut line_length: Vec<usize> = Vec::new();
    for line in io::stdin().lines() {
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
    // read command line argument "offset" (integer)
    let args: Vec<String> = env::args().collect(); // Get command-line arguments
    if args.len() < 2 {
        println!("Usage: {} <offset>", args[0]); // Print usage if no argument is provided
        return;
    }
    let offset: usize = match args[1].parse::<usize>() {
        Ok(pos) => std::cmp::min(pos, input.len() - 1),
        Err(_) => input.len() - 1, // defaults to tail of input string
    };
    // insert '_' to indicate the cursor
    input.insert(offset, '_');

    // convert offset to (row, column) format
    let pos = offset_to_tuple(offset, &line_length);

    let nu_lang = Language::from(tree_sitter_nu::LANGUAGE);
    let mut parser = Parser::new();
    parser.set_language(&nu_lang).expect("Error loading Nu parser");
    let parse_tree = parser.parse(&input, None).unwrap();

    print_tree(&parse_tree);
    println!("====================");
    let mut tree_cursor = parse_tree.walk();
    if let Some((start_pos, end_pos)) = walk_tree(&mut tree_cursor, &pos) {
        let start_offset = point_to_offset(start_pos, &line_length);
        let end_offset = point_to_offset(end_pos, &line_length);
        println!("{start_offset}");
        println!("{end_offset}");
        println!("{}", &input[start_offset..end_offset]);
    }
}

fn offset_to_tuple(offset: usize, line_length: &Vec<usize>) -> (usize, usize) {
    let mut pos: (usize, usize) = (0, offset);
    for l in line_length.clone() {
        if pos.1 >= l {
            pos = (pos.0 + 1, pos.1 - l);
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

fn is_position_before_point(pos: &(usize, usize), pt: Point) -> bool {
    pos.0 < pt.row || (pos.0 == pt.row && pos.1 < pt.column)
}

fn is_position_in_span(pos: &(usize, usize), start: Point, end: Point) -> bool {
    is_position_before_point(pos, end) && !is_position_before_point(pos, start)
}

fn point_to_offset(pt: Point, line_length: &Vec<usize>) -> usize {
    let mut res = pt.column;
    for idx in 0..pt.row {
        res += line_length.get(idx).unwrap();
    }
    res
}

fn walk_tree(
    cursor: &mut TreeCursor,
    pos: &(usize, usize),
) -> Option<(Point, Point)> {
    if cursor.goto_first_child() {
        loop {
            walk_tree(cursor, pos);
            let node = cursor.node();
            let start_pos = node.start_position();
            let end_pos = node.end_position();
            let kind = node.kind().trim();
            if kind == "command" && is_position_in_span(pos, start_pos, end_pos) {
                return Some((start_pos, end_pos));
            }
            if !cursor.goto_next_sibling() {
                break;
            }
        }
        cursor.goto_parent();
    }
    return None;
}
