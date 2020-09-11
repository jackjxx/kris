#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# @Date    : 2020-09-09 16:36:37
# @Author  : krisJ (kris_jiang@compal.com)
# @Link    : ${link}
# @Version : $Id$

from PyQt5.QtCore import pyqtSlot
from PyQt5.QtWidgets import QMainWindow,QApplication
from Ui_layout_demo_LayoutManage import Ui_practical


class LayoutDemo(QMainWindow, Ui_practical):
    """docstring for LayoutDemo"""
    def __init__(self, parent=None):
        super(LayoutDemo, self).__init__(parent)
        self.setupUi(self)

    @pyqtSlot()
    def on_pushButton_clicked(self):
    
        print('收益_min:',self.doubleSpinBox_returns_min.text())
        print('收益_max:',self.doubleSpinBox_returns_max.text())
        print('最大回撤_min:',self.doubleSpinBox_maxdrawdown_min.text())
        print('最大回撤_max:',self.doubleSpinBox_maxdrawdown_max.text())
        print('sharp比_min:',self.doubleSpinBox_sharp_min.text())
        print('sharp比_max:',self.doubleSpinBox_sharp_max.text())

if __name__ == '__main__':
    import sys

    app = QApplication(sys.argv)
    ui = LayoutDemo()
    ui.show()
    sys.exit(app.exec_())




