object AddVariableForm: TAddVariableForm
  Left = 301
  Top = 252
  AutoSize = True
  Caption = 'new variable'
  ClientHeight = 89
  ClientWidth = 249
  Color = clMoneyGreen
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 13
  object lblname: TLabel
    Left = 88
    Top = 0
    Width = 36
    Height = 13
    Caption = 'lblname'
  end
  object lbl1: TLabel
    Left = 0
    Top = 0
    Width = 67
    Height = 13
    Caption = 'variable name'
  end
  object lbl2: TLabel
    Left = 0
    Top = 40
    Width = 67
    Height = 13
    Caption = 'variable value'
  end
  object edtvalue: TEdit
    Left = 128
    Top = 32
    Width = 121
    Height = 21
    TabOrder = 0
    Text = 'edtvalue'
  end
  object btnsetvalue: TButton
    Left = 40
    Top = 64
    Width = 177
    Height = 25
    Caption = 'set the value of the variable'
    TabOrder = 1
    OnClick = btnsetvalueClick
  end
end
