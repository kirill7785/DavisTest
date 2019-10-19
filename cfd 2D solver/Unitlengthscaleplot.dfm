object Formlengthscaleplot: TFormlengthscaleplot
  Left = 327
  Top = 181
  AutoSize = True
  Caption = 'length scale plot'
  ClientHeight = 105
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
  object lbl1: TLabel
    Left = 0
    Top = 0
    Width = 194
    Height = 13
    Caption = #1084#1072#1089#1096#1090#1072#1073' '#1076#1083#1080#1085#1099' '#1076#1083#1103' '#1074#1099#1074#1086#1076#1072' '#1082#1072#1088#1090#1080#1085#1086#1082
  end
  object lbl2: TLabel
    Left = 0
    Top = 24
    Width = 66
    Height = 13
    Caption = 'length scale x'
  end
  object lbl3: TLabel
    Left = 0
    Top = 48
    Width = 66
    Height = 13
    Caption = 'length scale y'
  end
  object edtlengthscalex: TEdit
    Left = 80
    Top = 24
    Width = 121
    Height = 21
    TabOrder = 0
  end
  object edtlengthscaley: TEdit
    Left = 80
    Top = 48
    Width = 121
    Height = 21
    TabOrder = 1
  end
  object btnapplyandcontinue: TButton
    Left = 8
    Top = 80
    Width = 185
    Height = 25
    Caption = 'Apply and Continue'
    TabOrder = 2
    OnClick = btnapplyandcontinueClick
  end
end
