#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# @Date    : 2020-09-09 10:28:42
# @Author  : krisJ (kris_jiang@compal.com)
# @Link    : ${link}
# @Version : $Id$

import sys
from PyQt5.QtWidgets import QApplication,QMainWindow
from form import *

class MyMainWindow(QMainWindow,Ui_firstMainWin):
    """docstring for MyMainWindow"""
    def __init__(self, parent=None):
        super(MyMainWindow, self).__init__(parent)
        self.setupUi(self)

if __name__ == '__main__':
    app = QApplication(sys.argv)
    myWin = MyMainWindow()
    myWin.show()
    sys.exit(app.exec_())

