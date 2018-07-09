module ConnectionUtil exposing (..)

import Http
import Json.Decode
import Json.Encode


baseurl : String
baseurl =
    "http://localhost:8090"


get : String -> Json.Decode.Decoder a -> (Result Http.Error a -> msg) -> Cmd msg
get url decoder resultmsg =
    Http.send resultmsg (Http.get (baseurl ++ url) decoder)


put : String -> a -> (a -> Json.Encode.Value) -> Json.Decode.Decoder a -> (Result Http.Error a -> msg) -> Cmd msg
put url body encoder decoder resultmsg =
    request "PUT" url body encoder decoder resultmsg


post : String -> a -> (a -> Json.Encode.Value) -> Json.Decode.Decoder a -> (Result Http.Error a -> msg) -> Cmd msg
post url body encoder decoder resultmsg =
    request "POST" url body encoder decoder resultmsg


delete : String -> Json.Decode.Decoder a -> (Result Http.Error a -> msg) -> Cmd msg
delete url decoder resultmsg =
    Http.send resultmsg
        (Http.request
            { method = "DELETE"
            , url = baseurl ++ url
            , body = Http.emptyBody
            , expect = Http.expectJson decoder
            , headers = []
            , timeout = Nothing
            , withCredentials = False
            }
        )


request : String -> String -> a -> (a -> Json.Encode.Value) -> Json.Decode.Decoder a -> (Result Http.Error a -> msg) -> Cmd msg
request method url body encoder decoder resultmsg =
    Http.send resultmsg
        (Http.request
            { method = method
            , url = baseurl ++ url
            , body = body |> encoder |> Http.jsonBody
            , expect = Http.expectJson decoder
            , headers = []
            , timeout = Nothing
            , withCredentials = False
            }
        )
