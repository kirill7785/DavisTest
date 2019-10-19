object Formlanguage: TFormlanguage
  Left = 327
  Top = 159
  AutoSize = True
  ClientHeight = 257
  ClientWidth = 201
  Color = clMoneyGreen
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object pnllanguage1: TPanel
    Left = 0
    Top = 0
    Width = 201
    Height = 201
    Color = clMoneyGreen
    TabOrder = 0
    object rglanguage1: TRadioGroup
      Left = 8
      Top = 8
      Width = 185
      Height = 185
      Color = clMoneyGreen
      ItemIndex = 0
      Items.Strings = (
        'Pascal'
        'C'
        'C and OpenMP'
        'cuda C')
      ParentColor = False
      TabOrder = 0
      OnClick = rglanguage1Click
    end
  end
  object grpparallelcpu: TGroupBox
    Left = 0
    Top = 200
    Width = 201
    Height = 57
    Caption = 'parallel cpu'
    Color = clMoneyGreen
    ParentColor = False
    TabOrder = 1
    object lblcore: TLabel
      Left = 8
      Top = 24
      Width = 127
      Height = 13
      Caption = #1082#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1087#1086#1090#1086#1082#1086#1074' CPU'
    end
    object cbbcore: TComboBox
      Left = 144
      Top = 16
      Width = 49
      Height = 21
      ItemIndex = 0
      TabOrder = 0
      Text = '1'
      OnChange = cbbcoreChange
      Items.Strings = (
        '1'
        '2'
        '3'
        '4'
        '5'
        '6'
        '7'
        '8'
        '9'
        '10'
        '11'
        '12')
    end
  end
end
