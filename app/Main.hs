module Main where

import Control.Exception (evaluate, finally)
import Codegen (generateProgram, instructionCount, renderProgram)
import qualified Parser
import Parser (parseProgram, tokenize)
import System.Directory (doesFileExist, removeFile)
import System.Environment (getArgs)
import System.Exit (ExitCode (..), exitSuccess, exitWith)
import System.FilePath (dropExtension, replaceExtension)
import System.IO (hPutStrLn, stderr)
import System.Process (readProcessWithExitCode)

data Mode = Compile | Lex | Parse | Codegen | Assembly | Ast

data Args
  = Run Mode FilePath
  | Help
  | Invalid

parseArgs :: [String] -> Args
parseArgs ["--help"] = Help
parseArgs [file] = Run Compile file
parseArgs ["--lex", file] = Run Lex file
parseArgs ["--parse", file] = Run Parse file
parseArgs ["--codegen", file] = Run Codegen file
parseArgs ["--asm", file] = Run Assembly file
parseArgs ["--ast", file] = Run Ast file
parseArgs _ = Invalid

usage :: String
usage =
  unlines
    [ "usage: compiler [OPTIONS] <file>",
      "",
      "Options:",
      "  (no option) Compile and link an executable",
      "  --lex     Tokenize the input and exit",
      "  --parse   Parse the input and exit",
      "  --codegen Parse and generate assembly IR, then exit",
      "  --asm     Generate assembly and print it",
      "  --ast     Parse the input and print the AST",
      "  --help    Show this help message"
    ]

main :: IO ()
main = do
  args <- getArgs
  case parseArgs args of
    Help -> putStr usage
    Invalid -> failWith usage
    Run mode file -> do
      src <- readFile file
      let toks = tokenize src
      case mode of
        Compile -> case parseProgram toks of
          Right ast -> compileProgram file ast
          Left msg -> failWith ("parse error: " ++ msg)
        Lex -> do
          _ <- evaluate (length toks)
          exitSuccess
        Parse -> case parseProgram toks of
          Right _ -> exitSuccess
          Left msg -> failWith ("parse error: " ++ msg)
        Codegen -> case parseProgram toks of
          Right ast -> do
            _ <- evaluate (instructionCount (generateProgram ast))
            exitSuccess
          Left msg -> failWith ("parse error: " ++ msg)
        Assembly -> case parseProgram toks of
          Right ast -> do
            putStr (renderProgram (generateProgram ast))
            exitSuccess
          Left msg -> failWith ("parse error: " ++ msg)
        Ast -> case parseProgram toks of
          Right ast -> do
            print ast
            exitSuccess
          Left msg -> failWith ("parse error: " ++ msg)

compileProgram :: FilePath -> Parser.Program -> IO ()
compileProgram sourceFile ast = do
  let assemblyFile = replaceExtension sourceFile "s"
      executableFile = dropExtension sourceFile
      assembly = renderProgram (generateProgram ast)
  writeFile assemblyFile assembly
  (status, _, compilerError) <-
    readProcessWithExitCode "gcc" [assemblyFile, "-o", executableFile] ""
      `finally` removeIfExists assemblyFile
  case status of
    ExitSuccess -> exitSuccess
    ExitFailure _ -> do
      removeIfExists executableFile
      failWith ("assembly or linking failed: " ++ compilerError)

removeIfExists :: FilePath -> IO ()
removeIfExists file = do
  exists <- doesFileExist file
  if exists then removeFile file else pure ()

failWith :: String -> IO a
failWith msg = do
  hPutStrLn stderr msg
  exitWith (ExitFailure 1)
