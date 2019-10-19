object Form2DPlot: TForm2DPlot
  Left = 331
  Top = 160
  Caption = 'Visualisation parameters'
  ClientHeight = 151
  ClientWidth = 326
  Color = clMoneyGreen
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Bapply: TButton
    Left = 229
    Top = 118
    Width = 89
    Height = 25
    Caption = 'draw picture'
    TabOrder = 0
    OnClick = BapplyClick
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 305
    Height = 49
    Caption = 'category'
    Color = clMoneyGreen
    ParentColor = False
    TabOrder = 1
    object ComboBoxCategori: TComboBox
      Left = 8
      Top = 16
      Width = 281
      Height = 21
      ItemIndex = 0
      TabOrder = 0
      Text = 'Standart Flow'
      OnChange = ComboBoxCategoriChange
      Items.Strings = (
        'Standart Flow'
        'Volume of Fluid'
        'User Defined Scalars')
    end
  end
  object GroupBoxFunction: TGroupBox
    Left = 16
    Top = 64
    Width = 297
    Height = 41
    Caption = 'display function'
    Color = clMoneyGreen
    ParentColor = False
    TabOrder = 2
    object ComboBoxFunction: TComboBox
      Left = 8
      Top = 16
      Width = 273
      Height = 21
      ItemIndex = 0
      TabOrder = 0
      Text = 'temperature'
      Items.Strings = (
        'temperature'
        'horisontal velocity'
        'vertical velocity'
        'curl'
        'stream function'
        'pressure ambient'
        'pressure'
        'Sc term temperature equation'
        'velocity magnitude'
        'grad x temperature'
        'grad y temperature'
        'magnitude grad temperature')
    end
  end
end
