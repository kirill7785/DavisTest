object CabinetGlobalMeshForm: TCabinetGlobalMeshForm
  Left = 161
  Top = 396
  AutoSize = True
  Caption = 'Cabinet Mesh'
  ClientHeight = 217
  ClientWidth = 257
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
    Width = 257
    Height = 217
    Caption = 'number mesh nodes'
    Color = clMoneyGreen
    ParentColor = False
    TabOrder = 0
    object Label1: TLabel
      Left = 16
      Top = 32
      Width = 76
      Height = 13
      Caption = 'splitting cabinet '
    end
    object Panel1: TPanel
      Left = 16
      Top = 56
      Width = 217
      Height = 97
      Color = clMoneyGreen
      TabOrder = 0
      object Label2: TLabel
        Left = 16
        Top = 24
        Width = 45
        Height = 13
        Caption = 'horizontal'
      end
      object Label3: TLabel
        Left = 16
        Top = 60
        Width = 34
        Height = 13
        Caption = 'vertical'
      end
      object Einx: TEdit
        Left = 104
        Top = 16
        Width = 89
        Height = 21
        TabOrder = 0
      end
      object Einy: TEdit
        Left = 104
        Top = 52
        Width = 89
        Height = 21
        TabOrder = 1
      end
    end
    object ButtonApply: TButton
      Left = 144
      Top = 168
      Width = 75
      Height = 25
      Caption = 'Apply'
      TabOrder = 1
      OnClick = ButtonApplyClick
    end
  end
end
