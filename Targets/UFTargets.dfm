object FTargets: TFTargets
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'Install targets'
  ClientHeight = 235
  ClientWidth = 443
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LBerlinInst: TLabel
    Left = 188
    Top = 51
    Width = 45
    Height = 13
    Caption = 'Installed.'
    Visible = False
  end
  object LSydneyInst: TLabel
    Left = 188
    Top = 144
    Width = 45
    Height = 13
    Caption = 'Installed.'
    Visible = False
  end
  object LRioInst: TLabel
    Left = 188
    Top = 113
    Width = 45
    Height = 13
    Caption = 'Installed.'
    Visible = False
  end
  object LTokioInst: TLabel
    Left = 188
    Top = 83
    Width = 45
    Height = 13
    Caption = 'Installed.'
    Visible = False
  end
  object CBBerlin: TCheckBox
    Left = 54
    Top = 48
    Width = 105
    Height = 21
    Caption = 'Delphi 10.1 Berlin'
    TabOrder = 0
    OnClick = CBBerlinClick
  end
  object CBTokio: TCheckBox
    Left = 54
    Top = 79
    Width = 109
    Height = 21
    Caption = 'Delphi 10.2 Tokio'
    TabOrder = 1
    OnClick = CBBerlinClick
  end
  object CBRio: TCheckBox
    Left = 54
    Top = 110
    Width = 115
    Height = 21
    Caption = 'Delphi 10.3 Rio'
    TabOrder = 2
    OnClick = CBBerlinClick
  end
  object CBSydney: TCheckBox
    Left = 54
    Top = 141
    Width = 115
    Height = 21
    Caption = 'Delphi 10.4 Sydney'
    TabOrder = 3
    OnClick = CBBerlinClick
  end
  object BOK: TButton
    Left = 221
    Top = 192
    Width = 67
    Height = 29
    Caption = 'Install'
    TabOrder = 4
    OnClick = BOKClick
  end
  object BBerlinUI: TButton
    Left = 254
    Top = 47
    Width = 75
    Height = 21
    Caption = 'UnInstall'
    TabOrder = 5
    Visible = False
    OnClick = BBerlinUIClick
  end
  object BTokioUI: TButton
    Left = 254
    Top = 79
    Width = 75
    Height = 21
    Caption = 'UnInstall'
    TabOrder = 6
    Visible = False
    OnClick = BTokioUIClick
  end
  object BRioUI: TButton
    Left = 254
    Top = 109
    Width = 75
    Height = 21
    Caption = 'UnInstall'
    TabOrder = 7
    Visible = False
    OnClick = BRioUIClick
  end
  object BSydneyUI: TButton
    Left = 254
    Top = 140
    Width = 75
    Height = 21
    Caption = 'UnInstall'
    TabOrder = 8
    Visible = False
    OnClick = BSydneyUIClick
  end
  object BClose: TButton
    Left = 155
    Top = 192
    Width = 67
    Height = 29
    Caption = 'Close'
    TabOrder = 9
    OnClick = BCloseClick
  end
end
