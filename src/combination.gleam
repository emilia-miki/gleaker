import gleam/order
import gleam/option
import gleam/list
import gleam/dict
import gleam/function
import card

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
  let cards = list.append(table, hand)
  let compare_func = function.flip(card.compare)
  let cards = list.sort(cards, compare_func)
  // if royal flush is not checked, it will call check_straight_flush and so on
  check_royal_flush(cards)
}

fn choose(from cards: List(card.Card), n len: Int) -> List(List(card.Card)) {
  case len {
    0 -> [[]]
    _ ->
      case cards {
        [] -> []
        [x, ..xs] ->
          list.append(
            list.map(choose(from: xs, n: len - 1), fn(list) { [x, ..list] }),
            choose(from: xs, n: len),
          )
      }
  }
}

fn is_straight(cards: List(card.Card)) -> Bool {
  let assert Ok(rest) = list.rest(cards)
  let zipped = list.zip(cards, rest)
  let pred = fn(tup: #(card.Card, card.Card)) -> Bool {
    let #(l, r) = tup
    card.are_successive_descending(l, r)
  }
  list.all(zipped, pred)
}

fn is_flush(cards: List(card.Card)) -> Bool {
  let assert Ok(rest) = list.rest(cards)
  let zipped = list.zip(cards, rest)
  let pred = fn(tup: #(card.Card, card.Card)) -> Bool {
    let #(l, r) = tup
    l.suit == r.suit
  }
  list.all(zipped, pred)
}

fn check_helper(
  cards: List(card.Card),
  check_straight check_straight: Bool,
  check_flush check_flush: Bool,
) -> option.Option(List(card.Card)) {
  case check_straight {
    True -> {
      let choices =
        choose(cards, 5)
        |> list.map(list.permutations)
        |> list.concat
        |> list.filter(is_straight)
      let choices = case check_flush {
        True -> list.filter(choices, is_flush)
        False -> choices
      }
      let choices = list.sort(choices, function.flip(card.compare_lists))
      case choices {
        [] -> option.None
        [x, ..] -> option.Some(x)
      }
    }
    False -> {
      let groups =
        list.group(cards, fn(card) { card.suit })
        |> dict.filter(fn(_, l) { list.length(l) >= 5 })
        |> dict.values
        |> list.map(fn(l) {
          list.sort(l, function.flip(card.compare))
          |> list.take(5)
        })
        |> list.sort(function.flip(card.compare_lists))
      case groups {
        [] -> option.None
        [x, ..] -> option.Some(x)
      }
    }
  }
}

fn check_royal_flush(cards: List(card.Card)) -> Combination {
  case check_helper(cards, True, True) {
    option.None -> check_four_of_a_kind(cards)
    option.Some(cards_) -> {
      let assert [first, ..] = cards_
      case first.rank {
        card.Ace -> RoyalFlush(cards_)
        _ -> StraightFlush(cards_)
      }
    }
  }
}

fn check_four_of_a_kind(cards: List(card.Card)) -> Combination {
  let groups =
    list.group(cards, fn(c) { c.rank })
    |> dict.filter(fn(_, cards) { list.length(cards) == 4 })
  case dict.size(groups) {
    0 -> check_full_house(cards)
    _ -> {
      let assert [cards_] = dict.values(groups)
      let assert [first, ..] = cards_
      let assert [last, ..] = list.filter(cards, fn(c) { c != first })
      FourOfAKind(list.append(cards_, [last]))
    }
  }
}

fn check_full_house(cards: List(card.Card)) -> Combination {
  let groups = list.group(cards, fn(c) { c.rank })
  let groups_ = dict.filter(groups, fn(_, cards) { list.length(cards) == 3 })
  let three_cards_opt = case dict.size(groups_) {
    0 -> option.None
    1 -> {
      let assert [xcards] = dict.values(groups_)
      option.Some(xcards)
    }
    2 -> {
      let assert [[x, ..] as xcards, [y, ..] as ycards] = dict.values(groups_)
      case card.compare(x, y) {
        order.Lt -> option.Some(ycards)
        order.Gt -> option.Some(xcards)
        order.Eq -> panic
      }
    }
    _ -> panic
  }
  case three_cards_opt {
    option.Some(three_cards) -> {
      let assert [three_card, ..] = three_cards
      let groups_ =
        dict.filter(groups, fn(rank, cards) {
          list.length(cards) >= 2 && rank != three_card.rank
        })
      case dict.size(groups_) {
        0 -> check_flush(cards)
        1 -> {
          let assert [two_cards] = dict.values(groups_)
          FullHouse(list.append(three_cards, two_cards))
        }
        2 -> {
          let assert [[p1, ..] as pair1, [p2, ..] as pair2] =
            dict.values(groups_)
          let max_pair = case card.compare(p1, p2) {
            order.Lt -> pair2
            order.Gt -> pair1
            order.Eq -> panic
          }
          FullHouse(list.append(three_cards, max_pair))
        }
        _ -> panic
      }
    }
    option.None -> check_flush(cards)
  }
}

fn check_flush(cards: List(card.Card)) -> Combination {
  case check_helper(cards, False, True) {
    option.Some(cards) -> Flush(cards)
    option.None -> check_straight(cards)
  }
}

fn check_straight(cards: List(card.Card)) -> Combination {
  case check_helper(cards, True, False) {
    option.Some(cards) -> Straight(cards)
    option.None -> check_three_of_a_kind(cards)
  }
}

fn check_three_of_a_kind(cards: List(card.Card)) -> Combination {
  let three_groups =
    list.group(cards, fn(c) { c.rank })
    |> dict.filter(fn(_, cards) { list.length(cards) >= 3 })
    |> dict.values
    |> list.map(fn(l) { list.take(l, 3) })
    |> list.sort(function.flip(card.compare_lists))
  case three_groups {
    [] -> check_two_pair(cards)
    [three, ..] -> {
      let assert [three_first, ..] = three
      let three_rank = three_first.rank
      let rest =
        list.filter(cards, fn(c) { c.rank != three_rank })
        |> list.take(2)
      ThreeOfAKind(list.append(three, rest))
    }
  }
}

fn check_two_pair(cards: List(card.Card)) -> Combination {
  let groups =
    list.group(cards, fn(c) { c.rank })
    |> dict.filter(fn(_, cards) { list.length(cards) == 2 })
  let two_pairs_opt = case dict.size(groups) {
    0 -> option.None
    1 -> option.None
    2 -> {
      let assert [[x, ..] as xcards, [y, ..] as ycards] = dict.values(groups)
      case card.compare(x, y) {
        order.Lt -> option.Some(#(ycards, xcards))
        order.Gt -> option.Some(#(xcards, ycards))
        order.Eq -> panic
      }
    }
    3 -> {
      let compare_func = fn(ll: List(card.Card), lr: List(card.Card)) -> order.Order {
        let assert #([x, ..], [y, ..]) = #(ll, lr)
        case card.compare(x, y) {
          order.Lt -> order.Gt
          order.Gt -> order.Lt
          order.Eq -> panic
        }
      }
      let sorted = list.sort(dict.values(groups), compare_func)
      let assert [x, y, _] = sorted
      option.Some(#(x, y))
    }
    _ -> panic
  }
  case two_pairs_opt {
    option.Some(tup) -> {
      let assert #([x, ..] as xcards, [y, ..] as ycards) = tup
      let assert [last, ..] =
        list.filter(cards, fn(c) { c.rank != x.rank && c.rank != y.rank })
      TwoPair(list.concat([xcards, ycards, [last]]))
    }
    option.None -> check_pair(cards)
  }
}

fn check_pair(cards: List(card.Card)) -> Combination {
  let grouped =
    list.group(cards, fn(c) { c.rank })
    |> dict.filter(fn(_, cards) { list.length(cards) == 2 })
  case dict.size(grouped) {
    0 -> check_high_card(cards)
    1 -> {
      let assert [[x, ..] as xcards] = dict.values(grouped)
      let rest =
        list.filter(cards, fn(c) { c.rank != x.rank })
        |> list.take(3)
      Pair(list.append(xcards, rest))
    }
    _ -> panic
  }
}

fn check_high_card(cards: List(card.Card)) -> Combination {
  HighCard(list.take(cards, 5))
}
