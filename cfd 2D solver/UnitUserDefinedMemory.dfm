object FormUDM: TFormUDM
  Left = 324
  Top = 208
  AutoSize = True
  Caption = 'User-Defined Memory'
  ClientHeight = 21
  ClientWidth = 265
  Color = clMoneyGreen
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object lbludm: TLabel
    Left = 0
    Top = 0
    Width = 205
    Height = 13
    Caption = 'Number of User-Defined Memory Locations'
  end
  object cbbudm: TComboBox
    Left = 224
    Top = 0
    Width = 41
    Height = 21
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 0
    Text = '0'
    OnChange = cbbudmChange
    Items.Strings = (
      '0'
      '1'
      '2'
      '3')
  end
end
