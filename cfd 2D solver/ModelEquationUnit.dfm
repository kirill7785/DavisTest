object ModelEquationForm: TModelEquationForm
  Left = 332
  Top = 256
  AutoSize = True
  Caption = 'Select system Equation'
  ClientHeight = 265
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
    Height = 265
    Color = clMoneyGreen
    TabOrder = 0
    object RadioGroup1: TRadioGroup
      Left = 8
      Top = 8
      Width = 241
      Height = 201
      Caption = 'Equation'
      Color = clMoneyGreen
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ItemIndex = 0
      Items.Strings = (
        'Temperature'
        'User-Defined Segregated Solver'
        'Flow'
        'Flow and Temperature'
        'Flow and VOF')
      ParentColor = False
      ParentFont = False
      TabOrder = 0
      OnClick = RadioGroup1Click
    end
    object Bapply: TButton
      Left = 166
      Top = 224
      Width = 75
      Height = 25
      Caption = 'Apply'
      TabOrder = 1
      OnClick = BapplyClick
    end
    object btnvof: TButton
      Left = 128
      Top = 168
      Width = 75
      Height = 25
      Caption = 'Edit'
      TabOrder = 2
      Visible = False
      OnClick = btnvofClick
    end
  end
end
