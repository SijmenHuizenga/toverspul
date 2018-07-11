module Message exposing (..)

import Bootstrap.Alert as Alert
import Http
import Model exposing (ExecResult, Job, ModalModel, ModalModus, Server, setServerHostname, setServerIpPort, setServerPrivateKey, setServerUser)


type Msg
    = NoOp
      --- MODAL
    | OpenModal ModalModel ModalModus
    | CloseModal
    | ModalSave
    | ModalDelete
    | SetJobModalField (String -> Job -> Job) String
    | SetServerModalField (String -> Server -> Server) String
      --- JOBS
    | GetJobs
    | JobsReceived (Result Http.Error (List Job))
    | JobStored (Result Http.Error Job)
    | JobDeleted (Result Http.Error Job)
    | RunJob Job
    | JobStarted (Result Http.Error ExecResult)
      --- SERVERS
    | GetServers
    | ServersReceived (Result Http.Error (List Server))
    | ServerStored (Result Http.Error Server)
    | ServerDeleted (Result Http.Error Server)
      --- RESULTS
    | GetResults
    | ResultsReceived (Result Http.Error (List ExecResult))
      --- ALERT
    | DismissAlert Alert.Visibility


setServerHostnameMsg =
    SetServerModalField setServerHostname


setServerIpPortMsg =
    SetServerModalField setServerIpPort


setServerUserMsg =
    SetServerModalField setServerUser


setServerPrivateKeyMsg =
    SetServerModalField setServerPrivateKey
