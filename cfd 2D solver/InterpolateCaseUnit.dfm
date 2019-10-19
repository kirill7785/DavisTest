object InterpolateCaseForm: TInterpolateCaseForm
  Left = 330
  Top = 209
  AutoSize = True
  Caption = 'select interpolation method'
  ClientHeight = 185
  ClientWidth = 329
  Color = clMoneyGreen
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
    Width = 329
    Height = 185
    BorderStyle = bsSingle
    Color = clMoneyGreen
    TabOrder = 0
    object Label1: TLabel
      Left = 16
      Top = 24
      Width = 116
      Height = 13
      Caption = 'interpolation options'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object RadioGroup1: TRadioGroup
      Left = 16
      Top = 56
      Width = 169
      Height = 105
      Caption = 'parameters'
      Color = clMoneyGreen
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ItemIndex = 1
      Items.Strings = (
        'without interpolation'
        'OpenGL')
      ParentColor = False
      ParentFont = False
      TabOrder = 0
    end
  end
end
