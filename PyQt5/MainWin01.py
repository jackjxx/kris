# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file '/Users/kris/Desktop/PyQt5/LayoutManager/MainWin01.ui'
#
# Created by: PyQt5 UI code generator 5.15.0
#
# WARNING: Any manual changes made to this file will be lost when pyuic5 is
# run again.  Do not edit this file unless you know what you are doing.


from PyQt5 import QtCore, QtGui, QtWidgets


class Ui_mainwin01(object):
    def setupUi(self, mainwin01):
        mainwin01.setObjectName("mainwin01")
        mainwin01.resize(511, 443)
        self.widget = QtWidgets.QWidget(mainwin01)
        self.widget.setGeometry(QtCore.QRect(50, 40, 273, 30))
        self.widget.setObjectName("widget")
        self.horizontalLayout = QtWidgets.QHBoxLayout(self.widget)
        self.horizontalLayout.setContentsMargins(0, 0, 0, 0)
        self.horizontalLayout.setObjectName("horizontalLayout")
        self.lineEdit = QtWidgets.QLineEdit(self.widget)
        self.lineEdit.setObjectName("lineEdit")
        self.horizontalLayout.addWidget(self.lineEdit)
        self.pushButton = QtWidgets.QPushButton(self.widget)
        self.pushButton.setObjectName("pushButton")
        self.horizontalLayout.addWidget(self.pushButton)

        self.retranslateUi(mainwin01)
        QtCore.QMetaObject.connectSlotsByName(mainwin01)

    def retranslateUi(self, mainwin01):
        _translate = QtCore.QCoreApplication.translate
        mainwin01.setWindowTitle(_translate("mainwin01", "mainwin01"))
        self.pushButton.setText(_translate("mainwin01", "确定"))