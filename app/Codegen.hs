module Codegen
  ( Program (..),
    Function (..),
    Instruction (..),
    Operand (..),
    Register (..),
    generateProgram,
    instructionCount,
    renderProgram,
  )
where

import qualified Parser

data Program = Program Function
  deriving (Show, Eq)

data Function = Function String [Instruction]
  deriving (Show, Eq)

data Instruction
  = Mov Operand Operand
  | Ret
  deriving (Show, Eq)

data Operand
  = Imm Integer
  | Reg Register
  deriving (Show, Eq)

data Register = AX
  deriving (Show, Eq)

generateProgram :: Parser.Program -> Program
generateProgram (Parser.Program function) = Program (generateFunction function)

generateFunction :: Parser.Function -> Function
generateFunction (Parser.Function name statement) =
  Function name (generateStatement statement)

generateStatement :: Parser.Statement -> [Instruction]
generateStatement (Parser.Return expression) =
  [Mov (generateExpression expression) (Reg AX), Ret]

generateExpression :: Parser.Exp -> Operand
generateExpression (Parser.Constant value) = Imm value

instructionCount :: Program -> Int
instructionCount (Program (Function _ instructions)) = length instructions

renderProgram :: Program -> String
renderProgram (Program function) =
  unlines
    [ "    .text",
      renderFunction function,
      "    .section .note.GNU-stack,\"\",@progbits"
    ]

renderFunction :: Function -> String
renderFunction (Function name instructions) =
  unlines
    ( ["    .globl " ++ name, name ++ ":"]
        ++ map renderInstruction instructions
    )

renderInstruction :: Instruction -> String
renderInstruction (Mov source destination) =
  "    movl " ++ renderOperand source ++ ", " ++ renderOperand destination
renderInstruction Ret = "    ret"

renderOperand :: Operand -> String
renderOperand (Imm value) = '$' : show value
renderOperand (Reg AX) = "%eax"
