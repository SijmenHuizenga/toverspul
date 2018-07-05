module Model exposing (..)

import Json.Decode exposing (field, map4, string, list)

type alias Job =
    { id : String,
      title : String,
      hostnamePattern : String,
      commands : List String}

jobDecoder = map4 Job
    (field "ID" string)
    (field "title" string)
    (field "hostnamePattern" string)
    (field "commands" (Json.Decode.list string))