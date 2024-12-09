mod helper;
use helper::test_with_input_and_args;

#[test]
fn test_case1() {
    test_with_input_and_args("ls | cd ", vec!["-o", "2", "-i", "-k", "command"], "0\n4\n");
}

#[test]
fn test_case2() {
    test_with_input_and_args(
        "ls ; cd ",
        vec!["-o", "100", "-i", "-k", "command"],
        "5\n9\n",
    );
}

#[test]
fn test_case3() {
    test_with_input_and_args("ls ; cd ", vec!["-o", "4", "-i", "-k", "command"], "4\n9\n");
}

