object General: TGeneral
  Left = 538
  Top = 202
  AutoSize = True
  Caption = 'General'
  ClientHeight = 345
  ClientWidth = 273
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
    Width = 273
    Height = 345
    Color = clMoneyGreen
    TabOrder = 0
    object Label1: TLabel
      Left = 24
      Top = 16
      Width = 91
      Height = 13
      Caption = 'Solver Parametr'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Panel2: TPanel
      Left = 24
      Top = 184
      Width = 233
      Height = 113
      Color = clMoneyGreen
      TabOrder = 0
      object RadioGroup1: TRadioGroup
        Left = 16
        Top = 16
        Width = 185
        Height = 81
        Caption = 'Time depend'
        ItemIndex = 0
        Items.Strings = (
          'Steady'
          'Transient')
        TabOrder = 0
      end
    end
    object Panel3: TPanel
      Left = 24
      Top = 40
      Width = 233
      Height = 41
      Color = clMoneyGreen
      TabOrder = 1
      object Label2: TLabel
        Left = 88
        Top = 16
        Width = 123
        Height = 13
        Caption = ' ('#1088#1072#1079#1076#1077#1083#1100#1085#1099#1081') '#1088#1077#1096#1072#1090#1077#1083#1100
      end
      object Label3: TLabel
        Left = 16
        Top = 16
        Width = 66
        Height = 13
        Caption = 'Segregated'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object Bapply: TButton
      Left = 168
      Top = 304
      Width = 75
      Height = 25
      Caption = 'Apply'
      TabOrder = 2
      OnClick = BapplyClick
    end
    object Panel4: TPanel
      Left = 24
      Top = 88
      Width = 137
      Height = 41
      Color = clMoneyGreen
      TabOrder = 3
      object Label4: TLabel
        Left = 8
        Top = 16
        Width = 69
        Height = 13
        Caption = 'Chess Mesh'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object Panel5: TPanel
      Left = 24
      Top = 136
      Width = 185
      Height = 41
      Color = clMoneyGreen
      TabOrder = 4
      object Label5: TLabel
        Left = 8
        Top = 16
        Width = 165
        Height = 13
        Caption = #1087#1086#1091#1079#1083#1086#1074#1072#1103' '#1089#1073#1086#1088#1082#1072' '#1084#1072#1090#1088#1080#1094#1099
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
  end
end
