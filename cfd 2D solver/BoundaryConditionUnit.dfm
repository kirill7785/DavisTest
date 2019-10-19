object BoundaryConditionForm: TBoundaryConditionForm
  Left = 363
  Top = 189
  AutoSize = True
  Caption = #1047#1072#1076#1072#1085#1080#1077' '#1075#1088#1072#1085#1080#1095#1085#1099#1093' '#1091#1089#1083#1086#1074#1080#1081
  ClientHeight = 433
  ClientWidth = 473
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 473
    Height = 433
    Color = clMoneyGreen
    TabOrder = 0
    object PselectBoundary: TPanel
      Left = 24
      Top = 24
      Width = 313
      Height = 129
      BorderStyle = bsSingle
      Color = clMoneyGreen
      TabOrder = 0
      object LselectBoundary: TLabel
        Left = 32
        Top = 24
        Width = 190
        Height = 13
        Caption = 'Select the edge on which it is necessary'
      end
      object LselectBoundarycontin: TLabel
        Left = 32
        Top = 48
        Width = 140
        Height = 13
        Caption = 'to setr the boundary condition'
      end
      object EdgeComboBox: TComboBox
        Left = 32
        Top = 80
        Width = 217
        Height = 21
        ItemHeight = 13
        TabOrder = 0
        OnChange = EdgeComboBoxChange
        Items.Strings = (
          #1083#1077#1074#1072#1103
          #1085#1080#1078#1085#1103#1103
          #1087#1088#1072#1074#1072#1103
          #1074#1077#1088#1093#1085#1103#1103)
      end
    end
    object Bapply: TButton
      Left = 240
      Top = 392
      Width = 201
      Height = 25
      Caption = 'Set the boundary condition '
      TabOrder = 1
      OnClick = BapplyClick
    end
    object TabControl1: TTabControl
      Left = 24
      Top = 168
      Width = 433
      Height = 217
      MultiLine = True
      TabOrder = 2
      Tabs.Strings = (
        'Temperature'
        'Flow'
        'Color Function'
        'UDS')
      TabIndex = 0
      OnChange = TabControl1Change
      object PanelTemperature: TPanel
        Left = 8
        Top = 24
        Width = 377
        Height = 137
        Color = clMoneyGreen
        TabOrder = 0
        object RadioGroupTemperature: TRadioGroup
          Left = 16
          Top = 16
          Width = 153
          Height = 105
          Caption = 'type boundary condition'
          Color = clMoneyGreen
          ItemIndex = 0
          Items.Strings = (
            'Temperature'
            'Heat Flux'
            'OutFlow'
            'symmetry condition')
          ParentColor = False
          TabOrder = 0
          OnClick = RadioGroupTemperatureClick
        end
        object GroupBoxvalueTemperature: TGroupBox
          Left = 184
          Top = 16
          Width = 177
          Height = 65
          Caption = 'set value'
          Color = clMoneyGreen
          ParentColor = False
          TabOrder = 1
          object LabelUnitTemperature: TLabel
            Left = 136
            Top = 24
            Width = 7
            Height = 13
            Caption = 'K'
          end
          object Etemperature: TEdit
            Left = 16
            Top = 24
            Width = 105
            Height = 21
            TabOrder = 0
          end
        end
      end
      object GroupBoxVelocity: TGroupBox
        Left = 8
        Top = 32
        Width = 393
        Height = 177
        Color = clMoneyGreen
        ParentColor = False
        TabOrder = 1
        Visible = False
        object RadioGroupVelocity: TRadioGroup
          Left = 16
          Top = 16
          Width = 153
          Height = 153
          Caption = 'type boundary condition'
          Color = clMoneyGreen
          ItemIndex = 0
          Items.Strings = (
            'velocity components'
            'outflow '
            'symmetry condition'
            'pressure outlet'
            'Marangoni stress')
          ParentColor = False
          TabOrder = 0
          OnClick = RadioGroupVelocityClick
        end
        object PanelsetVelocity: TPanel
          Left = 176
          Top = 16
          Width = 209
          Height = 73
          Color = clMoneyGreen
          TabOrder = 1
          object Label1: TLabel
            Left = 8
            Top = 0
            Width = 36
            Height = 13
            Caption = 'velocity'
          end
          object Label2: TLabel
            Left = 16
            Top = 16
            Width = 61
            Height = 13
            Caption = 'x component'
          end
          object Label3: TLabel
            Left = 16
            Top = 40
            Width = 61
            Height = 13
            Caption = 'y component'
          end
          object Exvel: TEdit
            Left = 104
            Top = 8
            Width = 89
            Height = 21
            TabOrder = 0
          end
          object Eyvel: TEdit
            Left = 104
            Top = 40
            Width = 89
            Height = 21
            TabOrder = 1
          end
        end
        object GroupBoxStreamFunction: TGroupBox
          Left = 176
          Top = 96
          Width = 169
          Height = 73
          Caption = 'Stream Function'
          Color = clMoneyGreen
          ParentColor = False
          TabOrder = 2
          object LSFValue: TLabel
            Left = 8
            Top = 48
            Width = 47
            Height = 13
            Caption = #1079#1085#1072#1095#1077#1085#1080#1077
          end
          object Label4: TLabel
            Left = 8
            Top = 24
            Width = 69
            Height = 13
            Caption = 'type condition '
          end
          object ComboBox1: TComboBox
            Left = 88
            Top = 16
            Width = 73
            Height = 21
            ItemHeight = 13
            TabOrder = 0
            Text = 'const'
            OnChange = ComboBox1Change
            Items.Strings = (
              'const'
              'x'
              'y'
              'neiman')
          end
          object Editsfvalue: TEdit
            Left = 64
            Top = 40
            Width = 57
            Height = 21
            TabOrder = 1
          end
        end
      end
      object pnlvof: TPanel
        Left = 8
        Top = 32
        Width = 217
        Height = 177
        Color = clMoneyGreen
        TabOrder = 2
        object rgvof: TRadioGroup
          Left = 16
          Top = 24
          Width = 145
          Height = 105
          Caption = 'type boundary condition'
          ItemIndex = 1
          Items.Strings = (
            'Dirichlet'
            'Neumann')
          TabOrder = 0
          OnClick = rgvofClick
        end
        object pnlvofvalue: TPanel
          Left = 16
          Top = 136
          Width = 185
          Height = 41
          Color = clMoneyGreen
          TabOrder = 1
          Visible = False
          object lblvof: TLabel
            Left = 16
            Top = 16
            Width = 43
            Height = 13
            Caption = 'set value'
          end
          object cbbvof: TComboBox
            Left = 120
            Top = 8
            Width = 57
            Height = 21
            ItemHeight = 13
            ItemIndex = 0
            TabOrder = 0
            Text = '0.0'
            Items.Strings = (
              '0.0'
              '1.0')
          end
        end
      end
      object pnluds: TPanel
        Left = 8
        Top = 32
        Width = 409
        Height = 185
        Color = clMoneyGreen
        TabOrder = 3
        object lbludsind: TLabel
          Left = 280
          Top = 24
          Width = 52
          Height = 13
          Caption = 'UDS Index'
        end
        object rguds: TRadioGroup
          Left = 8
          Top = 16
          Width = 257
          Height = 121
          Caption = 'type of boundary conditions'
          ItemIndex = 1
          Items.Strings = (
            'Dirichlet'
            'continuation of the equation on the boundary'
            'zero normal total current'
            'zero normal diffusion current')
          TabOrder = 0
          OnClick = rgudsClick
        end
        object cbbudsindex: TComboBox
          Left = 344
          Top = 24
          Width = 49
          Height = 21
          ItemHeight = 13
          ItemIndex = 0
          TabOrder = 1
          Text = '1'
          OnChange = cbbudsindexChange
          Items.Strings = (
            '1'
            '2'
            '3'
            '4')
        end
        object grpvalue: TGroupBox
          Left = 272
          Top = 56
          Width = 129
          Height = 81
          Caption = 'numeric value'
          TabOrder = 2
          object edtvaluds: TEdit
            Left = 8
            Top = 32
            Width = 113
            Height = 21
            TabOrder = 0
          end
        end
      end
    end
  end
end
