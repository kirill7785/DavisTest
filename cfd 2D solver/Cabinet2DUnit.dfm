object Cabinet2DForm: TCabinet2DForm
  Left = 321
  Top = 170
  AutoSize = True
  Caption = 'Cabinet'
  ClientHeight = 137
  ClientWidth = 194
  Color = clMoneyGreen
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 0
    Top = 0
    Width = 193
    Height = 137
    Caption = 'resize Cabinet'
    Color = clMoneyGreen
    ParentColor = False
    TabOrder = 0
    object Label1: TLabel
      Left = 16
      Top = 32
      Width = 28
      Height = 13
      Caption = 'Width'
    end
    object Label2: TLabel
      Left = 16
      Top = 64
      Width = 31
      Height = 13
      Caption = 'Height'
    end
    object EdLx: TEdit
      Left = 72
      Top = 24
      Width = 97
      Height = 21
      TabOrder = 0
    end
    object EdLy: TEdit
      Left = 72
      Top = 56
      Width = 97
      Height = 21
      TabOrder = 1
    end
    object BApply: TButton
      Left = 80
      Top = 96
      Width = 75
      Height = 25
      Caption = 'Apply'
      TabOrder = 2
      OnClick = BApplyClick
    end
  end
end
