module Message exposing (..)

import Bootstrap.Alert as Alert
import Http
import Model exposing (ExecResult, Job, ModalModel, ModalModus, Server)


type Msg
    = NoOp
      --- MODAL
    | OpenModal ModalModel ModalModus
    | CloseModal
    | ModalSave
    | ModalDelete
    | SetModalField Fielding
      --- JOBS
    | GetJobs
    | JobsReceived (Result Http.Error (List Job))
    | JobStored (Result Http.Error Job)
    | JobDeleted (Result Http.Error Job)
    | RunJob Job
    | JobStarted (Result Http.Error ExecResult)
    | ModelNewTitle String
    | ModelNewHostnamePattern String
    | ModelNewCommands String
      --- SERVERS
    | GetServers
    | ServersReceived (Result Http.Error (List Server))
    | ServerStored (Result Http.Error Server)
    | ServerDeleted (Result Http.Error Server)
    | ModalNewPrivateKey String
    | ModalNewUser String
    | ModalNewIpPort String
    | ModalNewHostname String
      --- RESULTS
    | GetResults
    | ResultsReceived (Result Http.Error (List ExecResult))
      --- ALERT
    | DismissAlert Alert.Visibility
