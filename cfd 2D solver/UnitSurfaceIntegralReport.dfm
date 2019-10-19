object FormAutoReportSurfInt: TFormAutoReportSurfInt
  Left = 314
  Top = 404
  Caption = 'Report Surface Integral'
  ClientHeight = 326
  ClientWidth = 256
  Color = clMoneyGreen
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object grpreptype: TGroupBox
    Left = 8
    Top = 8
    Width = 241
    Height = 49
    Caption = 'Report Type'
    TabOrder = 0
    object cbbreporttype: TComboBox
      Left = 8
      Top = 16
      Width = 217
      Height = 21
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 0
      Text = 'Area'
      Items.Strings = (
        'Area'
        'Integral'
        'Vertex Average'
        'Vertex Minimum'
        'Vertex Maximum')
    end
  end
  object grpboundary: TGroupBox
    Left = 8
    Top = 64
    Width = 241
    Height = 49
    Caption = 'Boundary'
    TabOrder = 1
    object cbbboundary: TComboBox
      Left = 8
      Top = 16
      Width = 217
      Height = 21
      ItemHeight = 13
      TabOrder = 0
    end
  end
  object grpfieldvariable: TGroupBox
    Left = 8
    Top = 120
    Width = 241
    Height = 57
    Caption = 'Field Variable'
    TabOrder = 2
    object cbbfieldvariable: TComboBox
      Left = 8
      Top = 24
      Width = 217
      Height = 21
      ItemHeight = 13
      TabOrder = 0
    end
  end
  object grpreportname: TGroupBox
    Left = 8
    Top = 184
    Width = 241
    Height = 49
    Caption = 'Report Name'
    TabOrder = 3
    object edtreportname: TEdit
      Left = 8
      Top = 16
      Width = 217
      Height = 21
      TabOrder = 0
    end
  end
  object grpmultiplyer: TGroupBox
    Left = 8
    Top = 240
    Width = 241
    Height = 49
    Caption = 'Multiplyer'
    TabOrder = 4
    object edtmultiplyer: TEdit
      Left = 8
      Top = 16
      Width = 217
      Height = 21
      TabOrder = 0
      Text = 'e'
    end
  end
  object btnapply: TButton
    Left = 160
    Top = 296
    Width = 75
    Height = 25
    Caption = 'Apply'
    TabOrder = 5
    OnClick = btnapplyClick
  end
end
