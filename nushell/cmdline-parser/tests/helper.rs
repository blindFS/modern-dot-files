use std::{
    io::Write,
    process::{Command, Stdio},
};

pub fn test_with_input_and_args(input: &str, args: Vec<&str>, correct_output: &str) {
    // Set up the command to run the main function
    let mut cmd = Command::new("cargo");
    cmd.arg("run");
    cmd.arg("--quiet");
    cmd.arg("--");

    // Run the command with the given stdin and arguments
    let mut child = cmd
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .args(args)
        .spawn()
        .expect("Failed to spawn child process");

    child
        .stdin
        .take()
        .unwrap()
        .write_all(input.as_bytes())
        .expect("Failed to write to stdin");

    let output = child.wait_with_output().expect("Failed to read stdout");
    // Assert that the output of the command is as expected
    assert_eq!(output.stdout, correct_output.as_bytes());
}
