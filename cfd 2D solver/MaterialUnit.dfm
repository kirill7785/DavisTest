object MaterialForm: TMaterialForm
  Left = 508
  Top = 124
  AutoSize = True
  Caption = 'material properties'
  ClientHeight = 450
  ClientWidth = 323
  Color = clMoneyGreen
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Pmaterial: TPanel
    Left = 0
    Top = 0
    Width = 323
    Height = 339
    AutoSize = True
    Color = clMoneyGreen
    TabOrder = 0
    object Label1: TLabel
      Left = 1
      Top = 1
      Width = 75
      Height = 13
      Caption = 'abstract fluid'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label6: TLabel
      Left = 257
      Top = 9
      Width = 35
      Height = 13
      Caption = 'phase :'
    end
    object lbluds: TLabel
      Left = 7
      Top = 31
      Width = 71
      Height = 13
      Caption = 'UDS Diffusivity'
    end
    object SpeedButton1: TSpeedButton
      Left = 135
      Top = 23
      Width = 23
      Height = 22
      Caption = 'W'
      OnClick = SpeedButton1Click
    end
    object SpeedButton2: TSpeedButton
      Left = 159
      Top = 23
      Width = 23
      Height = 22
      Caption = '1'
      OnClick = SpeedButton2Click
    end
    object SpeedButton3: TSpeedButton
      Left = 184
      Top = 24
      Width = 22
      Height = 21
      Caption = 'A'
      OnClick = SpeedButton3Click
    end
    object Panellambda: TPanel
      Left = 1
      Top = 57
      Width = 321
      Height = 57
      Color = clSkyBlue
      TabOrder = 0
      object Llambda: TLabel
        Left = 8
        Top = 24
        Width = 141
        Height = 13
        Caption = 'thermal conductivity, W/(m*K)'
      end
      object Elambda: TEdit
        Left = 168
        Top = 16
        Width = 121
        Height = 21
        TabOrder = 0
      end
    end
    object PanelNusha: TPanel
      Left = 1
      Top = 281
      Width = 321
      Height = 57
      Alignment = taLeftJustify
      Caption = '       dynamic viscosity, Pa*s'
      Color = clSkyBlue
      TabOrder = 1
      object Emu: TEdit
        Left = 168
        Top = 20
        Width = 121
        Height = 21
        TabOrder = 0
      end
    end
    object PanelCp: TPanel
      Left = 1
      Top = 225
      Width = 321
      Height = 49
      Alignment = taLeftJustify
      Color = clSkyBlue
      TabOrder = 2
      object Lcp: TLabel
        Left = 32
        Top = 20
        Width = 102
        Height = 13
        Caption = 'heat caasity, J/(kg*K)'
      end
      object Ecp: TEdit
        Left = 152
        Top = 12
        Width = 121
        Height = 21
        TabOrder = 0
      end
    end
    object GroupBoxDensity: TGroupBox
      Left = 1
      Top = 121
      Width = 321
      Height = 97
      Caption = 'density, kg/m!3'
      Color = clSkyBlue
      ParentColor = False
      TabOrder = 3
      object Label4: TLabel
        Left = 16
        Top = 64
        Width = 26
        Height = 13
        Caption = 'value'
      end
      object Label5: TLabel
        Left = 16
        Top = 32
        Width = 20
        Height = 13
        Caption = 'type'
      end
      object Erho: TEdit
        Left = 56
        Top = 60
        Width = 121
        Height = 21
        TabOrder = 0
      end
      object ComboBox1: TComboBox
        Left = 56
        Top = 24
        Width = 121
        Height = 21
        TabOrder = 1
        Text = 'const'
        OnChange = ComboBox1Change
        Items.Strings = (
          'const'
          'Boussinesq')
      end
    end
    object materialComboBox: TComboBox
      Left = 248
      Top = 25
      Width = 65
      Height = 21
      ItemIndex = 0
      TabOrder = 4
      Text = 'first'
      OnChange = materialComboBoxChange
      Items.Strings = (
        'first'
        'second')
    end
    object btnuds: TButton
      Left = 88
      Top = 24
      Width = 41
      Height = 25
      Caption = 'Edit'
      TabOrder = 5
      OnClick = btnudsClick
    end
  end
  object Bapplymaterial: TButton
    Left = 97
    Top = 425
    Width = 225
    Height = 25
    Caption = 'set material parameters'
    TabOrder = 1
    OnClick = BapplymaterialClick
  end
  object PanelBeta: TPanel
    Left = 1
    Top = 345
    Width = 321
    Height = 73
    Color = clSkyBlue
    TabOrder = 2
    Visible = False
    object Label2: TLabel
      Left = 24
      Top = 16
      Width = 89
      Height = 13
      Caption = 'coefficient of linear'
    end
    object Label3: TLabel
      Left = 32
      Top = 40
      Width = 109
      Height = 13
      Caption = 'thermal expansion, 1/K'
    end
    object EbetaT: TEdit
      Left = 192
      Top = 32
      Width = 105
      Height = 21
      TabOrder = 0
    end
  end
end
