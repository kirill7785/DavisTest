object RectangleDomenForm: TRectangleDomenForm
  Left = 447
  Top = 207
  Caption = 'Form Rectangle Domen'
  ClientHeight = 250
  ClientWidth = 305
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
    Width = 305
    Height = 249
    Color = clMoneyGreen
    TabOrder = 0
    object PositionGroupBox: TGroupBox
      Left = 16
      Top = 16
      Width = 273
      Height = 97
      Caption = 'Position'
      Color = clSkyBlue
      ParentColor = False
      TabOrder = 0
      object Label1: TLabel
        Left = 16
        Top = 24
        Width = 12
        Height = 13
        Caption = 'xS'
      end
      object Label2: TLabel
        Left = 16
        Top = 56
        Width = 12
        Height = 13
        Caption = 'yS'
      end
      object Label3: TLabel
        Left = 128
        Top = 24
        Width = 11
        Height = 13
        Caption = 'xL'
      end
      object Label4: TLabel
        Left = 128
        Top = 56
        Width = 11
        Height = 13
        Caption = 'yL'
      end
      object ExS: TEdit
        Left = 40
        Top = 24
        Width = 73
        Height = 21
        TabOrder = 0
      end
      object EyS: TEdit
        Left = 40
        Top = 56
        Width = 73
        Height = 21
        TabOrder = 1
      end
      object ExL: TEdit
        Left = 152
        Top = 24
        Width = 81
        Height = 21
        TabOrder = 2
      end
      object EyL: TEdit
        Left = 152
        Top = 56
        Width = 81
        Height = 21
        TabOrder = 3
      end
    end
    object Panel2: TPanel
      Left = 16
      Top = 120
      Width = 185
      Height = 113
      Color = clSkyBlue
      TabOrder = 1
      object Label5: TLabel
        Left = 16
        Top = 24
        Width = 38
        Height = 13
        Caption = 'function'
      end
      object Label7: TLabel
        Left = 16
        Top = 56
        Width = 26
        Height = 13
        Caption = 'value'
      end
      object Evalue: TEdit
        Left = 80
        Top = 48
        Width = 73
        Height = 21
        TabOrder = 0
        Text = '1'
      end
      object CBSelectFunction: TComboBox
        Left = 80
        Top = 16
        Width = 73
        Height = 21
        ItemIndex = 0
        TabOrder = 1
        Text = 'VOF'
        Items.Strings = (
          'VOF')
      end
      object chkdeltay: TCheckBox
        Left = 16
        Top = 88
        Width = 81
        Height = 17
        Caption = 'delta y layer'
        TabOrder = 2
      end
    end
    object Bpatch: TButton
      Left = 208
      Top = 136
      Width = 75
      Height = 25
      Caption = 'Patch'
      TabOrder = 2
      OnClick = BpatchClick
    end
    object Bclose: TButton
      Left = 208
      Top = 176
      Width = 75
      Height = 25
      Caption = 'Close'
      TabOrder = 3
      OnClick = BcloseClick
    end
  end
end
