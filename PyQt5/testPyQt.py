#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# @Date    : 2020-09-08 13:04:12
# @Author  : krisJ (kris_jiang@compal.com)
# @Link    : ${link}
# @Version : $Id$

import sys
from PyQt5 import QtWidgets, QtCore

app = QtWidgets.QApplication(sys.argv)
widget = QtWidgets.QWidget()
widget.resize(360,360)
widget.setWindowTitle("Hello, PyQt5")
widget.show()
sys.exit(app.exec_())
