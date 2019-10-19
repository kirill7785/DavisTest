object PatchForm: TPatchForm
  Left = 532
  Top = 351
  AutoSize = True
  Caption = 'Patch Form'
  ClientHeight = 233
  ClientWidth = 249
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
    Width = 249
    Height = 233
    Color = clMoneyGreen
    TabOrder = 0
    object GroupBox1: TGroupBox
      Left = 16
      Top = 8
      Width = 217
      Height = 105
      Caption = 'Cabinet'
      Color = clMoneyGreen
      ParentColor = False
      TabOrder = 0
      object Label1: TLabel
        Left = 8
        Top = 48
        Width = 28
        Height = 13
        Caption = 'Width'
      end
      object Label2: TLabel
        Left = 8
        Top = 80
        Width = 31
        Height = 13
        Caption = 'Height'
      end
      object Llen: TLabel
        Left = 72
        Top = 48
        Width = 6
        Height = 13
        Caption = '1'
      end
      object Lhight: TLabel
        Left = 72
        Top = 80
        Width = 6
        Height = 13
        Caption = '1'
      end
      object Label5: TLabel
        Left = 8
        Top = 24
        Width = 70
        Height = 13
        Caption = 'start point (0,0)'
      end
    end
    object Panel2: TPanel
      Left = 16
      Top = 120
      Width = 217
      Height = 49
      Color = clMoneyGreen
      TabOrder = 1
      object Label3: TLabel
        Left = 8
        Top = 16
        Width = 113
        Height = 13
        Caption = 'Create rectangle domen'
      end
      object BrectangleCreate: TButton
        Left = 136
        Top = 16
        Width = 75
        Height = 25
        Caption = 'Create'
        TabOrder = 0
        OnClick = BrectangleCreateClick
      end
    end
    object Panel3: TPanel
      Left = 16
      Top = 176
      Width = 217
      Height = 49
      Color = clMoneyGreen
      TabOrder = 2
      object Label4: TLabel
        Left = 8
        Top = 16
        Width = 94
        Height = 13
        Caption = 'Create circle domen'
      end
      object BcircleCreate: TButton
        Left = 136
        Top = 16
        Width = 75
        Height = 25
        Caption = 'Create'
        TabOrder = 0
        OnClick = BcircleCreateClick
      end
    end
  end
end
