use regex::Regex;
use std::fs::File;
use std::io::Read;
use std::path::Path;

enum TokenType {
    Keyword(String),
    Identifier,
    Constant,
    OpenParenthesis,
    CloseParenthesis,
    OpenBrace,
    CloseBrace,
    Semicolon,
    Unknown,
}

fn classify_token(token: &str) -> TokenType {
    let keyword_patterns = vec![
        ("int", Regex::new(r"\bint\b").unwrap()),
        ("void", Regex::new(r"\bvoid\b").unwrap()),
        ("return", Regex::new(r"\breturn\b").unwrap()),
    ];

    let regex_patterns = vec![
        ("Identifier", Regex::new(r"^[a-zA-Z_]\w*$").unwrap()),
        ("Constant", Regex::new(r"^\d+$").unwrap()),
        ("Open parenthesis", Regex::new(r"^\($").unwrap()),
        ("Close parenthesis", Regex::new(r"^\)$").unwrap()),
        ("Open brace", Regex::new(r"^\{$").unwrap()),
        ("Close brace", Regex::new(r"^\}$").unwrap()),
        ("Semicolon", Regex::new(r"^;$").unwrap()),
    ];

    // Check for keywords
    for (keyword, regex) in &keyword_patterns {
        if regex.is_match(token) {
            return TokenType::Keyword(keyword.to_string());
        }
    }

    // Check for other patterns
    for (token_type, regex) in &regex_patterns {
        if regex.is_match(token) {
            return match *token_type {
                "Identifier" => TokenType::Identifier,
                "Constant" => TokenType::Constant,
                "Open parenthesis" => TokenType::OpenParenthesis,
                "Close parenthesis" => TokenType::CloseParenthesis,
                "Open brace" => TokenType::OpenBrace,
                "Close brace" => TokenType::CloseBrace,
                "Semicolon" => TokenType::Semicolon,
                _ => TokenType::Unknown,
            };
        }
    }

    TokenType::Unknown
}

pub fn init(input: &str) -> String {
    let path = Path::new(input);

    let mut file = match File::open(&path) {
        Ok(file) => file,
        Err(e) => {
            return format!("Failed to open the file: {}", e);
        }
    };

    let mut content_file = String::new();
    if let Err(e) = file.read_to_string(&mut content_file) {
        return format!("Failed to read the file: {}", e);
    }

    let mut classified = String::new();
    let mut tokens = Vec::new();

    // Tokenize the input based on whitespace and punctuations
    let token_pattern = Regex::new(r"[a-zA-Z_]\w*|\d+|[(){};]").unwrap();
    for mat in token_pattern.find_iter(&content_file) {
        tokens.push(mat.as_str().to_string());
    }

    for token in tokens {
        match classify_token(&token) {
            TokenType::Keyword(keyword) => {
                classified.push_str(&format!("Keyword '{}'\n", keyword));
            },
            TokenType::Identifier => {
                classified.push_str(&format!("Identifier: '{}'\n", token));
            },
            TokenType::Constant => {
                classified.push_str(&format!("Constant: '{}'\n", token));
            },
            TokenType::OpenParenthesis => {
                classified.push_str(&format!("Open Parenthesis: '{}'\n", token));
            },
            TokenType::CloseParenthesis => {
                classified.push_str(&format!("Close Parenthesis: '{}'\n", token));
            },
            TokenType::OpenBrace => {
                classified.push_str(&format!("Open Brace: '{}'\n", token));
            },
            TokenType::CloseBrace => {
                classified.push_str(&format!("Close Brace: '{}'\n", token));
            },
            TokenType::Semicolon => {
                classified.push_str(&format!("Semicolon: '{}'\n", token));
            },
            TokenType::Unknown => {
                classified.push_str(&format!("Unknown token: '{}'\n", token));
            },
        }
    }

    classified
}

