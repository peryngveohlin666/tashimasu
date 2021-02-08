# a user class to store information about the state of a user in game
import random

class Player:

    def __init__(self):
        self.deck = []
        self.enemy = ("", )  # our enemy players name and websocket
        self.hand = []  # cards in our hand
        self.board = []
        self.identifier = ("" , )  # a tuple of our name and websocket

    # assign the deck to the player
    def assign_deck(self, deck):
        random.shuffle(deck)
        self.deck = deck

    # draw a card for the player, return the card
    def draw_a_card(self):
        draw = self.deck.pop(len(self.deck))
        self.hand.append(draw) # pop the last card from the deck and add it to the hand
        return draw

    # play a card for the player
    def play_a_card(self, card):
        if card in self.hand:
            self.hand.remove(card)
            self.board.append(card)

    def set_enemy(self, enemy):
        self.enemy = enemy

    def set_identifier(self, identifier):
        self.identifier = identifier

