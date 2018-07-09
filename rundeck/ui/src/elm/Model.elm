module Model exposing (..)

import Json.Decode as Decode
import Json.Encode as Encode


type alias Job =
    { id : String
    , title : String
    , hostnamePattern : String
    , commands : List String
    }


setJobTitle : String -> Job -> Job
setJobTitle newTitle job =
    { job | title = newTitle }


setJobCommands : List String -> Job -> Job
setJobCommands newCommands job =
    { job | commands = newCommands }


setJobHostnamePattern : String -> Job -> Job
setJobHostnamePattern newHostnamePattern job =
    { job | hostnamePattern = newHostnamePattern }


asJobTitleIn : Job -> String -> Job
asJobTitleIn =
    flip setJobTitle


asJobPatternIn : Job -> String -> Job
asJobPatternIn =
    flip setJobHostnamePattern


asJobCommands : Job -> List String -> Job
asJobCommands =
    flip setJobCommands


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


asPrivateKeyIn : Server -> String -> Server
asPrivateKeyIn server newPrivateKey =
    { server | privateKey = newPrivateKey }


asUserIn : Server -> String -> Server
asUserIn server newUser =
    { server | user = newUser }


asIpPortIn : Server -> String -> Server
asIpPortIn server newIpPort =
    { server | ipPort = newIpPort }


asHostnameIn : Server -> String -> Server
asHostnameIn server newHostname =
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
    { server : String
    , startTimestamp : Int
    , finishTimestamp : Int
    , logs : String
    , status : String
    }


execResultServerDecoder : Decode.Decoder ExecResultServer
execResultServerDecoder =
    Decode.map5 ExecResultServer
        (Decode.field "Server" Decode.string)
        (Decode.field "startTimestamp" Decode.int)
        (Decode.field "finishTimestamp" Decode.int)
        (Decode.field "logs" Decode.string)
        (Decode.field "status" Decode.string)
