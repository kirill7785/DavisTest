object FormCustomFieldFunction: TFormCustomFieldFunction
  Left = 312
  Top = 155
  Caption = 'Custom Field Function Calculator'
  ClientHeight = 193
  ClientWidth = 231
  Color = clMoneyGreen
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object lblcount: TLabel
    Left = 16
    Top = 16
    Width = 145
    Height = 13
    Caption = 'Number Custom Field Function'
  end
  object cbbcount: TComboBox
    Left = 168
    Top = 8
    Width = 49
    Height = 21
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 0
    Text = '0'
    OnChange = cbbcountChange
    Items.Strings = (
      '0'
      '1'
      '2'
      '3'
      '4'
      '5'
      '6'
      '7'
      '8'
      '9'
      '10')
  end
  object pnlcff: TPanel
    Left = 8
    Top = 40
    Width = 217
    Height = 153
    Color = clMoneyGreen
    TabOrder = 1
    Visible = False
    object lbl1: TLabel
      Left = 16
      Top = 16
      Width = 137
      Height = 13
      Caption = 'Select Custom Field Function'
    end
    object lbl2: TLabel
      Left = 16
      Top = 56
      Width = 45
      Height = 13
      Caption = 'Definition'
    end
    object lblname: TLabel
      Left = 16
      Top = 96
      Width = 26
      Height = 13
      Caption = 'name'
    end
    object cbbindex: TComboBox
      Left = 160
      Top = 8
      Width = 49
      Height = 21
      ItemHeight = 13
      TabOrder = 0
      OnChange = cbbindexChange
    end
    object edtdefinition: TEdit
      Left = 72
      Top = 48
      Width = 121
      Height = 21
      TabOrder = 1
    end
    object edtname: TEdit
      Left = 48
      Top = 88
      Width = 145
      Height = 21
      TabOrder = 2
    end
    object btnapply: TButton
      Left = 136
      Top = 120
      Width = 75
      Height = 25
      Caption = 'Apply'
      TabOrder = 3
      OnClick = btnapplyClick
    end
  end
end
