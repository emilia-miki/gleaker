import gleam/order
import gleam/list
import gleam/option
import gleam/int
import card
import combination

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
    hand: List(card.Card),
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
    show_combinations: fn(List(#(Player, combination.Combination))) -> Nil,
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
  show_combinations show_combinations: fn(
    List(#(Player, combination.Combination)),
  ) ->
    Nil,
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
    deck: List(card.Card),
    table: List(card.Card),
    bet: Int,
    bank: Int,
    player_idx: Int,
    players: List(Player),
    callbacks: Callbacks,
  )
}

pub fn init_deck() -> List(card.Card) {
  let suits = [card.Hearts, card.Diamonds, card.Spades, card.Clubs]
  let ranks = [
    card.Ace,
    card.Two,
    card.Three,
    card.Four,
    card.Five,
    card.Six,
    card.Seven,
    card.Eight,
    card.Nine,
    card.Ten,
    card.Jack,
    card.Queen,
    card.King,
  ]
  let mapped =
    list.map(ranks, fn(rank) {
      list.map(suits, fn(suit) { card.Card(rank: rank, suit: suit) })
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

fn shuffle_deck(deck: List(card.Card)) -> List(card.Card) {
  rec_shuffle_deck(deck, [])
}

fn rec_shuffle_deck(
  deck: List(card.Card),
  new_deck: List(card.Card),
) -> List(card.Card) {
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
              #(p, combination.determine(poker.table, p.hand))
            })
          let pcs =
            list.sort(pcs, fn(pcl, pcr) {
              let #(_, combl) = pcl
              let #(_, combr) = pcr
              combination.compare(combr, combl)
            })
          poker.callbacks.show_combinations(pcs)
          let assert [#(_, max_comb), ..] = pcs
          let winners =
            list.filter(pcs, fn(pc) {
              let #(_, comb) = pc
              combination.compare(comb, max_comb) == order.Eq
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
