object FormInterpritator: TFormInterpritator
  Left = 309
  Top = 155
  Caption = 'Interpritator test'
  ClientHeight = 446
  ClientWidth = 345
  Color = clMoneyGreen
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object strngrdinterpritator: TStringGrid
    Left = 8
    Top = 8
    Width = 329
    Height = 257
    ColCount = 3
    RowCount = 10
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing]
    TabOrder = 0
    ColWidths = (
      64
      124
      130)
  end
  object grpanalisingstr: TGroupBox
    Left = 8
    Top = 280
    Width = 329
    Height = 65
    Caption = #1072#1085#1072#1083#1080#1079#1080#1088#1091#1077#1084#1072#1103' '#1089#1090#1088#1086#1082#1072
    TabOrder = 1
    object edtanalis: TEdit
      Left = 8
      Top = 24
      Width = 305
      Height = 21
      TabOrder = 0
    end
  end
  object grpresult: TGroupBox
    Left = 8
    Top = 352
    Width = 329
    Height = 49
    Caption = #1088#1077#1079#1091#1083#1100#1090#1072#1090' '#1080#1085#1090#1077#1088#1087#1088#1080#1090#1072#1094#1080#1080
    TabOrder = 2
    object lblresult: TLabel
      Left = 8
      Top = 24
      Width = 3
      Height = 13
    end
  end
  object btnapply: TButton
    Left = 120
    Top = 416
    Width = 209
    Height = 25
    Caption = #1085#1072#1095#1072#1090#1100' '#1080#1085#1090#1077#1088#1087#1088#1080#1090#1072#1094#1080#1102
    TabOrder = 3
    OnClick = btnapplyClick
  end
end
