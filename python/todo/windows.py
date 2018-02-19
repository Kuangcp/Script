# 仿制todo程序

import tkinter as tk
from tkinter import *

class App(tk.Frame):
    
    def __init__(self, master=None):
        super().__init__(master)
        self.mb = Menubutton(self, text='condiments',
                             relief=RAISED)
        self.mb.pack()

        self.mb.menu = Menu(self.mb, tearoff=0)
        self.mb['menu'] = self.mb.menu

        self.mayoVar  = IntVar()
        self.ketchVar = IntVar()
        self.mb.menu.add_checkbutton(label='mayo',
            variable=self.mayoVar)
        self.mb.menu.add_checkbutton(label='ketchup',
            variable=self.ketchVar)
        self.pack()
    
    def background(self):
        
        C = Canvas(self, bg="white", width=450,  height=400)
        # coord = 10, 50, 240, 210
        # arc = C.create_arc(coord, start=0, extent=150, fill="red")
        C.pack()
    def menu_list(self):
        pass
        # button1 = Menubutton('f')
        # m = Menu(button1)
        # m.pack()



        
root = App()

root.background()
root.menu_list()

root.master.title("Todo List")
root.master.maxsize(400, 600)
root.mainloop()

