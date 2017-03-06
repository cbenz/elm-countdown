module Main exposing (..)

import Json.Decode as Decode exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import String
import Time exposing (..)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- CONSTANTS


playersUrl : String
playersUrl =
    "/participants.json"


pageSize : Int
pageSize =
    20



-- DECODERS


decodePlayer : Decode.Decoder Player
decodePlayer =
    Decode.map4 Player
        (field "name" string)
        (field "country" (maybe string))
        (field "characters_index" string)
        (field "rank" int)



-- MODEL


type alias Player =
    { name : String
    , country : Maybe String
    , characters_index : String
    , rank : Int
    }


type alias Model =
    { countdown : Int
    , players : List Player
    , searchInput : String
    , pageNumber : Int
    }


initialModel : Model
initialModel =
    { countdown = 3
    , players = []
    , searchInput = ""
    , pageNumber = 0
    }


init : ( Model, Cmd Msg )
init =
    let
        fetchCmd =
            Http.send PlayersLoaded (Http.get playersUrl (Decode.list decodePlayer))
    in
        ( initialModel, fetchCmd )



-- UPDATE


type Msg
    = Tick Time
    | PlayersLoaded (Result Http.Error (List Player))
    | SearchInputChange String
    | PreviousPage
    | NextPage


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick time ->
            let
                newModel =
                    if model.countdown > 0 then
                        { model | countdown = model.countdown - 1 }
                    else
                        model
            in
                ( newModel, Cmd.none )

        PlayersLoaded result ->
            case result of
                Err _ ->
                    Debug.crash "error fetching players"

                Ok players ->
                    let
                        newModel =
                            { model | players = List.sortBy .rank players }
                    in
                        ( newModel, Cmd.none )

        SearchInputChange str ->
            { model
                | searchInput = str
                , pageNumber = 0
            }
                ! []

        PreviousPage ->
            { model | pageNumber = model.pageNumber - 1 } ! []

        NextPage ->
            { model | pageNumber = model.pageNumber + 1 } ! []



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    every second Tick



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ viewCountdown model.countdown
        , viewPlayers model.players model.searchInput model.pageNumber
        ]


viewCountdown : Int -> Html Msg
viewCountdown countdown =
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
                (if countdown > 0 then
                    toString countdown
                 else
                    "Hello, world!"
                )
            ]
        ]


viewPlayers : List Player -> String -> Int -> Html Msg
viewPlayers players searchInput pageNumber =
    let
        matchedPlayers =
            players
                |> List.filter
                    (\player ->
                        let
                            searchInputLower =
                                String.toLower searchInput
                        in
                            String.contains searchInputLower (String.toLower player.name)
                                || (case player.country of
                                        Nothing ->
                                            False

                                        Just country ->
                                            String.contains searchInputLower (String.toLower country)
                                   )
                                || String.contains searchInputLower (String.toLower player.characters_index)
                    )

        nbPages =
            List.length matchedPlayers // pageSize
    in
        div []
            [ input
                [ onInput SearchInputChange
                , Html.Attributes.value searchInput
                ]
                []
            , div []
                (matchedPlayers
                    |> List.drop (pageNumber * pageSize)
                    |> List.take pageSize
                    |> List.map
                        (\player ->
                            div []
                                [ text
                                    ((toString player.rank)
                                        ++ " – "
                                        ++ player.name
                                        ++ " – "
                                        ++ (toString player.country)
                                        ++ " – "
                                        ++ player.characters_index
                                    )
                                ]
                        )
                )
            , button
                [ disabled (pageNumber == 0)
                , onClick PreviousPage
                ]
                [ text "Previous" ]
            , text ((toString pageNumber) ++ " / " ++ (toString nbPages))
            , button
                [ disabled (pageNumber == nbPages)
                , onClick NextPage
                ]
                [ text "Next" ]
            ]
