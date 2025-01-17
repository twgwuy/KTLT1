import dearpygui.dearpygui as dpg
import random
from pics import *

dpg.create_context()

class Hangman:
    def __init__(self, tag):
        file = tag + ".txt"
        with open(file, 'r') as f:  # mở file chứa từ và random từ
            text = f.readlines()
            self.pick: str = random.choice(text).upper()[:-1]
        self.tries = 0  # số lần sai
        self.ans = self.space()  # hiển thị tình hình đoán từ
        self.lst_guess = []  # danh sách từ đã dùng

    def space(self):
        return ['_'] * len(self.pick)

    def game_play(self):
        if self.tries < 9:
            dpg.set_value("Letter", ''.join(self.ans))
            letter = str(dpg.get_value("Input text"))
            dpg.set_value("Input text", '')  # TỰ ĐỘNG XÓA SAU KHI NHẬP

            if len(letter) > 1 or letter.isalpha() is False:
                dpg.set_value("Announcement", "Invalid. Please choose a letter.")
            elif letter in self.lst_guess:
                dpg.set_value("Announcement", "You have guessed this one. Please choose another letter.")
            else:
                self.lst_guess.append(letter)
                dpg.set_value("Have guessed", ' '.join(self.lst_guess))  # IN RA KÍ TỰ ĐÃ NHẬP
                count = 0
                for i in range(len(self.pick)):
                    if letter == self.pick[i]:
                        count += 1
                        self.ans[i] = self.pick[i]
                if count > 0:
                    dpg.set_value("Announcement", f"The word has {count} letter(s) {letter}.")
                    dpg.set_value("Letter", ''.join(self.ans))
                else:
                    self.tries += 1
                    dpg.set_value("Announcement", f"Sorry, wrong character! You have {10 - self.tries} time(s) left.")
                self.pic()
                if '_' not in self.ans:
                    end_game()
                    self.lst_guess.clear()
                    dpg.set_value("End", f"Congratulation! The word was {self.pick.upper()}.")

        else:
            self.tries = 0
            end_game()
            dpg.set_value("End", f"You lost the game! The word was {self.pick.upper()}.")

    def pic(self):
        if self.tries != 0:
            dpg.set_value("HangMan", HANGMAN_PICS[self.tries - 1])  # IN HÌNH HANGMAN

    def full_word(self):
        fullword = dpg.get_value("Full word")
        dpg.set_value("Full word", "")  # TỰ ĐỘNG XÓA SAU KHI NHẬP

        if self.tries < 9:
            if len(fullword) != len(self.pick) or fullword.isalpha() is False:
                dpg.set_value("Announcement", "Invalid. Please type a word (that has a same length).")
            elif fullword == self.pick:
                self.tries = 0
                end_game()
                dpg.set_value("End", f"Congratulation! The word was {self.pick.upper()}.")
            else:
                self.tries += 1
                dpg.set_value("Announcement", f"Sorry, wrong guess! You have {10 - self.tries} time(s) left!")
                dpg.set_value("HangMan", HANGMAN_PICS[self.tries - 1])  # IN HÌNH
        else:
            self.tries = 0
            end_game()
            dpg.set_value("End", f"You lost the game! The word was {self.pick.upper()}.")


def popup_window(tag):
    file = tag + ".txt"
    with open(file, 'r') as f:
        text = f.read()
    f.close()

    with dpg.window(tag="popup_menu", width=400, height=500, no_collapse=True, no_resize=True, no_title_bar=True,
                    modal=True, pos=(120, 160)):
        dpg.add_text(tag="window", default_value=text, wrap=380, pos=(15, 10))
        dpg.add_button(tag="OK", label="OK", width=100, pos=(150, 460), callback=ok_btn)

        dpg.bind_item_font("window", "text_font")
        dpg.bind_item_font("OK", "menu_font")


def choose_topic():
    with dpg.window(width=660, height=800, no_resize=True, no_collapse=True, no_move=True, no_title_bar=True):
        dpg.disable_item("Start")  # VÔ HIỆU HÓA WINDOW

        dpg.add_text(default_value="CHOOSE THE TOPIC", tag="Topic", pos=(235, 320))

        dpg.add_button(label="Animal", tag="animal", width=655, pos=(0, 370), callback=play)
        dpg.add_button(label="Food", tag="food", width=655, pos=(0, 420), callback=play)

        dpg.bind_item_font("Topic", "text_font")
        dpg.bind_item_font("animal", "text_font")
        dpg.bind_item_font("food", "text_font")


def play(tag):
    with dpg.window(width=660, height=800, no_resize=True, no_collapse=True, no_move=True, no_title_bar=True,
                    tag="Play window"):
        word = Hangman(tag)

        dpg.add_text(default_value="", tag="HangMan", pos=(30, 20))

        dpg.add_text(default_value=f"Topic: {tag.upper()}", tag="Topic chosen", pos=(230, 40))

        dpg.add_text(default_value="Type here to guess:", tag="Guessing", pos=(5, 450))
        dpg.add_input_text(tag="Input text", width=655, pos=(220, 450), on_enter=True, uppercase=True,
                           callback=word.game_play)

        dpg.add_text(default_value="Or you can guess the FULL WORD:", tag="Full word text", pos=(5, 500))
        dpg.add_input_text(tag="Full word", width=655, pos=(350, 500), on_enter=True, uppercase=True,
                           callback=word.full_word)

        dpg.add_text(default_value="Choose a letter!", tag="Announcement", pos=(5, 550))
        dpg.add_text(default_value=''.join(word.ans), tag="Letter", pos=(400, 150))
        dpg.add_text(default_value=f"(There are {len(word.pick)} letters)", tag="Count", pos=(400, 230))

        dpg.add_text(default_value="Letters have been guessed:", tag="Guessed letters", pos=(5, 600))
        dpg.add_text(default_value="", tag="Have guessed", pos=(300, 600))

        dpg.bind_item_font("HangMan", "hangman_font")
        dpg.bind_item_font("Full word text", "text_font")
        dpg.bind_item_font("Full word", "text_font")
        dpg.bind_item_font("Announcement", "text_font")
        dpg.bind_item_font("Letter", "blank_font")
        dpg.bind_item_font("Count", "text_font")
        dpg.bind_item_font("Topic chosen", "topic_font")
        dpg.bind_item_font("Guessing", "text_font")
        dpg.bind_item_font("Input text", "text_font")
        dpg.bind_item_font("Guessed letters", "text_font")
        dpg.bind_item_font("Have guessed", "text_font")


def end_game():
    with dpg.window(tag="End game", width=660, height=800, no_resize=True, no_collapse=True, no_move=True,
                    no_title_bar=True):
        dpg.delete_item("Play window")  # XÓA "PLAY WINDOW"

        dpg.add_text(default_value="", tag="End", pos=(140, 300))
        dpg.bind_item_font("End", "text_font")

        dpg.add_button(label="Play again", tag="Play again", width=655, pos=(0, 370), callback=play_again)
        dpg.bind_item_font("Play again", "text_font")

        dpg.add_button(label="Exit", tag="exitgame", width=655, pos=(0, 420), callback=ask_exit_window)
        dpg.bind_item_font("exitgame", "text_font")


def play_again():
    dpg.delete_item("End game")  # XÓA "END GAME WINDOW"
    dpg.enable_item("Start")  # KHỞI TẠO LẠI TRÒ CHƠI (SAU KHI BẤM NÚT START)

def exit_game():
    exit()


def ask_exit_window():
    with dpg.window(tag="Popup window", width=400, height=200, no_collapse=True, no_resize=True, no_title_bar=True,
                    modal=True, pos=(120, 220)):
        dpg.add_text(tag="Notification", default_value="Do you want to quit game?", pos=(60, 80))
        dpg.add_button(tag="OK btn", label="OK", width=100, pos=(90, 160), callback=exit_game)
        dpg.add_button(tag="Cancel btn", label="Cancel", width=100, pos=(210, 160), callback=cancel_btn)

        dpg.bind_item_font("Popup window", "menu_font")
        dpg.bind_item_font("Notification", "text_font")
        dpg.bind_item_font("OK btn", "menu_font")
        dpg.bind_item_font("Cancel btn", "menu_font")


def cancel_btn():  # DÙNG CHO POPUP WINDOW
    dpg.delete_item("Popup window")


def ok_btn():  # DÙNG CHO POPUP Ở MAIN MENU
    dpg.delete_item("popup_menu")


# TẠO FONT
with dpg.font_registry():
    dpg.add_font("ROBOTOMONO-VARIABLEFONT_WGHT.ttf", 20, tag="menu_font")
    dpg.add_font("ROBOTOMONO-VARIABLEFONT_WGHT.ttf", 25, tag="text_font")
    dpg.add_font("ROBOTOMONO-VARIABLEFONT_WGHT.ttf", 35, tag="topic_font")
    dpg.add_font("ROBOTOMONO-VARIABLEFONT_WGHT.ttf", 70, tag="hangman_font")
    dpg.add_font("ROBOTOMONO-VARIABLEFONT_WGHT.ttf", 60, tag="blank_font")

with dpg.window(tag="MainWindow", width=660, height=750) as mainWindow:
    dpg.add_text(tag="Hangman", default_value="HANGMAN", pos=(220, 230))
    dpg.add_button(tag="Start", label="Start", width=660, pos=(0, 350), callback=choose_topic)
    dpg.add_button(tag="how_to_play", label="How to play", width=660, pos=(0, 400), callback=popup_window)
    dpg.add_button(tag="about", label="About", width=660, pos=(0, 450), callback=popup_window)
    dpg.add_button(tag="Exit", label="Exit", width=660, pos=(0, 500), callback=ask_exit_window)

    dpg.bind_item_font("Hangman", "hangman_font")
    dpg.bind_item_font("Start", "text_font")
    dpg.bind_item_font("how_to_play", "text_font")
    dpg.bind_item_font("about", "text_font")
    dpg.bind_item_font("Exit", "text_font")

dpg.create_viewport(title="HANGMAN", width=660, height=750, x_pos=350, y_pos=0)
dpg.setup_dearpygui()
dpg.show_viewport()
dpg.set_primary_window("MainWindow", True)
dpg.start_dearpygui()
dpg.destroy_context()
