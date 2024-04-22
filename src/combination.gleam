import card
import gleam/dict
import gleam/function
import gleam/list
import gleam/option
import gleam/order

pub type Combination {
  HighCard(cards: List(card.Card))
  Pair(cards: List(card.Card))
  TwoPair(cards: List(card.Card))
  ThreeOfAKind(cards: List(card.Card))
  Straight(cards: List(card.Card))
  Flush(cards: List(card.Card))
  FullHouse(cards: List(card.Card))
  FourOfAKind(cards: List(card.Card))
  StraightFlush(cards: List(card.Card))
  RoyalFlush(cards: List(card.Card))
}

pub fn compare(cl: Combination, cr: Combination) -> order.Order {
  case cl {
    RoyalFlush(_) ->
      case cr {
        RoyalFlush(_) -> order.Eq
        _ -> order.Gt
      }
    StraightFlush(lcards) ->
      case cr {
        RoyalFlush(_) -> order.Lt
        StraightFlush(rcards) -> {
          let assert #([cl, ..], [cr, ..]) = #(lcards, rcards)
          card.compare(cl, cr)
        }
        _ -> order.Gt
      }
    FourOfAKind(lcards) ->
      case cr {
        RoyalFlush(_) -> order.Lt
        StraightFlush(_) -> order.Lt
        FourOfAKind(rcards) -> {
          let assert [cl, _, _, _, cl_] = lcards
          let assert [cr, _, _, _, cr_] = rcards
          case card.compare(cl, cr) {
            order.Eq -> card.compare(cl_, cr_)
            ord -> ord
          }
        }
        _ -> order.Gt
      }
    FullHouse(lcards) ->
      case cr {
        RoyalFlush(_) -> order.Lt
        StraightFlush(_) -> order.Lt
        FourOfAKind(_) -> order.Lt
        FullHouse(rcards) -> {
          let assert [cl, _, _, cl_, _] = lcards
          let assert [cr, _, _, cr_, _] = rcards
          case card.compare(cl, cr) {
            order.Eq -> card.compare(cl_, cr_)
            ord -> ord
          }
        }
        _ -> order.Gt
      }
    Flush(lcards) ->
      case cr {
        RoyalFlush(_) -> order.Lt
        StraightFlush(_) -> order.Lt
        FourOfAKind(_) -> order.Lt
        FullHouse(_) -> order.Lt
        Flush(rcards) -> card.compare_lists(lcards, rcards)
        _ -> order.Gt
      }
    Straight(lcards) ->
      case cr {
        RoyalFlush(_) -> order.Lt
        StraightFlush(_) -> order.Lt
        FourOfAKind(_) -> order.Lt
        FullHouse(_) -> order.Lt
        Flush(_) -> order.Lt
        Straight(rcards) -> {
          let assert [l, ..] = lcards
          let assert [r, ..] = rcards
          card.compare(l, r)
        }
        _ -> order.Gt
      }
    ThreeOfAKind(lcards) ->
      case cr {
        RoyalFlush(_) -> order.Lt
        StraightFlush(_) -> order.Lt
        FourOfAKind(_) -> order.Lt
        FullHouse(_) -> order.Lt
        Flush(_) -> order.Lt
        Straight(_) -> order.Lt
        ThreeOfAKind(rcards) -> {
          let assert [lthree, _, _, lc1, lc2] = lcards
          let assert [rthree, _, _, rc1, rc2] = rcards
          card.compare_lists([lthree, lc1, lc2], [rthree, rc1, rc2])
        }
        _ -> order.Gt
      }
    TwoPair(lcards) ->
      case cr {
        RoyalFlush(_) -> order.Lt
        StraightFlush(_) -> order.Lt
        FourOfAKind(_) -> order.Lt
        FullHouse(_) -> order.Lt
        Flush(_) -> order.Lt
        Straight(_) -> order.Lt
        ThreeOfAKind(_) -> order.Lt
        TwoPair(rcards) -> {
          let assert [lp1, _, lp2, _, lc] = lcards
          let assert [rp1, _, rp2, _, rc] = rcards
          card.compare_lists([lp1, lp2, lc], [rp1, rp2, rc])
        }
        _ -> order.Gt
      }
    Pair(lcards) ->
      case cr {
        RoyalFlush(_) -> order.Lt
        StraightFlush(_) -> order.Lt
        FourOfAKind(_) -> order.Lt
        FullHouse(_) -> order.Lt
        Flush(_) -> order.Lt
        Straight(_) -> order.Lt
        ThreeOfAKind(_) -> order.Lt
        TwoPair(_) -> order.Lt
        Pair(rcards) -> {
          let assert [lp, _, ..lrest] = lcards
          let assert [rp, _, ..rrest] = rcards
          card.compare_lists([lp, ..lrest], [rp, ..rrest])
        }
        _ -> order.Gt
      }
    HighCard(lcards) ->
      case cr {
        RoyalFlush(_) -> order.Lt
        StraightFlush(_) -> order.Lt
        FourOfAKind(_) -> order.Lt
        FullHouse(_) -> order.Lt
        Flush(_) -> order.Lt
        Straight(_) -> order.Lt
        ThreeOfAKind(_) -> order.Lt
        TwoPair(_) -> order.Lt
        Pair(_) -> order.Lt
        HighCard(rcards) -> card.compare_lists(lcards, rcards)
      }
  }
}

pub fn determine(
  table table: List(card.Card),
  hand hand: List(card.Card),
) -> Combination {
  let compare_func = function.flip(card.compare)
  list.append(table, hand)
  |> list.sort(compare_func)
  // if royal flush is not checked, it will call check_straight_flush and so on
  |> check_royal_flush()
}

fn is_straight(cards: List(card.Card)) -> Bool {
  let pred = fn(tup: #(card.Card, card.Card)) -> Bool {
    let #(l, r) = tup
    card.are_successive_descending(l, r)
  }
  let assert Ok(rest) = list.rest(cards)
  list.zip(cards, rest)
  |> list.all(pred)
}

fn is_flush(cards: List(card.Card)) -> Bool {
  let pred = fn(tup: #(card.Card, card.Card)) -> Bool {
    let #(l, r) = tup
    l.suit == r.suit
  }
  let assert Ok(rest) = list.rest(cards)
  list.zip(cards, rest)
  |> list.all(pred)
}

fn check_helper_straight(
  cards: List(card.Card),
  check_flush: Bool,
) -> option.Option(List(card.Card)) {
  let choices =
    cards
    |> list.combinations(5)
    |> list.map(list.permutations)
    |> list.concat
    |> list.filter(is_straight)

  case check_flush {
    True -> list.filter(choices, is_flush)
    False -> choices
  }
  |> list.sort(function.flip(card.compare_lists))
  |> list.first
  |> option.from_result
}

type Check {
  StraightCheck
  FlushCheck
  StraightFlushCheck
}

fn check_helper(
  cards: List(card.Card),
  check: Check,
) -> option.Option(List(card.Card)) {
  case check {
    StraightCheck -> check_helper_straight(cards, False)
    StraightFlushCheck -> check_helper_straight(cards, True)
    FlushCheck ->
      list.group(cards, fn(card) { card.suit })
      |> dict.filter(fn(_, l) { list.length(l) >= 5 })
      |> dict.values
      |> list.map(fn(l) {
        list.sort(l, function.flip(card.compare))
        |> list.take(5)
      })
      |> list.sort(function.flip(card.compare_lists))
      |> list.first
      |> option.from_result
  }
}

fn check_royal_flush(cards: List(card.Card)) -> Combination {
  cards
  |> check_helper(StraightFlushCheck)
  |> option.map(fn(cards) {
    let assert [first, ..] = cards
    case first.rank {
      card.Ace -> RoyalFlush(cards)
      _ -> StraightFlush(cards)
    }
  })
  |> option.lazy_unwrap(fn() { check_four_of_a_kind(cards) })
}

fn check_four_of_a_kind(cards: List(card.Card)) -> Combination {
  cards
  |> get_tuple(4)
  |> option.map(fn(tup) {
    let #(four, rest) = tup
    FourOfAKind(list.append(four, list.take(rest, 1)))
  })
  |> option.lazy_unwrap(fn() { check_full_house(cards) })
}

fn check_full_house(cards: List(card.Card)) -> Combination {
  cards
  |> get_tuple(3)
  |> option.then(fn(tup) {
    let #(three, rest) = tup
    rest
    |> get_tuple(2)
    |> option.map(fn(tup) {
      let #(two, _) = tup
      FullHouse(list.append(three, two))
    })
  })
  |> option.lazy_unwrap(fn() { check_flush(cards) })
}

fn check_flush(cards: List(card.Card)) -> Combination {
  cards
  |> check_helper(FlushCheck)
  |> option.map(fn(cards) { Flush(cards) })
  |> option.lazy_unwrap(fn() { check_straight(cards) })
}

fn check_straight(cards: List(card.Card)) -> Combination {
  cards
  |> check_helper(StraightCheck)
  |> option.map(fn(cards) { Straight(cards) })
  |> option.lazy_unwrap(fn() { check_three_of_a_kind(cards) })
}

fn get_tuple(
  cards: List(card.Card),
  count: Int,
) -> option.Option(#(List(card.Card), List(card.Card))) {
  let #(result, rest) =
    cards
    |> list.chunk(by: fn(c) { c.rank })
    |> list.fold(from: #(option.None, []), with: fn(acc, list) {
      case acc {
        #(option.None, rest) ->
          case list.length(list) >= count {
            True -> {
              let #(group, rest_) = list.split(list, count)
              #(option.Some(group), list.append(rest, rest_))
            }
            False -> #(option.None, list.append(rest, list))
          }
        #(option.Some(x), rest) -> #(option.Some(x), list.append(rest, list))
      }
    })
  option.map(over: result, with: fn(result) { #(result, rest) })
}

fn check_three_of_a_kind(cards: List(card.Card)) -> Combination {
  cards
  |> get_tuple(3)
  |> option.map(fn(tup) {
    let #(group, rest) = tup
    ThreeOfAKind(list.append(group, list.take(rest, 2)))
  })
  |> option.lazy_unwrap(fn() { check_two_pair(cards) })
}

fn check_two_pair(cards: List(card.Card)) -> Combination {
  cards
  |> get_tuple(2)
  |> option.then(fn(tup) {
    let #(first_pair, rest) = tup
    option.map(get_tuple(rest, 2), fn(tup) {
      let #(second_pair, rest) = tup
      let assert [last, ..] = rest
      TwoPair(list.concat([first_pair, second_pair, [last]]))
    })
  })
  |> option.lazy_unwrap(fn() { check_pair(cards) })
}

fn check_pair(cards: List(card.Card)) -> Combination {
  cards
  |> get_tuple(2)
  |> option.map(fn(tup) {
    let #(pair, rest) = tup
    Pair(list.append(pair, list.take(rest, 3)))
  })
  |> option.lazy_unwrap(fn() { check_high_card(cards) })
}

fn check_high_card(cards: List(card.Card)) -> Combination {
  HighCard(list.take(cards, 5))
}
