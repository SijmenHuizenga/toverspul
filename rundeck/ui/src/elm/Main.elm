module Main exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing ( onClick )

-- component import example
import Components.Hello exposing ( hello )
import Http
import Json.Decode exposing (field, map4, string, list)
import String exposing (join)


-- APP
main : Program Never Model Msg
main =
  program { init = ({counter =  0, jobs = [], error = ""}, getJobsCmd),
            view = view,
            update = update,
            subscriptions = \_ -> Sub.none }


-- MODEL
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

type alias Model = {counter : Int, jobs : List Job, error : String}


-- UPDATE
type Msg = NoOp | Increment | GetJobs | JobsReceived (Result Http.Error (List Job))

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    GetJobs -> (model, getJobsCmd)
    JobsReceived (Ok jobs) ->({model | jobs = jobs}, Cmd.none)
    JobsReceived (Err httpError) -> ({model | error = (toString httpError) }, Cmd.none)
    NoOp -> (model, Cmd.none)
    Increment -> ({model | counter = model.counter + 1}, Cmd.none)

getJobsCmd : Cmd Msg
getJobsCmd = Http.send JobsReceived (Http.get "http://localhost:8090/jobs" (Json.Decode.list jobDecoder))

-- VIEW
-- Html is defined as: elem [ attribs ][ children ]
-- CSS can be applied via class names or inline style attrib
view : Model -> Html Msg
view model =
  div [ class "container", style [("margin-top", "30px"), ( "text-align", "center" )] ][
    div [ class "row" ][
      div [ class "col-xs-12" ][
        div [ class "jumbotron" ][
          p [] [ text (model.error)]
          , img [ src "static/img/elm.jpg", style styles.img ] []
          , hello model.counter
          , p [] [ text ( "Elm Webpack Starter" ) ]
          , button [ class "btn btn-primary btn-lg", onClick Increment ] [
            span[ class "glyphicon glyphicon-star" ][]
            , span[][ text "FTW!" ]
          ]
        ]
      ],

      table [class "table"] (List.map renderJobRow model.jobs)
    ]
  ]

renderJobRow : Job -> Html Msg
renderJobRow job =
    tr [] [
        td [] [ text (job.id)],
        td [] [ text (job.title)],
        td [] [ text (job.hostnamePattern)],
        td [] [ text (join ", " job.commands)]
    ]



-- CSS STYLES
styles : { img : List ( String, String ) }
styles =
  {
    img =
      [ ( "width", "33%" )
      , ( "border", "4px solid #337AB7")
      ]
  }
