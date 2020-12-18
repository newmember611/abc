object MainForm: TMainForm
  Left = 459
  Top = 287
  BorderStyle = bsSingle
  Caption = 'FBAPI Test Application'
  ClientHeight = 447
  ClientWidth = 386
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 8
    Top = 16
    Width = 369
    Height = 273
    Caption = ' General FBAPI '
    TabOrder = 0
    object Label1: TLabel
      Left = 14
      Top = 62
      Width = 77
      Height = 13
      Caption = 'Movie file name:'
    end
    object btnStartRecording: TButton
      Left = 8
      Top = 88
      Width = 113
      Height = 25
      Hint = 'Launch FB Recorder if necessary.'#10'And then starts it to record.'
      Caption = 'Start Recording'
      TabOrder = 2
      OnClick = btnStartRecordingClick
    end
    object btnStopRecording: TButton
      Left = 128
      Top = 88
      Width = 113
      Height = 25
      Hint = 'Stops recording of FB Recorder.'
      Caption = 'Stop Recording'
      TabOrder = 3
      OnClick = btnStopRecordingClick
    end
    object btnSendReport: TButton
      Left = 248
      Top = 88
      Width = 113
      Height = 25
      Hint = 
        'Launch FB Recorder if necessary.'#10'And then shows Send Report wiz' +
        'ard.'
      Caption = 'Send Report'
      TabOrder = 4
      OnClick = btnSendReportClick
    end
    object btnCrash: TButton
      Left = 248
      Top = 120
      Width = 113
      Height = 25
      Hint = 'Emulate crash of the test program'
      Caption = 'Crash!'
      TabOrder = 7
      OnClick = btnCrashClick
    end
    object btnPauseRecording: TButton
      Left = 8
      Top = 120
      Width = 113
      Height = 25
      Hint = 'Pauses recording of FB Recorder.'
      Caption = 'Pause Recording'
      TabOrder = 5
      OnClick = btnPauseRecordingClick
    end
    object btnResumeRecording: TButton
      Left = 128
      Top = 120
      Width = 113
      Height = 25
      Hint = 'Resumes recording of FB Recorder.'
      Caption = 'Resume Recording'
      TabOrder = 6
      OnClick = btnResumeRecordingClick
    end
    object btnIsRecording: TButton
      Left = 8
      Top = 168
      Width = 113
      Height = 25
      Hint = 'Examines FB Recorder for recording status'
      Caption = 'Is Recording?'
      TabOrder = 8
      OnClick = btnIsRecordingClick
    end
    object btnIsPaused: TButton
      Left = 128
      Top = 168
      Width = 113
      Height = 25
      Hint = 'Examines FB Recorder for pause status'
      Caption = 'Is Paused?'
      TabOrder = 9
      OnClick = btnIsPausedClick
    end
    object btnIsErrorCatchingOn: TButton
      Left = 248
      Top = 168
      Width = 113
      Height = 25
      Hint = 'Examines FB Recorder for error catching status'
      Caption = 'Is Error Catching On?'
      TabOrder = 10
      OnClick = btnIsErrorCatchingOnClick
    end
    object edtFileName: TEdit
      Left = 96
      Top = 56
      Width = 265
      Height = 21
      TabOrder = 1
    end
    object btnIsChecker: TButton
      Left = 8
      Top = 200
      Width = 113
      Height = 25
      Hint = 'Examines if FB Recorder Checker is running'
      Caption = 'Is checker running?'
      TabOrder = 11
      OnClick = btnIsCheckerClick
    end
    object btnStartChecker: TButton
      Left = 128
      Top = 200
      Width = 113
      Height = 25
      Hint = 'Starts FB recorder checker'
      Caption = 'Start checker'
      TabOrder = 12
      OnClick = btnStartCheckerClick
    end
    object btnStopChecker: TButton
      Left = 248
      Top = 200
      Width = 113
      Height = 25
      Hint = 'Stops FB recorder checker'
      Caption = 'Stop checker'
      TabOrder = 13
      OnClick = btnStopCheckerClick
    end
    object btnGetIncMovies: TButton
      Left = 8
      Top = 232
      Width = 113
      Height = 25
      Hint = 'Gets incomplete movies count'
      Caption = 'Get inc. movies count'
      TabOrder = 14
      OnClick = btnGetIncMoviesClick
    end
    object btnRestoreIncMovies: TButton
      Left = 128
      Top = 232
      Width = 113
      Height = 25
      Hint = 'Restores incomplete movies'
      Caption = 'Restore inc. movies'
      TabOrder = 15
      OnClick = btnRestoreIncMoviesClick
    end
    object DiscardIncMovies: TButton
      Left = 248
      Top = 232
      Width = 113
      Height = 25
      Hint = 'Discards incomplete movies'
      Caption = 'Discard inc. movies'
      TabOrder = 16
      OnClick = DiscardIncMoviesClick
    end
    object btnStartRecorder: TButton
      Left = 128
      Top = 16
      Width = 113
      Height = 25
      Hint = 'Launch FB Recorder'
      Caption = 'Start Recorder'
      TabOrder = 0
      OnClick = btnStartRecorderClick
    end
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 304
    Width = 369
    Height = 129
    Caption = ' Extended FBAPI Error Catching '
    TabOrder = 1
    object btnGenerateUnhandledException: TButton
      Left = 112
      Top = 88
      Width = 161
      Height = 25
      Hint = 'Generates Unhandle Exception error'
      Caption = 'Generate Unhandled Exception'
      TabOrder = 0
      OnClick = btnGenerateUnhandledExceptionClick
    end
    object btnGenerateAccessViolation: TButton
      Left = 112
      Top = 56
      Width = 161
      Height = 25
      Hint = 'Generates Access Violation error.'
      Caption = 'Generate Access Violation'
      TabOrder = 1
      OnClick = btnGenerateAccessViolationClick
    end
    object btnStopErrorCatch: TButton
      Left = 128
      Top = 24
      Width = 113
      Height = 25
      Hint = 'Notifies FB Recorder to stop error catching.'
      Caption = 'Stop Error Catch'
      TabOrder = 2
      OnClick = btnStopErrorCatchClick
    end
    object btnStartErrorCatch: TButton
      Left = 8
      Top = 24
      Width = 113
      Height = 25
      Hint = 
        'Launch FB Recorder if necessary.'#10'And then notifies it to start ' +
        'error catching.'
      Caption = 'Start Error Catch'
      TabOrder = 3
      OnClick = btnStartErrorCatchClick
    end
  end
end
