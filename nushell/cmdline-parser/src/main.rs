use clap::Parser as ArgParser;
use streaming_iterator::StreamingIterator;
use tree_sitter::{Language, Parser, Query, QueryCursor, TreeCursor};

/// Find the nushell AST node of given type at position, code is read from stdin
#[derive(ArgParser, Debug)]
#[command(version, about, long_about = None)]
struct Args {
    /// node type to find
    #[arg(short, long)]
    kind: Option<String>,
    /// offset from the start of the code
    #[arg(short, long)]
    offset: usize,
    /// if set, auto insert a place taking character to the offset of src code
    #[arg(short, long, default_value_t = false)]
    insert: bool,
    /// which character to insert if auto-insert is set to true
    #[arg(short, long, default_value_t = 'a')]
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
    // Read lines until EOF is encountered
    loop {
        let bytes_read = std::io::stdin().read_line(&mut input).unwrap();
        // Break the loop if EOF is reached (bytes_read is 0)
        if bytes_read == 0 {
            break;
        }
    }
    let offset = std::cmp::min(args.offset, input.len());
    if args.insert {
        // auto insert a place taking char
        input.insert(offset, args.char);
    }

    let matching_kinds = std::collections::HashMap::from([
        ("(", ")"),
        (")", "("),
        ("[", "]"),
        ("]", "["),
        ("{", "}"),
        ("}", "{"),
        ("'", "'"),
        ("\"", "\\\""),
    ]);

    let nu_lang = Language::from(tree_sitter_nu::LANGUAGE);
    let mut parser = Parser::new();
    parser
        .set_language(&nu_lang)
        .expect("Error loading Nu parser");
    let parse_tree = parser.parse(&input, None).unwrap();

    if cfg!(feature = "debug") {
        print_tree(&parse_tree);
        println!("====================");
    }

    let mut tree_cursor = parse_tree.walk();
    tree_node_at_position_by_kind(&mut tree_cursor, offset + 1, args.kind.as_deref());
    // find the opposite node
    // if not the first node then must be the last one
    if args.matchit {
        let this_kind = tree_cursor.node().kind().trim();
        let target_kind = matching_kinds.get(this_kind);
        // big span like val_string
        if tree_cursor.node().byte_range().len() > 1 {
            print_the_further_end(offset, &tree_cursor);
            return;
        } else if tree_cursor.goto_parent() {
            // search within the parent node
            let node = tree_cursor.node();
            match target_kind {
                Some(t_kind) => {
                    let query_s_expr = format!("(\"{}\" @m)", *t_kind);
                    let query =
                        Query::new(&nu_lang, query_s_expr.as_str()).expect("Error loading query");
                    let mut query_cursor = QueryCursor::new();
                    query_cursor.set_byte_range(node.byte_range());
                    let mut query_matches = query_cursor.matches(&query, node, input.as_bytes());
                    while let Some(qm) = query_matches.next() {
                        for cn in qm.captures {
                            if cfg!(feature = "debug") {
                                println!("=={:#?}==", cn.node);
                            }
                            let start_offset = cn.node.start_byte();
                            if node.id() == cn.node.parent().unwrap().id() && start_offset != offset
                            {
                                println!("{}", start_offset);
                                return;
                            }
                        }
                    }
                }
                // at some random position, return the left/right end of parent node.
                None => {
                    print_the_further_end(offset, &tree_cursor);
                    return;
                }
            }
        }
    }
    let start_offset = tree_cursor.node().start_byte();
    let end_offset = tree_cursor.node().end_byte();
    println!("{start_offset}");
    println!("{end_offset}");
    // println!("{}", &input[start_offset..end_offset]);
}

fn print_the_further_end(offset: usize, cursor: &TreeCursor) {
    let start = cursor.node().start_byte();
    let end = cursor.node().end_byte() - 1;
    // get the end that is far from offset
    println!(
        "{}",
        if offset.abs_diff(start) < offset.abs_diff(end) {
            end
        } else {
            start
        }
    );
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

fn tree_node_at_position_by_kind(
    cursor: &mut TreeCursor,
    offset: usize,
    target_kind: Option<&str>,
) {
    // find the inner most node that contains pos, do nothing in the block
    while cursor.goto_first_child_for_byte(offset).is_some() {
        if cfg!(feature = "debug") {
            println!("{:#?}", cursor.node());
        }
    }
    // if target_kind is not specified, no further ops
    if target_kind.is_none() {
        return;
    }
    // reverse back to the parent of the given kind
    while cursor.node().kind().trim() != target_kind.unwrap() && cursor.goto_parent() {}
}
