import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk

from window import MyWindow


win = MyWindow()
# 关闭的设置
win.connect("delete-event", Gtk.main_quit)
# 显示窗体
win.show_all()
Gtk.main()