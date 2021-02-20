# a user class to store information about the state of a user in game
import random

class Player:

    def __init__(self):
        self.mana = 0
        self.current_mana = 0
        self.deck = []
        self.enemy = None  # our enemy player object
        self.hand = []  # cards in our hand
        self.board = []
        self.attacked = [False, False, False, False, False]
        self.identifier = ("" , )  # a tuple of our name and websocket

    # assign the deck to the player
    def assign_deck(self, deck):
        random.shuffle(deck)
        self.deck = deck

    # draw a card for the player, return the card
    def draw_a_card(self):
        draw = self.deck.pop(len(self.deck) -1)
        self.hand.append(draw) # pop the last card from the deck and add it to the hand
        return draw

    # play a card for the player
    def play_a_card(self, card):
        if card in self.hand:
            cost = self.get_cost_value(card)
            if cost <= self.current_mana:
                self.hand.remove(card)
                self.board.append(card)
                self.current_mana -= cost

    def set_enemy(self, enemy):
        self.enemy = enemy

    def set_identifier(self, identifier):
        self.identifier = identifier

    def attack(self, attacking_card, defending_card):
        if attacking_card in self.board and defending_card in self.enemy.board:
            attacking_card_defense = self.get_defense_value(attacking_card)
            defending_card_defense = self.get_defense_value(defending_card)
            if attacking_card_defense >= defending_card_defense:
                self.enemy.kill_a_card(defending_card)
            if attacking_card_defense <= defending_card_defense:
                self.kill_a_card(attacking_card)

    def get_defense_value(self, card_name):
        return int(card_name.split(".")[0].split("_")[3])

    def get_cost_value(self, card_name):
        return int(card_name.split(".")[0].split("_")[5])

    def get_attack_value(self, card_name):
        return int(card_name.split(".")[0].split("_")[4])

    def kill_a_card(self, card_name):
        if card_name in self.board:
            self.board.remove(card_name)


