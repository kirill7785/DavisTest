object PamendmendcontrolForm: TPamendmendcontrolForm
  Left = 367
  Top = 147
  Caption = #1085#1072#1089#1090#1088#1086#1081#1082#1072' '#1087#1086#1087#1088#1072#1074#1082#1080' '#1076#1072#1074#1083#1077#1085#1080#1103
  ClientHeight = 330
  ClientWidth = 229
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 8
    Top = 16
    Width = 209
    Height = 233
    Color = clMoneyGreen
    TabOrder = 0
    object Label1: TLabel
      Left = 32
      Top = 160
      Width = 133
      Height = 13
      Caption = #1088#1072#1074#1082#1080' '#1076#1072#1074#1083#1077#1085#1080#1103' '#1074' '#1084#1077#1090#1086#1076#1077' '
    end
    object Label2: TLabel
      Left = 32
      Top = 184
      Width = 84
      Height = 13
      Caption = #1043#1072#1091#1089#1089#1072'-'#1047#1077#1081#1076#1077#1083#1103' '
    end
    object RadioGroup1: TRadioGroup
      Left = 8
      Top = 16
      Width = 185
      Height = 105
      Caption = #1087#1086#1087#1088#1072#1074#1082#1072' '#1076#1072#1074#1083#1077#1085#1080#1103' '#1085#1072' '#1075#1088#1072#1085#1080#1094#1077
      Color = clSkyBlue
      Items.Strings = (
        #1091#1089#1083#1086#1074#1080#1077' '#1055#1072#1090#1072#1085#1082#1072#1088#1072
        #1091#1089#1083#1086#1074#1080#1077' '#1053#1077#1081#1084#1072#1085#1072)
      ParentColor = False
      TabOrder = 0
    end
    object ButtonApplay: TButton
      Left = 112
      Top = 200
      Width = 75
      Height = 25
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      TabOrder = 1
      OnClick = ButtonApplayClick
    end
    object CheckBoxipifixpamendment: TCheckBox
      Left = 16
      Top = 136
      Width = 177
      Height = 17
      Caption = #1092#1080#1082#1089#1080#1088#1086#1074#1072#1090#1100' '#1091#1088#1086#1074#1077#1085#1100' '#1087#1086#1087'-'
      TabOrder = 2
    end
  end
  object Panel2: TPanel
    Left = 24
    Top = 264
    Width = 185
    Height = 41
    Color = clSkyBlue
    TabOrder = 1
    object Bresetpressure: TButton
      Left = 24
      Top = 8
      Width = 129
      Height = 25
      Caption = 'reset pressure'
      TabOrder = 0
      OnClick = BresetpressureClick
    end
  end
end
