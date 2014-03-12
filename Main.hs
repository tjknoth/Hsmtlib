module Main where

import           SmtConfig   as Conf
import           SMTLib2
import           SMTLib2.Int
import           Solver
import           Z3

data Solvers = Z3 | Yices | Cvc4


startSolver :: Solvers -> String -> Mode -> Maybe Config-> Maybe FilePath -> IO Solver
startSolver Z3 = startZ3

main :: IO ()
main = do
  solver <- startSolver Z3 "QF_LIA" Online Nothing Nothing
  commands solver

mainScript :: IO ()
mainScript = do
  solver <- startSolver Z3 "QF_LIA" Conf.Script Nothing (Just "teste.hs")
  commands solver

commands :: Solver -> IO ()
commands solver = do
  declareFun solver (N "a") [] tInt >>= print
  declareFun solver (N "x") [] tInt >>= print
  declareFun solver (N "y") [] tInt >>= print
  checkSat solver >>= print
  exit solver >>= print
