#!/usr/bin/env python3
import gi
gi.require_version('Wnck', '3.0')
gi.require_version('Gtk', '3.0')
from gi.repository import Wnck, Gtk

import time

class WeChatWindowMonitor():
    def __init__(self):
        self.screen = Wnck.Screen.get_default()
        self.screen.force_update()

        self.wechat_window_name = "WeChat"

        self.screen.connect("active_window_changed", self.active_window_changed)

    def active_window_changed(self, screen, window):
        active_window = self.screen.get_active_window()
        # debug 找到微信应用
        print(active_window.get_name()) 
        if active_window and active_window.get_name() != self.wechat_window_name:
            for win in self.screen.get_windows():
                if win and win.get_name() == self.wechat_window_name:
                    win.minimize()
                    # win.close(time.time())

    def run(self):
        Gtk.main()

WeChatWindowMonitor().run()
