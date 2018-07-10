module Model exposing (..)

import Bootstrap.Modal as BSModal
import Json.Decode as Decode
import Json.Encode as Encode


type alias Model =
    { errorMessage : Maybe String
    , results : List ExecResult
    , jobs : List Job
    , servers : List Server
    , modalvisability : BSModal.Visibility
    , modalmodel : ModalModel
    , modalmodus : ModalModus
    }


type ModalModel
    = ModalJob Job
    | ModalServer Server
    | ModalExecResult ExecResult


type ModalModus
    = New
    | Edit


type alias Job =
    { id : String
    , title : String
    , hostnamePattern : String
    , commands : List String
    }


setJobTitle : String -> Job -> Job
setJobTitle newTitle job =
    { job | title = newTitle }


setJobCommands : String -> Job -> Job
setJobCommands newCommands job =
    { job | commands = String.split "\n " newCommands }


setJobHostnamePattern : String -> Job -> Job
setJobHostnamePattern newHostnamePattern job =
    { job | hostnamePattern = newHostnamePattern }


asJobWithoutEmptyCommands : Job -> Job
asJobWithoutEmptyCommands job =
    { job | commands = List.filter (not << String.isEmpty) job.commands }


jobDecoder : Decode.Decoder Job
jobDecoder =
    Decode.map4 Job
        (Decode.field "ID" Decode.string)
        (Decode.field "title" Decode.string)
        (Decode.field "hostnamePattern" Decode.string)
        (Decode.field "commands" (Decode.list Decode.string))


jobEncoder : Job -> Encode.Value
jobEncoder job =
    Encode.object
        [ ( "ID", Encode.string job.id )
        , ( "title", Encode.string job.title )
        , ( "hostnamePattern", Encode.string job.hostnamePattern )
        , ( "commands", Encode.list (List.map Encode.string job.commands) )
        ]


type alias Server =
    { id : String
    , hostname : String
    , ipPort : String
    , privateKey : String
    , user : String
    }


serverDecoder : Decode.Decoder Server
serverDecoder =
    Decode.map5 Server
        (Decode.field "ID" Decode.string)
        (Decode.field "hostname" Decode.string)
        (Decode.field "ipPort" Decode.string)
        (Decode.field "privateKey" Decode.string)
        (Decode.field "user" Decode.string)


serverEncoder : Server -> Encode.Value
serverEncoder server =
    Encode.object
        [ ( "ID", Encode.string server.id )
        , ( "hostname", Encode.string server.hostname )
        , ( "ipPort", Encode.string server.ipPort )
        , ( "privateKey", Encode.string server.privateKey )
        , ( "user", Encode.string server.user )
        ]


setServerPrivateKey : String -> Server -> Server
setServerPrivateKey newPrivateKey server =
    { server | privateKey = newPrivateKey }


setServerUser : String -> Server -> Server
setServerUser newUser server =
    { server | user = newUser }


setServerIpPort : String -> Server -> Server
setServerIpPort newIpPort server =
    { server | ipPort = newIpPort }


setServerHostname : String -> Server -> Server
setServerHostname newHostname server =
    { server | hostname = newHostname }


type alias ExecResult =
    { id : String
    , startTimestamp : Int
    , finishTimestamp : Int
    , job : Job
    , executions : List ExecResultServer
    }


execResultDecoder : Decode.Decoder ExecResult
execResultDecoder =
    Decode.map5 ExecResult
        (Decode.field "ID" Decode.string)
        (Decode.field "startTimestamp" Decode.int)
        (Decode.field "finishTimestamp" Decode.int)
        (Decode.field "job" jobDecoder)
        (Decode.field "executions" (Decode.list execResultServerDecoder))


type alias ExecResultServer =
    { server : Server
    , startTimestamp : Int
    , finishTimestamp : Int
    , logs : String
    , status : String
    }


execResultServerDecoder : Decode.Decoder ExecResultServer
execResultServerDecoder =
    Decode.map5 ExecResultServer
        (Decode.field "server" serverDecoder)
        (Decode.field "startTimestamp" Decode.int)
        (Decode.field "finishTimestamp" Decode.int)
        (Decode.field "logs" Decode.string)
        (Decode.field "status" Decode.string)
