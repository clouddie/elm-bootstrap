module Bootstrap.TabTest exposing (..)

import Bootstrap.Tab as Tab
import Html exposing (text, h4, p)
import Html.Attributes as Attributes
import Test exposing (Test, test, describe)
import Expect
import Test.Html.Query as Query
import Test.Html.Selector as Selector exposing (tag, class, classes, attribute)


{-| @ltignore
-}
all : Test
all =
    Test.concat
        [ simpleTabs
        , pillsAndAttributes
        , horizontalAlignment
        ]


simpleTabs : Test
simpleTabs =
    let
        html =
            Tab.config (\_ -> ())
                |> Tab.items
                    [ Tab.item
                        { link = Tab.link [] [ text "Tab 1" ]
                        , pane =
                            Tab.pane [ Attributes.class "mt-3" ]
                                [ h4 [] [ text "Tab 1 Heading" ]
                                , p [] [ text "Contents of tab 1." ]
                                ]
                        }
                    , Tab.item
                        { link = Tab.link [] [ text "Tab 2" ]
                        , pane =
                            Tab.pane [ Attributes.class "mt-3" ]
                                [ h4 [] [ text "Tab 2 Heading" ]
                                , p [] [ text "This is something completely different." ]
                                ]
                        }
                    ]
                |> Tab.view Tab.initialState

        nav =
            html
                |> Query.fromHtml
                |> Query.find [ class "nav", class "nav-tabs" ]

        content =
            html
                |> Query.fromHtml
                |> Query.find [ class "tab-content" ]
    in
        describe "Simple tab"
            [ describe "nav"
                [ test "Expect 2 nav-items" <|
                    \() ->
                        nav
                            |> Query.findAll [ class "nav-item" ]
                            |> Query.count (Expect.equal 2)
                , test "Expect links to have href='#'" <|
                    \() ->
                        nav
                            |> Query.findAll [ tag "a" ]
                            |> Query.each (Query.has [ attribute "href" "#" ])
                , test "Expect links to have children" <|
                    \() ->
                        nav
                            |> Query.findAll [ tag "a" ]
                            |> Query.index 0
                            |> Query.has [ Selector.text "Tab 1" ]
                ]
            , describe "content"
                [ test "Expect 2 tab-panes" <|
                    \() ->
                        content
                            |> Query.findAll [ class "tab-pane" ]
                            |> Query.count (Expect.equal 2)
                , test "Expect 2 mt-3 (custom attributes work)" <|
                    \() ->
                        content
                            |> Query.findAll [ class "mt-3" ]
                            |> Query.count (Expect.equal 2)
                , test "Expect pane to have children" <|
                    \() ->
                        content
                            |> Query.findAll [ class "tab-pane" ]
                            |> Query.index 0
                            |> Query.find [ tag "h4" ]
                            |> Query.has [ Selector.text "Tab 1 Heading" ]
                ]
            ]


pillsAndAttributes =
    let
        html =
            Tab.config (\_ -> ())
                |> Tab.pills
                |> Tab.attrs [ Attributes.name "myTabs" ]
                |> Tab.view Tab.initialState
    in
        describe "pills"
            [ test "Expect nav-pills class" <|
                \() ->
                    html
                        |> Query.fromHtml
                        |> Query.find [ tag "ul" ]
                        |> Query.has [ class "nav-pills" ]
            , test "Expect custom name attribute" <|
                \() ->
                    html
                        |> Query.fromHtml
                        |> Query.find [ tag "ul" ]
                        |> Query.has [ attribute "name" "myTabs" ]
            ]


horizontalAlignment =
    let
        html alignment =
            Tab.config (\_ -> ())
                |> alignment
                |> Tab.view Tab.initialState

        alignmentTest alignment className =
            test ("alignment of " ++ className) <|
                \() ->
                    html alignment
                        |> Query.fromHtml
                        |> Query.find [ class "nav-tabs" ]
                        |> Query.has [ class className ]
    in
        describe "alignment"
            [ alignmentTest Tab.center "justify-content-center"
            , alignmentTest Tab.right "justify-content-end"
            , alignmentTest Tab.justified "nav-justified"
            , alignmentTest Tab.fill "nav-fill"
            ]
