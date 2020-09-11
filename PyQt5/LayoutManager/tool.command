#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# @Date    : 2020-09-08 15:17:24
# @Author  : krisJ (kris_jiang@compal.com)
# @Link    : ${link}
# @Version : $Id$

import os
import os.path

current_path = os.path.dirname(__file__)


def listUiFile():
    ui_list = []
    files = os.listdir(current_path)

    for filename in files:
        if os.path.splitext(filename)[1] == '.ui':
            ui_list.append(filename)
    return ui_list

def transPyFile(filename):
    return os.path.splitext(filename)[0] + '.py'

def runMain():
    ui_file_list = listUiFile()
    for uifile in ui_file_list:
        pyfile = transPyFile(uifile)
        cmd = 'pyuic5 -o {pyfile} {uifile}'.format(pyfile=current_path+"/"+pyfile,uifile=current_path+"/"+uifile)
        os.system(cmd)

if __name__ == '__main__':
    runMain()



