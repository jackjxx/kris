#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# @Date    : 2020-09-08 13:57:27
# @Author  : krisJ (kris_jiang@compal.com)
# @Link    : ${link}
# @Version : $Id$

import sys
import os
from PyQt5.QtWidgets import QWidget

HOME = os.path.expanduser('~')
out =sys.stdout
sys.stdout = open(HOME+r"/Desktop/PyQt5/QWidget.txt","w")
help(QWidget)
sys.stdout.close()
sys.stdout = out