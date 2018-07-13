module Commands exposing (createJobCmd, createServerCmd, deleteJobCmd, deleteServerCmd, getJobsCmd, getResultsCmd, getServersCmd, refreshAllCmd, runJobCmd, updateJobCmd, updateServerCmd)

import ConnectionUtil
import Json.Decode
import Message exposing (Msg(..))
import Model exposing (Job, Server, asJobWithoutEmptyCommands, execResultDecoder, jobDecoder, jobEncoder, serverDecoder, serverEncoder)


getResultsCmd : Cmd Msg
getResultsCmd =
    ConnectionUtil.get "/results" (Json.Decode.list execResultDecoder) ResultsReceived


getJobsCmd : Cmd Msg
getJobsCmd =
    ConnectionUtil.get "/jobs" (Json.Decode.list jobDecoder) JobsReceived


updateJobCmd : Job -> Cmd Msg
updateJobCmd job =
    ConnectionUtil.put ("/jobs/" ++ job.id) (job |> asJobWithoutEmptyCommands) jobEncoder jobDecoder JobStored


deleteJobCmd : Job -> Cmd Msg
deleteJobCmd job =
    ConnectionUtil.delete ("/jobs/" ++ job.id) jobDecoder JobDeleted


createJobCmd : Job -> Cmd Msg
createJobCmd job =
    ConnectionUtil.post "/jobs" (job |> asJobWithoutEmptyCommands) jobEncoder jobDecoder JobStored


runJobCmd : Job -> Cmd Msg
runJobCmd job =
    ConnectionUtil.get ("/run/" ++ job.id) execResultDecoder JobStarted


getServersCmd : Cmd Msg
getServersCmd =
    ConnectionUtil.get "/servers" (Json.Decode.list serverDecoder) ServersReceived


updateServerCmd : Server -> Cmd Msg
updateServerCmd server =
    ConnectionUtil.put ("/servers/" ++ server.id) server serverEncoder serverDecoder ServerStored


deleteServerCmd : Server -> Cmd Msg
deleteServerCmd server =
    ConnectionUtil.delete ("/servers/" ++ server.id) serverDecoder ServerDeleted


createServerCmd : Server -> Cmd Msg
createServerCmd server =
    ConnectionUtil.post "/servers" server serverEncoder serverDecoder ServerStored


refreshAllCmd : Cmd Msg
refreshAllCmd =
    Cmd.batch
        [ getJobsCmd
        , getServersCmd
        , getResultsCmd
        ]
