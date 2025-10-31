object fmMain: TfmMain
  Left = 575
  Top = 298
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'FPrint Launcher'
  ClientHeight = 589
  ClientWidth = 770
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnActivate = FormActivate
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 16
  object sBar: TStatusBar
    Left = 0
    Top = 570
    Width = 770
    Height = 19
    Panels = <
      item
        Text = ' Status'
        Width = 50
      end
      item
        Width = 50
      end>
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 770
    Height = 73
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object Label1: TLabel
      Left = 304
      Top = 12
      Width = 115
      Height = 16
      Caption = 'Available operations'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
    end
    object Label7: TLabel
      Left = 483
      Top = 12
      Width = 71
      Height = 16
      Caption = 'Sample files'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
    end
    object rgMode: TRadioGroup
      Left = 8
      Top = 10
      Width = 281
      Height = 55
      Caption = ' Launch mode '
      Columns = 2
      Ctl3D = True
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = []
      ItemIndex = 1
      Items.Strings = (
        'Command line'
        'Resident')
      ParentCtl3D = False
      ParentFont = False
      TabOrder = 0
      OnClick = rgModeClick
    end
    object cbxOperation: TComboBox
      Left = 304
      Top = 30
      Width = 161
      Height = 24
      Style = csDropDownList
      ItemHeight = 16
      ItemIndex = 0
      TabOrder = 1
      Text = 'Start with command line'
      OnChange = cbxOperationChange
      Items.Strings = (
        'Start with command line'
        'Copy file to folder')
    end
    object btnRun: TButton
      Left = 664
      Top = 8
      Width = 97
      Height = 25
      Caption = 'Run'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
      OnClick = btnRunClick
    end
    object cbxSamples: TComboBox
      Left = 483
      Top = 30
      Width = 161
      Height = 24
      Style = csDropDownList
      ItemHeight = 16
      TabOrder = 2
      OnChange = cbxSamplesChange
    end
    object btnAbout: TButton
      Left = 664
      Top = 40
      Width = 97
      Height = 25
      Caption = 'About'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      TabOrder = 4
      OnClick = btnAboutClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 73
    Width = 377
    Height = 497
    Align = alLeft
    BevelOuter = bvLowered
    TabOrder = 2
    object Label4: TLabel
      Left = 24
      Top = 183
      Width = 163
      Height = 16
      Caption = 'Parameter 4 : Serial number'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
    end
    object Label2: TLabel
      Left = 24
      Top = 136
      Width = 140
      Height = 16
      Caption = 'Parameter 3 : File name'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
    end
    object Label3: TLabel
      Left = 24
      Top = 89
      Width = 141
      Height = 16
      Caption = 'Parameter 1 : COM Port'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
    end
    object Label6: TLabel
      Left = 174
      Top = 89
      Width = 174
      Height = 16
      Caption = 'Parameter 2 : Bits per second'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
    end
    object Label9: TLabel
      Left = 24
      Top = 40
      Width = 116
      Height = 16
      Caption = 'Path to "FPrint.exe"'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
    end
    object lbAnswrFile: TLabel
      Left = 24
      Top = 230
      Width = 103
      Height = 16
      Caption = 'Answer file name '
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
    end
    object edSerialNumber: TEdit
      Left = 24
      Top = 202
      Width = 137
      Height = 24
      Ctl3D = True
      ParentCtl3D = False
      TabOrder = 6
    end
    object edPar3: TEdit
      Left = 24
      Top = 154
      Width = 297
      Height = 24
      Ctl3D = True
      ParentCtl3D = False
      TabOrder = 4
    end
    object cbbxPort: TComboBox
      Left = 24
      Top = 107
      Width = 137
      Height = 24
      Style = csDropDownList
      Ctl3D = False
      ItemHeight = 16
      ParentCtl3D = False
      TabOrder = 2
    end
    object cbbxSpeed: TComboBox
      Left = 172
      Top = 107
      Width = 149
      Height = 24
      Style = csDropDownList
      Ctl3D = False
      ItemHeight = 16
      ParentCtl3D = False
      TabOrder = 3
      Items.Strings = (
        '4800'
        '9600'
        '14400'
        '19200'
        '28800'
        '38400'
        '57600'
        '115200')
    end
    object bFiletoPrint: TButton
      Left = 330
      Top = 154
      Width = 24
      Height = 24
      Caption = ' ... '
      TabOrder = 5
      OnClick = bFiletoPrintClick
    end
    object MemoCmdLine: TMemo
      Left = 1
      Top = 341
      Width = 375
      Height = 155
      Align = alBottom
      TabOrder = 10
    end
    object edPath: TEdit
      Left = 24
      Top = 58
      Width = 297
      Height = 24
      Ctl3D = True
      ParentCtl3D = False
      TabOrder = 0
    end
    object bFprint: TButton
      Left = 330
      Top = 58
      Width = 24
      Height = 24
      Caption = ' ... '
      TabOrder = 1
      OnClick = bFprintClick
    end
    object chkAnswer: TCheckBox
      Left = 24
      Top = 277
      Width = 289
      Height = 17
      Caption = 'Answer In the same file'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      TabOrder = 7
      OnClick = chkAnswerClick
    end
    object edAnswFileName: TEdit
      Left = 24
      Top = 249
      Width = 297
      Height = 24
      Ctl3D = True
      ParentCtl3D = False
      TabOrder = 8
    end
    object Panel4: TPanel
      Left = 1
      Top = 1
      Width = 375
      Height = 24
      Align = alTop
      TabOrder = 11
      object Label12: TLabel
        Left = 7
        Top = 3
        Width = 152
        Height = 16
        Caption = 'Command line parameters'
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = 8936192
        Font.Height = -13
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
      end
    end
    object bAnswerfile: TButton
      Left = 330
      Top = 248
      Width = 24
      Height = 24
      Caption = ' ... '
      TabOrder = 9
      OnClick = bAnswerfileClick
    end
  end
  object Panel3: TPanel
    Left = 377
    Top = 73
    Width = 393
    Height = 497
    Align = alClient
    BevelOuter = bvLowered
    TabOrder = 3
    object Label5: TLabel
      Left = 32
      Top = 40
      Width = 124
      Height = 16
      Caption = 'Executable file folder:'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
    end
    object Label8: TLabel
      Left = 32
      Top = 89
      Width = 72
      Height = 16
      Caption = 'File to copy:'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
    end
    object Label10: TLabel
      Left = 32
      Top = 169
      Width = 102
      Height = 16
      Caption = 'Answer file folder:'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
    end
    object lbAnswerFileName: TLabel
      Left = 32
      Top = 263
      Width = 107
      Height = 16
      Caption = 'Answer file name: '
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
    end
    object Label11: TLabel
      Left = 32
      Top = 216
      Width = 113
      Height = 16
      Caption = 'Answer file options:'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
    end
    object edCopyFolder: TEdit
      Left = 32
      Top = 58
      Width = 297
      Height = 24
      Ctl3D = True
      ParentCtl3D = False
      TabOrder = 0
    end
    object bExecFolder: TButton
      Left = 345
      Top = 58
      Width = 24
      Height = 24
      Caption = ' ... '
      TabOrder = 1
      OnClick = bExecFolderClick
    end
    object edFile: TEdit
      Left = 32
      Top = 107
      Width = 297
      Height = 24
      Ctl3D = True
      ParentCtl3D = False
      TabOrder = 2
    end
    object bFileToCopy: TButton
      Left = 345
      Top = 107
      Width = 24
      Height = 24
      Caption = ' ... '
      TabOrder = 3
      OnClick = bFileToCopyClick
    end
    object MemoResident: TMemo
      Left = 1
      Top = 341
      Width = 391
      Height = 155
      Align = alBottom
      TabOrder = 8
    end
    object edAnswer: TEdit
      Left = 32
      Top = 187
      Width = 297
      Height = 24
      Ctl3D = True
      ParentCtl3D = False
      TabOrder = 4
    end
    object bAnswerFolder: TButton
      Left = 345
      Top = 187
      Width = 24
      Height = 24
      Caption = ' ... '
      TabOrder = 5
      OnClick = bAnswerFolderClick
    end
    object edAnswerFileName: TEdit
      Left = 32
      Top = 282
      Width = 297
      Height = 24
      Ctl3D = True
      ParentCtl3D = False
      TabOrder = 7
    end
    object cbxAnswer: TComboBox
      Left = 32
      Top = 235
      Width = 297
      Height = 24
      Style = csDropDownList
      Ctl3D = False
      ItemHeight = 16
      ItemIndex = 0
      ParentCtl3D = False
      TabOrder = 6
      Text = 'Constant name'
      OnChange = cbxAnswerChange
      Items.Strings = (
        'Constant name'
        'DateTime name')
    end
    object Panel5: TPanel
      Left = 1
      Top = 1
      Width = 391
      Height = 24
      Align = alTop
      TabOrder = 9
      object Label13: TLabel
        Left = 7
        Top = 3
        Width = 156
        Height = 16
        Caption = 'Resident mode parameters'
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = 8936192
        Font.Height = -13
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
      end
    end
    object chbxRepeatCopy: TCheckBox
      Left = 32
      Top = 142
      Width = 121
      Height = 17
      Caption = 'Repeat copy:'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      TabOrder = 10
      OnClick = chkAnswerClick
    end
    object edRepeatCount: TEdit
      Left = 248
      Top = 139
      Width = 81
      Height = 24
      Ctl3D = True
      ParentCtl3D = False
      TabOrder = 11
      Text = '10'
      OnChange = edRepeatCountChange
    end
  end
  object odlgAnswerFile: TOpenDialog
    DefaultExt = 'txt'
    Filter = 'Text Files|*.txt|Cash Files|*.inp'
    Left = 264
    Top = 392
  end
  object odlgFPrintExe: TOpenDialog
    DefaultExt = 'exe'
    Filter = 'Exe Files|*.exe'
    Left = 192
    Top = 392
  end
  object odlgFileToCopy: TOpenDialog
    DefaultExt = 'txt'
    Filter = 'Text Files|*.txt|Cash Files|*.inp'
    Left = 304
    Top = 392
  end
  object odlgFileToPrint: TOpenDialog
    DefaultExt = 'txt'
    Filter = 'Text Files|*.txt|Cash Files|*.inp'
    Left = 229
    Top = 392
  end
  object ApplicationEvents1: TApplicationEvents
    OnException = ApplicationEvents1Exception
    Left = 152
    Top = 392
  end
  object tmrRepeatCopy: TTimer
    Enabled = False
    OnTimer = tmrRepeatCopyTimer
    Left = 641
    Top = 97
  end
end
