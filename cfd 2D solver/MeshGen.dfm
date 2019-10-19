object FMesh: TFMesh
  Left = 258
  Top = 157
  Caption = #1043#1077#1085#1077#1088#1072#1090#1086#1088' '#1088#1072#1089#1095#1105#1090#1085#1086#1081' '#1089#1077#1090#1082#1080
  ClientHeight = 249
  ClientWidth = 324
  Color = clMoneyGreen
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel6: TPanel
    Left = 0
    Top = 0
    Width = 321
    Height = 249
    BorderStyle = bsSingle
    Color = clMoneyGreen
    TabOrder = 0
    object grpcondensationmeshnodes: TGroupBox
      Left = 8
      Top = 16
      Width = 273
      Height = 177
      Caption = 'Condensation mesh nodes'
      TabOrder = 0
      object lblLeft: TLabel
        Left = 88
        Top = 24
        Width = 24
        Height = 13
        Caption = 'qLeft'
      end
      object lblRight: TLabel
        Left = 88
        Top = 64
        Width = 31
        Height = 13
        Caption = 'qRight'
      end
      object lblTop: TLabel
        Left = 88
        Top = 104
        Width = 25
        Height = 13
        Caption = 'qTop'
      end
      object lblBottom: TLabel
        Left = 88
        Top = 144
        Width = 39
        Height = 13
        Caption = 'qBottom'
      end
      object chkLeft: TCheckBox
        Left = 16
        Top = 24
        Width = 49
        Height = 17
        Caption = 'Left'
        TabOrder = 0
      end
      object chkRight: TCheckBox
        Left = 16
        Top = 64
        Width = 57
        Height = 17
        Caption = 'Right'
        TabOrder = 1
      end
      object chkTop: TCheckBox
        Left = 16
        Top = 104
        Width = 49
        Height = 17
        Caption = 'Top'
        TabOrder = 2
      end
      object chkBottom: TCheckBox
        Left = 16
        Top = 144
        Width = 57
        Height = 17
        Caption = 'Bottom'
        TabOrder = 3
      end
      object edtEqleft: TEdit
        Left = 136
        Top = 16
        Width = 97
        Height = 21
        TabOrder = 4
        Text = '1.05'
      end
      object edtEqRight: TEdit
        Left = 136
        Top = 56
        Width = 97
        Height = 21
        TabOrder = 5
        Text = '1.05'
      end
      object edtEqTop: TEdit
        Left = 136
        Top = 96
        Width = 97
        Height = 21
        TabOrder = 6
        Text = '1.05'
      end
      object edtEqBottom: TEdit
        Left = 136
        Top = 136
        Width = 97
        Height = 21
        TabOrder = 7
        Text = '1.05'
      end
      object pnlmessage: TPanel
        Left = 0
        Top = 0
        Width = 273
        Height = 177
        Color = clMoneyGreen
        TabOrder = 8
        object lbl1: TLabel
          Left = 32
          Top = 48
          Width = 152
          Height = 13
          Caption = 'Go to additional unical mesh line'
        end
      end
    end
  end
  object Button1: TButton
    Left = 200
    Top = 208
    Width = 75
    Height = 25
    Caption = 'Create Mesh'
    TabOrder = 1
    OnClick = Button1Click
  end
end
