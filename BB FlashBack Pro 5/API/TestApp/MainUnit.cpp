//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "MainUnit.h"

//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TMainForm *MainForm;
bool bGenerateUnhadledException;
//---------------------------------------------------------------------------
void __fastcall TMainForm::ShowError(DWORD dwError)
{
  switch (dwError)
  {
  case FBAPI_ERROR_IFBAPI_FAILED:
    MessageBox(Handle, "IFBAPI interface was not initialised.", Caption.c_str(), MB_OK | MB_ICONERROR);
    break;
  case FBAPI_ERROR_RECORDER_FAILED:
    MessageBox(Handle, "FBAPI was unable to locate FB Recorder.", Caption.c_str(), MB_OK | MB_ICONERROR);
    break;
  case FBAPI_ERROR_RECORDER_WRONG_EDITION:
    MessageBox(Handle, "FB Recorder is not Test Assistant version.", Caption.c_str(), MB_OK | MB_ICONERROR);
    break;
  case FBAPI_ERROR_SETTING_STATE_ALREADY:
    MessageBox(Handle, "FB Recorder is already in the state you are setting it.", Caption.c_str(), MB_OK | MB_ICONINFORMATION);
    break;
  case FBAPI_ERROR_SENDING_REPORT:
    MessageBox(Handle, "FB Recorder is sending report.", Caption.c_str(), MB_OK | MB_ICONERROR);
    break;
  case FBAPI_ERROR_NOTRECORDING:
    MessageBox(Handle, "FB Recorder is not recording.", Caption.c_str(), MB_OK | MB_ICONERROR);
    break;
  case FBAPI_ERROR_OPEN_PROCESS:
    MessageBox(Handle, "FB Recorder was unable to open handle for ulProcessId process.", Caption.c_str(), MB_OK | MB_ICONERROR);
    break;
  case FBAPI_ERROR_GET_PROCESS_STATUS:
    MessageBox(Handle, "FB Recorder was unable to get process status of ulProcessId process.", Caption.c_str(), MB_OK | MB_ICONERROR);
    break;
  case FBAPI_ERROR_LOADING_FBAPIDLL:
    MessageBox(Handle, "FB Recorder was unable to load FBAPI.dll.", Caption.c_str(), MB_OK | MB_ICONERROR);
    break;
  case FBAPI_ERROR_FBAPIDLL_INITHOOK:
    MessageBox(Handle, "FB Recorder was unable to InitErrorMsgHook at FBAPI.dll.", Caption.c_str(), MB_OK | MB_ICONERROR);
    break;
  }
}
//---------------------------------------------------------------------------
__fastcall TMainForm::TMainForm(TComponent* Owner)
        : TForm(Owner)
{
  bGenerateUnhadledException = false;
  CoInitialize(0);
  fbapi = new TFBAPI();
  HRESULT hres = fbapi->AppStartOK(GetCurrentProcessId());
  //if (hres != FBAPI_ERROR_SUCCESS)
    //ShowError(hres);
}
//---------------------------------------------------------------------------
__fastcall TMainForm::~TMainForm()
{
  HRESULT hres = fbapi->AppEndOK(GetCurrentProcessId());
  //if (hres != FBAPI_ERROR_SUCCESS)
    //ShowError(hres);

  delete fbapi;
  CoUninitialize();
}
//---------------------------------------------------------------------------

void __fastcall TMainForm::btnStartRecordingClick(TObject *Sender)
{
  wchar_t wszArray[MAX_PATH];
  edtFileName->Text.WideChar(wszArray, MAX_PATH);
  BSTR bstrFileName = SysAllocString(wszArray);
  HRESULT hres = fbapi->StartRecording(bstrFileName, NULL);
  SysFreeString(bstrFileName);
  if (hres != FBAPI_ERROR_SUCCESS)
    ShowError(hres);
}
//---------------------------------------------------------------------------
void __fastcall TMainForm::btnStopRecordingClick(TObject *Sender)
{
  HRESULT hres = fbapi->StopRecording();
  if (hres != FBAPI_ERROR_SUCCESS)
    ShowError(hres);
}
//---------------------------------------------------------------------------

void __fastcall TMainForm::btnSendReportClick(TObject *Sender)
{
  HRESULT hres = fbapi->SendReport();
  if (hres != FBAPI_ERROR_SUCCESS)
    ShowError(hres);
}
//---------------------------------------------------------------------------

void __fastcall TMainForm::btnCrashClick(TObject *Sender)
{
  if (Application->MessageBox("Application will be terminated", "Crash Application", MB_OKCANCEL || MB_ICONWARNING) == IDOK)
    TerminateProcess(GetCurrentProcess(), 0);
}
//---------------------------------------------------------------------------

void __fastcall TMainForm::btnStartErrorCatchClick(TObject *Sender)
{
  HRESULT hres = fbapi->StartErrorCatch();
  if (hres != FBAPI_ERROR_SUCCESS)
    ShowError(hres);
}
//---------------------------------------------------------------------------

void __fastcall TMainForm::btnStopErrorCatchClick(TObject *Sender)
{
  HRESULT hres = fbapi->StopErrorCatch();
  if (hres != FBAPI_ERROR_SUCCESS)
    ShowError(hres);
}
//---------------------------------------------------------------------------
void __fastcall TMainForm::btnGenerateAccessViolationClick(TObject *Sender)
{
  memset(0, 0, 100);
}
//---------------------------------------------------------------------------

void __fastcall TMainForm::btnGenerateUnhandledExceptionClick(
      TObject *Sender)
{
  bGenerateUnhadledException = true;
  Close();
}
//---------------------------------------------------------------------------


void __fastcall TMainForm::btnPauseRecordingClick(TObject *Sender)
{
  HRESULT hres = fbapi->PauseRecording();
  if (hres != FBAPI_ERROR_SUCCESS)
    ShowError(hres);
}
//---------------------------------------------------------------------------

void __fastcall TMainForm::btnResumeRecordingClick(TObject *Sender)
{
  HRESULT hres = fbapi->ResumeRecording();
  if (hres != FBAPI_ERROR_SUCCESS)
    ShowError(hres);
}
//---------------------------------------------------------------------------

void __fastcall TMainForm::btnIsRecordingClick(TObject *Sender)
{
  BYTE bRes;
  HRESULT hres = fbapi->IsRecording(&bRes);

  if (hres == FBAPI_ERROR_SUCCESS)
  {
    if (bRes)
      MessageBox(Handle, "Yes, recording is running", Caption.c_str(), MB_OK | MB_ICONINFORMATION);
    else
      MessageBox(Handle, "No, recording is not running", Caption.c_str(), MB_OK | MB_ICONINFORMATION);
  }
  else
    ShowError(hres);
}
//---------------------------------------------------------------------------

void __fastcall TMainForm::btnIsPausedClick(TObject *Sender)
{
  BYTE bRes;
  HRESULT hres = fbapi->IsPaused(&bRes);

  if (hres == FBAPI_ERROR_SUCCESS)
  {
    if (bRes)
      MessageBox(Handle, "Yes, recording is paused", Caption.c_str(), MB_OK | MB_ICONINFORMATION);
    else
      MessageBox(Handle, "No, recording is not paused", Caption.c_str(), MB_OK | MB_ICONINFORMATION);
  }
  else
    ShowError(hres);
}
//---------------------------------------------------------------------------

void __fastcall TMainForm::btnIsErrorCatchingOnClick(TObject *Sender)
{
  BYTE bRes;
  HRESULT hres = fbapi->IsErrorCatchingOn(&bRes);

  if (hres == FBAPI_ERROR_SUCCESS)
  {
    if (bRes)
      MessageBox(Handle, "Yes, error catching is on", Caption.c_str(), MB_OK | MB_ICONINFORMATION);
    else
      MessageBox(Handle, "No, error catching is off", Caption.c_str(), MB_OK | MB_ICONINFORMATION);
  }
  else
    ShowError(hres);
}
//---------------------------------------------------------------------------

void __fastcall TMainForm::btnIsCheckerClick(TObject *Sender)
{
  BYTE bRes;
  HRESULT hres = fbapi->IsRecorderCheckerRunning(&bRes);

  if (hres == FBAPI_ERROR_SUCCESS)
  {
    if (bRes)
      MessageBox(Handle, "Yes, recorder checker is running", Caption.c_str(), MB_OK | MB_ICONINFORMATION);
    else
      MessageBox(Handle, "No, recorder checker is not running", Caption.c_str(), MB_OK | MB_ICONINFORMATION);
  }
  else
    ShowError(hres);
}
//---------------------------------------------------------------------------

void __fastcall TMainForm::btnStartCheckerClick(TObject *Sender)
{
  HRESULT hres = fbapi->StartRecorderChecker();
  if (hres != FBAPI_ERROR_SUCCESS)
    ShowError(hres);
}
//---------------------------------------------------------------------------

void __fastcall TMainForm::btnStopCheckerClick(TObject *Sender)
{
  HRESULT hres = fbapi->StopRecorderChecker();
  if (hres != FBAPI_ERROR_SUCCESS)
    ShowError(hres);
}
//---------------------------------------------------------------------------

void __fastcall TMainForm::btnGetIncMoviesClick(TObject *Sender)
{
  ULONG ulRes;
  HRESULT hres = fbapi->GetIncompleteMoviesCount(&ulRes);

  if (hres == FBAPI_ERROR_SUCCESS)
  {
    AnsiString text;
    text.sprintf("Get incomplete movies count returned: %d", ulRes);
    MessageBox(Handle, text.c_str(), Caption.c_str(), MB_OK | MB_ICONINFORMATION);
  }
  else
    ShowError(hres);
}
//---------------------------------------------------------------------------

void __fastcall TMainForm::btnRestoreIncMoviesClick(TObject *Sender)
{
  HRESULT hres = fbapi->RestoreIncompleteMovies(L"c:\\Temp");
  if (hres != FBAPI_ERROR_SUCCESS)
    ShowError(hres);
}
//---------------------------------------------------------------------------

void __fastcall TMainForm::DiscardIncMoviesClick(TObject *Sender)
{
  HRESULT hres = fbapi->DiscardIncompleteMovies();
  if (hres != FBAPI_ERROR_SUCCESS)
    ShowError(hres);
}
//---------------------------------------------------------------------------

void __fastcall TMainForm::btnStartRecorderClick(TObject *Sender)
{
  HRESULT hres = fbapi->StartRecorder();
  if (hres != FBAPI_ERROR_SUCCESS)
    ShowError(hres);
}
//---------------------------------------------------------------------------

