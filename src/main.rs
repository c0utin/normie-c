use std::env;
use std::process;
use std::path::Path;

mod lexer;

fn main() {
    let args: Vec<String> = env::args().collect();

    let file_path = &args[1];

    if !Path::new(file_path).exists() {
        eprintln!("Error: The specified file does not exist.");
        process::exit(1);
    }

    if args.contains(&"--lex".to_string()) {
        let result = lexer::init(file_path);
        println!("{}", result);
        process::exit(0);
    }

    if args.contains(&"--parse".to_string()) {
        println!("Parser executed");
        process::exit(0);
    }

    if args.contains(&"--codegen".to_string()) {
        println!("Codegen executed");
        process::exit(0);
    }

    if args.contains(&"-S".to_string()) {
        println!("Assembly emitted");
        process::exit(0);
    }

    full_compilation(file_path);
}

fn full_compilation(file_path: &str) {
    let tokens = lexer::init(file_path);
    println!("{}", tokens);

    process::exit(0);
}

