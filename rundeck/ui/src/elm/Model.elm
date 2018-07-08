module Model exposing (..)

import Json.Decode exposing (field, map4, string, list)

type alias Job =
    { id : String,
      title : String,
      hostnamePattern : String,
      commands : List String}

setJobTitle : String -> Job -> Job
setJobTitle newTitle job =
    {job | title = newTitle}

setJobCommands : List String -> Job -> Job
setJobCommands newCommands job =
    {job | commands = newCommands}

setJobHostnamePattern : String -> Job -> Job
setJobHostnamePattern newHostnamePattern job =
    {job | hostnamePattern = newHostnamePattern}

asJobTitleIn : Job -> String -> Job
asJobTitleIn = flip setJobTitle

asJobPatternIn : Job -> String -> Job
asJobPatternIn = flip setJobHostnamePattern

asJobCommands : Job -> List String -> Job
asJobCommands = flip setJobCommands

jobDecoder = map4 Job
    (field "ID" string)
    (field "title" string)
    (field "hostnamePattern" string)
    (field "commands" (Json.Decode.list string))