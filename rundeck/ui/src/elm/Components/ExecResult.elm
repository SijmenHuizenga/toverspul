module Components.ExecResult exposing (..)

import Components.Job exposing (emptyJob)
import Model exposing (ExecResult)


emptyExecResult : ExecResult
emptyExecResult =
    { id = "", startTimestamp = 0, finishTimestamp = 0, job = emptyJob, executions = [] }
