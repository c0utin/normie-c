module Codegen
  ( Program (..),
    Function (..),
    Instruction (..),
    Operand (..),
    Register (..),
    generateProgram,
    instructionCount,
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
