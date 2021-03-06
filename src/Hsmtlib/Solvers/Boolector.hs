{- |
Module      : Hsmtlib.Solvers.Boolector
  Module wich has the standard configuration for all boolector Modes and
  provides the initilizing function.
-}
module Hsmtlib.Solvers.Boolector(startBoolector) where

import           Hsmtlib.Solver                      as Slv
import           Hsmtlib.Solvers.Cmd.OnlineCmd
import           Hsmtlib.Solvers.Cmd.ProcCom.Process
import           Hsmtlib.Solvers.Cmd.ScriptCmd
import           Smtlib.Syntax.Syntax
import           System.IO                           (Handle,
                                                      IOMode (WriteMode),
                                                      openFile)

-- All the configurations are the same but have diferent names so if anything
-- changes it's easy to alter its configuration.


boolectorConfigOnline :: SolverConfig
boolectorConfigOnline =
        Config { path = "boolector"
               , args = ["--smt2", "-d2", "-o STDOUT"]
               }

boolectorConfigScript :: SolverConfig
boolectorConfigScript =
        Config { path = "boolector"
               , args = ["--smt2", "-d2", "-o STDOUT"]
               }

boolectorConfigBatch :: SolverConfig
boolectorConfigBatch =
        Config { path = "boolector"
               , args = ["--smt2", "-d2", "-o STDOUT"]
               }


{- |
  Function that initialyzes a boolector Solver.
  It Receives a Mode, an SMT Logic, it can receive a diferent configuration
  for the solver and an anternative path to create the script in Script Mode.

  In Online Mode if a FilePath is passed then it's ignored.
-}
startBoolector :: Mode
               -> String
               -> Maybe SolverConfig
               -> Maybe FilePath
               -> IO Solver
startBoolector Slv.Online logic sConf _ = startBoolectorOnline logic sConf
startBoolector Slv.Script logic sConf scriptFilePath =
    startBoolectorScript logic sConf scriptFilePath

-- Start boolector Online.

startBoolectorOnline :: String -> Maybe SolverConfig -> IO Solver
startBoolectorOnline logic Nothing = startBoolectorOnline' logic boolectorConfigOnline
startBoolectorOnline logic (Just conf) = startBoolectorOnline' logic conf

startBoolectorOnline' :: String -> SolverConfig -> IO Solver
startBoolectorOnline' logic conf = do
  -- Starts a Z4 Process.
  process <- beginProcess (path conf) (args conf)
  --Set Option to print success after accepting a Command.
  --onlineSetOption process (OptPrintSuccess True)
  -- Sets the SMT Logic.
  _ <- onlineSetLogic Boolector process logic
  -- Initialize the solver Functions and return them.
  return $ onlineSolver process

--Start boolector Script.

startBoolectorScript :: String -> Maybe SolverConfig -> Maybe FilePath -> IO Solver
startBoolectorScript logic Nothing Nothing =
    startBoolectorScript' logic boolectorConfigScript "temp.smt2"
startBoolectorScript logic (Just conf) Nothing =
    startBoolectorScript' logic conf "temp.smt2"
startBoolectorScript logic Nothing (Just scriptFilePath) =
    startBoolectorScript' logic boolectorConfigScript scriptFilePath
startBoolectorScript logic (Just conf) (Just scriptFilePath) =
    startBoolectorScript' logic conf scriptFilePath

{-
  In this function a file is created where the commands are kept.

  Every function in the ScriptCmd Module needs a ScriptConf data which has:

  - sHandle: The handle of the script file
  - sCmdPath: The Path to initilyze the solver
  - sArgs: The options of the solver
  - sFilePath: The file path of the script so it can be passed to the solver
               when started.
-}
startBoolectorScript' :: String -> SolverConfig -> FilePath -> IO Solver
startBoolectorScript' logic conf scriptFilePath = do
  scriptHandle <- openFile scriptFilePath WriteMode
  let srcmd = newScriptArgs conf scriptHandle scriptFilePath
  _ <- scriptSetOption srcmd (PrintSuccess True)
  _ <- scriptSetLogic srcmd logic
  return $ scriptSolver srcmd

--Function which creates the ScriptConf for the script functions.
newScriptArgs :: SolverConfig  -> Handle -> FilePath -> ScriptConf
newScriptArgs solverConfig nHandle scriptFilePath =
  ScriptConf { sHandle = nHandle
             , sCmdPath = path solverConfig
             , sArgs = args solverConfig
             , sFilePath  = scriptFilePath
             }

-- Creates the functions for online mode with the process already running.
-- Each function will send the command to the solver and wait for the response.
onlineSolver :: Process -> Solver
onlineSolver process =
  Solver { setLogic = onlineSetLogic Boolector process
         , setOption = onlineSetOption Boolector process
         , setInfo = onlineSetInfo Boolector process
         , declareSort = onlineDeclareSort Boolector process
         , defineSort = onlineDefineSort Boolector process
         , declareFun = onlineDeclareFun Boolector process
         , defineFun = onlineDefineFun Boolector process
         , push = onlinePush Boolector process
         , pop = onlinePop Boolector process
         , assert = onlineAssert Boolector process
         , checkSat = onlineCheckSat Boolector process
         , getAssertions = onlineGetAssertions Boolector process
         , getValue = onlineGetValue Boolector process
         , getProof = onlineGetProof Boolector process
         , getUnsatCore = onlineGetUnsatCore Boolector process
         , getInfo = onlineGetInfo Boolector process
         , getOption = onlineGetOption Boolector process
         , exit = onlineExit process
         }

-- Creates the funtion for the script mode.
-- The configuration of the file is passed.
scriptSolver :: ScriptConf -> Solver
scriptSolver srcmd =
  Solver { setLogic = scriptSetLogic srcmd
         , setOption = scriptSetOption srcmd
         , setInfo = scriptSetInfo srcmd
         , declareSort = scriptDeclareSort srcmd
         , defineSort = scriptDefineSort srcmd
         , declareFun = scriptDeclareFun srcmd
         , defineFun = scriptDefineFun srcmd
         , push = scriptPush srcmd
         , pop = scriptPop srcmd
         , assert = scriptAssert srcmd
         , checkSat = scriptCheckSat srcmd
         , getAssertions = scriptGetAssertions srcmd
         , getValue = scriptGetValue srcmd
         , getProof = scriptGetProof srcmd
         , getUnsatCore = scriptGetUnsatCore srcmd
         , getInfo = scriptGetInfo srcmd
         , getOption = scriptGetOption srcmd
         , exit = scriptExit srcmd
         }
