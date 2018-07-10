module Components.Server exposing (..)

import List
import List.Extra
import Model exposing (Model, Server)


emptyServer : Server
emptyServer =
    { id = "", hostname = "", ipPort = "", privateKey = "", user = "" }


createServer : Server -> Model -> Model
createServer server model =
    { model | servers = server :: model.servers }


updateServer : Server -> Model -> Model
updateServer server model =
    { model | servers = model.servers |> List.Extra.replaceIf (\j -> j.id == server.id) server }


deleteServer : Server -> Model -> Model
deleteServer server model =
    { model | servers = model.servers |> List.filter (\j -> j.id /= server.id) }
