object FormUserDefinedScalar: TFormUserDefinedScalar
  Left = 310
  Top = 155
  Caption = 'User-Defined Scalars'
  ClientHeight = 294
  ClientWidth = 209
  Color = clMoneyGreen
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object lbluds: TLabel
    Left = 0
    Top = 0
    Width = 153
    Height = 13
    Caption = 'Number of User-Defined Scalars'
  end
  object cbbuds: TComboBox
    Left = 160
    Top = 0
    Width = 41
    Height = 21
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 0
    Text = '0'
    OnChange = cbbudsChange
    Items.Strings = (
      '0'
      '1'
      '2'
      '3'
      '4')
  end
  object grpuds: TGroupBox
    Left = 0
    Top = 32
    Width = 209
    Height = 257
    Caption = 'User-Defined Scalars Option'
    TabOrder = 1
    Visible = False
    object lbludsindex: TLabel
      Left = 72
      Top = 24
      Width = 51
      Height = 13
      Caption = 'UDS Index'
    end
    object lblsolutionzones: TLabel
      Left = 16
      Top = 56
      Width = 70
      Height = 13
      Caption = 'Solution Zones'
    end
    object lblFluxFunction: TLabel
      Left = 16
      Top = 88
      Width = 67
      Height = 13
      Caption = 'Flux  Function'
    end
    object lblunsteady: TLabel
      Left = 8
      Top = 192
      Width = 90
      Height = 13
      Caption = 'Unsteady Function'
    end
    object cbbindex: TComboBox
      Left = 128
      Top = 16
      Width = 57
      Height = 21
      ItemHeight = 13
      TabOrder = 0
      Text = '1'
      OnChange = cbbindexChange
      Items.Strings = (
        '1')
    end
    object cbbsolutionzones: TComboBox
      Left = 96
      Top = 48
      Width = 89
      Height = 21
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 1
      Text = 'all'
      Items.Strings = (
        'all')
    end
    object cbbfluxfunction: TComboBox
      Left = 88
      Top = 80
      Width = 97
      Height = 21
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 2
      Text = 'none'
      OnChange = cbbfluxfunctionChange
      Items.Strings = (
        'none'
        'mass flow rate'
        'user-defined')
    end
    object cbbunsteadyfunction: TComboBox
      Left = 112
      Top = 192
      Width = 73
      Height = 21
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 3
      Text = 'none'
      Items.Strings = (
        'none'
        'default')
    end
    object btnapply: TButton
      Left = 128
      Top = 224
      Width = 75
      Height = 25
      Caption = 'Apply'
      TabOrder = 4
      OnClick = btnapplyClick
    end
    object grpvelocitycomponent: TGroupBox
      Left = 16
      Top = 112
      Width = 185
      Height = 73
      Caption = 'velocity component'
      TabOrder = 5
      Visible = False
      object lblVx: TLabel
        Left = 8
        Top = 24
        Width = 12
        Height = 13
        Caption = 'Vx'
      end
      object lblVy: TLabel
        Left = 8
        Top = 48
        Width = 12
        Height = 13
        Caption = 'Vy'
      end
      object edtVx: TEdit
        Left = 32
        Top = 16
        Width = 145
        Height = 21
        TabOrder = 0
      end
      object edtVy: TEdit
        Left = 32
        Top = 40
        Width = 145
        Height = 21
        TabOrder = 1
      end
    end
  end
end
