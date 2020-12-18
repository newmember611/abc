#include <objbase.h>

#ifndef   FBAPI_TLBH
#define   FBAPI_TLBH

#define FBAPI_ERROR_SUCCESS 		 	 0 //Successful, no error occured.
#define FBAPI_ERROR_IFBAPI_FAILED 		-1 //IFBAPI interface was not initialised (may be returned by FBAPI Wrapper only).
#define FBAPI_ERROR_RECORDER_FAILED	 	 1 //FBAPI was unable to locate FB Recorder.
#define FBAPI_ERROR_RECORDER_WRONG_EDITION 	 2 //FB Recorder is not Test Assistant version.
#define FBAPI_ERROR_SETTING_STATE_ALREADY	 3 //FB Recorder is already in the state you are setting it.
#define FBAPI_ERROR_SENDING_REPORT		 4 //FB Recorder is sending report.
#define FBAPI_ERROR_NOTRECORDING		 5 //FB Recorder is not recording.
#define FBAPI_ERROR_OPEN_PROCESS		 6 //FB Recorder was unable to open handle for ulProcessId process.
#define FBAPI_ERROR_GET_PROCESS_STATUS		 7 //FB Recorder was unable to get process status of ulProcessId process.
#define FBAPI_ERROR_LOADING_FBAPIDLL		 8 //FB Recorder was unable to load FBAPI.dll.
#define FBAPI_ERROR_FBAPIDLL_INITHOOK		 9 //FB Recorder was unable to InitErrorMsgHook at FBAPI.dll.

#define FBAPI_STATE_IS_ON		     0
#define FBAPI_STATE_IS_OFF		     1

EXTERN_C const GUID LIBID_FBAPI;
EXTERN_C const GUID IID_IFBAPI;
EXTERN_C const GUID CLSID_CFBAPI;

MIDL_INTERFACE("1C980ABD-7670-4C89-B9E2-C31211A92FCC")
IFBAPI  : public IDispatch
{
public:
  // [1] Starts recording FB movie
  virtual HRESULT STDMETHODCALLTYPE StartRecording(BSTR szFileName, BSTR szXMLSettingsFile) = 0;
  // [2] Stops recording FB movie
  virtual HRESULT STDMETHODCALLTYPE StopRecording(void) = 0;
  // [3] Shows Send Report wizard
  virtual HRESULT STDMETHODCALLTYPE SendReport(void) = 0;
  // [4] Sets application status to started correctly
  virtual HRESULT STDMETHODCALLTYPE AppStartOK(ULONG ulProcessId) = 0;
  // [5] Sets application status to end correctly
  virtual HRESULT STDMETHODCALLTYPE AppEndOK(ULONG ulProcessId) = 0;
  // [6] Starts error catching
  virtual HRESULT STDMETHODCALLTYPE StartErrorCatch(void) = 0;
  // [7] Stops error catching
  virtual HRESULT STDMETHODCALLTYPE StopErrorCatch(void) = 0;
  // [8] Method PauseRecording
  virtual HRESULT STDMETHODCALLTYPE PauseRecording(void) = 0;
  // [9] Method ResumeRecording
  virtual HRESULT STDMETHODCALLTYPE ResumeRecording(void) = 0;
  // [10] Method IsRecording
  virtual HRESULT STDMETHODCALLTYPE IsRecording(BYTE* pbResult) = 0;
  // [11] Method IsPaused
  virtual HRESULT STDMETHODCALLTYPE IsPaused(BYTE* pbResult) = 0;
  // [12] Method IsErrorCatchingOn
  virtual HRESULT STDMETHODCALLTYPE IsErrorCatchingOn(BYTE* pbResult) = 0;
  // [13] Method SetCollectPCInfo
  virtual HRESULT STDMETHODCALLTYPE SetCollectPCInfo(BOOL bCollect) = 0;
  // [14] Method CloseRecorder
  virtual HRESULT STDMETHODCALLTYPE CloseRecorder(void) = 0;
  // [15] Method StartRecorder
  virtual HRESULT STDMETHODCALLTYPE StartRecorder(void) = 0;
  // [16] Method IsRecorderCheckerRunning
  virtual HRESULT STDMETHODCALLTYPE IsRecorderCheckerRunning(BYTE* pbResult) = 0;
  // [17] Method StartRecorderChecker
  virtual HRESULT STDMETHODCALLTYPE StartRecorderChecker(void) = 0;
  // [18] Method StopRecorderChecker
  virtual HRESULT STDMETHODCALLTYPE StopRecorderChecker(void) = 0;
  // [19] Method GetIncompleteMoviesCount
  virtual HRESULT STDMETHODCALLTYPE GetIncompleteMoviesCount(ULONG* pulResult) = 0;
  // [20] Method DiscardIncompleteMovies
  virtual HRESULT STDMETHODCALLTYPE DiscardIncompleteMovies(void) = 0;
  // [21] Method RestoreIncompleteMovies
  virtual HRESULT STDMETHODCALLTYPE RestoreIncompleteMovies(BSTR wszRestoreFolder) = 0;
};

class TFBAPI
{
private:
  IFBAPI* pfbapi;
public:
  // [1] Starts recording FB movie
  HRESULT StartRecording(BSTR szFileName, BSTR szXMLSettingsFile);
  // [2] Stops recording FB movie
  HRESULT StopRecording();
  // [3] Shows Send Report wizard
  HRESULT SendReport();
  // [4] Sets application status to started correctly
  HRESULT AppStartOK(ULONG ulProcessId);
  // [5] Sets application status to end correctly
  HRESULT AppEndOK(ULONG ulProcessId);
  // [6] Starts error catching
  HRESULT StartErrorCatch(void);
  // [7] Stops error catching
  HRESULT StopErrorCatch(void);
  // [8] Method PauseRecording
  HRESULT PauseRecording(void);
  // [9] Method ResumeRecording
  HRESULT ResumeRecording(void);
  // [10] Method IsRecording
  HRESULT IsRecording(BYTE* pbResult);
  // [11] Method IsPaused
  HRESULT IsPaused(BYTE* pbResult);
  // [12] Method IsErrorCatchingOn
  HRESULT IsErrorCatchingOn(BYTE* pbResult);
  // [13] Method SetCollectPCInfo
  HRESULT SetCollectPCInfo(BOOL bCollect);
  // [14] Method CloseRecorder
  HRESULT CloseRecorder(void);
  // [15] Method StartRecorder
  HRESULT StartRecorder(void);
  // [16] Method IsRecorderCheckerRunning
  HRESULT IsRecorderCheckerRunning(BYTE* pbResult);
  // [17] Method StartRecorderChecker
  HRESULT StartRecorderChecker(void);
  // [18] Method StopRecorderChecker
  HRESULT StopRecorderChecker(void);
  // [19] Method GetIncompleteMoviesCount
  HRESULT GetIncompleteMoviesCount(ULONG* pulResult);
  // [20] Method DiscardIncompleteMovies
  HRESULT DiscardIncompleteMovies(void);
  // [21] Method RestoreIncompleteMovies
  HRESULT RestoreIncompleteMovies(BSTR wszRestoreFolder);

  TFBAPI();
  ~TFBAPI();
};

#endif // FBAPI_TLBH
