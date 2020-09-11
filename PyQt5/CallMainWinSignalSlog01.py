#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# @Date    : 2020-09-10 09:48:30
# @Author  : krisJ (kris_jiang@compal.com)
# @Link    : ${link}
# @Version : $Id$
import sys
from PyQt5.QtWidgets import QMainWindow,QApplication
from MainWinSignalSlog01 import Ui_Form


class CloseDemo(QMainWindow, Ui_Form):
    """docstring for LayoutDemo"""
    def __init__(self, parent=None):
        super(CloseDemo, self).__init__(parent)
        self.setupUi(self)



if __name__ == '__main__':
    app = QApplication(sys.argv)
    ui = CloseDemo()
    ui.show()
    sys.exit(app.exec_())




