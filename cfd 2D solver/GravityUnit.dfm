object GravityForm: TGravityForm
  Left = 380
  Top = 153
  AutoSize = True
  Caption = #1079#1072#1076#1072#1085#1080#1077' '#1089#1080#1083#1099' '#1090#1103#1078#1077#1089#1090#1080
  ClientHeight = 425
  ClientWidth = 449
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
    Width = 449
    Height = 425
    Color = clMoneyGreen
    TabOrder = 0
    object CheckBox1: TCheckBox
      Left = 24
      Top = 24
      Width = 97
      Height = 17
      Caption = #1089#1080#1083#1072' '#1090#1103#1078#1077#1089#1090#1080
      TabOrder = 0
      OnClick = CheckBox1Click
    end
    object GroupBox1: TGroupBox
      Left = 24
      Top = 56
      Width = 257
      Height = 113
      Caption = #1079#1085#1072#1095#1077#1085#1080#1077' '#1091#1089#1082#1086#1088#1077#1085#1080#1103' '#1089#1074#1086#1073#1086#1076#1085#1086#1075#1086' '#1087#1072#1076#1077#1085#1080#1103
      Color = clSkyBlue
      ParentColor = False
      TabOrder = 1
      Visible = False
      object Lgx: TLabel
        Left = 16
        Top = 32
        Width = 47
        Height = 13
        Caption = 'X - gravity'
      end
      object Label1: TLabel
        Left = 16
        Top = 72
        Width = 47
        Height = 13
        Caption = 'Y - gravity'
      end
      object Egx: TEdit
        Left = 80
        Top = 32
        Width = 121
        Height = 21
        TabOrder = 0
      end
      object Egy: TEdit
        Left = 80
        Top = 72
        Width = 121
        Height = 21
        TabOrder = 1
      end
    end
    object Bapply: TButton
      Left = 304
      Top = 376
      Width = 75
      Height = 25
      Caption = 'Apply'
      TabOrder = 2
      OnClick = BapplyClick
    end
    object CheckBoxGravityVibrations: TCheckBox
      Left = 24
      Top = 184
      Width = 97
      Height = 17
      Caption = 'gravity vibrations'
      TabOrder = 3
      OnClick = CheckBoxGravityVibrationsClick
    end
    object Panel2: TPanel
      Left = 24
      Top = 216
      Width = 401
      Height = 145
      TabOrder = 4
      Visible = False
      object GroupBoxParam: TGroupBox
        Left = 16
        Top = 24
        Width = 193
        Height = 105
        Caption = 'parameters'
        Color = clSkyBlue
        ParentColor = False
        TabOrder = 0
        object LabelAmplityde: TLabel
          Left = 16
          Top = 32
          Width = 45
          Height = 13
          Caption = 'amplitude'
        end
        object LabelFrequency: TLabel
          Left = 16
          Top = 64
          Width = 47
          Height = 13
          Caption = 'frequency'
        end
        object EAmplityde: TEdit
          Left = 88
          Top = 24
          Width = 89
          Height = 21
          TabOrder = 0
        end
        object EFrequency: TEdit
          Left = 88
          Top = 64
          Width = 89
          Height = 21
          TabOrder = 1
        end
      end
      object RadioGroupDirect: TRadioGroup
        Left = 232
        Top = 24
        Width = 153
        Height = 105
        Caption = 'direction of vibrations'
        Color = clSkyBlue
        ItemIndex = 1
        Items.Strings = (
          'horisontal'
          'vertical')
        ParentColor = False
        TabOrder = 1
      end
    end
  end
end
