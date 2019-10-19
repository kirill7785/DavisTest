object FormPatCFF: TFormPatCFF
  Left = 343
  Top = 172
  Caption = 'Pattern Custom Field Function'
  ClientHeight = 278
  ClientWidth = 311
  Color = clMoneyGreen
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object lbl1: TLabel
    Left = 8
    Top = 16
    Width = 36
    Height = 13
    Caption = 'Pattern'
  end
  object cbbpattern: TComboBox
    Left = 56
    Top = 8
    Width = 249
    Height = 21
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 0
    Text = 'none'
    OnChange = cbbpatternChange
    Items.Strings = (
      'none'
      'silicon'
      'diamond'
      'GaAs')
  end
  object pnlsilicon: TPanel
    Left = 8
    Top = 40
    Width = 297
    Height = 201
    Color = clMoneyGreen
    TabOrder = 1
    Visible = False
    object lbl2: TLabel
      Left = 16
      Top = 16
      Width = 217
      Height = 13
      Caption = 'dimensionless velocity saturation of electrons'
    end
    object lblvsat: TLabel
      Left = 16
      Top = 40
      Width = 58
      Height = 13
      Caption = 'V saturation'
    end
    object lbl3: TLabel
      Left = 16
      Top = 72
      Width = 178
      Height = 13
      Caption = 'dimensionless electron mobility at low'
    end
    object lbl4: TLabel
      Left = 16
      Top = 96
      Width = 62
      Height = 13
      Caption = 'electric fields'
    end
    object lblelectronmobility: TLabel
      Left = 16
      Top = 120
      Width = 78
      Height = 13
      Caption = 'electron mobility'
    end
    object edtvsat: TEdit
      Left = 88
      Top = 32
      Width = 121
      Height = 21
      TabOrder = 0
      Text = '0.1'
    end
    object edtelectronmobility: TEdit
      Left = 104
      Top = 112
      Width = 121
      Height = 21
      TabOrder = 1
      Text = '0.07'
    end
    object btninfo: TButton
      Left = 16
      Top = 152
      Width = 75
      Height = 25
      Caption = 'info'
      TabOrder = 2
      OnClick = btninfoClick
    end
  end
  object btncontinue: TButton
    Left = 192
    Top = 248
    Width = 75
    Height = 25
    Caption = 'continue'
    TabOrder = 2
    OnClick = btncontinueClick
  end
end
