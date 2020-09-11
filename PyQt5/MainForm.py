# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file '/Users/kris/Desktop/PyQt5/MainForm.ui'
#
# Created by: PyQt5 UI code generator 5.15.0
#
# WARNING: Any manual changes made to this file will be lost when pyuic5 is
# run again.  Do not edit this file unless you know what you are doing.


from PyQt5 import QtCore, QtGui, QtWidgets


class Ui_MainWindow(object):
    def setupUi(self, MainWindow):
        MainWindow.setObjectName("MainWindow")
        MainWindow.resize(826, 504)
        self.centralwidget = QtWidgets.QWidget(MainWindow)
        self.centralwidget.setObjectName("centralwidget")
        MainWindow.setCentralWidget(self.centralwidget)
        self.statusBar = QtWidgets.QStatusBar(MainWindow)
        self.statusBar.setObjectName("statusBar")
        MainWindow.setStatusBar(self.statusBar)
        self.menuBar = QtWidgets.QMenuBar(MainWindow)
        self.menuBar.setGeometry(QtCore.QRect(0, 0, 826, 22))
        self.menuBar.setObjectName("menuBar")
        self.menuOpen = QtWidgets.QMenu(self.menuBar)
        self.menuOpen.setObjectName("menuOpen")
        self.menuNew = QtWidgets.QMenu(self.menuBar)
        self.menuNew.setObjectName("menuNew")
        MainWindow.setMenuBar(self.menuBar)
        self.toolBar = QtWidgets.QToolBar(MainWindow)
        self.toolBar.setObjectName("toolBar")
        MainWindow.addToolBar(QtCore.Qt.TopToolBarArea, self.toolBar)
        self.fileOpemAction = QtWidgets.QAction(MainWindow)
        self.fileOpemAction.setObjectName("fileOpemAction")
        self.fileNewAction = QtWidgets.QAction(MainWindow)
        self.fileNewAction.setObjectName("fileNewAction")
        self.fileCloseAction = QtWidgets.QAction(MainWindow)
        self.fileCloseAction.setObjectName("fileCloseAction")
        self.actionaddWinAction = QtWidgets.QAction(MainWindow)
        self.actionaddWinAction.setObjectName("actionaddWinAction")
        self.menuOpen.addAction(self.fileOpemAction)
        self.menuOpen.addAction(self.fileNewAction)
        self.menuOpen.addAction(self.fileCloseAction)
        self.menuBar.addAction(self.menuOpen.menuAction())
        self.menuBar.addAction(self.menuNew.menuAction())
        self.toolBar.addAction(self.actionaddWinAction)
        self.toolBar.addSeparator()

        self.retranslateUi(MainWindow)
        QtCore.QMetaObject.connectSlotsByName(MainWindow)

    def retranslateUi(self, MainWindow):
        _translate = QtCore.QCoreApplication.translate
        MainWindow.setWindowTitle(_translate("MainWindow", "MainWindow"))
        self.menuOpen.setTitle(_translate("MainWindow", "File"))
        self.menuNew.setTitle(_translate("MainWindow", "Edit"))
        self.toolBar.setWindowTitle(_translate("MainWindow", "toolBar"))
        self.fileOpemAction.setText(_translate("MainWindow", "Open"))
        self.fileOpemAction.setToolTip(_translate("MainWindow", "打开"))
        self.fileOpemAction.setShortcut(_translate("MainWindow", "Alt+O"))
        self.fileNewAction.setText(_translate("MainWindow", "New"))
        self.fileNewAction.setShortcut(_translate("MainWindow", "Alt+N"))
        self.fileCloseAction.setText(_translate("MainWindow", "Close"))
        self.fileCloseAction.setShortcut(_translate("MainWindow", "Alt+C"))
        self.actionaddWinAction.setText(_translate("MainWindow", "addWinAction"))
        self.actionaddWinAction.setToolTip(_translate("MainWindow", "添加窗体"))