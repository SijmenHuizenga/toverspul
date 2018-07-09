module Server exposing (..)

import Json.Decode as Decode exposing (field, map5, string)
import Json.Encode as Encode


type alias Server =
    { id : String
    , hostname : String
    , ipPort : String
    , privateKey : String
    , user : String
    }


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


asPrivateKeyIn server newPrivateKey =
    { server | privateKey = newPrivateKey }


asUserIn server newUser =
    { server | user = newUser }


asIpPortIn server newIpPort =
    { server | ipPort = newIpPort }


asHostnameIn server newHostname =
    { server | hostname = newHostname }
