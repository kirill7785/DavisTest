object RelaxFactorsForm: TRelaxFactorsForm
  Left = 337
  Top = 194
  AutoSize = True
  Caption = 'Relaxation factors'
  ClientHeight = 305
  ClientWidth = 361
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
    Width = 361
    Height = 305
    Color = clMoneyGreen
    TabOrder = 0
    object Label1: TLabel
      Left = 88
      Top = 16
      Width = 162
      Height = 13
      Caption = 'Parametrization of relaxation'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Bapply: TButton
      Left = 104
      Top = 264
      Width = 75
      Height = 25
      Caption = 'Apply'
      TabOrder = 0
      OnClick = BapplyClick
    end
    object GroupBox3: TGroupBox
      Left = 16
      Top = 40
      Width = 169
      Height = 201
      Caption = 'SIMPLE'
      Color = clMoneyGreen
      ParentColor = False
      TabOrder = 1
      object GroupBox1: TGroupBox
        Left = 16
        Top = 16
        Width = 137
        Height = 65
        Caption = 'SIMPLE && SIMPLEC'
        Color = clMoneyGreen
        ParentColor = False
        TabOrder = 0
        object lblMomentum: TLabel
          Left = 8
          Top = 40
          Width = 52
          Height = 13
          Caption = 'Momentum'
        end
        object Label2: TLabel
          Left = 8
          Top = 16
          Width = 68
          Height = 13
          Caption = 'and SIMPLER'
        end
        object edtEMomentum: TEdit
          Left = 72
          Top = 32
          Width = 49
          Height = 21
          TabOrder = 0
          Text = '5e-1'
        end
      end
      object GroupBoxPressure: TGroupBox
        Left = 16
        Top = 88
        Width = 137
        Height = 41
        Caption = 'SIMPLE'
        Color = clMoneyGreen
        ParentColor = False
        TabOrder = 1
        object LPressure: TLabel
          Left = 16
          Top = 20
          Width = 41
          Height = 13
          Caption = 'Pressure'
        end
        object EPressure: TEdit
          Left = 72
          Top = 12
          Width = 49
          Height = 21
          TabOrder = 0
          Text = '8e-1'
        end
      end
      object GroupBoxBussinesk: TGroupBox
        Left = 16
        Top = 136
        Width = 137
        Height = 57
        Caption = 'BodyForce Ra>>1 '
        Color = clMoneyGreen
        ParentColor = False
        TabOrder = 2
        object EBodyForce: TEdit
          Left = 16
          Top = 24
          Width = 73
          Height = 21
          TabOrder = 0
          Text = '1.0'
        end
      end
    end
    object GroupBox2: TGroupBox
      Left = 192
      Top = 40
      Width = 153
      Height = 257
      Caption = 'Relax'
      Color = clMoneyGreen
      ParentColor = False
      TabOrder = 2
      object GroupBox4: TGroupBox
        Left = 16
        Top = 16
        Width = 121
        Height = 73
        Caption = 'SOR Flow'
        Color = clMoneyGreen
        ParentColor = False
        TabOrder = 0
        object Label6: TLabel
          Left = 8
          Top = 24
          Width = 98
          Height = 13
          Caption = 'amendment pressure'
        end
        object SpeedButton1: TSpeedButton
          Left = 88
          Top = 40
          Width = 23
          Height = 22
          OnClick = SpeedButton1Click
        end
        object ESORPamendment: TEdit
          Left = 8
          Top = 40
          Width = 73
          Height = 21
          TabOrder = 0
        end
      end
      object GroupBox5: TGroupBox
        Left = 16
        Top = 192
        Width = 121
        Height = 57
        Caption = 'Temperature'
        Color = clMoneyGreen
        ParentColor = False
        TabOrder = 1
        object ESORTempretrure: TEdit
          Left = 16
          Top = 24
          Width = 73
          Height = 21
          TabOrder = 0
        end
      end
      object GBUDS: TGroupBox
        Left = 16
        Top = 104
        Width = 129
        Height = 81
        Caption = 'UDS Index'
        Color = clMoneyGreen
        ParentColor = False
        TabOrder = 2
        object CBUDS: TComboBox
          Left = 8
          Top = 16
          Width = 49
          Height = 21
          ItemHeight = 13
          ItemIndex = 0
          TabOrder = 0
          Text = '1'
          OnChange = CBUDSChange
          Items.Strings = (
            '1'
            '2'
            '3'
            '4')
        end
        object Edituds: TEdit
          Left = 8
          Top = 48
          Width = 73
          Height = 21
          TabOrder = 1
        end
      end
    end
  end
end
