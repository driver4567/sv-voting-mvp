module FormatSwmBalanceTests exposing (..)

import Decimal as Decimal
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import SecureVote.Eth.Utils exposing (formatBalance)
import Test exposing (..)


formatBalanceSuite : Test
formatBalanceSuite =
    describe "Etherum tests"
        [ describe "Format Balance"
            [ test "test example List" <|
                \_ ->
                    let
                        lhsAnswers =
                            List.map Tuple.second exampleList

                        rhsAnswers =
                            List.map formatBalance <| List.map Tuple.first exampleList
                    in
                    Expect.equalLists lhsAnswers rhsAnswers
            ]
        ]


exampleList : List ( String, String )
exampleList =
    [ ( "1", "1" )
    , ( "0", "0" )
    , ( "-1", "-1" )
    , ( "09", "9" )
    , ( "10", "10" )
    , ( "58", "58" )
    , ( "100", "100" )
    , ( "123", "123" )
    , ( "023", "23" )
    , ( "00035", "35" )
    , ( "1000", "1,000" )
    , ( "2234", "2,234" )
    , ( "86854", "86,854" )
    , ( "10000", "10,000" )
    , ( "100000", "100,000" )
    , ( "00026784633", "26,784,633" )
    , ( "1000000", "1,000,000" )
    , ( "10000000", "10,000,000" )
    , ( "1000000000", "1,000,000,000" )
    , ( "1000000000000", "1,000,000,000,000" )
    , ( "1000000000000000", "1,000,000,000,000,000" )
    , ( "1000000000000000000", "1,000,000,000,000,000,000" )
    , ( "9999999999999999999", "9,999,999,999,999,999,999" )
    , ( "7357456867953467845", "7,357,456,867,953,467,845" )
    , ( "0.1", "0.1" )
    , ( "0.01", "0.01" )
    , ( "0.001", "0.001" )
    , ( "0.0001", "0.0001" )
    , ( "0.537000", "0.537" )
    , ( "0.3455", "0.3455" )
    , ( "0.0000001", "0.0000001" )
    , ( "0.7856465", "0.7856465" )
    , ( "0.0000000001", "0.0000000001" )
    , ( "0.3457855573", "0.3457855573" )
    , ( "0.000000000000000001", "0.000000000000000001" )
    , ( "0.347375683564574535", "0.347375683564574535" )
    , ( "0.999999999999999999", "0.999999999999999999" )
    , ( "1.1", "1.1" )
    , ( "4.8", "4.8" )
    , ( "73.01", "73.01" )
    , ( "456.25475", "456.25475" )
    , ( "5743.756", "5,743.756" )
    , ( "00234.567000", "234.567" )
    , ( "12.678576956742345", "12.678576956742345" )
    , ( "352435573.1", "352,435,573.1" )
    , ( "437457834523.8589546334", "437,457,834,523.8589546334" )
    , ( "1000000000000000000.000000000000000001", "1,000,000,000,000,000,000.000000000000000001" )
    , ( "9999999999999999999.999999999999999999", "9,999,999,999,999,999,999.999999999999999999" )
    , ( "6436834647456523566.234678957843414564", "6,436,834,647,456,523,566.234678957843414564" )
    , ( "1.0", "1" )
    , ( "45.00000", "45" )
    , ( "324.0", "324" )
    , ( "6734.0", "6,734" )
    , ( "1.000000000000000000", "1" )
    ]
