object FormSurfaceIntegrals: TFormSurfaceIntegrals
  Left = 309
  Top = 155
  AutoSize = True
  BorderIcons = [biSystemMenu]
  Caption = 'Surface Integrals'
  ClientHeight = 257
  ClientWidth = 185
  Color = clMoneyGreen
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object grpreporttype: TGroupBox
    Left = 0
    Top = 0
    Width = 185
    Height = 49
    Caption = 'Report Type'
    TabOrder = 0
    object cbbreptype: TComboBox
      Left = 8
      Top = 16
      Width = 169
      Height = 21
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
    Left = 0
    Top = 56
    Width = 185
    Height = 49
    Caption = 'Boundary'
    TabOrder = 1
    object cbbboundary: TComboBox
      Left = 8
      Top = 16
      Width = 169
      Height = 21
      TabOrder = 0
    end
  end
  object grpfieldvar: TGroupBox
    Left = 0
    Top = 112
    Width = 185
    Height = 57
    Caption = 'Field Variable'
    TabOrder = 2
    object cbbfieldvar: TComboBox
      Left = 8
      Top = 24
      Width = 169
      Height = 21
      TabOrder = 0
    end
  end
  object grpresult: TGroupBox
    Left = 0
    Top = 176
    Width = 185
    Height = 41
    Caption = 'Result'
    TabOrder = 3
    object lblresult: TLabel
      Left = 8
      Top = 16
      Width = 16
      Height = 13
      Caption = '0.0'
    end
  end
  object btncompute: TButton
    Left = 8
    Top = 232
    Width = 75
    Height = 25
    Caption = 'Compute'
    TabOrder = 4
    OnClick = btncomputeClick
  end
end
