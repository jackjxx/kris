#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Date    : 2020-09-10 14:14:54
# @Author  : krisJ (kris_jiang@compal.com)
# @Link    : ${link}
# @Version : $Id$

from PyQt5.QtWidgets import QApplication, QPushButton, QColorDialog, QWidget
from PyQt5.QtCore import Qt
from PyQt5.QtGui import QColor
import sys

class ColorDialog(QWidget):
    """docstring for ColorDialog"""
    def __init__(self):
        super(ColorDialog, self).__init__()
        color = QColor(0,0,0)
        self.setGeometry(300,300,350,280)
        self.setWindowTitle('颜色选择')
        self.button = QPushButton('Dialog',self)
        self.button.setFocusPolicy(Qt.NoFocus)
        self.button.move(20,20)
        self.button.clicked.connect(self.showDialog)
        self.setFocus()
        self.widget =QWidget(self)
        self.widget.setStyleSheet('QtWidget{backgroud-color:%s}'%color.name())
        self.widget.setGeometry(130,22,100,100)

    def showDialog(self):
        col = QColorDialog.getColor()
        if col.isValid():
            self.widget.setStyleSheet('QtWidget{backgroud-color:%s}'%col.name())


if __name__ == '__main__':
    app = QApplication(sys.argv)
    qb = ColorDialog()
    qb.show()
    sys.exit(app.exec_())
