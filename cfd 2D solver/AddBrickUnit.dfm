object AddbrickForm: TAddbrickForm
  Left = 512
  Top = 223
  Caption = 'Add Hollow block'
  ClientHeight = 224
  ClientWidth = 360
  Color = clMoneyGreen
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox2: TGroupBox
    Left = 8
    Top = 8
    Width = 345
    Height = 209
    Caption = 'adding an hollow block'
    Color = clMoneyGreen
    ParentColor = False
    TabOrder = 0
    object AddButton: TButton
      Left = 200
      Top = 160
      Width = 105
      Height = 25
      Caption = 'Add hollow block'
      TabOrder = 0
      OnClick = AddButtonClick
    end
    object GroupBox1: TGroupBox
      Left = 8
      Top = 24
      Width = 177
      Height = 177
      Caption = 'the size and position of the block'
      Color = clMoneyGreen
      ParentColor = False
      TabOrder = 1
      object Label1: TLabel
        Left = 16
        Top = 56
        Width = 12
        Height = 13
        Caption = 'xS'
      end
      object Label2: TLabel
        Left = 16
        Top = 88
        Width = 12
        Height = 13
        Caption = 'yS'
      end
      object Label3: TLabel
        Left = 16
        Top = 120
        Width = 11
        Height = 13
        Caption = 'xL'
      end
      object Label4: TLabel
        Left = 16
        Top = 152
        Width = 11
        Height = 13
        Caption = 'yL'
      end
      object LnameHollowblock: TLabel
        Left = 16
        Top = 24
        Width = 59
        Height = 13
        Caption = 'hollow block'
      end
      object Labelnumberhb: TLabel
        Left = 88
        Top = 24
        Width = 3
        Height = 13
      end
      object ExS: TEdit
        Left = 48
        Top = 48
        Width = 89
        Height = 21
        TabOrder = 0
      end
      object EyS: TEdit
        Left = 48
        Top = 80
        Width = 89
        Height = 21
        TabOrder = 1
      end
      object ExL: TEdit
        Left = 48
        Top = 112
        Width = 89
        Height = 21
        TabOrder = 2
      end
      object EyL: TEdit
        Left = 48
        Top = 144
        Width = 89
        Height = 21
        TabOrder = 3
      end
    end
    object GroupBox3: TGroupBox
      Left = 192
      Top = 24
      Width = 137
      Height = 81
      Caption = 'boundary layer'
      Color = clMoneyGreen
      ParentColor = False
      TabOrder = 2
      object Label5: TLabel
        Left = 16
        Top = 24
        Width = 116
        Height = 13
        Caption = 'around the hollow block '
      end
      object CheckBoxBL: TCheckBox
        Left = 16
        Top = 48
        Width = 73
        Height = 17
        Caption = 'is present'
        TabOrder = 0
      end
    end
  end
end
