object fmMain: TfmMain
  Left = 552
  Top = 195
  BorderStyle = bsToolWindow
  Caption = 'CheckConnection'
  ClientHeight = 224
  ClientWidth = 370
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
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 370
    Height = 160
    Align = alClient
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    object Label1: TLabel
      Left = 57
      Top = 16
      Width = 55
      Height = 15
      Caption = 'COM Port:'
    end
    object Label2: TLabel
      Left = 54
      Top = 48
      Width = 58
      Height = 15
      Caption = 'BaudRate:'
    end
    object Label3: TLabel
      Left = 23
      Top = 80
      Width = 89
      Height = 15
      Caption = 'Logical number:'
    end
    object Label4: TLabel
      Left = 72
      Top = 112
      Width = 40
      Height = 15
      Caption = 'Device:'
    end
    object cbxCOMPort: TComboBox
      Left = 120
      Top = 12
      Width = 121
      Height = 23
      Style = csDropDownList
      ItemHeight = 15
      TabOrder = 0
      OnChange = cbxCOMPortChange
    end
    object cbxBaudRate: TComboBox
      Left = 120
      Top = 44
      Width = 121
      Height = 23
      Style = csDropDownList
      ItemHeight = 15
      TabOrder = 1
      OnChange = cbxCOMPortChange
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
    object speLogicalNum: TSpinEdit
      Left = 120
      Top = 75
      Width = 121
      Height = 24
      MaxValue = 200
      MinValue = 1
      TabOrder = 2
      Value = 1
    end
    object cbxDevice: TComboBox
      Left = 120
      Top = 108
      Width = 201
      Height = 23
      Style = csDropDownList
      ItemHeight = 15
      TabOrder = 3
      OnChange = cbxDeviceChange
      Items.Strings = (
        '----------------ECR'#39's-------------------'
        'DP50'
        'DP50D'
        'DP50-Ke'
        'DP50-Ro'
        'DP50D-Ro'
        'ER250F'
        'MP50'
        'MP55'
        'MP55-Arm'
        'MP55M'
        'MP55B'
        'MP55M-Yu'
        'MP55-Ro'
        'MP55L-Ro'
        'MP55LD-Ro'
        'MP56-Li'
        'MP500'
        'MP500-La'
        'MP500T'
        'MP500TR'
        'MP500TR-Yu'
        'MP500TR-La'
        'MP5000'
        'MP5000M'
        'MP5000-Est'
        'MP5000-Mo'
        'MP5000-Ro'
        'DP500'
        '------------Fiscal printers----------------'
        'FP300'
        'FP300-Ke'
        'FP3530'
        'FP550F-40'
        'FP550F'
        'FP550F-Mo'
        'FP550F-Ro'
        'FP550F-Yu'
        'FP1000'
        'FP550-Bd'
        'FP300-Kz'
        'FP1000-Kz'
        'FP550-Kz'
        'FP60-Ethiopia'
        '------ KL devices - Bulgaria ----------'
        'DP 05 KL'
        'DP 15 KL'
        'DP 25 KL'
        'DP 35 KL'
        'DP 50 KL'
        'DP 55 KL'
        'DP 500 KL'
        'MP 55 KL'
        'FP 60 KL'
        'FP 300 KL'
        'FP 1000 KL'
        'FP 2000 KL')
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 160
    Width = 370
    Height = 64
    Align = alBottom
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    object lbSerial: TLabel
      Left = 156
      Top = 9
      Width = 3
      Height = 15
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
    end
    object Label5: TLabel
      Left = 63
      Top = 9
      Width = 81
      Height = 15
      Caption = 'Serial number:'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
    end
    object btnCheck: TButton
      Left = 64
      Top = 32
      Width = 217
      Height = 25
      Caption = 'Check for connection'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnClick = btnCheckClick
    end
  end
end
