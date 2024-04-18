import gleeunit/should
import card
import combination

pub fn royal_flush_test() {
  let expected =
    combination.RoyalFlush([
      card.Card(card.Ace, card.Spades),
      card.Card(card.King, card.Spades),
      card.Card(card.Queen, card.Spades),
      card.Card(card.Jack, card.Spades),
      card.Card(card.Ten, card.Spades),
    ])

  let table = [
    card.Card(card.Queen, card.Spades),
    card.Card(card.Ace, card.Hearts),
    card.Card(card.Ten, card.Spades),
    card.Card(card.Ace, card.Diamonds),
    card.Card(card.Jack, card.Spades),
  ]
  let hand = [
    card.Card(card.Ace, card.Spades),
    card.Card(card.King, card.Spades),
  ]
  let actual = combination.determine(table: table, hand: hand)

  should.equal(actual, expected)
}

pub fn straight_flush_test() {
  let expected =
    combination.StraightFlush([
      card.Card(card.Five, card.Clubs),
      card.Card(card.Four, card.Clubs),
      card.Card(card.Three, card.Clubs),
      card.Card(card.Two, card.Clubs),
      card.Card(card.Ace, card.Clubs),
    ])

  let table = [
    card.Card(card.Ace, card.Clubs),
    card.Card(card.Four, card.Clubs),
    card.Card(card.Three, card.Clubs),
    card.Card(card.Two, card.Hearts),
    card.Card(card.Five, card.Hearts),
  ]
  let hand = [card.Card(card.Two, card.Clubs), card.Card(card.Five, card.Clubs)]
  let actual = combination.determine(table: table, hand: hand)

  should.equal(actual, expected)
}

pub fn four_of_a_kind_test() {
  let expected =
    combination.FourOfAKind([
      card.Card(card.Eight, card.Clubs),
      card.Card(card.Eight, card.Spades),
      card.Card(card.Eight, card.Hearts),
      card.Card(card.Eight, card.Diamonds),
      card.Card(card.King, card.Spades),
    ])

  let table = [
    card.Card(card.Eight, card.Diamonds),
    card.Card(card.King, card.Spades),
    card.Card(card.Eight, card.Hearts),
    card.Card(card.Eight, card.Spades),
    card.Card(card.Ten, card.Spades),
  ]
  let hand = [
    card.Card(card.Eight, card.Clubs),
    card.Card(card.Seven, card.Diamonds),
  ]
  let actual = combination.determine(table: table, hand: hand)

  should.equal(actual, expected)
}

pub fn full_house_test() {
  let expected =
    combination.FullHouse([
      card.Card(card.Five, card.Spades),
      card.Card(card.Five, card.Diamonds),
      card.Card(card.Five, card.Hearts),
      card.Card(card.King, card.Spades),
      card.Card(card.King, card.Clubs),
    ])

  let table = [
    card.Card(card.King, card.Clubs),
    card.Card(card.King, card.Spades),
    card.Card(card.Five, card.Hearts),
    card.Card(card.Ace, card.Hearts),
    card.Card(card.Two, card.Diamonds),
  ]
  let hand = [
    card.Card(card.Five, card.Diamonds),
    card.Card(card.Five, card.Spades),
  ]
  let actual = combination.determine(table: table, hand: hand)

  should.equal(actual, expected)
}

pub fn flush_test() {
  let expected =
    combination.Flush([
      card.Card(card.Ace, card.Hearts),
      card.Card(card.Queen, card.Hearts),
      card.Card(card.Jack, card.Hearts),
      card.Card(card.Five, card.Hearts),
      card.Card(card.Four, card.Hearts),
    ])

  let table = [
    card.Card(card.Three, card.Hearts),
    card.Card(card.Five, card.Hearts),
    card.Card(card.Jack, card.Hearts),
    card.Card(card.Five, card.Spades),
    card.Card(card.Four, card.Hearts),
  ]
  let hand = [
    card.Card(card.Queen, card.Hearts),
    card.Card(card.Ace, card.Hearts),
  ]
  let actual = combination.determine(table: table, hand: hand)

  should.equal(actual, expected)
}

pub fn straight_test() {
  let expected =
    combination.Straight([
      card.Card(card.Ten, card.Hearts),
      card.Card(card.Nine, card.Hearts),
      card.Card(card.Eight, card.Diamonds),
      card.Card(card.Seven, card.Clubs),
      card.Card(card.Six, card.Hearts),
    ])

  let table = [
    card.Card(card.Six, card.Hearts),
    card.Card(card.Two, card.Diamonds),
    card.Card(card.Ace, card.Clubs),
    card.Card(card.Ten, card.Hearts),
    card.Card(card.Eight, card.Diamonds),
  ]
  let hand = [
    card.Card(card.Nine, card.Hearts),
    card.Card(card.Seven, card.Clubs),
  ]
  let actual = combination.determine(table: table, hand: hand)

  should.equal(actual, expected)
}

pub fn three_of_a_kind_test() {
  let expected =
    combination.ThreeOfAKind([
      card.Card(card.Three, card.Hearts),
      card.Card(card.Three, card.Clubs),
      card.Card(card.Three, card.Diamonds),
      card.Card(card.King, card.Hearts),
      card.Card(card.Ten, card.Spades),
    ])

  let table = [
    card.Card(card.Nine, card.Hearts),
    card.Card(card.Seven, card.Diamonds),
    card.Card(card.Three, card.Diamonds),
    card.Card(card.Three, card.Clubs),
    card.Card(card.Ten, card.Spades),
  ]
  let hand = [
    card.Card(card.Three, card.Hearts),
    card.Card(card.King, card.Hearts),
  ]
  let actual = combination.determine(table: table, hand: hand)

  should.equal(actual, expected)
}

pub fn two_pair_test() {
  let expected =
    combination.TwoPair([
      card.Card(card.Jack, card.Hearts),
      card.Card(card.Jack, card.Diamonds),
      card.Card(card.Five, card.Clubs),
      card.Card(card.Five, card.Spades),
      card.Card(card.Ten, card.Spades),
    ])

  let table = [
    card.Card(card.Jack, card.Diamonds),
    card.Card(card.Five, card.Spades),
    card.Card(card.Ten, card.Spades),
    card.Card(card.Two, card.Diamonds),
    card.Card(card.Four, card.Hearts),
  ]
  let hand = [
    card.Card(card.Jack, card.Hearts),
    card.Card(card.Five, card.Clubs),
  ]
  let actual = combination.determine(table: table, hand: hand)

  should.equal(actual, expected)
}

pub fn pair_test() {
  let expected =
    combination.Pair([
      card.Card(card.Jack, card.Diamonds),
      card.Card(card.Jack, card.Hearts),
      card.Card(card.Ten, card.Hearts),
      card.Card(card.Nine, card.Hearts),
      card.Card(card.Eight, card.Clubs),
    ])

  let table = [
    card.Card(card.Six, card.Diamonds),
    card.Card(card.Four, card.Spades),
    card.Card(card.Eight, card.Clubs),
    card.Card(card.Ten, card.Hearts),
    card.Card(card.Nine, card.Hearts),
  ]
  let hand = [
    card.Card(card.Jack, card.Hearts),
    card.Card(card.Jack, card.Diamonds),
  ]
  let actual = combination.determine(table: table, hand: hand)

  should.equal(actual, expected)
}

pub fn high_card_test() {
  let expected =
    combination.HighCard([
      card.Card(card.Ace, card.Hearts),
      card.Card(card.King, card.Hearts),
      card.Card(card.Queen, card.Hearts),
      card.Card(card.Jack, card.Hearts),
      card.Card(card.Nine, card.Diamonds),
    ])

  let table = [
    card.Card(card.Ace, card.Hearts),
    card.Card(card.King, card.Hearts),
    card.Card(card.Queen, card.Hearts),
    card.Card(card.Jack, card.Hearts),
    card.Card(card.Seven, card.Diamonds),
  ]
  let hand = [
    card.Card(card.Eight, card.Diamonds),
    card.Card(card.Nine, card.Diamonds),
  ]
  let actual = combination.determine(table: table, hand: hand)

  should.equal(actual, expected)
}
