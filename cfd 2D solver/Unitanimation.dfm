object FormAnimationSetting: TFormAnimationSetting
  Left = 665
  Top = 436
  Caption = 'Animation Setting'
  ClientHeight = 123
  ClientWidth = 227
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
    Left = 0
    Top = 0
    Width = 160
    Height = 13
    Caption = 'record an animation frame every '
  end
  object lbl2: TLabel
    Left = 80
    Top = 32
    Width = 49
    Height = 13
    Caption = 'time steps'
  end
  object cbbanimate: TComboBox
    Left = 8
    Top = 32
    Width = 57
    Height = 21
    ItemIndex = 0
    TabOrder = 0
    Text = '1'
    Items.Strings = (
      '1'
      '2'
      '3'
      '4'
      '5'
      '10'
      '15'
      '20'
      '25'
      '30'
      '40'
      '50'
      '100'
      '200')
  end
  object btnapply: TButton
    Left = 144
    Top = 96
    Width = 75
    Height = 25
    Caption = 'Apply'
    TabOrder = 1
    OnClick = btnapplyClick
  end
  object chkanimation: TCheckBox
    Left = 8
    Top = 64
    Width = 209
    Height = 17
    Caption = 'animation during the computation'
    TabOrder = 2
  end
end
