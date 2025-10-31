object fmAbout: TfmAbout
  Left = 1275
  Top = 427
  BorderIcons = []
  BorderStyle = bsToolWindow
  Caption = 'About FP Launcher'
  ClientHeight = 149
  ClientWidth = 273
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lbVer: TLabel
    Left = 8
    Top = 8
    Width = 68
    Height = 15
    Caption = 'Version : 4.0'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clBlack
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    Transparent = True
  end
  object Label6: TLabel
    Left = 8
    Top = 47
    Width = 103
    Height = 26
    Caption = 'E-mail :   cvetanov@datecs.bg'
    WordWrap = True
  end
  object Label2: TLabel
    Left = 8
    Top = 105
    Width = 106
    Height = 30
    Caption = 'Copyright (c) 2007  Datecs Ltd.'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clBlack
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    Transparent = True
    WordWrap = True
  end
  object Bevel1: TBevel
    Left = 8
    Top = 84
    Width = 253
    Height = 14
    Shape = bsBottomLine
  end
  object Label1: TLabel
    Left = 160
    Top = 32
    Width = 91
    Height = 15
    Caption = 'Please RTFM !!!'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = [fsBold, fsItalic]
    ParentFont = False
  end
  object bbtnExit: TBitBtn
    Left = 160
    Top = 109
    Width = 101
    Height = 25
    Caption = '&Close'
    TabOrder = 0
    OnClick = bbtnExitClick
  end
  object Button7: TButton
    Left = 160
    Top = 53
    Width = 97
    Height = 25
    Caption = 'Help'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnClick = Button7Click
  end
end
