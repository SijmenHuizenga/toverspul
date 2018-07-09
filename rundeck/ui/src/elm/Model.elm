module Model exposing (..)

import Json.Decode exposing (field, list, map4, string)
import Json.Encode


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


jobDecoder =
    map4 Job
        (field "ID" string)
        (field "title" string)
        (field "hostnamePattern" string)
        (field "commands" (Json.Decode.list string))


jobEncoder : Job -> Json.Encode.Value
jobEncoder job =
    Json.Encode.object
        [ ( "ID", Json.Encode.string job.id )
        , ( "title", Json.Encode.string job.title )
        , ( "hostnamePattern", Json.Encode.string job.hostnamePattern )
        , ( "commands", Json.Encode.list (List.map Json.Encode.string job.commands) )
        ]
