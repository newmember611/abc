#include "FBAPIWrap.h"

const GUID LIBID_FBAPI = {0xF6B232EE, 0x3310, 0x4F42,{ 0xB3, 0x27, 0xA9,0x68, 0x16, 0x02,0xBE, 0x88} };
const GUID CLSID_CFBAPI = {0x8320BDC5, 0x9097, 0x4353,{ 0xA7, 0x3C, 0x66,0x97, 0xF1, 0x1D,0x4C, 0xAB} };
const GUID IID_IFBAPI = {0x1C980ABD, 0x7670, 0x4C89,{ 0xB9, 0xE2, 0xC3,0x12, 0x11, 0xA9,0x2F, 0xCC} };

TFBAPI::TFBAPI()
{
  pfbapi = NULL;
  CoCreateInstance(CLSID_CFBAPI, NULL, CLSCTX_INPROC, IID_IFBAPI, (void **)&pfbapi);
}

TFBAPI::~TFBAPI()
{
  if (pfbapi)
    pfbapi->Release();
}

// [1] Starts recording FB movie
HRESULT TFBAPI::StartRecording(BSTR szFileName, BSTR szXMLSettingsFile)
{
  if (pfbapi)
    return pfbapi->StartRecording(szFileName, szXMLSettingsFile);
  else
    return FBAPI_ERROR_IFBAPI_FAILED;
}

// [2] Stops recording FB movie
HRESULT TFBAPI::StopRecording()
{
  if (pfbapi)
    return pfbapi->StopRecording();
  else
    return FBAPI_ERROR_IFBAPI_FAILED;
}

// [3] Shows Send Report wizard
HRESULT TFBAPI::SendReport()
{
  if (pfbapi)
    return pfbapi->SendReport();
  else
    return FBAPI_ERROR_IFBAPI_FAILED;
}

// [4] Sets application status to started correctly
HRESULT TFBAPI::AppStartOK(ULONG ulProcessId)
{
  if (pfbapi)
    return pfbapi->AppStartOK(ulProcessId);
  else
    return FBAPI_ERROR_IFBAPI_FAILED;
}

// [5] Sets application status to end correctly
HRESULT TFBAPI::AppEndOK(ULONG ulProcessId)
{
  if (pfbapi)
    return pfbapi->AppEndOK(ulProcessId);
  else
    return FBAPI_ERROR_IFBAPI_FAILED;
}

// [6] Starts error catching
HRESULT TFBAPI::StartErrorCatch(void)
{
  if (pfbapi)
    return pfbapi->StartErrorCatch();
  else
    return FBAPI_ERROR_IFBAPI_FAILED;
}

// [7] Stops error catching
HRESULT TFBAPI::StopErrorCatch(void)
{
  if (pfbapi)
    return pfbapi->StopErrorCatch();
  else
    return FBAPI_ERROR_IFBAPI_FAILED;
}

// [8] Method PauseRecording
HRESULT TFBAPI::PauseRecording(void)
{
  if (pfbapi)
    return pfbapi->PauseRecording();
  else
    return FBAPI_ERROR_IFBAPI_FAILED;
}

// [9] Method ResumeRecording
HRESULT TFBAPI::ResumeRecording(void)
{
  if (pfbapi)
    return pfbapi->ResumeRecording();
  else
    return FBAPI_ERROR_IFBAPI_FAILED;
}

// [10] Method IsRecording
HRESULT TFBAPI::IsRecording(BYTE* pbResult)
{
  if (pfbapi)
    return pfbapi->IsRecording(pbResult);
  else
    return FBAPI_ERROR_IFBAPI_FAILED;
}

// [11] Method IsPaused
HRESULT TFBAPI::IsPaused(BYTE* pbResult)
{
  if (pfbapi)
    return pfbapi->IsPaused(pbResult);
  else
    return FBAPI_ERROR_IFBAPI_FAILED;
}

// [12] Method IsErrorCatchingOn
HRESULT TFBAPI::IsErrorCatchingOn(BYTE* pbResult)
{
  if (pfbapi)
    return pfbapi->IsErrorCatchingOn(pbResult);
  else
    return FBAPI_ERROR_IFBAPI_FAILED;
}

// [13] Method SetCollectPCInfo
HRESULT TFBAPI::SetCollectPCInfo(BOOL bCollect)
{
  if (pfbapi)
    return pfbapi->SetCollectPCInfo(bCollect);
  else
    return FBAPI_ERROR_IFBAPI_FAILED;
}

// [14] Method CloseRecorder
HRESULT TFBAPI::CloseRecorder(void)
{
  if (pfbapi)
    return pfbapi->CloseRecorder();
  else
    return FBAPI_ERROR_IFBAPI_FAILED;
}

// [15] Method StartRecorder
HRESULT TFBAPI::StartRecorder(void)
{
  if (pfbapi)
    return pfbapi->StartRecorder();
  else
    return FBAPI_ERROR_IFBAPI_FAILED;
}

// [16] Method IsRecorderCheckerRunning
HRESULT TFBAPI::IsRecorderCheckerRunning(BYTE* pbResult)
{
  if (pfbapi)
    return pfbapi->IsRecorderCheckerRunning(pbResult);
  else
    return FBAPI_ERROR_IFBAPI_FAILED;
}

// [17] Method StartRecorderChecker
HRESULT TFBAPI::StartRecorderChecker(void)
{
  if (pfbapi)
    return pfbapi->StartRecorderChecker();
  else
    return FBAPI_ERROR_IFBAPI_FAILED;
}

// [18] Method StopRecorderChecker
HRESULT TFBAPI::StopRecorderChecker(void)
{
  if (pfbapi)
    return pfbapi->StopRecorderChecker();
  else
    return FBAPI_ERROR_IFBAPI_FAILED;
}

// [19] Method GetIncompleteMoviesCount
HRESULT TFBAPI::GetIncompleteMoviesCount(ULONG* pulResult)
{
  if (pfbapi)
    return pfbapi->GetIncompleteMoviesCount(pulResult);
  else
    return FBAPI_ERROR_IFBAPI_FAILED;
}

// [20] Method DiscardIncompleteMovies
HRESULT TFBAPI::DiscardIncompleteMovies(void)
{
  if (pfbapi)
    return pfbapi->DiscardIncompleteMovies();
  else
    return FBAPI_ERROR_IFBAPI_FAILED;
}

// [21] Method RestoreIncompleteMovies
HRESULT TFBAPI::RestoreIncompleteMovies(BSTR wszRestoreFolder)
{
  if (pfbapi)
    return pfbapi->RestoreIncompleteMovies(wszRestoreFolder);
  else
    return FBAPI_ERROR_IFBAPI_FAILED;
}