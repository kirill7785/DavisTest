object BonConRedoForm: TBonConRedoForm
  Left = 315
  Top = 148
  AutoSize = True
  Caption = #1088#1077#1076#1072#1082#1090#1086#1088' '#1075#1088#1072#1085#1080#1094' '#1088#1072#1089#1095#1105#1090#1085#1086#1081' '#1086#1073#1083#1072#1089#1090#1080
  ClientHeight = 297
  ClientWidth = 473
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
  object GroupBox1: TGroupBox
    Left = 0
    Top = 0
    Width = 241
    Height = 297
    Caption = #1075#1088#1072#1085#1080#1094#1099
    Color = clMoneyGreen
    ParentColor = False
    TabOrder = 0
    object CheckListBoxBoundaryCondition: TCheckListBox
      Left = 16
      Top = 32
      Width = 201
      Height = 233
      ItemHeight = 13
      TabOrder = 0
      OnClick = CheckListBoxBoundaryConditionClick
    end
  end
  object GroupBox2: TGroupBox
    Left = 248
    Top = 0
    Width = 225
    Height = 297
    Caption = #1054#1087#1077#1088#1072#1094#1080#1080
    Color = clMoneyGreen
    ParentColor = False
    TabOrder = 1
    object Label1: TLabel
      Left = 16
      Top = 32
      Width = 128
      Height = 13
      Caption = #1053#1072#1088#1080#1089#1086#1074#1072#1090#1100' '#1074#1099#1076#1077#1083#1077#1085#1085#1099#1077
    end
    object Label2: TLabel
      Left = 152
      Top = 32
      Width = 43
      Height = 13
      Caption = #1075#1088#1072#1085#1080#1094#1099
    end
    object Label3: TLabel
      Left = 16
      Top = 160
      Width = 193
      Height = 13
      Caption = #1055#1077#1088#1077#1080#1084#1077#1085#1086#1074#1072#1090#1100' '#1074#1099#1076#1077#1083#1077#1085#1085#1091#1102'  '#1075#1088#1072#1085#1080#1094#1091
    end
    object Label4: TLabel
      Left = 16
      Top = 96
      Width = 175
      Height = 13
      Caption = #1054#1073#1098#1077#1076#1080#1085#1080#1090#1100' '#1074#1099#1076#1077#1083#1077#1085#1085#1099#1077' '#1075#1088#1072#1085#1080#1094#1099
    end
    object Label5: TLabel
      Left = 16
      Top = 216
      Width = 141
      Height = 13
      Caption = #1088#1072#1079#1073#1080#1090#1100' '#1088#1077#1073#1088#1086' '#1085#1072' '#1076#1074#1077' '#1095#1072#1089#1090#1080
    end
    object Label6: TLabel
      Left = 16
      Top = 240
      Width = 34
      Height = 13
      Caption = 'Uvalue'
    end
    object Label7: TLabel
      Left = 128
      Top = 240
      Width = 24
      Height = 13
      Caption = '[0..1]'
    end
    object Button1: TButton
      Left = 16
      Top = 56
      Width = 161
      Height = 25
      Caption = 'Display selected boundary'
      TabOrder = 0
      OnClick = Button1Click
    end
    object RenameButton: TButton
      Left = 16
      Top = 184
      Width = 105
      Height = 25
      Caption = 'Rename'
      TabOrder = 1
      OnClick = RenameButtonClick
    end
    object UnitBoundaryButton: TButton
      Left = 16
      Top = 120
      Width = 129
      Height = 25
      Caption = 'Unit Boundary'
      TabOrder = 2
      OnClick = UnitBoundaryButtonClick
    end
    object EUvalue: TEdit
      Left = 64
      Top = 232
      Width = 49
      Height = 21
      TabOrder = 3
      Text = '0.2'
    end
    object Button2: TButton
      Left = 24
      Top = 264
      Width = 113
      Height = 25
      Caption = 'Separate Edge'
      TabOrder = 4
      OnClick = Button2Click
    end
  end
end
