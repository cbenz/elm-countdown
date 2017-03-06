module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


--import Html.Events exposing (onClick)

import Time exposing (..)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    Int


initialModel : Model
initialModel =
    3


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )



-- UPDATE


type Msg
    = Tick Time


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick time ->
            let
                newModel =
                    if model > 0 then
                        model - 1
                    else
                        model
            in
                ( newModel, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    every second Tick



-- VIEW


view : Model -> Html Msg
view model =
    div
        [ style
            [ ( "display", "flex" )
            , ( "align-items", "center" )
            , ( "justify-content", "center" )
            , ( "height", "100%" )
            ]
        ]
        [ div [ style [ ( "max-width", "50%" ) ] ]
            [ text
                (if model > 0 then
                    toString model
                 else
                    "Hello, world!"
                )
            ]
        ]
