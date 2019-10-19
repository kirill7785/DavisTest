object SourceInEquationForm: TSourceInEquationForm
  Left = 403
  Top = 210
  AutoSize = True
  Caption = #1047#1072#1076#1072#1085#1080#1077' '#1080#1089#1090#1086#1095#1085#1080#1082#1086#1074#1086#1075#1086' '#1095#1083#1077#1085#1072
  ClientHeight = 369
  ClientWidth = 289
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
    Left = 0
    Top = 0
    Width = 289
    Height = 329
    Color = clMoneyGreen
    TabOrder = 0
    object Ltitle: TLabel
      Left = 24
      Top = 24
      Width = 186
      Height = 13
      Caption = #1080#1089#1090#1086#1095#1085#1080#1082#1086#1074#1099#1081' '#1095#1083#1077#1085' '#1091#1088#1072#1074#1085#1077#1085#1080#1103' '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Panel2: TPanel
      Left = 24
      Top = 176
      Width = 241
      Height = 137
      Color = clSkyBlue
      TabOrder = 0
      object LSc: TLabel
        Left = 32
        Top = 32
        Width = 13
        Height = 13
        Caption = 'Sc'
      end
      object LSp: TLabel
        Left = 32
        Top = 80
        Width = 13
        Height = 13
        Caption = 'Sp'
      end
      object ESc: TEdit
        Left = 72
        Top = 24
        Width = 121
        Height = 21
        TabOrder = 0
      end
      object ESp: TEdit
        Left = 72
        Top = 80
        Width = 121
        Height = 21
        TabOrder = 1
      end
    end
    object Panel3: TPanel
      Left = 24
      Top = 56
      Width = 241
      Height = 105
      Color = clSkyBlue
      TabOrder = 1
      object Lnameequ: TLabel
        Left = 16
        Top = 24
        Width = 105
        Height = 13
        Caption = #1074#1099#1073#1077#1088#1080#1090#1077' '#1091#1088#1072#1074#1085#1077#1085#1080#1077
      end
      object EquationComboBox: TComboBox
        Left = 16
        Top = 64
        Width = 193
        Height = 21
        TabOrder = 0
        OnChange = EquationComboBoxChange
        OnSelect = OnSelect
        Items.Strings = (
          #1090#1077#1087#1083#1086#1087#1088#1086#1074#1086#1076#1085#1086#1089#1090#1100
          #1075#1086#1088#1080#1079#1086#1085#1090#1072#1083#1100#1085#1072#1103' '#1089#1082#1086#1088#1086#1089#1090#1100
          #1074#1077#1088#1090#1080#1082#1072#1083#1100#1085#1072#1103' '#1089#1082#1086#1088#1086#1089#1090#1100)
      end
    end
  end
  object Bapply: TButton
    Left = 48
    Top = 344
    Width = 217
    Height = 25
    Caption = #1047#1072#1076#1072#1090#1100' '#1080#1089#1090#1086#1095#1085#1080#1082#1086#1074#1099#1081' '#1095#1083#1077#1085
    TabOrder = 1
    OnClick = BapplyClick
  end
end
