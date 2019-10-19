object FormUDSDiffusivity: TFormUDSDiffusivity
  Left = 313
  Top = 155
  AutoSize = True
  Caption = 'UDS Diffusivity'
  ClientHeight = 273
  ClientWidth = 147
  Color = clMoneyGreen
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object lbl1: TLabel
    Left = 0
    Top = 0
    Width = 78
    Height = 13
    Caption = 'UDS coefficients'
  end
  object lbl2: TLabel
    Left = 0
    Top = 136
    Width = 97
    Height = 13
    Caption = 'Diffusion Coefficient'
  end
  object lblBoussinesq: TLabel
    Left = 0
    Top = 192
    Width = 106
    Height = 13
    Caption = 'Boussinesq coefficient'
  end
  object lstuds: TListBox
    Left = 0
    Top = 24
    Width = 145
    Height = 97
    ItemHeight = 13
    TabOrder = 0
    OnClick = lstudsClick
  end
  object edtdiffusivity: TEdit
    Left = 0
    Top = 160
    Width = 121
    Height = 21
    TabOrder = 1
  end
  object btnApply: TButton
    Left = 72
    Top = 248
    Width = 75
    Height = 25
    Caption = 'Apply'
    TabOrder = 2
    OnClick = btnApplyClick
  end
  object edtBoussinesq: TEdit
    Left = 0
    Top = 216
    Width = 121
    Height = 21
    TabOrder = 3
  end
end
