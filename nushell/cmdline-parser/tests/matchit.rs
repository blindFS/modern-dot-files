mod helper;
use helper::test_with_input_and_args;

#[test]
fn test_left_curly() {
    test_with_input_and_args("{(['string'])}", vec!["-o", "0", "-m"], "13\n");
}

#[test]
fn test_right_curly() {
    test_with_input_and_args("{(['string'])}", vec!["-o", "13", "-m"], "0\n");
}

#[test]
fn test_left_paren() {
    test_with_input_and_args("{(['string'])}", vec!["-o", "1", "-m"], "12\n");
}

#[test]
fn test_right_paren() {
    test_with_input_and_args("{(['string'])}", vec!["-o", "12", "-m"], "1\n");
}

#[test]
fn test_left_bracket() {
    test_with_input_and_args("{(['string'])}", vec!["-o", "2", "-m"], "11\n");
}

#[test]
fn test_right_bracket() {
    test_with_input_and_args("{(['string'])}", vec!["-o", "11", "-m"], "2\n");
}

#[test]
fn test_right_single_quote() {
    test_with_input_and_args("{(['string'])}", vec!["-o", "10", "-m"], "3\n");
    test_with_input_and_args("{(['string'])}", vec!["-o", "3", "-m"], "10\n");
}

