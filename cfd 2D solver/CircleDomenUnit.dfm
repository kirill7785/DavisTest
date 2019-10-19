object CircleDomenForm: TCircleDomenForm
  Left = 419
  Top = 276
  AutoSize = True
  Caption = 'Form Circle Domen'
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
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 257
    Height = 217
    Color = clMoneyGreen
    TabOrder = 0
    object Panel2: TPanel
      Left = 16
      Top = 16
      Width = 225
      Height = 105
      Color = clMoneyGreen
      TabOrder = 0
      object Label1: TLabel
        Left = 8
        Top = 16
        Width = 56
        Height = 13
        Caption = 'center point'
      end
      object Label2: TLabel
        Left = 8
        Top = 40
        Width = 12
        Height = 13
        Caption = 'xC'
      end
      object Label3: TLabel
        Left = 112
        Top = 40
        Width = 12
        Height = 13
        Caption = 'yC'
      end
      object Label4: TLabel
        Left = 8
        Top = 72
        Width = 28
        Height = 13
        Caption = 'radius'
      end
      object ExC: TEdit
        Left = 32
        Top = 32
        Width = 65
        Height = 21
        TabOrder = 0
      end
      object EyC: TEdit
        Left = 136
        Top = 32
        Width = 65
        Height = 21
        TabOrder = 1
      end
      object Eradius: TEdit
        Left = 48
        Top = 64
        Width = 65
        Height = 21
        TabOrder = 2
      end
    end
    object Panel3: TPanel
      Left = 16
      Top = 128
      Width = 225
      Height = 73
      Color = clMoneyGreen
      TabOrder = 1
      object Label5: TLabel
        Left = 8
        Top = 16
        Width = 38
        Height = 13
        Caption = 'function'
      end
      object Label6: TLabel
        Left = 8
        Top = 40
        Width = 26
        Height = 13
        Caption = 'value'
      end
      object cbbCBSelectFunction: TComboBox
        Left = 56
        Top = 8
        Width = 65
        Height = 21
        ItemIndex = 0
        TabOrder = 0
        Text = 'VOF'
        Items.Strings = (
          'VOF')
      end
      object Evalue: TEdit
        Left = 56
        Top = 40
        Width = 65
        Height = 21
        TabOrder = 1
        Text = '1'
      end
      object Bpatch: TButton
        Left = 136
        Top = 8
        Width = 75
        Height = 25
        Caption = 'Patch'
        TabOrder = 2
        OnClick = BpatchClick
      end
      object Bclose: TButton
        Left = 136
        Top = 40
        Width = 75
        Height = 25
        Caption = 'Close'
        TabOrder = 3
        OnClick = BcloseClick
      end
    end
  end
end
