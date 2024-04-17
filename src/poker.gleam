import gleam/order
import gleam/list
import gleam/option
import gleam/dict
import gleam/int

pub type Suit {
  Hearts
  Diamonds
  Spades
  Clubs
}

pub type Rank {
  Two
  Three
  Four
  Five
  Six
  Seven
  Eight
  Nine
  Ten
  Jack
  Queen
  King
  Ace
}

fn compare_ranks(l: Rank, r: Rank) -> order.Order {
  case l {
    Ace ->
      case r {
        Ace -> order.Eq
        _ -> order.Gt
      }
    King ->
      case r {
        Ace -> order.Lt
        King -> order.Eq
        _ -> order.Gt
      }
    Queen ->
      case r {
        Ace -> order.Lt
        King -> order.Lt
        Queen -> order.Eq
        _ -> order.Lt
      }
    Jack ->
      case r {
        Ace -> order.Lt
        King -> order.Lt
        Queen -> order.Lt
        Jack -> order.Eq
        _ -> order.Gt
      }
    Ten ->
      case r {
        Ace -> order.Lt
        King -> order.Lt
        Queen -> order.Lt
        Jack -> order.Lt
        Ten -> order.Eq
        _ -> order.Gt
      }
    Nine ->
      case r {
        Ace -> order.Lt
        King -> order.Lt
        Queen -> order.Lt
        Jack -> order.Lt
        Ten -> order.Lt
        Nine -> order.Eq
        _ -> order.Gt
      }
    Eight ->
      case r {
        Ace -> order.Lt
        King -> order.Lt
        Queen -> order.Lt
        Jack -> order.Lt
        Ten -> order.Lt
        Nine -> order.Lt
        Eight -> order.Eq
        _ -> order.Gt
      }
    Seven ->
      case r {
        Ace -> order.Lt
        King -> order.Lt
        Queen -> order.Lt
        Jack -> order.Lt
        Ten -> order.Lt
        Nine -> order.Lt
        Eight -> order.Lt
        Seven -> order.Eq
        _ -> order.Gt
      }
    Six ->
      case r {
        Ace -> order.Lt
        King -> order.Lt
        Queen -> order.Lt
        Jack -> order.Lt
        Ten -> order.Lt
        Nine -> order.Lt
        Eight -> order.Lt
        Seven -> order.Lt
        Six -> order.Eq
        _ -> order.Gt
      }
    Five ->
      case r {
        Ace -> order.Lt
        King -> order.Lt
        Queen -> order.Lt
        Jack -> order.Lt
        Ten -> order.Lt
        Nine -> order.Lt
        Eight -> order.Lt
        Seven -> order.Lt
        Six -> order.Lt
        Five -> order.Eq
        _ -> order.Gt
      }
    Four ->
      case r {
        Ace -> order.Lt
        King -> order.Lt
        Queen -> order.Lt
        Jack -> order.Lt
        Ten -> order.Lt
        Nine -> order.Lt
        Eight -> order.Lt
        Seven -> order.Lt
        Six -> order.Lt
        Five -> order.Lt
        Four -> order.Eq
        _ -> order.Gt
      }
    Three ->
      case r {
        Ace -> order.Lt
        King -> order.Lt
        Queen -> order.Lt
        Jack -> order.Lt
        Ten -> order.Lt
        Nine -> order.Lt
        Eight -> order.Lt
        Seven -> order.Lt
        Six -> order.Lt
        Five -> order.Lt
        Four -> order.Lt
        Three -> order.Eq
        _ -> order.Gt
      }
    Two ->
      case r {
        Ace -> order.Lt
        King -> order.Lt
        Queen -> order.Lt
        Jack -> order.Lt
        Ten -> order.Lt
        Nine -> order.Lt
        Eight -> order.Lt
        Seven -> order.Lt
        Six -> order.Lt
        Five -> order.Lt
        Four -> order.Lt
        Three -> order.Lt
        Two -> order.Eq
      }
  }
}

fn are_ranks_successive_descending(l: Rank, r: Rank) -> Bool {
  case l {
    Ace ->
      case r {
        King -> True
        _ -> False
      }
    Two ->
      case r {
        Ace -> True
        _ -> False
      }
    Three ->
      case r {
        Two -> True
        _ -> False
      }
    Four ->
      case r {
        Three -> True
        _ -> False
      }
    Five ->
      case r {
        Four -> True
        _ -> False
      }
    Six ->
      case r {
        Five -> True
        _ -> False
      }
    Seven ->
      case r {
        Six -> True
        _ -> False
      }
    Eight ->
      case r {
        Seven -> True
        _ -> False
      }
    Nine ->
      case r {
        Eight -> True
        _ -> False
      }
    Ten ->
      case r {
        Nine -> True
        _ -> False
      }
    Jack ->
      case r {
        Ten -> True
        _ -> False
      }
    Queen ->
      case r {
        Jack -> True
        _ -> False
      }
    King ->
      case r {
        Queen -> True
        _ -> False
      }
  }
}

pub type Card {
  Card(rank: Rank, suit: Suit)
}

fn compare_cards(lcards: List(Card), rcards: List(Card)) -> order.Order {
  case lcards {
    [] -> order.Eq
    [l, ..lrest] -> {
      let assert [r, ..rrest] = rcards
      case compare_ranks(l.rank, r.rank) {
        order.Eq -> compare_cards(lrest, rrest)
        ord -> ord
      }
    }
  }
}

pub type Combination {
  HighCard(cards: List(Card))
  Pair(cards: List(Card))
  TwoPair(cards: List(Card))
  ThreeOfAKind(cards: List(Card))
  Straight(cards: List(Card))
  Flush(cards: List(Card))
  FullHouse(cards: List(Card))
  FourOfAKind(cards: List(Card))
  StraightFlush(cards: List(Card))
  RoyalFlush(cards: List(Card))
}

fn compare_combination(cl: Combination, cr: Combination) -> order.Order {
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
          compare_ranks(cl.rank, cr.rank)
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
          case compare_ranks(cl.rank, cr.rank) {
            order.Eq -> compare_ranks(cl_.rank, cr_.rank)
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
          case compare_ranks(cl.rank, cr.rank) {
            order.Eq -> compare_ranks(cl_.rank, cr_.rank)
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
        Flush(rcards) -> compare_cards(lcards, rcards)
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
          compare_ranks(l.rank, r.rank)
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
          compare_cards([lthree, lc1, lc2], [rthree, rc1, rc2])
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
          compare_cards([lp1, lp2, lc], [rp1, rp2, rc])
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
          compare_cards([lp, ..lrest], [rp, ..rrest])
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
        HighCard(rcards) -> compare_cards(lcards, rcards)
      }
  }
}

fn determine_combination(table: List(Card), hand: List(Card)) -> Combination {
  let cards = list.append(table, hand)
  let compare_func = fn(l: Card, r: Card) -> order.Order {
    case compare_ranks(l.rank, r.rank) {
      order.Lt -> order.Gt
      order.Eq -> order.Eq
      order.Gt -> order.Lt
    }
  }
  let cards = list.sort(cards, compare_func)
  // if royal flush is not checked, it will call check_straight_flush and so on
  check_royal_flush(cards)
}

fn check_helper(
  cards: List(Card),
  check_straight: Bool,
  check_flush: Bool,
) -> option.Option(List(Card)) {
  case list.length(cards) {
    4 -> option.None
    _ -> {
      let truncated = list.take(cards, 5)
      let assert Ok(rest) = list.rest(truncated)
      let zipped = list.zip(truncated, rest)
      let succ_pred = fn(tup: #(Card, Card)) -> Bool {
        let #(l, r) = tup
        are_ranks_successive_descending(l.rank, r.rank)
      }
      let flush_pred = fn(tup: #(Card, Card)) -> Bool {
        let #(l, r) = tup
        l.suit == r.suit
      }
      let pred = fn(tup: #(Card, Card)) -> Bool {
        case check_straight {
          True ->
            case check_flush {
              True -> succ_pred(tup) && flush_pred(tup)
              False -> succ_pred(tup)
            }
          False ->
            case check_flush {
              True -> flush_pred(tup)
              False -> panic
            }
        }
      }
      case list.all(zipped, pred) {
        True -> option.Some(truncated)
        False -> {
          let assert Ok(rest) = list.rest(cards)
          check_helper(rest, check_straight, check_flush)
        }
      }
    }
  }
}

fn check_royal_flush(cards: List(Card)) -> Combination {
  case check_helper(cards, True, True) {
    option.None -> check_four_of_a_kind(cards)
    option.Some(cards_) -> {
      let assert [first, ..] = cards_
      case first.rank {
        Ace -> RoyalFlush(cards_)
        _ -> StraightFlush(cards_)
      }
    }
  }
}

fn check_four_of_a_kind(cards: List(Card)) -> Combination {
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

fn check_full_house(cards: List(Card)) -> Combination {
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
      case compare_ranks(x.rank, y.rank) {
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
          let max_pair = case compare_ranks(p1.rank, p2.rank) {
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

fn check_flush(cards: List(Card)) -> Combination {
  case check_helper(cards, False, True) {
    option.Some(cards) -> Flush(cards)
    option.None -> check_straight(cards)
  }
}

fn check_straight(cards: List(Card)) -> Combination {
  case check_helper(cards, True, False) {
    option.Some(cards) -> Straight(cards)
    option.None -> check_three_of_a_kind(cards)
  }
}

fn check_three_of_a_kind(cards: List(Card)) -> Combination {
  let groups =
    list.group(cards, fn(c) { c.rank })
    |> dict.filter(fn(_, cards) { list.length(cards) == 3 })
  let three_cards_opt = case dict.size(groups) {
    0 -> option.None
    1 -> {
      let assert [xcards] = dict.values(groups)
      option.Some(xcards)
    }
    2 -> {
      let assert [[x, ..] as xcards, [y, ..] as ycards] = dict.values(groups)
      case compare_ranks(x.rank, y.rank) {
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
      let rest =
        list.filter(cards, fn(c) { c.rank != three_card.rank })
        |> list.take(3)
      ThreeOfAKind(list.append(three_cards, rest))
    }
    option.None -> check_two_pair(cards)
  }
}

fn check_two_pair(cards: List(Card)) -> Combination {
  let groups =
    list.group(cards, fn(c) { c.rank })
    |> dict.filter(fn(_, cards) { list.length(cards) == 2 })
  let two_pairs_opt = case dict.size(groups) {
    0 -> option.None
    1 -> option.None
    2 -> {
      let assert [[x, ..] as xcards, [y, ..] as ycards] = dict.values(groups)
      case compare_ranks(x.rank, y.rank) {
        order.Lt -> option.Some(#(ycards, xcards))
        order.Gt -> option.Some(#(xcards, ycards))
        order.Eq -> panic
      }
    }
    3 -> {
      let compare_func = fn(ll: List(Card), lr: List(Card)) -> order.Order {
        let assert #([x, ..], [y, ..]) = #(ll, lr)
        case compare_ranks(x.rank, y.rank) {
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

fn check_pair(cards: List(Card)) -> Combination {
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

fn check_high_card(cards: List(Card)) -> Combination {
  HighCard(list.take(cards, 5))
}

pub type Play {
  Fold
  Check
  Call
  Raise(bet: Int)
  AllIn
}

pub type PlayDesc {
  FoldDesc
  CheckDesc
  CallDesc
  RaiseDesc(excl_min: Int, excl_max: Int)
  AllInDesc
}

pub type Player {
  Player(
    name: String,
    hand: List(Card),
    bet: Int,
    bank: Int,
    has_played: Bool,
    has_folded: Bool,
  )
}

pub type WinCondition {
  EveryoneFolded
  LastRoundEnded
}

pub opaque type Callbacks {
  Callbacks(
    // defines how to get a play from the current player
    get_play: fn(Poker, Player, List(PlayDesc)) -> Play,
    // lets the user handle player combinations at game end
    show_combinations: fn(List(#(Player, Combination))) -> Nil,
    // lets the user display the winners at game end
    show_winner: fn(Poker, WinCondition, List(String)) -> Nil,
    // gets executed before the first game starts
    first_game_start: fn(Poker) -> Nil,
    // gets executed before a game starts (except the first one)
    next_game_start: fn(Poker) -> Nil,
    // gets executed before a game starts
    game_start: fn(Poker) -> Nil,
    // gets executed after a game ends, before starting the next one
    game_end: fn(Poker) -> Nil,
    // gets executed before the first round starts
    first_round_start: fn(Poker) -> Nil,
    // gets executed before a round starts (except the first one)
    next_round_start: fn(Poker) -> Nil,
    // gets executed before a round starts
    round_start: fn(Poker) -> Nil,
    // gets executed after a round ends
    round_end: fn(Poker) -> Nil,
  )
}

pub fn new_callbacks(
  get_play get_play: fn(Poker, Player, List(PlayDesc)) -> Play,
  show_combinations show_combinations: fn(List(#(Player, Combination))) -> Nil,
  show_winner show_winner: fn(Poker, WinCondition, List(String)) -> Nil,
) {
  Callbacks(
    get_play: get_play,
    show_combinations: show_combinations,
    show_winner: show_winner,
    first_game_start: fn(_) { Nil },
    next_game_start: fn(_) { Nil },
    game_start: fn(_) { Nil },
    game_end: fn(_) { Nil },
    first_round_start: fn(_) { Nil },
    next_round_start: fn(_) { Nil },
    round_start: fn(_) { Nil },
    round_end: fn(_) { Nil },
  )
}

pub fn set_first_game_start_callback(cbs: Callbacks, cb: fn(Poker) -> Nil) {
  Callbacks(..cbs, first_game_start: cb)
}

pub fn set_next_game_start_callback(cbs: Callbacks, cb: fn(Poker) -> Nil) {
  Callbacks(..cbs, next_game_start: cb)
}

pub fn set_game_start_callback(cbs: Callbacks, cb: fn(Poker) -> Nil) {
  Callbacks(..cbs, game_start: cb)
}

pub fn set_game_end_callback(cbs: Callbacks, cb: fn(Poker) -> Nil) {
  Callbacks(..cbs, game_end: cb)
}

pub fn set_first_round_start_callback(cbs: Callbacks, cb: fn(Poker) -> Nil) {
  Callbacks(..cbs, first_round_start: cb)
}

pub fn set_next_round_start_callback(cbs: Callbacks, cb: fn(Poker) -> Nil) {
  Callbacks(..cbs, next_round_start: cb)
}

pub fn set_round_start_callback(cbs: Callbacks, cb: fn(Poker) -> Nil) {
  Callbacks(..cbs, round_start: cb)
}

pub fn set_round_end_callback(cbs: Callbacks, cb: fn(Poker) -> Nil) {
  Callbacks(..cbs, round_end: cb)
}

pub type Poker {
  Poker(
    deck: List(Card),
    table: List(Card),
    bet: Int,
    bank: Int,
    player_idx: Int,
    players: List(Player),
    callbacks: Callbacks,
  )
}

pub fn init_deck() -> List(Card) {
  let suits = [Hearts, Diamonds, Spades, Clubs]
  let ranks = [
    Ace,
    Two,
    Three,
    Four,
    Five,
    Six,
    Seven,
    Eight,
    Nine,
    Ten,
    Jack,
    Queen,
    King,
  ]
  let mapped =
    list.map(ranks, fn(rank) {
      list.map(suits, fn(suit) { Card(rank: rank, suit: suit) })
    })
  list.concat(mapped)
}

pub fn init_poker(names: List(String), callbacks: Callbacks) -> Poker {
  let players =
    list.map(names, fn(name) {
      Player(
        name: name,
        hand: [],
        bank: 500,
        bet: 0,
        has_played: False,
        has_folded: False,
      )
    })
  Poker(
    deck: init_deck(),
    table: [],
    bet: 0,
    bank: 0,
    player_idx: 0,
    players: players,
    callbacks: callbacks,
  )
}

fn shuffle_deck(deck: List(Card)) -> List(Card) {
  rec_shuffle_deck(deck, [])
}

fn rec_shuffle_deck(deck: List(Card), new_deck: List(Card)) -> List(Card) {
  case list.length(deck) {
    0 -> new_deck
    len -> {
      let idx = int.random(len)
      let left = list.take(deck, idx)
      let assert [card, ..right] = list.drop(deck, idx)
      let deck = list.append(left, right)
      let new_deck = [card, ..new_deck]
      rec_shuffle_deck(deck, new_deck)
    }
  }
}

fn next_round(poker: Poker) -> option.Option(Poker) {
  case is_game_end(poker) {
    True -> option.None
    False -> {
      let players =
        list.map(poker.players, fn(p) { Player(..p, bet: 0, has_played: False) })
      let num_cards_to_show = case list.length(poker.table) {
        0 -> option.Some(3)
        3 -> option.Some(1)
        4 -> option.Some(1)
        _ -> option.None
      }
      case num_cards_to_show {
        option.Some(num) -> {
          let shown = list.take(poker.deck, num)
          let deck = list.drop(poker.deck, num)
          let table = list.append(poker.table, shown)
          let poker =
            Poker(
              ..poker,
              deck: deck,
              table: table,
              bet: 0,
              player_idx: 0,
              players: players,
            )
          let poker = skip_passive(poker)
          option.Some(poker)
        }
        option.None -> option.None
      }
    }
  }
}

fn take_blind(poker: Poker, big_blind: Bool) -> option.Option(Poker) {
  let #(val, idx) = case big_blind {
    False -> #(5, 0)
    True -> #(10, 1)
  }
  let left = list.take(poker.players, idx)
  case list.drop(poker.players, idx) {
    [] -> option.None
    [player, ..right] -> {
      case player.bank >= val {
        True -> {
          let poker = advance_player(poker)
          let player = Player(..player, bet: val, bank: player.bank - val)
          let poker =
            Poker(
              ..poker,
              bet: val,
              bank: poker.bank
              + val,
              players: list.concat([left, [player], right]),
            )
          option.Some(poker)
        }
        False ->
          take_blind(
            Poker(..poker, players: list.append(left, right)),
            big_blind,
          )
      }
    }
  }
}

fn next_game(poker: Poker) -> option.Option(Poker) {
  let hands = list.concat(list.map(poker.players, fn(p) { p.hand }))
  let deck = list.append(poker.deck, hands)
  let deck = shuffle_deck(deck)
  let players =
    list.map(poker.players, fn(p) {
      Player(..p, hand: [], bet: 0, has_played: False, has_folded: False)
    })
  let poker =
    Poker(
      ..poker,
      deck: deck,
      table: [],
      bet: 0,
      bank: 0,
      player_idx: 0,
      players: players,
    )
  case take_blind(poker, False) {
    option.Some(poker) ->
      case take_blind(poker, True) {
        option.Some(poker) -> {
          let num_players = list.length(poker.players)
          let dealt = list.take(poker.deck, num_players * 2)
          let deck = list.drop(poker.deck, num_players * 2)
          let dealt = list.sized_chunk(dealt, 2)
          let players =
            list.map2(poker.players, dealt, fn(p, c) { Player(..p, hand: c) })
          option.Some(Poker(..poker, deck: deck, players: players))
        }
        option.None -> option.None
      }
    option.None -> option.None
  }
}

fn is_game_end_by_fold(poker: Poker) -> Bool {
  let folded = list.filter(poker.players, fn(p) { p.has_folded })
  list.length(folded) == list.length(poker.players) - 1
}

fn is_round_end(poker: Poker) -> Bool {
  case is_game_end_by_fold(poker) {
    True -> True
    False -> {
      let pred = fn(p: Player) -> Bool {
        p.bank == 0 || p.has_folded || { p.has_played && p.bet == poker.bet }
      }
      list.all(poker.players, pred)
    }
  }
}

fn is_game_end(poker: Poker) -> Bool {
  case is_game_end_by_fold(poker) {
    True -> True
    False -> {
      case list.all(poker.players, fn(p) { p.bank == 0 || p.has_folded }) {
        True -> True
        False ->
          case list.length(poker.table) {
            5 -> is_round_end(poker)
            _ -> False
          }
      }
    }
  }
}

fn skip_passive(poker: Poker) -> Poker {
  case list.drop(poker.players, poker.player_idx) {
    [] -> poker
    [player, ..] ->
      case player.bank == 0 || player.has_folded {
        True -> skip_passive(advance_player(poker))
        False -> poker
      }
  }
}

fn advance_player(poker: Poker) -> Poker {
  case is_round_end(poker) {
    True -> poker
    False -> {
      let assert Ok(next_idx) =
        int.modulo(poker.player_idx + 1, list.length(poker.players))
      let poker = Poker(..poker, player_idx: next_idx)
      skip_passive(poker)
    }
  }
}

pub fn validate_play(play: Play, play_descs: List(PlayDesc)) -> Bool {
  case play {
    Fold -> list.any(play_descs, fn(pd) { pd == FoldDesc })
    Check -> list.any(play_descs, fn(pd) { pd == CheckDesc })
    Call -> list.any(play_descs, fn(pd) { pd == CallDesc })
    Raise(bet) ->
      list.any(play_descs, fn(pd) {
        case pd {
          RaiseDesc(excl_min, excl_max) -> excl_min < bet && bet < excl_max
          _ -> False
        }
      })
    AllIn -> list.any(play_descs, fn(pd) { pd == AllInDesc })
  }
}

pub fn get_valid_plays(poker: Poker) -> List(PlayDesc) {
  let assert [player, ..] = list.drop(poker.players, poker.player_idx)
  let diff = poker.bet - player.bet
  case diff == 0 {
    True -> [
      CheckDesc,
      RaiseDesc(poker.bet, player.bet + player.bank),
      AllInDesc,
    ]
    False ->
      case diff >= player.bank {
        True -> [FoldDesc, AllInDesc]
        False -> [
          FoldDesc,
          CallDesc,
          RaiseDesc(poker.bet, player.bet + player.bank),
          AllInDesc,
        ]
      }
  }
}

fn play_turn(poker: Poker, play: Play) -> Poker {
  let left = list.take(poker.players, poker.player_idx)
  let assert [player, ..right] = list.drop(poker.players, poker.player_idx)
  let #(poker, player) = case play {
    Fold -> #(poker, Player(..player, has_folded: True))
    Check -> #(poker, player)
    Call -> {
      let diff = int.clamp(poker.bet - player.bet, 0, player.bank)
      let player = Player(..player, bet: poker.bet, bank: player.bank - diff)
      let poker = Poker(..poker, bank: poker.bank + diff)
      #(poker, player)
    }
    Raise(bet) -> {
      let diff = bet - player.bet
      let player =
        Player(..player, bet: player.bet + diff, bank: player.bank - diff)
      let poker = Poker(..poker, bet: bet, bank: poker.bank + diff)
      #(poker, player)
    }
    AllIn -> {
      let bank = player.bank
      let player = Player(..player, bet: bank, bank: 0)
      let bet = int.max(poker.bet, bank)
      let poker = Poker(..poker, bet: bet, bank: poker.bank + bank)
      #(poker, player)
    }
  }
  let player = Player(..player, has_played: True)
  let poker = Poker(..poker, players: list.concat([left, [player], right]))
  advance_player(poker)
}

fn give_bank(winners: List(String), poker: Poker) -> Poker {
  let bank_share = poker.bank / list.length(winners)
  let players =
    list.map(poker.players, fn(pl) {
      case list.contains(winners, pl.name) {
        True -> Player(..pl, bank: pl.bank + bank_share)
        False -> pl
      }
    })
  Poker(..poker, players: players)
}

fn turn_loop(poker: Poker) -> Poker {
  case is_round_end(poker) {
    True -> poker
    False -> {
      let assert [player, ..] = list.drop(poker.players, poker.player_idx)
      let valid_plays = get_valid_plays(poker)
      let play = poker.callbacks.get_play(poker, player, valid_plays)
      case validate_play(play, valid_plays) {
        True -> Nil
        False -> panic as "invalid play received"
      }
      let poker = play_turn(poker, play)
      turn_loop(poker)
    }
  }
}

fn round_loop_helper(poker: Poker, first: Bool) {
  case first {
    True -> poker.callbacks.first_round_start(poker)
    False -> poker.callbacks.next_round_start(poker)
  }
  poker.callbacks.round_start(poker)
  let poker = turn_loop(poker)
  poker.callbacks.round_end(poker)
  case next_round(poker) {
    option.Some(poker) -> {
      round_loop_helper(poker, False)
    }
    option.None ->
      case is_game_end_by_fold(poker) {
        True -> {
          let assert [winner] =
            list.filter(poker.players, fn(p) { !p.has_folded })
          poker.callbacks.show_winner(poker, EveryoneFolded, [winner.name])
          let poker = give_bank([winner.name], poker)
          poker
        }
        False -> {
          let to_show = 5 - list.length(poker.table)
          let deck = list.drop(poker.deck, to_show)
          let to_show = list.take(poker.deck, to_show)
          let poker =
            Poker(..poker, table: list.append(poker.table, to_show), deck: deck)
          let players = list.filter(poker.players, fn(p) { !p.has_folded })
          let pcs =
            list.map(players, fn(p) {
              #(p, determine_combination(poker.table, p.hand))
            })
          let pcs =
            list.sort(pcs, fn(pcl, pcr) {
              let #(_, combl) = pcl
              let #(_, combr) = pcr
              case compare_combination(combl, combr) {
                order.Lt -> order.Gt
                order.Eq -> order.Eq
                order.Gt -> order.Lt
              }
            })
          poker.callbacks.show_combinations(pcs)
          let assert [#(_, max_comb), ..] = pcs
          let winners =
            list.filter(pcs, fn(pc) {
              let #(_, comb) = pc
              compare_combination(comb, max_comb) == order.Eq
            })
          let winners =
            list.map(winners, fn(pc) {
              let #(pl, _) = pc
              pl
            })
          poker.callbacks.show_winner(
            poker,
            LastRoundEnded,
            list.map(winners, fn(w) { w.name }),
          )
          give_bank(list.map(winners, fn(w) { w.name }), poker)
        }
      }
  }
}

fn round_loop(poker: Poker) -> Poker {
  round_loop_helper(poker, True)
}

fn game_loop_helper(poker: Poker, first first: Bool) -> Nil {
  case next_game(poker) {
    option.Some(poker) -> {
      case first {
        True -> poker.callbacks.first_game_start(poker)
        False -> poker.callbacks.next_game_start(poker)
      }
      poker.callbacks.game_start(poker)
      let poker = round_loop(poker)
      poker.callbacks.game_end(poker)
      game_loop_helper(poker, False)
    }
    option.None -> Nil
  }
}

pub fn game_loop(poker: Poker) -> Nil {
  game_loop_helper(poker, True)
}
